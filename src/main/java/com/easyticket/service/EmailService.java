package com.easyticket.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.internet.MimeMessage;

/**
 * 邮件服务
 *
 * @author hxp
 * @version 1.0.0
 */
@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    @Value("${easy-ticket.system-email}")
    private String systemEmail;

    @Value("${easy-ticket.domain:http://localhost:8080}")
    private String systemDomain;

    /**
     * 发送激活邮件
     */
    public void sendActivationEmail(String toEmail, String username, String activationToken) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(systemEmail);
            helper.setTo(toEmail);
            helper.setSubject("Easy Ticket System - 账户激活");

            String activationUrl = systemDomain + "/activate?token=" + activationToken;

            String content = buildActivationEmailContent(username, activationUrl);
            helper.setText(content, true);

            mailSender.send(message);
            logger.info("激活邮件已发送至: {}", toEmail);

        } catch (Exception e) {
            logger.error("发送激活邮件失败: {}", e.getMessage(), e);
            throw new RuntimeException("邮件发送失败: " + e.getMessage());
        }
    }

    /**
     * 构建激活邮件内容
     */
    private String buildActivationEmailContent(String username, String activationUrl) {
        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html>");
        sb.append("<html>");
        sb.append("<head>");
        sb.append("<meta charset='UTF-8'>");
        sb.append("<title>账户激活</title>");
        sb.append("</head>");
        sb.append("<body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;'>");

        sb.append("<div style='background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 20px;'>");
        sb.append("<h2 style='color: #009688; margin: 0;'>Easy Ticket System</h2>");
        sb.append("</div>");

        sb.append("<h3>尊敬的 ").append(username).append("：</h3>");
        sb.append("<p>感谢您注册 Easy Ticket System！</p>");
        sb.append("<p>为了确保您的账户安全，请点击下面的链接激活您的账户：</p>");

        sb.append("<div style='text-align: center; margin: 30px 0;'>");
        sb.append("<a href='").append(activationUrl).append("' ");
        sb.append("style='background-color: #009688; color: white; padding: 12px 30px; ");
        sb.append("text-decoration: none; border-radius: 5px; display: inline-block;'>");
        sb.append("立即激活账户");
        sb.append("</a>");
        sb.append("</div>");

        sb.append("<p>如果按钮无法点击，请复制以下链接到浏览器地址栏：</p>");
        sb.append("<p style='word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 3px;'>");
        sb.append(activationUrl);
        sb.append("</p>");

        sb.append("<p style='color: #666; font-size: 14px;'>");
        sb.append("注意：此激活链接将在24小时后失效。如果您没有注册过我们的账户，请忽略此邮件。");
        sb.append("</p>");

        sb.append("<div style='border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; color: #666; font-size: 12px;'>");
        sb.append("<p>此邮件由系统自动发送，请勿回复。</p>");
        sb.append("<p>hxp</p>");
        sb.append("</div>");

        sb.append("</body>");
        sb.append("</html>");

        return sb.toString();
    }

}
