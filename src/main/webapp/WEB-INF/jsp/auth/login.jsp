<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title><fmt:message key="login.title"/></title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css">

    <!-- CSRF Token for AJAX -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <style>
        body {
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
            font-family: Arial, sans-serif;
        }
        .login-container {
            max-width: 400px;
            margin: 50px auto;
            padding: 30px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .login-title {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
            font-size: 24px;
        }
        .login-btn-container {
            text-align: center;
            margin: 30px 0 20px 0;
        }
        .login-btn-container .layui-btn {
            width: 200px;
            height: 40px;
        }
        .login-links {
            text-align: center;
            margin-top: 20px;
        }
        .login-links a {
            color: #009688;
            text-decoration: none;
            margin: 0 10px;
        }
        .login-links a:hover {
            text-decoration: underline;
        }
        .message-box {
            margin-bottom: 20px;
            padding: 15px;
            border-radius: 5px;
            display: none;
        }
        .message-success {
            background-color: #f0f9ff;
            border: 1px solid #009688;
            color: #009688;
        }
        .message-error {
            background-color: #fff2f0;
            border: 1px solid #FF5722;
            color: #FF5722;
        }
        .message-info {
            background-color: #f0f9ff;
            border: 1px solid #2196F3;
            color: #2196F3;
        }
        /* 语言切换按钮样式 */
        .language-switcher {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 999;
        }
        .language-switcher .layui-btn {
            min-width: 50px;
            margin-left: 5px;
        }
    </style>
</head>
<body>

<!-- 语言切换按钮 -->
<div class="language-switcher">
    <button id="btn-en" class="layui-btn layui-btn-primary layui-btn-sm">EN</button>
    <button id="btn-cn" class="layui-btn layui-btn-primary layui-btn-sm">CN</button>
</div>

<div class="login-container">
    <h2 class="login-title">
        <i class="layui-icon layui-icon-username" style="color: #009688;"></i>
        <fmt:message key="login.header"/>
    </h2>

    <!-- 动态消息显示区域 -->
    <div id="messageBox" class="message-box">
        <i id="messageIcon" class="layui-icon"></i>
        <span id="messageText"></span>
    </div>

    <!-- 默认消息显示 -->
    <c:if test="${not empty param.error}">
        <div class="layui-elem-quote layui-quote-nm" style="border-left: 5px solid #FF5722; color: #FF5722;">
            <i class="layui-icon layui-icon-close"></i>
            <fmt:message key="login.error"/>
        </div>
    </c:if>

    <c:if test="${not empty param.logout}">
        <div class="layui-elem-quote layui-quote-nm" style="border-left: 5px solid #009688; color: #009688;">
            <i class="layui-icon layui-icon-ok"></i>
            <fmt:message key="login.logout"/>
        </div>
    </c:if>

    <c:if test="${not empty param.registered}">
        <div class="layui-elem-quote layui-quote-nm" style="border-left: 5px solid #009688; color: #009688;">
            <i class="layui-icon layui-icon-ok"></i>
            <fmt:message key="login.registered"/>
        </div>
    </c:if>

    <c:if test="${not empty param.activated}">
        <div class="layui-elem-quote layui-quote-nm" style="border-left: 5px solid #009688; color: #009688;">
            <i class="layui-icon layui-icon-ok"></i>
            <fmt:message key="login.activated"/>
        </div>
    </c:if>

    <!-- 登录表单 -->
    <form id="loginForm" class="layui-form" action="${pageContext.request.contextPath}/perform-login" method="post">
        <!-- CSRF Token -->
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="login.username"/></label>
            <div class="layui-input-block">
                <input type="text" name="username" id="username" placeholder="<fmt:message key="login.username.placeholder"/>"
                       class="layui-input" lay-verify="required" lay-reqText="<fmt:message key="login.username.required"/>" autocomplete="username">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="login.password"/></label>
            <div class="layui-input-block">
                <input type="password" name="password" id="password" placeholder="<fmt:message key="login.password.placeholder"/>"
                       class="layui-input" lay-verify="required" lay-reqText="<fmt:message key="login.password.required"/>" autocomplete="current-password">
            </div>
        </div>

        <div class="layui-form-item">
            <div class="layui-input-block">
                <input type="checkbox" id="rememberPassword" title="<fmt:message key="login.remember"/>" lay-skin="primary" lay-filter="rememberPassword">
            </div>
        </div>

        <div class="login-btn-container">
            <button type="submit" id="loginBtn" class="layui-btn layui-btn-normal">
                <i class="layui-icon layui-icon-ok"></i>
                <fmt:message key="login.button"/>
            </button>
        </div>
    </form>

    <div class="login-links">
        <a href="${pageContext.request.contextPath}/register">
            <i class="layui-icon layui-icon-user"></i>
            <fmt:message key="login.registerLink"/>
        </a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    layui.use(['form', 'layer'], function(){
        var form = layui.form;
        var layer = layui.layer;
        var $ = layui.$;

        // Cookie操作函数
        function setCookie(name, value, days) {
            var expires = "";
            if (days) {
                var date = new Date();
                date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
                expires = "; expires=" + date.toUTCString();
            }
            document.cookie = name + "=" + (value || "") + expires + "; path=/";
        }

        function getCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for(var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) == ' ') c = c.substring(1, c.length);
                if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
            }
            return null;
        }

        function deleteCookie(name) {
            document.cookie = name + "=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;";
        }

        // 显示消息
        function showMessage(type, message) {
            var $messageBox = $('#messageBox');
            var $messageIcon = $('#messageIcon');
            var $messageText = $('#messageText');

            $messageBox.removeClass('message-success message-error message-info');

            switch(type) {
                case 'success':
                    $messageBox.addClass('message-success');
                    $messageIcon.removeClass().addClass('layui-icon layui-icon-ok');
                    break;
                case 'error':
                    $messageBox.addClass('message-error');
                    $messageIcon.removeClass().addClass('layui-icon layui-icon-close');
                    break;
                case 'info':
                    $messageBox.addClass('message-info');
                    $messageIcon.removeClass().addClass('layui-icon layui-icon-tips');
                    break;
            }

            $messageText.text(message);
            $messageBox.show();
        }

        // 隐藏消息
        function hideMessage() {
            $('#messageBox').hide();
        }

        // 加载保存的密码
        function loadSavedPassword() {
            var savedUsername = getCookie('rememberedUsername');
            var savedPassword = getCookie('rememberedPassword');

            if (savedUsername) {
                $('#username').val(savedUsername);
            }

            if (savedPassword) {
                $('#password').val(savedPassword);
                $('#rememberPassword').prop('checked', true);
                form.render('checkbox');
            }
        }

        // 保存密码到cookie
        function savePassword() {
            var username = $('#username').val();
            var password = $('#password').val();
            var rememberPassword = $('#rememberPassword').prop('checked');

            if (rememberPassword && username && password) {
                setCookie('rememberedUsername', username, 7);
                setCookie('rememberedPassword', password, 7);
            } else {
                deleteCookie('rememberedUsername');
                deleteCookie('rememberedPassword');
            }
        }

        // 检查登录状态
        function checkLoginStatus() {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/login-status',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.loggedIn) {
                        showMessage('info', '<fmt:message key="login.alreadyLoggedIn"/>: ' + response.username);
                        setTimeout(function() {
                            window.location.href = '${pageContext.request.contextPath}' + response.redirectUrl;
                        }, 2000);
                    }
                },
                error: function() {
                }
            });
        }

        // 表单提交处理
        $('#loginForm').on('submit', function(e) {
            e.preventDefault(); // 阻止默认提交

            var $btn = $('#loginBtn');
            var username = $('#username').val().trim();
            var password = $('#password').val().trim();

            // 验证表单
            if (!username) {
                showMessage('error', '<fmt:message key="login.username.required"/>');
                $('#username').focus();
                return false;
            }

            if (!password) {
                showMessage('error', '<fmt:message key="login.password.required"/>');
                $('#password').focus();
                return false;
            }

            // 显示登录中状态
            $btn.prop('disabled', true).html('<i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i> <fmt:message key="login.processing"/>');
            hideMessage();

            // 保存密码（如果勾选了记住密码）
            savePassword();

            // 获取CSRF令牌
            var token = $('meta[name="_csrf"]').attr('content');
            var header = $('meta[name="_csrf_header"]').attr('content');

            // 发送AJAX登录请求
            $.ajax({
                url: '${pageContext.request.contextPath}/api/login',
                type: 'POST',
                headers: {
                    [header]: token
                },
                data: {
                    username: username,
                    password: password,
                    rememberMe: false
                },
                dataType: 'json',
                success: function(response) {
                    $btn.prop('disabled', false).html('<i class="layui-icon layui-icon-ok"></i> <fmt:message key="login.button"/>');

                    if (response.success) {
                        showMessage('success', response.message || '<fmt:message key="login.success"/>');

                        // 延迟跳转，让用户看到成功消息
                        setTimeout(function() {
                            window.location.href = '${pageContext.request.contextPath}' + response.redirectUrl;
                        }, 1000);
                    } else {
                        showMessage('error', response.message || '<fmt:message key="login.failed"/>');
                    }
                },
                error: function(xhr, status, error) {
                    $btn.prop('disabled', false).html('<i class="layui-icon layui-icon-ok"></i> <fmt:message key="login.button"/>');

                    try {
                        var response = JSON.parse(xhr.responseText);
                        showMessage('error', response.message || '<fmt:message key="login.failed"/>');
                    } catch (e) {
                        showMessage('error', '<fmt:message key="login.networkError"/>');
                    }
                }
            });
        });

        // 记住密码checkbox变化时的处理
        form.on('checkbox(rememberPassword)', function(data) {
            if (!data.elem.checked) {
                // 如果取消勾选，删除保存的密码
                deleteCookie('rememberedUsername');
                deleteCookie('rememberedPassword');
            }
        });

        // 语言切换按钮事件
        $('#btn-en').on('click', function() {
            window.location.href = window.location.pathname + '?lang=en';
        });

        $('#btn-cn').on('click', function() {
            window.location.href = window.location.pathname + '?lang=zh_CN';
        });

        // 页面加载完成后的处理
        $(document).ready(function() {
            // 加载保存的密码
            loadSavedPassword();

            // 检查是否已登录
            checkLoginStatus();

            // 如果URL中有成功消息参数，显示消息
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('registered')) {
                showMessage('success', '<fmt:message key="login.registered"/>');
            } else if (urlParams.get('activated')) {
                showMessage('success', '<fmt:message key="login.activated"/>');
            } else if (urlParams.get('logout')) {
                showMessage('info', '<fmt:message key="login.logout"/>');
            } else if (urlParams.get('error')) {
                showMessage('error', '<fmt:message key="login.error"/>');
                // 恢复按钮状态
                $('#loginBtn').prop('disabled', false).html('<i class="layui-icon layui-icon-ok"></i> <fmt:message key="login.button"/>');
            }

            // 自动聚焦到用户名输入框（如果为空）
            if (!$('#username').val()) {
                $('#username').focus();
            } else {
                $('#password').focus();
            }
        });

        // 输入时隐藏错误消息
        $('#loginForm input').on('input', function() {
            if ($('#messageBox').hasClass('message-error')) {
                hideMessage();
            }
        });
    });
</script>

<!-- 底部 -->
<div class="layui-footer" style="text-align: center; margin-top: 50px; padding: 20px; background-color: #f2f2f2; border-top: 1px solid #e6e6e6;">
    <p style="margin: 0; color: #666;">
        © 2025 Easy Ticket System. <fmt:message key="copyright"/> |
        <a href="#" style="color: #009688;"><fmt:message key="footer.help"/></a> |
        <a href="#" style="color: #009688;"><fmt:message key="footer.contact"/></a>
    </p>
</div>

</body>
</html>