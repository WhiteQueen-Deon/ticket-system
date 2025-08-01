<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>Easy Ticket System - Management System</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css">

    <!-- CSRF Token for AJAX -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <style>

        /* Header Logo Style */
        .admin-header-logo {
            float: left;
            color: #fff;
            font-size: 18px;
            font-weight: 600;
            line-height: 60px;
            padding: 0 20px;
        }

        .admin-header-logo .layui-icon {
            font-size: 20px;
            vertical-align: middle;
            margin-right: 8px;
            color: #1E9FFF;
        }

        /* Header Navigation */
        .admin-header-nav {
            float: right;
        }

        .admin-header-nav .layui-nav-item {
            margin-left: 15px;
        }

        /* Menu Icon Spacing */
        .layui-nav-tree .layui-nav-item a .layui-icon {
            margin-right: 8px;
        }

        /* User Avatar */
        .admin-user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            margin-right: 8px;
            vertical-align: middle;
        }

        /* Breadcrumb Navigation */
        .admin-breadcrumb {
            background: #fff;
            padding: 15px 20px;
            margin-bottom: 15px;
            border-radius: 2px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
            position: relative;
            z-index: 999;
        }

        /* Content Frame iframe */
        .admin-iframe-container {
            width: 100%;
            height: calc(100vh - 170px);
            border: none;
            background: #f2f2f2;
        }

        .admin-content-iframe {
            width: 100%;
            height: 100%;
            border: none;
            background: #fff;
            border-radius: 2px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }

        /* Mobile Menu Button */
        .mobile-menu-btn {
            display: none;
            float: left;
            color: #fff;
            font-size: 18px;
            line-height: 60px;
            padding: 0 20px;
            cursor: pointer;
        }

        /* Menu Item Hover Effect */
        .layui-nav-tree .layui-nav-item a:hover {
            background-color: #2F4056;
        }

        .layui-nav-tree .layui-nav-child dd a:hover {
            background-color: #1E9FFF;
        }

        /* Active Menu Item */
        .layui-nav-tree .layui-nav-item.layui-this > a,
        .layui-nav-tree .layui-nav-child dd.layui-this {
            background-color: #1E9FFF;
        }

        /* Responsive Handling */
        @media screen and (max-width: 768px) {
            .admin-header-logo {
                display: none;
            }

            .mobile-menu-btn {
                display: block;
            }

            .layui-layout-admin .layui-side {
                left: -200px;
                transition: left 0.3s ease;
            }

            .layui-layout-admin.mobile-show-side .layui-side {
                left: 0;
            }

            .admin-iframe-container {
                height: calc(100vh - 140px);
            }
        }
    </style>
</head>
<body class="layui-layout-body">
<div class="layui-layout layui-layout-admin">

    <!-- Header -->
    <div class="layui-header">
        <div class="admin-header-logo">
            <i class="layui-icon layui-icon-home"></i>
            Easy Ticket System
        </div>

        <!-- Mobile Menu Button -->
        <div class="mobile-menu-btn" onclick="toggleMobileMenu()">
            <i class="layui-icon layui-icon-spread-left"></i>
        </div>

        <!-- Header Navigation Menu -->
        <ul class="layui-nav layui-layout-right admin-header-nav" lay-filter="headerNav">
            <li class="layui-nav-item">
                <a href="javascript:;" class="admin-user-info">
                    <img src="${pageContext.request.contextPath}/images/avatar-default.svg" class="admin-user-avatar" alt="Avatar">
                    <sec:authentication property="name" var="username"/>
                    <span>${username}</span>
                </a>
                <dl class="layui-nav-child">
                    <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/profile', 'Profile')"><i class="layui-icon layui-icon-username"></i> Profile</a></dd>
                    <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/change-password', 'Change Password')"><i class="layui-icon layui-icon-password"></i> Change Password</a></dd>
                    <hr>
                    <dd><a href="javascript:;" onclick="logout()"><i class="layui-icon layui-icon-logout"></i> Logout</a></dd>
                </dl>
            </li>
        </ul>
    </div>

    <!-- Left Side Menu -->
    <div class="layui-side layui-bg-black">
        <div class="layui-side-scroll">
            <ul class="layui-nav layui-nav-tree" lay-filter="sideNav">

                <!-- System Home -->
                <li class="layui-nav-item layui-this">
                    <a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/dashboard', 'System Home')">
                        <i class="layui-icon layui-icon-console"></i>
                        <span>System Home</span>
                    </a>
                </li>

                <!-- Ticket Management - Visible to Customers and Managers -->
                <sec:authorize access="hasAnyRole('CUSTOMER', 'MANAGER', 'ADMIN')">
                    <li class="layui-nav-item">
                        <a href="javascript:;">
                            <i class="layui-icon layui-icon-cart-simple"></i>
                            <span>Ticket Management</span>
                        </a>
                        <dl class="layui-nav-child">
                            <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/tickets/events', 'Browse Events')">Browse Events</a></dd>
                            <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/tickets/my-orders', 'My Orders')">My Orders</a></dd>
                            <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
                                <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/tickets/all-orders', 'All Orders')">All Orders</a></dd>
                            </sec:authorize>
                        </dl>
                    </li>
                </sec:authorize>

                <!-- Event Management - Visible to Managers and Admins -->
                <sec:authorize access="hasAnyRole('MANAGER', 'ADMIN')">
                    <li class="layui-nav-item">
                        <a href="javascript:;">
                            <i class="layui-icon layui-icon-date"></i>
                            <span>Event Management</span>
                        </a>
                        <dl class="layui-nav-child">
                            <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/tickets/event-management', 'Event Management')">Event Management</a></dd>
                        </dl>
                    </li>
                </sec:authorize>

                <!-- User Management - Visible to Admin Only -->
                <sec:authorize access="hasRole('ADMIN')">
                    <li class="layui-nav-item">
                        <a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/users/list', 'User Management')">
                            <i class="layui-icon layui-icon-user"></i>
                            <span>User Management</span>
                        </a>
                    </li>
                </sec:authorize>

                <!-- Personal Center -->
                <li class="layui-nav-item">
                    <a href="javascript:;">
                        <i class="layui-icon layui-icon-username"></i>
                        <span>Personal Center</span>
                    </a>
                    <dl class="layui-nav-child">
                        <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/profile', 'Profile')">Profile</a></dd>
                        <dd><a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/change-password', 'Change Password')">Change Password</a></dd>
                    </dl>
                </li>

            </ul>
        </div>
    </div>

    <!-- Main Content -->
    <div class="layui-body">
        <!-- Breadcrumb Navigation -->
        <div class="admin-breadcrumb">
                <span class="layui-breadcrumb" lay-separator=">">
                    <a href="javascript:;" onclick="loadPage('${pageContext.request.contextPath}/dashboard', 'System Home')">Home</a>
                    <a><cite id="currentPageTitle">System Home</cite></a>
                </span>
        </div>

        <!-- iframe Content Area -->
        <div class="admin-iframe-container">
            <iframe id="contentFrame" class="admin-content-iframe"
                    src="${pageContext.request.contextPath}/dashboard"
                    frameborder="0"
                    scrolling="auto">
            </iframe>
        </div>
    </div>

    <!-- Footer -->
    <div class="layui-footer">
        <p>
            &copy; 2025 Easy Ticket System. All Rights Reserved | Developed with Spring Boot + Spring Security + LayUI
            <span style="float: right; margin-right: 15px;">
                    <i class="layui-icon layui-icon-heart-fill" style="color: #FF5722;"></i>
                    Committed to providing the best ticket purchasing experience
                </span>
        </p>
    </div>
</div>

<!-- LayUI JS -->
<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<!-- Common JS -->
<script src="${pageContext.request.contextPath}/js/common.js"></script>

<script>
    // Common JavaScript Code
    layui.use(['element', 'layer'], function(){
        var element = layui.element,
            layer = layui.layer;

        // Page Load Complete
        $(document).ready(function() {
            // Default load home page
            loadPage('${pageContext.request.contextPath}/dashboard', 'System Home');
        });
    });

    // Load Page to iframe
    function loadPage(url, title) {
        document.getElementById('contentFrame').src = url;
        document.getElementById('currentPageTitle').textContent = title;

        // Auto close menu on mobile
        if (window.innerWidth <= 768) {
            document.querySelector('.layui-layout-admin').classList.remove('mobile-show-side');
        }
    }

    // Logout
    function logout() {
        layui.layer.confirm('Are you sure you want to logout?', {
            btn: ['Confirm', 'Cancel'],
            icon: 3,
            title: 'Confirm Logout'
        }, function(index) {
            // Get CSRF Token
            var token = document.querySelector('meta[name="_csrf"]').getAttribute('content');
            var header = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

            // Create form and submit
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/logout';

            var csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = '_csrf';  // Use standard CSRF parameter name
            csrfInput.value = token;

            form.appendChild(csrfInput);
            document.body.appendChild(form);
            form.submit();

            layui.layer.close(index);
        });
    }

    // Mobile Menu Toggle
    function toggleMobileMenu() {
        var layout = document.querySelector('.layui-layout-admin');
        if (layout.classList.contains('mobile-show-side')) {
            layout.classList.remove('mobile-show-side');
        } else {
            layout.classList.add('mobile-show-side');
        }
    }

    // Click Mask to Hide Mobile Menu
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768) {
            var layout = document.querySelector('.layui-layout-admin');
            var side = document.querySelector('.layui-side');
            var mobileBtn = document.querySelector('.mobile-menu-btn');

            if (!side.contains(e.target) && !mobileBtn.contains(e.target)) {
                layout.classList.remove('mobile-show-side');
            }
        }
    });
</script>
</body>
</html>