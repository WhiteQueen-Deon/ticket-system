package com.easyticket.service;

import com.easyticket.entity.Order;
import com.easyticket.mapper.OrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class OrderCancelScheduler {

    @Autowired
    private OrderMapper orderMapper;

//    @Scheduled(fixedDelay = 5 * 60 * 1000)
    @Scheduled(fixedDelay = 6 * 1000)
    public void cancelExpiredOrders() {
        int expirationSeconds = 6;

        LocalDateTime expireTime = LocalDateTime.now().minusSeconds(expirationSeconds);
        List<Order> expiredOrders = orderMapper.findExpiredPendingOrders(expireTime);

        for (Order order : expiredOrders) {
            orderMapper.updateStatus(order.getId(), "cancelled");

        }
    }
}
