package com.easyticket.service;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Token服务
 * 用于生成和验证各种类型的令牌
 *
 * @author hxp
 * @version 1.0.0
 */
@Service
public class TokenService {

    private static final int TOKEN_LENGTH = 32;
    private static final int ACTIVATION_TOKEN_HOURS = 24;
    private static final int RESET_TOKEN_HOURS = 2;

    private final Map<String, TokenInfo> tokenStore = new ConcurrentHashMap<>();

    private final SecureRandom secureRandom = new SecureRandom();

    /**
     * Token信息类
     */
    public static class TokenInfo {
        private final String userId;
        private final String type;
        private final LocalDateTime expiryTime;
        private final Map<String, Object> data;

        public TokenInfo(String userId, String type, LocalDateTime expiryTime, Map<String, Object> data) {
            this.userId = userId;
            this.type = type;
            this.expiryTime = expiryTime;
            this.data = data != null ? data : new ConcurrentHashMap<>();
        }

        public String getUserId() { return userId; }
        public String getType() { return type; }
        public Map<String, Object> getData() { return data; }

        public boolean isExpired() {
            return LocalDateTime.now().isAfter(expiryTime);
        }
    }

    /**
     * 生成激活令牌
     */
    public String generateActivationToken(String userId, String email) {
        String token = generateRandomToken();
        LocalDateTime expiryTime = LocalDateTime.now().plusHours(ACTIVATION_TOKEN_HOURS);

        Map<String, Object> data = new ConcurrentHashMap<>();
        data.put("email", email);

        tokenStore.put(token, new TokenInfo(userId, "ACTIVATION", expiryTime, data));

        // 清理过期令牌
        cleanupExpiredTokens();

        return token;
    }

    /**
     * 验证令牌
     */
    private TokenInfo validateToken(String token, String expectedType) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }

        TokenInfo tokenInfo = tokenStore.get(token);
        if (tokenInfo == null) {
            return null;
        }

        // 检查令牌类型
        if (!expectedType.equals(tokenInfo.getType())) {
            return null;
        }

        // 检查是否过期
        if (tokenInfo.isExpired()) {
            tokenStore.remove(token); // 移除过期令牌
            return null;
        }

        return tokenInfo;
    }

    /**
     * 使用令牌（使用后删除）
     */
    public TokenInfo consumeToken(String token, String expectedType) {
        TokenInfo tokenInfo = validateToken(token, expectedType);
        if (tokenInfo != null) {
            tokenStore.remove(token); // 使用后删除令牌
        }
        return tokenInfo;
    }

    /**
     * 删除用户的所有令牌
     */
    public void removeUserTokens(String userId, String type) {
        tokenStore.entrySet().removeIf(entry -> {
            TokenInfo info = entry.getValue();
            return userId.equals(info.getUserId()) &&
                   (type == null || type.equals(info.getType()));
        });
    }

    /**
     * 生成随机令牌
     */
    private String generateRandomToken() {
        byte[] bytes = new byte[TOKEN_LENGTH];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /**
     * 清理过期令牌
     */
    private void cleanupExpiredTokens() {
        tokenStore.entrySet().removeIf(entry -> entry.getValue().isExpired());
    }

}
