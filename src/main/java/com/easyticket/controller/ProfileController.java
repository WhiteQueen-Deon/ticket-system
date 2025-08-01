package com.easyticket.controller;

import com.easyticket.entity.User;
import com.easyticket.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Controller
public class ProfileController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/profile")
    public String profilePage() {
        return "profile/profile";
    }

    @GetMapping("/change-password")
    public String changePasswordPage() {
        return "profile/change-password";
    }

    @GetMapping("/api/profile")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCurrentUserProfile() {
        try {
            String username = SecurityContextHolder.getContext().getAuthentication().getName();
            User user = userService.getUserByUsername(username);

            Map<String, Object> result = new HashMap<>();
            if (user != null) {
                user.setPassword(null);
                user.setActivationToken(null);

                result.put("code", 0);
                result.put("msg", "success");
                result.put("data", user);
            } else {
                result.put("code", 404);
                result.put("msg", "用户不存在");
            }

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 500);
            result.put("msg", "获取用户信息失败：" + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    @PutMapping("/api/profile")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateProfile(@RequestBody Map<String, String> request) {
        try {
            String username = SecurityContextHolder.getContext().getAuthentication().getName();
            User user = userService.getUserByUsername(username);

            if (user == null) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 404);
                result.put("msg", "用户不存在");
                return ResponseEntity.ok(result);
            }

            // 更新允许修改的字段
            if (request.containsKey("email")) {
                user.setEmail(request.get("email"));
            }
            if (request.containsKey("nickname")) {
                user.setNickname(request.get("nickname"));
            }
            if (request.containsKey("phone")) {
                user.setPhone(request.get("phone"));
            }

            user.setUpdateTime(LocalDateTime.now());
            userService.updateUser(user);

            Map<String, Object> result = new HashMap<>();
            result.put("code", 0);
            result.put("msg", "个人信息更新成功");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 500);
            result.put("msg", e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    @PostMapping("/api/change-password")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody Map<String, String> request) {
        try {
            String username = SecurityContextHolder.getContext().getAuthentication().getName();
            User user = userService.getUserByUsername(username);

            if (user == null) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 404);
                result.put("msg", "用户不存在");
                return ResponseEntity.ok(result);
            }

            String oldPassword = request.get("oldPassword");
            String newPassword = request.get("newPassword");

            // 验证旧密码
            if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 400);
                result.put("msg", "原密码不正确");
                return ResponseEntity.ok(result);
            }

            // 更新密码
            userService.resetPassword(user.getId(), newPassword);

            Map<String, Object> result = new HashMap<>();
            result.put("code", 0);
            result.put("msg", "密码修改成功");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 500);
            result.put("msg", e.getMessage());
            return ResponseEntity.ok(result);
        }
    }
}
