package com.easyticket.service;

import com.easyticket.entity.Event;
import com.easyticket.entity.Order;
import com.easyticket.entity.User;
import com.easyticket.mapper.EventMapper;
import com.easyticket.mapper.OrderMapper;
import com.easyticket.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 购票服务类
 *
 * @author hxp
 * @version 1.0.0
 */
@Service
@Transactional
public class TicketService {

    @Autowired
    private EventMapper eventMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private UserMapper userMapper;

    /**
     * 分页查询可购买的活动场次
     */
    public List<Event> getAvailableEvents(int page, int size, String keyword) {
        int offset = page * size;
        LocalDateTime currentTime = LocalDateTime.now();
        return eventMapper.findAvailableEvents(offset, size, keyword, currentTime);
    }

    /**
     * 获取可购买场次总数
     */
    public long getAvailableEventsCount(String keyword) {
        LocalDateTime currentTime = LocalDateTime.now();
        return eventMapper.countAvailableEvents(keyword, currentTime);
    }

    /**
     * 根据ID获取活动详情
     */
    public Event getEventById(Long eventId) {
        return eventMapper.findById(eventId);
    }

    /**
     * 创建订单
     */
    @Transactional
    public Order createOrder(Long eventId, String username, int quantity) {
        // 获取活动信息
        Event event = eventMapper.findById(eventId);
        if (event == null) {
            throw new RuntimeException("活动不存在");
        }

        // 检查活动状态
        if (!"ACTIVE".equals(event.getStatus())) {
            throw new RuntimeException("活动已停售");
        }

        // 检查活动时间
        if (event.getEventDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("活动已结束");
        }

        // 检查余票
        if (event.getAvailableQuantity() < quantity) {
            throw new RuntimeException("余票不足，当前余票：" + event.getAvailableQuantity());
        }

        // 获取用户信息
        User user = userMapper.findByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 创建订单
        Order order = new Order();
        order.setEvent(event);
        order.setUser(user);
        order.setQuantity(quantity);
        order.setTotalAmount(event.getPrice().multiply(new BigDecimal(quantity)));
        order.setStatus("pending");
        order.setOrderDate(LocalDateTime.now());
        order.setOrderNumber(generateOrderNumber());

        // 保存订单
        orderMapper.insert(order);

        // 更新活动余票
        int newAvailableTickets = event.getAvailableQuantity() - quantity;
        eventMapper.updateAvailableQuantity(eventId, newAvailableTickets);

        return order;
    }

    /**
     * 查询用户订单
     */
    public List<Order> getUserOrders(String username, int page, int size) {
        int offset = page * size;
        return orderMapper.findUserOrders(username, null, null, offset, size);
    }

    /**
     * 获取用户订单总数
     */
    public long getUserOrdersCount(String username) {
        return orderMapper.countUserOrders(username, null, null);
    }

    /**
     * 查询所有订单（管理员用）
     */
    public List<Order> getAllOrders(int page, int size, String keyword, String status) {
        int offset = page * size;
        return orderMapper.findAllOrders(keyword, status, offset, size);
    }

    /**
     * 获取所有订单总数
     */
    public long getAllOrdersCount(String keyword, String status) {
        return orderMapper.countAllOrders(keyword, status);
    }

    /**
     * 根据ID获取订单详情
     */
    public Order getOrderById(Long orderId) {
        return orderMapper.findById(orderId);
    }

    /**
     * 更新订单状态
     */
    @Transactional
    public void updateOrderStatus(Long orderId, String status) {
        orderMapper.updateStatus(orderId, status);
    }

    /**
     * 取消订单
     */
    @Transactional
    public void cancelOrder(Long orderId, String username) {
        Order order = orderMapper.findById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 检查订单所有者
        if (!order.getUser().getUsername().equals(username)) {
            throw new RuntimeException("无权限操作此订单");
        }

        // 只有待支付状态的订单可以取消
        if (!"pending".equals(order.getStatus())) {
            throw new RuntimeException("订单状态不允许取消");
        }

        // 更新订单状态
        orderMapper.updateStatus(orderId, "cancelled");

        Event event = eventMapper.findById(order.getEvent().getId());
        if (event == null) {
            throw new RuntimeException("关联的活动不存在");
        }

        if (event.getAvailableQuantity() == null) {
            throw new RuntimeException("活动库存信息异常，无法恢复库存");
        }

        // 恢复活动余票
        int newAvailableTickets = event.getAvailableQuantity() + order.getQuantity();

        if (event.getTotalQuantity() != null && newAvailableTickets > event.getTotalQuantity()) {
            newAvailableTickets = event.getTotalQuantity();
        }

        eventMapper.updateAvailableQuantity(event.getId(), newAvailableTickets);
    }

    /**
     * 支付订单
     */
    @Transactional
    public void payOrder(Long orderId, String username) {
        Order order = orderMapper.findById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 检查订单所有者
        if (!order.getUser().getUsername().equals(username)) {
            throw new RuntimeException("无权限操作此订单");
        }

        // 只有待支付状态的订单可以支付
        if (!"pending".equals(order.getStatus())) {
            throw new RuntimeException("订单状态不允许支付");
        }

        // 从数据库重新获取活动信息以确保获取最新状态
        Event event = eventMapper.findById(order.getEvent().getId());
        if (event == null) {
            throw new RuntimeException("关联的活动不存在");
        }

        if (!"ACTIVE".equals(event.getStatus())) {
            throw new RuntimeException("活动已停售，无法支付");
        }

        if (event.getEventDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("活动已结束，无法支付");
        }

        if (event.getAvailableQuantity() == null) {
            throw new RuntimeException("活动库存信息异常");
        }

        // 更新订单状态为已支付，并设置支付时间
        orderMapper.updateStatus(orderId, "paid");
        orderMapper.updatePaymentTime(orderId, LocalDateTime.now());
    }

    /**
     * 获取订单统计信息
     */
    public Map<String, Object> getOrderStats() {
        return orderMapper.getOrderStats();
    }

    /**
     * 获取今日订单统计信息
     */
    public Map<String, Object> getTodayOrderStats() {
        return orderMapper.getTodayOrderStats();
    }

    /**
     * 生成订单号
     */
    private String generateOrderNumber() {
        long timestamp = System.currentTimeMillis();
        int random = (int)(Math.random() * 1000);
        return "ET" + timestamp + String.format("%03d", random);
    }
}
