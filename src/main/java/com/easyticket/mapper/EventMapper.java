package com.easyticket.mapper;

import com.easyticket.entity.Event;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 活动数据访问层
 * 
 * @author hxp
 * @version 1.0.0
 */
@Mapper
public interface EventMapper {

    /**
     * 根据ID查询活动
     */
    Event findById(@Param("id") Long id);

    /**
     * 插入新活动
     */
    int insertEvent(Event event);

    /**
     * 更新活动信息
     */
    int updateEvent(Event event);

    /**
     * 删除活动
     */
    int deleteById(@Param("id") Long id);

    /**
     * 分页查询可购买的活动场次
     */
    List<Event> findAvailableEvents(@Param("offset") int offset, 
                                    @Param("limit") int limit,
                                    @Param("keyword") String keyword,
                                    @Param("currentTime") LocalDateTime currentTime);

    /**
     * 获取可购买场次总数
     */
    long countAvailableEvents(@Param("keyword") String keyword,
                              @Param("currentTime") LocalDateTime currentTime);

    /**
     * 更新活动可用票数
     */
    int updateAvailableQuantity(@Param("eventId") Long eventId, @Param("availableQuantity") int availableQuantity);

    /**
     * 根据状态查询活动
     */
    List<Event> findByStatus(@Param("status") String status);

    /**
     * 查询即将开始的活动
     */
    List<Event> findUpcomingEvents(@Param("currentTime") LocalDateTime currentTime, 
                                   @Param("hours") int hours);

    /**
     * 分页查询所有活动（管理员用）
     */
    List<Event> findAllEvents(@Param("offset") int offset, 
                              @Param("limit") int limit,
                              @Param("keyword") String keyword,
                              @Param("status") String status);

    /**
     * 获取所有活动总数（管理员用）
     */
    long countAllEvents(@Param("keyword") String keyword,
                        @Param("status") String status);

    /**
     * 根据管理员ID查询活动
     */
    List<Event> findByManagerId(@Param("managerId") Long managerId,
                                @Param("offset") int offset, 
                                @Param("limit") int limit);

    /**
     * 统计管理员的活动数量
     */
    long countByManagerId(@Param("managerId") Long managerId);
} 
