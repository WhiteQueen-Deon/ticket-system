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
    <title><fmt:message key="register.title"/> - Easy Ticket System</title>

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
        .register-container {
            max-width: 500px;
            margin: 30px auto;
            padding: 30px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .register-title {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
            font-size: 24px;
        }
        .captcha-container {
            display: flex;
            align-items: center;
        }
        .captcha-img {
            height: 38px;
            margin-left: 10px;
            cursor: pointer;
            border: 1px solid #e6e6e6;
            border-radius: 2px;
        }
        .register-links {
            text-align: center;
            margin-top: 20px;
        }
        .register-links a {
            color: #009688;
            text-decoration: none;
            margin: 0 10px;
        }
        .register-links a:hover {
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

<div class="register-container">
    <h2 class="register-title">
        <i class="layui-icon layui-icon-user" style="color: #009688;"></i>
        <fmt:message key="register.header"/>
    </h2>

    <!-- 消息显示区域 -->
    <div id="messageBox" class="message-box">
        <i id="messageIcon" class="layui-icon"></i>
        <span id="messageText"></span>
    </div>

    <!-- 注册表单 -->
    <form id="registerForm" class="layui-form" lay-filter="registerForm">
        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.username"/></label>
            <div class="layui-input-block">
                <input type="text" name="username" placeholder="<fmt:message key="register.username.placeholder"/>"
                       class="layui-input" lay-verify="required|username" lay-reqText="<fmt:message key="register.username.required"/>"
                       autocomplete="username" maxlength="20">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.email"/></label>
            <div class="layui-input-block">
                <input type="email" name="email" placeholder="<fmt:message key="register.email.placeholder"/>"
                       class="layui-input" lay-verify="required|email" lay-reqText="<fmt:message key="register.email.required"/>"
                       autocomplete="email">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.password"/></label>
            <div class="layui-input-block">
                <input type="password" name="password" placeholder="<fmt:message key="register.password.placeholder"/>"
                       class="layui-input" lay-verify="required|password" lay-reqText="<fmt:message key="register.password.required"/>"
                       autocomplete="new-password" minlength="6">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.confirmPassword"/></label>
            <div class="layui-input-block">
                <input type="password" name="confirmPassword" placeholder="<fmt:message key="register.confirmPassword.placeholder"/>"
                       class="layui-input" lay-verify="required|confirmPassword" lay-reqText="<fmt:message key="register.confirmPassword.required"/>"
                       autocomplete="new-password">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.nickname"/></label>
            <div class="layui-input-block">
                <input type="text" name="nickname" placeholder="<fmt:message key="register.nickname.placeholder"/>"
                       class="layui-input" autocomplete="name" maxlength="50">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.phone"/></label>
            <div class="layui-input-block">
                <input type="tel" name="phone" placeholder="<fmt:message key="register.phone.placeholder"/>"
                       class="layui-input" lay-verify="phone" autocomplete="tel" maxlength="11">
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"><fmt:message key="register.captcha"/></label>
            <div class="layui-input-block captcha-container">
                <input type="text" name="captcha" placeholder="<fmt:message key="register.captcha.placeholder"/>"
                       class="layui-input" lay-verify="required" lay-reqText="<fmt:message key="register.captcha.required"/>"
                       style="flex: 1;" autocomplete="off" maxlength="4">
                <img id="captchaImg" src="${pageContext.request.contextPath}/captcha"
                     class="captcha-img"
                     title="<fmt:message key="register.captcha.refresh"/>" alt="<fmt:message key="register.captcha"/>">
            </div>
        </div>

        <div class="layui-form-item">
            <div class="layui-input-block">
                <input type="checkbox" name="agreement" value="true" title="<fmt:message key="register.agreement"/>"
                       lay-skin="primary" lay-filter="agreement" lay-verify="required" lay-reqText="<fmt:message key="register.agreement.required"/>">
            </div>
        </div>

        <div class="layui-form-item">
            <div class="layui-input-block">
                <button type="button" id="registerBtn" class="layui-btn layui-btn-fluid layui-btn-normal">
                    <i class="layui-icon layui-icon-ok"></i>
                    <fmt:message key="register.button"/>
                </button>
            </div>
        </div>
    </form>

    <div class="register-links">
        <a href="${pageContext.request.contextPath}/login">
            <i class="layui-icon layui-icon-return"></i>
            <fmt:message key="register.loginLink"/>
        </a>
    </div>
</div>

<!-- 底部 -->
<div class="layui-footer" style="text-align: center; margin-top: 50px; padding: 20px; background-color: #f2f2f2; border-top: 1px solid #e6e6e6;">
    <p style="margin: 0; color: #666;">
        © 2025 Easy Ticket System. <fmt:message key="copyright"/>
    </p>
</div>

<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    // 确保LayUI加载完成后再执行
    (function() {
        function initRegisterPage() {
            // 检查LayUI是否已加载
            if (typeof layui === 'undefined') {
                console.error('LayUI 未加载');
                setTimeout(initRegisterPage, 100);
                return;
            }

            layui.use(['form', 'layer', 'jquery'], function(){
                var form = layui.form;
                var layer = layui.layer;
                var $ = layui.jquery;

                // 自定义验证规则
                form.verify({
                    username: function(value, item) {
                        if(!new RegExp("^[a-zA-Z0-9_]{3,20}$").test(value)){
                            return '<fmt:message key="register.username.invalid"/>';
                        }
                    },
                    password: function(value, item) {
                        if(value.length < 6){
                            return '<fmt:message key="register.password.required"/>';
                        }
                    },
                    confirmPassword: function(value, item) {
                        var password = document.querySelector('input[name="password"]').value;
                        if(value !== password){
                            return '<fmt:message key="register.confirmPassword.mismatch"/>';
                        }
                    },
                    phone: function(value, item) {
                        if(value && !new RegExp("^1[3-9]\\d{9}$").test(value)){
                            return '<fmt:message key="register.phone.invalid"/>';
                        }
                    }
                });

                // 显示消息
                function showMessage(type, message) {
                    var $messageBox = $('#messageBox');
                    var $messageIcon = $('#messageIcon');
                    var $messageText = $('#messageText');

                    $messageBox.removeClass('message-success message-error');

                    if (type === 'success') {
                        $messageBox.addClass('message-success');
                        $messageIcon.removeClass().addClass('layui-icon layui-icon-ok');
                    } else {
                        $messageBox.addClass('message-error');
                        $messageIcon.removeClass().addClass('layui-icon layui-icon-close');
                    }

                    $messageText.text(message);
                    $messageBox.show();
                }

                // 刷新验证码
                function refreshCaptcha() {
                    $('#captchaImg').attr('src', '${pageContext.request.contextPath}/captcha?' + Math.random());
                }

                // 注册按钮点击事件
                $('#registerBtn').on('click', function() {
                    var $btn = $(this);
                    var formValid = true;

                    // 手动触发验证
                    $('input[lay-verify]').each(function() {
                        var verify = $(this).attr('lay-verify').split('|');
                        for(var i = 0; i < verify.length; i++) {
                            var rule = verify[i];
                            if(rule && form.verify[rule]) {
                                var msg = form.verify[rule](this.value, this);
                                if(msg) {
                                    layer.msg(msg, {icon: 2});
                                    formValid = false;
                                    return false;
                                }
                            }
                        }
                    });

                    if (!formValid) return;

                    // 显示加载状态
                    $btn.prop('disabled', true).html('<i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i> <fmt:message key="register.processing"/>');

                    // 发送AJAX请求
                    $.ajax({
                        url: '${pageContext.request.contextPath}/api/register',
                        type: 'POST',
                        data: $('#registerForm').serialize(),
                        headers: {
                            '${_csrf.headerName}': '${_csrf.token}'
                        },
                        success: function(response) {
                            if (response.success) {
                                showMessage('success', '<fmt:message key="register.success"/>');
                                setTimeout(function() {
                                    window.location.href = '${pageContext.request.contextPath}/login?registered=true';
                                }, 2000);
                            } else {
                                showMessage('error', response.message || '<fmt:message key="register.error"/>');
                                refreshCaptcha();
                            }
                        },
                        error: function(xhr) {
                            showMessage('error', xhr.responseJSON?.message || '<fmt:message key="register.networkError"/>');
                            refreshCaptcha();
                        },
                        complete: function() {
                            $btn.prop('disabled', false).html('<i class="layui-icon layui-icon-ok"></i> <fmt:message key="register.button"/>');
                        }
                    });
                });

                // 验证码点击刷新
                $('#captchaImg').on('click', refreshCaptcha);

                // 语言切换
                $('#btn-en').on('click', function() {
                    window.location.href = window.location.pathname + '?lang=en';
                });
                $('#btn-cn').on('click', function() {
                    window.location.href = window.location.pathname + '?lang=zh_CN';
                });
            });
        }

        // 初始化页面
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initRegisterPage);
        } else {
            initRegisterPage();
        }
    })();
</script>
</body>
</html>