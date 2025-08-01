package com.easyticket.mapper;

import com.easyticket.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 订单数据访问层
 * 
 * @author hxp
 * @version 1.0.0
 */
@Mapper
public interface OrderMapper {

    /**
     * 根据ID查询订单
     */
    Order findById(@Param("id") Long id);

    /**
     * 插入新订单
     */
    int insert(Order order);

    /**
     * 更新订单信息
     */
    int update(Order order);

    /**
     * 删除订单
     */
    int deleteById(@Param("id") Long id);

    /**
     * 查询用户订单（分页）
     */
    List<Order> findUserOrders(@Param("username") String username,
                               @Param("orderNumber") String orderNumber,
                               @Param("status") String status,
                               @Param("offset") int offset,
                               @Param("limit") int limit);

    /**
     * 查询所有待支付且下单时间早于指定时间的订单
     */
    List<Order> findExpiredPendingOrders(@Param("expireTime") java.time.LocalDateTime expireTime);



    /**
     * 获取用户订单总数
     */
    long countUserOrders(@Param("username") String username,
                         @Param("orderNumber") String orderNumber,
                         @Param("status") String status);

    /**
     * 查询所有订单（管理员用，分页）
     */
    List<Order> findAllOrders(@Param("keyword") String keyword,
                              @Param("status") String status,
                              @Param("offset") int offset,
                              @Param("limit") int limit);

    /**
     * 获取所有订单总数
     */
    long countAllOrders(@Param("keyword") String keyword,
                        @Param("status") String status);

    /**
     * 更新订单状态
     */
    int updateStatus(@Param("id") Long id, @Param("status") String status);

    /**
     * 更新订单支付时间
     */
    int updatePaymentTime(@Param("id") Long id, @Param("paymentTime") java.time.LocalDateTime paymentTime);

    /**
     * 根据订单号查询订单
     */
    Order findByOrderNumber(@Param("orderNumber") String orderNumber);

    /**
     * 查询用户特定活动的订单
     */
    List<Order> findUserEventOrders(@Param("userId") Long userId, @Param("eventId") Long eventId);

    /**
     * 获取订单统计信息
     */
    Map<String, Object> getOrderStats();

    /**
     * 根据状态统计订单数量
     */
    Map<String, Long> countOrdersByStatus();

    /**
     * 根据活动ID查询订单数量
     */
    long countOrdersByEventId(@Param("eventId") Long eventId);

    /**
     * 根据活动ID查询订单（用于删除活动前的检查）
     */
    List<Order> findOrdersByEventId(@Param("eventId") Long eventId, 
                                    @Param("offset") int offset, 
                                    @Param("limit") int limit);

    /**
     * 获取今日订单统计信息
     */
    Map<String, Object> getTodayOrderStats();
} 
