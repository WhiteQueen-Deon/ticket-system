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
    <title><fmt:message key="activation.title"/></title>

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

        .activation-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 40px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .activation-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .activation-success {
            color: #009688;
        }

        .activation-error {
            color: #FF5722;
        }

        .activation-title {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }

        .activation-message {
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 30px;
            color: #666;
        }

        .activation-actions {
            margin-top: 30px;
        }

        .activation-actions .layui-btn {
            margin: 0 10px;
        }

        .loading-container {
            display: block;
        }

        .result-container {
            display: none;
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
        }
    </style>
</head>
<body>

<!-- 语言切换按钮 -->
<div class="language-switcher">
    <button id="btn-en" class="layui-btn layui-btn-primary layui-btn-sm">EN</button>
    <button id="btn-cn" class="layui-btn layui-btn-primary layui-btn-sm">CN</button>
</div>

<div class="activation-container">
    <!-- 加载状态 -->
    <div id="loadingContainer" class="loading-container">
        <div class="activation-icon">
            <i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"
               style="color: #009688;"></i>
        </div>
        <h2 class="activation-title"><fmt:message key="activation.loading"/></h2>
        <div class="activation-message">
            <fmt:message key="activation.loading.message"/>
        </div>
    </div>

    <!-- 结果显示 -->
    <div id="resultContainer" class="result-container">
        <div id="resultIcon" class="activation-icon">
            <i id="resultIconElement" class="layui-icon"></i>
        </div>
        <h2 id="resultTitle" class="activation-title"></h2>
        <div id="resultMessage" class="activation-message"></div>
        <div id="resultActions" class="activation-actions"></div>
    </div>

    <!-- 帮助信息 -->
    <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee;">
        <p style="color: #999; font-size: 14px;">
            <i class="layui-icon layui-icon-tips"></i>
            <fmt:message key="contact.hint"/>
        </p>

        <!-- 重新发送激活邮件 -->
        <div style="margin-top: 15px;" id="resendContainer" class="result-container">
            <button type="button" id="resendBtn" class="layui-btn layui-btn-primary layui-btn-sm">
                <i class="layui-icon layui-icon-refresh"></i>
                <fmt:message key="resend.button"/>
            </button>
        </div>
    </div>
</div>

<!-- 底部 -->
<div class="layui-footer"
     style="text-align: center; margin-top: 50px; padding: 20px; background-color: #f2f2f2; border-top: 1px solid #e6e6e6;">
    <p style="margin: 0; color: #666;">
        <fmt:message key="copyright"/>
    </p>
</div>

<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    // 确保LayUI加载完成后再执行
    (function () {
        function initActivationPage() {
            // 检查LayUI是否已加载
            if (typeof layui === 'undefined') {
                console.error('LayUI 未加载');
                setTimeout(initActivationPage, 100);
                return;
            }

            layui.use(['layer', 'jquery'], function () {
                var layer = layui.layer;
                var $ = layui.jquery;

                console.log('LayUI 加载成功');

                // 获取URL参数中的token
                function getUrlParameter(name) {
                    var url = new URL(window.location.href);
                    return url.searchParams.get(name);
                }

                // 显示结果
                function showResult(success, message, actions) {
                    document.getElementById('loadingContainer').style.display = 'none';
                    document.getElementById('resultContainer').style.display = 'block';

                    var resultIcon = document.getElementById('resultIcon');
                    var resultIconElement = document.getElementById('resultIconElement');
                    var resultTitle = document.getElementById('resultTitle');
                    var resultMessage = document.getElementById('resultMessage');
                    var resultActions = document.getElementById('resultActions');

                    if (success) {
                        resultIcon.className = 'activation-icon activation-success';
                        resultIconElement.className = 'layui-icon layui-icon-ok-circle';
                        resultTitle.className = 'activation-title activation-success';
                        resultTitle.textContent = '<fmt:message key="activation.success"/>';

                        // 成功时的操作按钮
                        resultActions.innerHTML =
                            '<a href="${pageContext.request.contextPath}/login" class="layui-btn layui-btn-normal">' +
                            '<i class="layui-icon layui-icon-username"></i>' +
                            '<fmt:message key="login.button"/>' +
                            '</a>' +
                            '<a href="${pageContext.request.contextPath}/" class="layui-btn layui-btn-primary">' +
                            '<i class="layui-icon layui-icon-home"></i>' +
                            '<fmt:message key="home.button"/>' +
                            '</a>';

                        // 显示成功提示
                        layer.msg(message, {icon: 1, time: 3000});

                    } else {
                        resultIcon.className = 'activation-icon activation-error';
                        resultIconElement.className = 'layui-icon layui-icon-close-fill';
                        resultTitle.className = 'activation-title activation-error';
                        resultTitle.textContent = '<fmt:message key="activation.failure"/>';

                        // 失败时的操作按钮
                        resultActions.innerHTML =
                            '<a href="${pageContext.request.contextPath}/register" class="layui-btn layui-btn-warm">' +
                            '<i class="layui-icon layui-icon-user"></i>' +
                            '<fmt:message key="register.button"/>' +
                            '</a>' +
                            '<a href="${pageContext.request.contextPath}/login" class="layui-btn layui-btn-primary">' +
                            '<i class="layui-icon layui-icon-username"></i>' +
                            '<fmt:message key="login.button"/>' +
                            '</a>' +
                            '<a href="${pageContext.request.contextPath}/" class="layui-btn layui-btn-primary">' +
                            '<i class="layui-icon layui-icon-home"></i>' +
                            '<fmt:message key="home.button"/>' +
                            '</a>';

                        // 显示重新发送按钮
                        document.getElementById('resendContainer').style.display = 'block';

                        // 显示错误提示
                        layer.msg(message, {icon: 2, time: 3000});
                    }

                    resultMessage.textContent = message;
                }

                // 激活账户
                function activateAccount(token) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/api/activate',
                        type: 'GET',
                        data: {token: token},
                        dataType: 'json',
                        success: function (response) {
                            showResult(response.success, response.message);

                            if (response.success && response.redirectUrl) {
                                // 激活成功后延迟跳转
                                setTimeout(function () {
                                    window.location.href = '${pageContext.request.contextPath}' + response.redirectUrl;
                                }, 3000);
                            }
                        },
                        error: function (xhr, status, error) {
                            var message = '<fmt:message key="activation.failure.message"/>';
                            if (xhr.responseJSON && xhr.responseJSON.message) {
                                message = xhr.responseJSON.message;
                            }
                            showResult(false, message);
                        }
                    });
                }

                // 重新发送激活邮件事件绑定
                document.getElementById('resendBtn').addEventListener('click', function () {
                    var btn = this;
                    var email = prompt('<fmt:message key="resend.email.prompt"/>');

                    if (!email) {
                        return;
                    }

                    if (!email.match(/^[A-Za-z0-9+_.-]+@(.+)$/)) {
                        layer.msg('<fmt:message key="resend.email.invalid"/>', {icon: 2});
                        return;
                    }

                    btn.disabled = true;
                    btn.innerHTML = '<i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i> <fmt:message key="resend.sending"/>';

                    $.ajax({
                        url: '${pageContext.request.contextPath}/api/resend-activation',
                        type: 'POST',
                        data: {email: email},
                        dataType: 'json',
                        success: function (response) {
                            if (response.success) {
                                layer.msg(response.message, {icon: 1});
                            } else {
                                layer.msg(response.message, {icon: 2});
                            }
                        },
                        error: function (xhr, status, error) {
                            layer.msg('<fmt:message key="resend.failed"/>', {icon: 2});
                        },
                        complete: function () {
                            btn.disabled = false;
                            btn.innerHTML = '<i class="layui-icon layui-icon-refresh"></i> <fmt:message key="resend.button"/>';
                        }
                    });
                });

                // 语言切换按钮事件
                $('#btn-en').on('click', function() {
                    window.location.href = window.location.pathname + '?lang=en';
                });

                $('#btn-cn').on('click', function() {
                    window.location.href = window.location.pathname + '?lang=zh_CN';
                });

                // 页面加载完成后自动执行激活
                var token = getUrlParameter('token') || '${token}';

                if (token && token == '${token}') {
                    // 延迟1秒执行激活，让用户看到加载状态
                    setTimeout(function () {
                        activateAccount(token);
                    }, 1000);
                } else {
                    showResult(false, '<fmt:message key="activation.token.missing"/>');
                }
            });
        }

        // 页面加载完成后初始化
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initActivationPage);
        } else {
            initActivationPage();
        }
    })();
</script>
</body>
</html>