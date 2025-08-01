package com.easyticket.mapper;

import com.easyticket.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 用户数据访问层
 *
 * @author hxp
 * @version 1.0.0
 */
@Mapper
public interface UserMapper {

    /**
     * 根据ID查询用户
     */
    User findById(@Param("id") Long id);

    /**
     * 根据用户名查询用户
     */
    User findByUsername(@Param("username") String username);

    /**
     * 根据邮箱查询用户
     */
    User findByEmail(@Param("email") String email);

    /**
     * 插入新用户
     */
    int insert(User user);

    /**
     * 更新用户信息
     */
    int update(User user);

    /**
     * 删除用户
     */
    int deleteById(@Param("id") Long id);

    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(@Param("username") String username);

    /**
     * 检查邮箱是否存在
     */
    boolean existsByEmail(@Param("email") String email);

    /**
     * 根据ID和邮箱查询用户（用于激活验证）
     */
    User findByIdAndEmail(@Param("id") Long id, @Param("email") String email);

    /**
     * 更新用户激活状态
     */
    int updateActivationStatus(@Param("id") Long id, @Param("activated") boolean activated);

    /**
     * 更新用户密码
     */
    int updatePassword(@Param("id") Long id, @Param("password") String password);

    /**
     * 分页查询用户列表（管理员用）
     */
    List<User> findAllUsers(@Param("offset") int offset,
                           @Param("limit") int limit,
                           @Param("keyword") String keyword,
                           @Param("role") String role,
                           @Param("enabled") Boolean enabled);

    /**
     * 获取用户总数
     */
    long countAllUsers(@Param("keyword") String keyword,
                       @Param("role") String role,
                       @Param("enabled") Boolean enabled);

    /**
     * 更新用户角色
     */
    int updateRoles(@Param("id") Long id, @Param("roles") String roles);

    /**
     * 更新用户启用状态
     */
    int updateEnabledStatus(@Param("id") Long id, @Param("enabled") Boolean enabled);

    /**
     * 批量删除用户
     */
    int deleteByIds(@Param("ids") List<Long> ids);

    /**
     * 获取用户统计信息
     */
    Map<String, Object> getUserStats();
}
