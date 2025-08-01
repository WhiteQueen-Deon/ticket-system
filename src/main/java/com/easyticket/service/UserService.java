package com.easyticket.service;

import com.easyticket.entity.User;
import com.easyticket.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public List<User> getAllUsers(int page, int size, String keyword, String role, Boolean enabled) {
        int offset = (page - 1) * size;
        return userMapper.findAllUsers(offset, size, keyword, role, enabled);
    }

    public long getAllUsersCount(String keyword, String role, Boolean enabled) {
        return userMapper.countAllUsers(keyword, role, enabled);
    }

    public User getUserById(Long id) {
        return userMapper.findById(id);
    }

    public User getUserByUsername(String username) {
        return userMapper.findByUsername(username);
    }

    public User getUserByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    @Transactional
    public User createUser(User user) {
        if (userMapper.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }

        if (userMapper.existsByEmail(user.getEmail())) {
            throw new RuntimeException("邮箱已存在");
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        user.setRegistrationDate(LocalDateTime.now());

        if (user.getEnabled() == null) {
            user.setEnabled(false);
        }

        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            user.setRoles("ROLE_CUSTOMER");
        }

        userMapper.insert(user);
        return user;
    }

    @Transactional
    public User updateUser(User user) {
        User existingUser = userMapper.findById(user.getId());
        if (existingUser == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!existingUser.getUsername().equals(user.getUsername()) &&
            userMapper.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }

        if (!existingUser.getEmail().equals(user.getEmail()) &&
            userMapper.existsByEmail(user.getEmail())) {
            throw new RuntimeException("邮箱已存在");
        }

        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        return user;
    }

    @Transactional
    public void deleteUser(Long id) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (user.hasRole("ROLE_ADMIN")) {
            throw new RuntimeException("不能删除管理员用户");
        }

        userMapper.deleteById(id);
    }

    @Transactional
    public void deleteUsers(List<Long> ids) {
        for (Long id : ids) {
            User user = userMapper.findById(id);
            if (user != null && user.hasRole("ROLE_ADMIN")) {
                throw new RuntimeException("不能删除管理员用户");
            }
        }
        userMapper.deleteByIds(ids);
    }

    @Transactional
    public void updateUserRole(Long id, String roles) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        userMapper.updateRoles(id, roles);
    }

    @Transactional
    public void updateUserStatus(Long id, Boolean enabled) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (user.hasRole("ROLE_ADMIN") && !enabled) {
            throw new RuntimeException("不能禁用管理员用户");
        }

        userMapper.updateEnabledStatus(id, enabled);
    }

    @Transactional
    public void resetPassword(Long id, String newPassword) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        String encodedPassword = passwordEncoder.encode(newPassword);
        userMapper.updatePassword(id, encodedPassword);
    }

    public Map<String, Object> getUserStats() {
        return userMapper.getUserStats();
    }

}
