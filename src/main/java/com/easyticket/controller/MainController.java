package com.easyticket.controller;

import com.easyticket.service.EventService;
import com.easyticket.service.TicketService;
import com.easyticket.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

/**
 * 主控制器
 *
 * @author hxp
 * @version 1.0.0
 */
@Controller
public class MainController {

    @Autowired
    private EventService eventService;

    @Autowired
    private TicketService ticketService;

    @Autowired
    private UserService userService;

    /**
     * 主框架页面
     */
    @GetMapping({"/", "/main"})
    public String mainPage() {
        return "main";
    }

    /**
     * 系统首页
     */
    @GetMapping("/dashboard")
    public String dashboard() {
        return "dashboard";
    }

    /**
     * 获取仪表盘统计数据
     */
    @GetMapping("/api/dashboard/stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 获取活跃场次数量
            long activeEventCount = eventService.getAllEventsCount(null, "ACTIVE");
            result.put("eventCount", activeEventCount);
            
            // 获取今日订单统计数据
            Map<String, Object> todayOrderStats = ticketService.getTodayOrderStats();
            result.put("orderCount", todayOrderStats.get("todayOrders"));
            result.put("todayRevenue", todayOrderStats.get("todayRevenue"));
            
            Map<String, Object> response = new HashMap<>();
            response.put("code", 0);
            response.put("msg", "success");
            response.put("data", result);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("code", 500);
            response.put("msg", "获取统计数据失败：" + e.getMessage());
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 获取管理员专用统计数据
     */
    @GetMapping("/api/dashboard/admin-stats")
    @ResponseBody
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getAdminStats() {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 获取用户统计数据
            Map<String, Object> userStats = userService.getUserStats();
            result.put("userCount", userStats.get("totalUsers"));
            
            Map<String, Object> response = new HashMap<>();
            response.put("code", 0);
            response.put("msg", "success");
            response.put("data", result);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("code", 500);
            response.put("msg", "获取管理员统计数据失败：" + e.getMessage());
            
            return ResponseEntity.ok(response);
        }
    }
}
