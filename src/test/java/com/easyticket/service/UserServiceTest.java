package com.easyticket.service;

import com.easyticket.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
public class UserServiceTest {

    @Autowired
    private UserService userService;

    @Test
    public void testGetUserByUsername() {
        // 测试查找现有用户
        User admin = userService.getUserByUsername("admin");
        assertNotNull(admin);
        assertEquals("admin", admin.getUsername());
        assertEquals("admin@easyticket.com", admin.getEmail());
    }

    @Test
    public void testGetUserByEmail() {
        // 测试查找现有用户
        User admin = userService.getUserByEmail("admin@easyticket.com");
        assertNotNull(admin);
        assertEquals("admin", admin.getUsername());
        assertEquals("admin@easyticket.com", admin.getEmail());
    }

    @Test
    public void testGetUserByEmail1() {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        System.out.println(passwordEncoder.encode("123456"));
    }


    @Test
    public void testCreateUserWithInactiveStatus() {
        // 测试创建未激活用户
        User newUser = new User();
        newUser.setUsername("testuser123");
        newUser.setEmail("testuser123@example.com");
        newUser.setPassword("123456");
        newUser.setNickname("测试用户");
        newUser.setPhone("13800138000");
        newUser.setEnabled(false); // 设置为未激活状态
        newUser.setActivationToken("test-token-123");
        newUser.setRoles("ROLE_CUSTOMER");

        User savedUser = userService.createUser(newUser);
        
        assertNotNull(savedUser);
        assertNotNull(savedUser.getId());
        assertEquals("testuser123", savedUser.getUsername());
        assertEquals("testuser123@example.com", savedUser.getEmail());
        assertEquals(false, savedUser.getEnabled()); // 验证是否保持未激活状态
        assertEquals("test-token-123", savedUser.getActivationToken());
        assertEquals("ROLE_CUSTOMER", savedUser.getRoles());
    }

    @Test
    public void testCreateUserWithDuplicateUsername() {
        // 测试创建重复用户名的用户
        User newUser = new User();
        newUser.setUsername("admin"); // 使用已存在的用户名
        newUser.setEmail("newemail@example.com");
        newUser.setPassword("123456");
        newUser.setEnabled(false);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.createUser(newUser);
        });
        
        assertEquals("用户名已存在", exception.getMessage());
    }

    @Test
    public void testCreateUserWithDuplicateEmail() {
        // 测试创建重复邮箱的用户
        User newUser = new User();
        newUser.setUsername("newuser");
        newUser.setEmail("admin@easyticket.com"); // 使用已存在的邮箱
        newUser.setPassword("123456");
        newUser.setEnabled(false);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.createUser(newUser);
        });
        
        assertEquals("邮箱已存在", exception.getMessage());
    }

    @Test
    public void testActivateUser() {
        // 测试激活用户功能
        // 首先创建一个未激活的用户
        User newUser = new User();
        newUser.setUsername("activatetest");
        newUser.setEmail("activatetest@example.com");
        newUser.setPassword("123456");
        newUser.setEnabled(false);
        newUser.setActivationToken("activate-token-123");
        newUser.setRoles("ROLE_CUSTOMER");

        User savedUser = userService.createUser(newUser);
        assertFalse(savedUser.getEnabled());
        assertNotNull(savedUser.getActivationToken());

        // 激活用户
        savedUser.setEnabled(true);
        savedUser.setActivationToken(null);
        User updatedUser = userService.updateUser(savedUser);

        assertTrue(updatedUser.getEnabled());
        assertNull(updatedUser.getActivationToken());
    }
} 