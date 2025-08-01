<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>System Homepage</title>


    <link rel="stylesheet" href="${pageContext.request.contextPath}/layui/css/layui.css">

    <style>
        body {
            background: #f2f2f2;
            margin: 0;
            padding: 20px;
        }

        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }

        .welcome-title {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .welcome-subtitle {
            font-size: 16px;
            opacity: 0.9;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-2px);
        }

        .stat-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .stat-icon.events { color: #1E9FFF; }
        .stat-icon.orders { color: #FF5722; }
        .stat-icon.users { color: #4CAF50; }
        .stat-icon.revenue { color: #FF9800; }

        .stat-number {
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }

        .stat-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }

        .quick-actions {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }

        .actions-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            text-decoration: none;
            color: #495057;
            transition: all 0.3s ease;
        }

        .action-btn:hover {
            background: #e9ecef;
            transform: translateY(-1px);
            text-decoration: none;
            color: #495057;
        }

        .action-btn i {
            font-size: 24px;
            margin-right: 12px;
            color: #1E9FFF;
        }

        @media screen and (max-width: 768px) {
            body {
                padding: 10px;
            }

            .stats-row {
                grid-template-columns: repeat(2, 1fr);
            }

            .action-buttons {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<!-- Welcome Card -->
<div class="welcome-card">
    <div class="welcome-title">
        <i class="layui-icon layui-icon-heart-fill"></i>
        Welcome to Easy Ticket System
    </div>
    <div class="welcome-subtitle">
        <sec:authentication property="name" var="username"/>
        Hello, ${username}! Today is a wonderful day, wish you a pleasant work!
    </div>
</div>

<!-- Statistics -->
<div class="stats-row">
    <div class="stat-card">
        <div class="stat-icon events">
            <i class="layui-icon layui-icon-date"></i>
        </div>
        <div class="stat-number" id="eventCount">0</div>
        <div class="stat-label">Active Events</div>
        <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/event-management', 'Event List')" class="layui-btn layui-btn-xs">Manage Events</a>
        </sec:authorize>
    </div>

    <div class="stat-card">
        <div class="stat-icon orders">
            <i class="layui-icon layui-icon-cart"></i>
        </div>
        <div class="stat-number" id="orderCount">0</div>
        <div class="stat-label">Today's Orders</div>
        <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/my-orders', 'My Orders')" class="layui-btn layui-btn-xs">View Orders</a>
    </div>

    <sec:authorize access="hasRole('ADMIN')">
        <div class="stat-card">
            <div class="stat-icon users">
                <i class="layui-icon layui-icon-user"></i>
            </div>
            <div class="stat-number" id="userCount">0</div>
            <div class="stat-label">Registered Users</div>
            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/users/list', 'User List')" class="layui-btn layui-btn-xs">Manage Users</a>
        </div>
    </sec:authorize>
</div>

<!-- Quick Actions -->
<div class="quick-actions">
    <div class="actions-title">
        <i class="layui-icon layui-icon-app"></i>
        Quick Actions
    </div>
    <div class="action-buttons">

        <!-- Ticket Related -->
        <sec:authorize access="hasAnyRole('CUSTOMER', 'MANAGER', 'ADMIN')">
            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/events', 'Browse Events')" class="action-btn">
                <i class="layui-icon layui-icon-cart-simple"></i>
                <div>
                    <div style="font-weight: 600;">Browse Events</div>
                    <div style="font-size: 12px; color: #999;">View available events</div>
                </div>
            </a>

            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/my-orders', 'My Orders')" class="action-btn">
                <i class="layui-icon layui-icon-template-1"></i>
                <div>
                    <div style="font-weight: 600;">My Orders</div>
                    <div style="font-size: 12px; color: #999;">View purchase history</div>
                </div>
            </a>
        </sec:authorize>

        <!-- Management Related -->
        <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/event-management', 'Add Event')" class="action-btn">
                <i class="layui-icon layui-icon-add-circle"></i>
                <div>
                    <div style="font-weight: 600;">Add Event</div>
                    <div style="font-size: 12px; color: #999;">Create new event</div>
                </div>
            </a>

            <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/tickets/all-orders', 'All Orders')" class="action-btn">
                <i class="layui-icon layui-icon-form"></i>
                <div>
                    <div style="font-weight: 600;">Order Management</div>
                    <div style="font-size: 12px; color: #999;">Manage all orders</div>
                </div>
            </a>
        </sec:authorize>

        <!-- Personal Center -->
        <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/profile', 'Profile')" class="action-btn">
            <i class="layui-icon layui-icon-username"></i>
            <div>
                <div style="font-weight: 600;">Profile</div>
                <div style="font-size: 12px; color: #999;">View and edit personal information</div>
            </div>
        </a>

        <a href="javascript:;" onclick="parent.loadPage('${pageContext.request.contextPath}/change-password', 'Change Password')" class="action-btn">
            <i class="layui-icon layui-icon-password"></i>
            <div>
                <div style="font-weight: 600;">Change Password</div>
                <div style="font-size: 12px; color: #999;">Update login password</div>
            </div>
        </a>

    </div>
</div>

<!-- LayUI JS -->
<script src="${pageContext.request.contextPath}/layui/layui.js"></script>

<script>
    layui.use(['layer'], function(){
        var layer = layui.layer;

        // Load statistics after page loads
        loadDashboardStats();

        // Load dashboard statistics
        function loadDashboardStats() {
            // Get basic statistics
            fetch('${pageContext.request.contextPath}/api/dashboard/stats')
                .then(response => response.json())
                .then(data => {
                    if (data.code === 0) {
                        const stats = data.data;

                        // Update active events count
                        document.getElementById('eventCount').textContent = stats.eventCount || '0';

                        // Update orders count
                        document.getElementById('orderCount').textContent = stats.orderCount || '0';

                        // Update revenue data (visible to admin/manager)
                        var revenueCountElement = document.getElementById('revenueCount');
                        if (revenueCountElement) {
                            const revenue = stats.todayRevenue || 0;
                            revenueCountElement.textContent = '¥' + formatNumber(revenue);
                        }
                    } else {
                        console.error('Failed to get statistics:', data.msg);
                        // Show default values
                        setDefaultValues();
                    }
                })
                .catch(error => {
                    console.error('Request statistics failed:', error);
                    // Show default values
                    setDefaultValues();
                });

            // Get admin-only statistics
            var userCountElement = document.getElementById('userCount');
            if (userCountElement) {
                fetch('${pageContext.request.contextPath}/api/dashboard/admin-stats')
                    .then(response => response.json())
                    .then(data => {
                        if (data.code === 0) {
                            const stats = data.data;
                            userCountElement.textContent = stats.userCount || '0';
                        } else {
                            console.error('Failed to get admin statistics:', data.msg);
                            userCountElement.textContent = '0';
                        }
                    })
                    .catch(error => {
                        console.error('Request admin statistics failed:', error);
                        userCountElement.textContent = '0';
                    });
            }
        }

        // Set default values
        function setDefaultValues() {
            document.getElementById('eventCount').textContent = '0';
            document.getElementById('orderCount').textContent = '0';

            var revenueCountElement = document.getElementById('revenueCount');
            if (revenueCountElement) {
                revenueCountElement.textContent = '¥0';
            }

            var userCountElement = document.getElementById('userCount');
            if (userCountElement) {
                userCountElement.textContent = '0';
            }
        }

        // Format number display
        function formatNumber(num) {
            if (num === null || num === undefined) return '0';

            // Convert to number
            const number = typeof num === 'string' ? parseFloat(num) : num;

            if (isNaN(number)) return '0';

            // Format with thousands separator
            return number.toLocaleString('zh-CN', {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2
            });
        }
    });
</script>

</body>
</html>