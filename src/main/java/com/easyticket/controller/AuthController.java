package com.easyticket.controller;

import com.easyticket.service.EmailService;
import com.easyticket.service.TokenService;
import com.easyticket.service.UserService;
import com.easyticket.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.AccountExpiredException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.imageio.ImageIO;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

/**
 * 认证控制器
 *
 * @author hxp
 * @version 1.0.0
 */
@Controller
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private EmailService emailService;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private UserService userService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 显示登录页面
     */
    @GetMapping("/login")
    public String login() {
        return "auth/login";
    }

    /**
     * 显示注册页面
     */
    @GetMapping("/register")
    public String register() {
        return "auth/register";
    }

    /**
     * AJAX处理用户注册
     */
    @PostMapping("/api/register")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> performRegisterAjax(
            @RequestParam String username,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String confirmPassword,
            @RequestParam(required = false) String nickname,
            @RequestParam(required = false) String phone,
            @RequestParam String captcha,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();

        try {
            // 验证验证码
            String sessionCaptcha = (String) session.getAttribute("captcha");
            if (sessionCaptcha == null || !sessionCaptcha.equalsIgnoreCase(captcha)) {
                result.put("success", false);
                result.put("message", "验证码错误");
                return ResponseEntity.ok(result);
            }

            // 验证密码确认
            if (!password.equals(confirmPassword)) {
                result.put("success", false);
                result.put("message", "两次输入的密码不一致");
                return ResponseEntity.ok(result);
            }

            // 验证用户名长度
            if (username.length() < 3 || username.length() > 20) {
                result.put("success", false);
                result.put("message", "用户名长度必须在3-20个字符之间");
                return ResponseEntity.ok(result);
            }

            // 验证密码长度
            if (password.length() < 6) {
                result.put("success", false);
                result.put("message", "密码至少6个字符");
                return ResponseEntity.ok(result);
            }

            // 验证邮箱格式
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                result.put("success", false);
                result.put("message", "邮箱格式不正确");
                return ResponseEntity.ok(result);
            }

            // 检查用户名和邮箱是否已存在
            if (userService.getUserByUsername(username) != null) {
                result.put("success", false);
                result.put("message", "用户名已存在，请选择其他用户名");
                return ResponseEntity.ok(result);
            }

            if (userService.getUserByEmail(email) != null) {
                result.put("success", false);
                result.put("message", "邮箱已被注册，请使用其他邮箱或找回密码");
                return ResponseEntity.ok(result);
            }

            // 创建用户（状态为未激活）
            User newUser = new User();
            newUser.setUsername(username);
            newUser.setEmail(email);
            newUser.setPassword(password);
            newUser.setNickname(nickname);
            newUser.setPhone(phone);
            newUser.setEnabled(false); // 未激活状态
            newUser.setRoles("ROLE_CUSTOMER"); // 默认角色

            // 生成激活令牌
            String activationToken = tokenService.generateActivationToken(null, email);
            newUser.setActivationToken(activationToken);

            // 保存用户到数据库
            User savedUser = userService.createUser(newUser);
            logger.info("创建新用户成功: {}, ID: {}", username, savedUser.getId());

            // 发送激活邮件
            try {
                emailService.sendActivationEmail(email, username, activationToken);
                logger.info("激活邮件已发送给用户: {}", username);

                // 清除验证码
                session.removeAttribute("captcha");

                result.put("success", true);
                result.put("message", "注册成功！激活邮件已发送至 " + email + "，请查收邮件并点击激活链接完成账户激活。");
                result.put("redirectUrl", "/login");
                return ResponseEntity.ok(result);

            } catch (Exception e) {
                logger.error("发送激活邮件失败: {}", e.getMessage(), e);
                result.put("success", false);
                result.put("message", "发送激活邮件失败，请稍后重试或联系管理员");
                return ResponseEntity.ok(result);
            }

        } catch (Exception e) {
            logger.error("注册失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "注册失败：" + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    /**
     * AJAX处理账户激活
     */
    @GetMapping("/api/activate")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> activateAjax(@RequestParam String token) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 验证并消费激活令牌
            TokenService.TokenInfo tokenInfo = tokenService.consumeToken(token, "ACTIVATION");

            if (tokenInfo == null) {
                result.put("success", false);
                result.put("message", "激活链接无效或已过期，请重新注册或联系管理员");
                return ResponseEntity.ok(result);
            }

            String email = (String) tokenInfo.getData().get("email");

            // 根据邮箱查找用户并激活
            User user = userService.getUserByEmail(email);
            if (user != null && user.getActivationToken() != null && user.getActivationToken().equals(token)) {
                user.setEnabled(true);
                user.setActivationToken(null); // 清除激活令牌
                userService.updateUser(user);

                logger.info("用户账户激活成功: {}", user.getUsername());
                result.put("success", true);
                result.put("message", "账户激活成功！现在您可以登录系统了。");
                result.put("redirectUrl", "/login");
            } else {
                result.put("success", false);
                result.put("message", "激活失败：未找到对应的用户账户或激活令牌无效");
            }

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            logger.error("账户激活失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "激活失败：" + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    /**
     * 处理账户激活页面显示
     */
    @GetMapping("/activate")
    public String activate(@RequestParam String token, Model model) {
        model.addAttribute("token", token);
        return "auth/activation-result";
    }

    /**
     * AJAX登录状态检查接口
     */
    @GetMapping("/api/login-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkLoginStatus(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        // 检查用户是否已登录
        if (request.getUserPrincipal() != null) {
            result.put("loggedIn", true);
            result.put("username", request.getUserPrincipal().getName());
            result.put("redirectUrl", "/");
        } else {
            result.put("loggedIn", false);
        }

        return ResponseEntity.ok(result);
    }

    /**
     * AJAX注销接口
     */
    @PostMapping("/api/logout")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> logoutAjax(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();

        try {
            // Spring Security会自动处理注销
            result.put("success", true);
            result.put("message", "注销成功");
            result.put("redirectUrl", "/login");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "注销失败");
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 重新发送激活邮件
     */
    @PostMapping("/api/resend-activation")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resendActivationEmail(@RequestParam String email) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 验证邮箱格式
            if (email == null || email.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "请输入邮箱地址");
                return ResponseEntity.ok(result);
            }

            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                result.put("success", false);
                result.put("message", "邮箱格式不正确");
                return ResponseEntity.ok(result);
            }

            // 查找用户
            User user = userService.getUserByEmail(email.trim());
            if (user == null) {
                result.put("success", false);
                result.put("message", "该邮箱未注册，请先注册账户");
                return ResponseEntity.ok(result);
            }

            // 检查激活状态
            if (user.getEnabled()) {
                result.put("success", false);
                result.put("message", "账户已激活，无需重新发送激活邮件");
                return ResponseEntity.ok(result);
            }

            // 生成新的激活令牌
            String activationToken = tokenService.generateActivationToken(user.getId().toString(), email.trim());

            // 更新用户的激活令牌
            user.setActivationToken(activationToken);
            userService.updateUser(user);

            // 发送激活邮件
            emailService.sendActivationEmail(email.trim(), user.getUsername(), activationToken);

            logger.info("重新发送激活邮件成功: {}", user.getUsername());

            result.put("success", true);
            result.put("message", "激活邮件已重新发送至 " + email + "，请查收邮件并点击激活链接");

        } catch (Exception e) {
            logger.error("重新发送激活邮件失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "重新发送失败：" + e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 生成验证码
     */
    @GetMapping("/captcha")
    public void captcha(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        response.setContentType("image/jpeg");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // 生成验证码
        String captchaText = generateCaptchaText(4);
        session.setAttribute("captcha", captchaText);

        // 创建验证码图片
        BufferedImage image = createCaptchaImage(captchaText, 120, 40);

        ServletOutputStream out = response.getOutputStream();
        try {
            ImageIO.write(image, "jpg", out);
        } finally {
            out.close();
        }
    }

    /**
     * 生成验证码文本
     */
    private String generateCaptchaText(int length) {
        String chars = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"; // 去掉容易混淆的字符
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    /**
     * 创建验证码图片
     */
    private BufferedImage createCaptchaImage(String text, int width, int height) {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();

        // 设置抗锯齿
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 填充背景
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, width, height);

        // 绘制干扰线
        Random random = new Random();
        g.setColor(Color.LIGHT_GRAY);
        for (int i = 0; i < 5; i++) {
            int x1 = random.nextInt(width);
            int y1 = random.nextInt(height);
            int x2 = random.nextInt(width);
            int y2 = random.nextInt(height);
            g.drawLine(x1, y1, x2, y2);
        }

        // 绘制验证码文字
        g.setFont(new Font("Arial", Font.BOLD, 24));
        int x = 10;
        for (int i = 0; i < text.length(); i++) {
            // 随机颜色
            g.setColor(new Color(random.nextInt(100), random.nextInt(100), random.nextInt(100)));
            // 随机位置
            int y = 20 + random.nextInt(10);
            g.drawString(String.valueOf(text.charAt(i)), x, y);
            x += 25;
        }

        // 添加噪点
        for (int i = 0; i < 50; i++) {
            int x1 = random.nextInt(width);
            int y1 = random.nextInt(height);
            g.setColor(new Color(random.nextInt(255), random.nextInt(255), random.nextInt(255)));
            g.fillOval(x1, y1, 1, 1);
        }

        g.dispose();
        return image;
    }

    /**
     * AJAX处理用户登录
     */
    @PostMapping("/api/login")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> performLoginAjax(
            @RequestParam String username,
            @RequestParam String password,
            @RequestParam(required = false, defaultValue = "false") boolean rememberMe,
            HttpServletRequest request,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();

        try {
            // 验证用户名和密码
            if (username == null || username.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "请输入用户名");
                return ResponseEntity.ok(result);
            }

            if (password == null || password.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "请输入密码");
                return ResponseEntity.ok(result);
            }

            // 查找用户
            User user = userService.getUserByUsername(username.trim());
            if (user == null) {
                result.put("success", false);
                result.put("message", "用户名或密码错误");
                return ResponseEntity.ok(result);
            }

            // 检查账户是否已激活
            if (!user.getEnabled()) {
                result.put("success", false);
                result.put("message", "账户未激活，请检查邮箱完成激活");
                return ResponseEntity.ok(result);
            }

//             验证密码
            if (!passwordEncoder.matches(password, user.getPassword())) {
                result.put("success", false);
                result.put("message", "用户名或密码错误");
                return ResponseEntity.ok(result);
            }



            // 创建Spring Security认证信息
            UsernamePasswordAuthenticationToken authToken =
                new UsernamePasswordAuthenticationToken(username, password);

            try {
                Authentication authentication = authenticationManager.authenticate(authToken);

                // 设置认证上下文
                SecurityContextHolder.getContext().setAuthentication(authentication);

                // 创建新的Session（防止Session固定攻击）
                session.invalidate();
                session = request.getSession(true);

                // 保存认证信息到Session
                session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                    SecurityContextHolder.getContext());

                logger.info("用户登录成功: {}", username);

                result.put("success", true);
                result.put("message", "登录成功");
                result.put("redirectUrl", "/");
                result.put("user", Map.of(
                    "username", user.getUsername(),
                    "nickname", user.getNickname() != null ? user.getNickname() : user.getUsername(),
                    "roles", user.getRoles()
                ));

                return ResponseEntity.ok(result);

            } catch (BadCredentialsException e) {
                result.put("success", false);
                result.put("message", "用户名或密码错误");
                return ResponseEntity.ok(result);
            } catch (DisabledException e) {
                result.put("success", false);
                result.put("message", "账户已被禁用");
                return ResponseEntity.ok(result);
            } catch (AccountExpiredException e) {
                result.put("success", false);
                result.put("message", "账户已过期");
                return ResponseEntity.ok(result);
            } catch (LockedException e) {
                result.put("success", false);
                result.put("message", "账户已被锁定");
                return ResponseEntity.ok(result);
            }

        } catch (Exception e) {
            logger.error("登录失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "登录失败：" + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }
}
