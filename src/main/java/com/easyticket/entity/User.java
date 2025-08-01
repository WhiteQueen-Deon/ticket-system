package com.easyticket.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import javax.persistence.*; // 新增

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.List;
import java.util.Set;

/**
 * 用户实体类
 *
 * @author hxp
 * @version 1.0.0
 */

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "username cannot be empty")
    @Size(min = 3, max = 20, message = "username must be between 3 and 20 characters")
    private String username;

    @JsonIgnore
    @NotBlank(message = "password cannot be empty")
    @Size(min = 6, message = "password must be at least 6 characters long")
    private String password;

    @NotBlank(message = "email cannot be empty")
    @Email(message = "email format is incorrect")
    private String email;

    private String nickname;

    private String phone;

    private String roles = "ROLE_CUSTOMER";

    private Boolean enabled = false;

    private String activationToken;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime registrationDate;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime updateTime;


    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "card_id")
    private IdentityCard card;

    @ManyToMany
    @JoinTable(
            name = "user_event",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "event_id")
    )
    private Set<Event> events = new HashSet<>();


    public User() {
        this.createTime = LocalDateTime.now();
        this.updateTime = LocalDateTime.now();
        this.registrationDate = LocalDateTime.now();
        this.enabled = false;
        this.roles = "ROLE_CUSTOMER";
    }

    // 有参构造函数
    public User(String username, String password, String email) {
        this();
        this.username = username;
        this.password = password;
        this.email = email;
    }

    // Getter和Setter方法
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRoles() {
        return roles;
    }

    public void setRoles(String roles) {
        this.roles = roles;
    }

    public String getActivationToken() {
        return activationToken;
    }

    public void setActivationToken(String activationToken) {
        this.activationToken = activationToken;
    }

    public LocalDateTime getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(LocalDateTime registrationDate) {
        this.registrationDate = registrationDate;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    /**
     * 检查用户是否拥有指定角色
     */
    public boolean hasRole(String role) {
        return this.roles != null && this.roles.contains(role);
    }

    /**
     * 检查用户是否为管理员
     */
    public boolean isAdmin() {
        return hasRole("ROLE_ADMIN");
    }

    /**
     * 检查用户是否为经理
     */
    public boolean isManager() {
        return hasRole("ROLE_MANAGER");
    }

    /**
     * 检查用户是否为客户
     */
    public boolean isCustomer() {
        return hasRole("ROLE_CUSTOMER");
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        User user = (User) obj;
        return Objects.equals(id, user.id) &&
               Objects.equals(username, user.username);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, username);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", enabled=" + enabled +
                ", roles='" + roles + '\'' +
                ", createTime=" + createTime +
                '}';
    }
}
