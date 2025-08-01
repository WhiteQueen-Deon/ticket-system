package com.easyticket.service;

import com.easyticket.entity.Event;
import com.easyticket.mapper.EventMapper;
import com.easyticket.mapper.OrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 活动场次管理服务类
 *
 * @author hxp
 * @version 1.0.0
 */
@Service
@Transactional
public class EventService {

    @Autowired
    private EventMapper eventMapper;

    @Autowired
    private OrderMapper orderMapper;

    /**
     * 分页查询所有活动
     */
    public List<Event> getAllEvents(int page, int size, String keyword, String status) {
        int offset = page * size;
        return eventMapper.findAllEvents(offset, size, keyword, status);
    }

    /**
     * 获取所有活动总数
     */
    public long getAllEventsCount(String keyword, String status) {
        return eventMapper.countAllEvents(keyword, status);
    }

    /**
     * 根据ID获取活动详情
     */
    public Event getEventById(Long eventId) {
        return eventMapper.findById(eventId);
    }

    /**
     * 创建新活动
     */
    @Transactional
    public Event createEvent(Event event) {
        event.setCreateTime(LocalDateTime.now());
        event.setUpdateTime(LocalDateTime.now());

        // 设置默认状态
        if (event.getStatus() == null || event.getStatus().isEmpty()) {
            event.setStatus("ACTIVE");
        }

        // 设置可用票数等于总票数
        if (event.getAvailableQuantity() == null) {
            event.setAvailableQuantity(event.getTotalQuantity());
        }

        eventMapper.insertEvent(event);
        return event;
    }

    /**
     * 更新活动信息
     */
    @Transactional
    public Event updateEvent(Event event) {
        Event existingEvent = eventMapper.findById(event.getId());
        if (existingEvent == null) {
            throw new RuntimeException("活动不存在");
        }

        // 处理票务数量逻辑
        if (event.getTotalQuantity() != null && existingEvent.getTotalQuantity() != null) {
            // 计算票数变化
            int totalChange = event.getTotalQuantity() - existingEvent.getTotalQuantity();

            if (totalChange > 0) {
                // 总票数增加，相应增加可用票数
                event.setAvailableQuantity(existingEvent.getAvailableQuantity() + totalChange);
            } else if (totalChange < 0) {
                // 总票数减少，检查是否有足够的可用票
                int newAvailable = existingEvent.getAvailableQuantity() + totalChange;
                if (newAvailable < 0) {
                    throw new RuntimeException("总票数不能少于已售票数");
                }
                event.setAvailableQuantity(newAvailable);
            } else {
                // 总票数没变，保持原有可用票数
                event.setAvailableQuantity(existingEvent.getAvailableQuantity());
            }
        } else {
            // 保持原有的可用票数
            event.setAvailableQuantity(existingEvent.getAvailableQuantity());
        }

        // 保持原有的managerId和createTime
        event.setManagerId(existingEvent.getManagerId());
        event.setCreateTime(existingEvent.getCreateTime());
        event.setUpdateTime(LocalDateTime.now());

        eventMapper.updateEvent(event);
        return event;
    }

    /**
     * 删除活动
     */
    @Transactional
    public void deleteEvent(Long eventId) {
        deleteEvent(eventId, false);
    }

    /**
     * 删除活动
     *
     * @param eventId 活动ID
     * @param forceDelete 是否强制删除
     */
    @Transactional
    public void deleteEvent(Long eventId, boolean forceDelete) {
        Event event = eventMapper.findById(eventId);
        if (event == null) {
            throw new RuntimeException("活动不存在");
        }

        // 检查活动是否已有订单
        long orderCount = orderMapper.countOrdersByEventId(eventId);
        if (orderCount > 0) {
            if (!forceDelete) {
                throw new RuntimeException("该活动已有 " + orderCount + " 个订单，无法删除。请先取消所有相关订单或联系管理员处理。");
            } else {
                System.out.println("警告：强制删除活动 [" + event.getEventName() + "] 及其 " + orderCount + " 个相关订单");
                orderMapper.findOrdersByEventId(eventId, 0, (int)orderCount)
                    .forEach(order -> orderMapper.updateStatus(order.getId(), "CANCELLED_BY_EVENT_DELETION"));
            }
        }

        // 删除活动
        eventMapper.deleteById(eventId);
    }

    /**
     * 检查活动是否可以安全删除
     *
     * @param eventId 活动ID
     * @return 检查结果信息
     */
    public EventDeletionCheckResult checkEventDeletion(Long eventId) {
        Event event = eventMapper.findById(eventId);
        if (event == null) {
            return new EventDeletionCheckResult(false, "活动不存在", 0);
        }

        long orderCount = orderMapper.countOrdersByEventId(eventId);
        boolean canDelete = orderCount == 0;
        String message = canDelete ?
            "可以安全删除此活动" :
            "该活动有 " + orderCount + " 个相关订单，建议先处理这些订单";

        return new EventDeletionCheckResult(canDelete, message, orderCount);
    }

    /**
     * 活动删除检查结果
     */
    public static class EventDeletionCheckResult {
        private final boolean canDelete;
        private final String message;
        private final long orderCount;

        public EventDeletionCheckResult(boolean canDelete, String message, long orderCount) {
            this.canDelete = canDelete;
            this.message = message;
            this.orderCount = orderCount;
        }

        public boolean isCanDelete() { return canDelete; }
        public String getMessage() { return message; }
        public long getOrderCount() { return orderCount; }
    }

    /**
     * 根据管理员ID查询活动
     */
    public List<Event> getEventsByManagerId(Long managerId, int page, int size) {
        int offset = page * size;
        return eventMapper.findByManagerId(managerId, offset, size);
    }

    /**
     * 统计管理员的活动数量
     */
    public long getEventsCountByManagerId(Long managerId) {
        return eventMapper.countByManagerId(managerId);
    }

    /**
     * 启用/禁用活动
     */
    @Transactional
    public void toggleEventStatus(Long eventId) {
        Event event = eventMapper.findById(eventId);
        if (event == null) {
            throw new RuntimeException("活动不存在");
        }

        String newStatus = "ACTIVE".equals(event.getStatus()) ? "INACTIVE" : "ACTIVE";
        event.setStatus(newStatus);
        event.setUpdateTime(LocalDateTime.now());
        eventMapper.updateEvent(event);
    }
}
