<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>Profile</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <style>
        .profile-container {
            padding: 15px;
            background: #fff;
            border-radius: 2px;
        }

        .profile-header {
            text-align: center;
            padding: 30px 0;
            border-bottom: 1px solid #e6e6e6;
            margin-bottom: 30px;
        }

        .avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            margin: 0 auto 15px;
            background: #5FB878;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 30px;
            font-weight: bold;
        }

        .profile-form {
            max-width: 600px;
            margin: 0 auto;
        }

        .info-item {
            margin-bottom: 15px;
            padding: 15px;
            background: #f8f8f8;
            border-radius: 2px;
        }

        .info-label {
            color: #666;
            font-size: 12px;
            margin-bottom: 5px;
        }

        .info-value {
            font-size: 14px;
            color: #333;
        }

        .role-admin {
            color: #FF5722;
            font-weight: bold;
            padding: 2px 8px;
            background: #fff2f0;
            border: 1px solid #FF5722;
            border-radius: 2px;
        }

        .role-manager {
            color: #FF9900;
            font-weight: bold;
            padding: 2px 8px;
            background: #fff7e6;
            border: 1px solid #FF9900;
            border-radius: 2px;
        }

        .role-customer {
            color: #1E9FFF;
            font-weight: bold;
            padding: 2px 8px;
            background: #e6f7ff;
            border: 1px solid #1E9FFF;
            border-radius: 2px;
        }

        .status-enabled {
            color: #5FB878;
            font-weight: bold;
            padding: 2px 8px;
            background: #f6ffed;
            border: 1px solid #5FB878;
            border-radius: 2px;
        }

        .status-disabled {
            color: #FF5722;
            font-weight: bold;
            padding: 2px 8px;
            background: #fff2f0;
            border: 1px solid #FF5722;
            border-radius: 2px;
        }
    </style>
</head>
<body>
<div class="profile-container">
    <div class="profile-header">
        <div class="avatar" id="userAvatar"></div>
        <h2 id="userDisplayName"></h2>
        <p id="userEmail"></p>
    </div>

    <div class="profile-form">
        <div class="layui-card">
            <div class="layui-card-header">
                <span>Basic Information</span>
                <button class="layui-btn layui-btn-sm layui-btn-normal" style="float: right;" onclick="editProfile()">
                    <i class="layui-icon layui-icon-edit"></i> Edit
                </button>
            </div>
            <div class="layui-card-body">
                <div class="layui-row layui-col-space15">
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Username</div>
                            <div class="info-value" id="username"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Email</div>
                            <div class="info-value" id="email"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Nickname</div>
                            <div class="info-value" id="nickname"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Phone</div>
                            <div class="info-value" id="phone"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Role</div>
                            <div class="info-value" id="role"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Status</div>
                            <div class="info-value" id="status"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Created At</div>
                            <div class="info-value" id="createTime"></div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="info-item">
                            <div class="info-label">Updated At</div>
                            <div class="info-value" id="updateTime"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    layui.use(['form', 'layer', 'jquery'], function(){
        var form = layui.form,
            layer = layui.layer,
            $ = layui.jquery;

        // Load user profile on page load
        loadUserProfile();

        function loadUserProfile() {
            layer.load(2);
            $.ajax({
                url: '${pageContext.request.contextPath}/api/profile',
                type: 'GET',
                beforeSend: function(xhr) {
                    var token = $('meta[name="_csrf"]').attr('content');
                    var header = $('meta[name="_csrf_header"]').attr('content');
                    xhr.setRequestHeader(header, token);
                },
                success: function(res) {
                    layer.closeAll('loading');
                    if (res.code === 0) {
                        displayUserProfile(res.data);
                    } else {
                        layer.msg(res.msg || 'Failed to get user information');
                    }
                },
                error: function() {
                    layer.closeAll('loading');
                    layer.msg('Network error');
                }
            });
        }

        function displayUserProfile(user) {
            // Avatar shows the first letter of the username
            var firstLetter = user.username ? user.username.charAt(0).toUpperCase() : 'U';
            $('#userAvatar').text(firstLetter);

            // Display username or nickname
            var displayName = user.nickname || user.username || 'Not Set';
            $('#userDisplayName').text(displayName);
            $('#userEmail').text(user.email || 'Not Set');

            // Basic info
            $('#username').text(user.username || 'Not Set');
            $('#email').text(user.email || 'Not Set');
            $('#nickname').text(user.nickname || 'Not Set');
            $('#phone').text(user.phone || 'Not Set');

            // Role display
            var roleHtml = '';
            if (user.roles && user.roles.includes('ROLE_ADMIN')) {
                roleHtml = '<span class="role-admin">Admin</span>';
            } else if (user.roles && user.roles.includes('ROLE_MANAGER')) {
                roleHtml = '<span class="role-manager">Manager</span>';
            } else if (user.roles && user.roles.includes('ROLE_CUSTOMER')) {
                roleHtml = '<span class="role-customer">Customer</span>';
            } else {
                roleHtml = 'Unknown';
            }
            $('#role').html(roleHtml);

            // Status display
            var statusHtml = user.enabled ?
                '<span class="status-enabled">Enabled</span>' :
                '<span class="status-disabled">Disabled</span>';
            $('#status').html(statusHtml);

            // Time display
            $('#createTime').text(user.createTime || 'Unknown');
            $('#updateTime').text(user.updateTime || 'Unknown');
        }

        window.editProfile = function() {
            // Get current info
            var currentEmail = $('#email').text();
            var currentNickname = $('#nickname').text();
            var currentPhone = $('#phone').text();

            // Handle "Not Set" cases
            if (currentEmail === 'Not Set') currentEmail = '';
            if (currentNickname === 'Not Set') currentNickname = '';
            if (currentPhone === 'Not Set') currentPhone = '';

            var content = '<form class="layui-form" style="padding: 20px;" lay-filter="editProfileForm">' +
                '<div class="layui-form-item">' +
                '<label class="layui-form-label">Email <span style="color:red">*</span></label>' +
                '<div class="layui-input-block">' +
                '<input type="email" name="email" value="' + currentEmail + '" placeholder="Please enter email address" lay-verify="required|email" class="layui-input" autocomplete="off">' +
                '</div>' +
                '</div>' +
                '<div class="layui-form-item">' +
                '<label class="layui-form-label">Nickname</label>' +
                '<div class="layui-input-block">' +
                '<input type="text" name="nickname" value="' + currentNickname + '" placeholder="Please enter nickname" class="layui-input" autocomplete="off">' +
                '</div>' +
                '</div>' +
                '<div class="layui-form-item">' +
                '<label class="layui-form-label">Phone</label>' +
                '<div class="layui-input-block">' +
                '<input type="text" name="phone" value="' + currentPhone + '" placeholder="Please enter phone number" lay-verify="phone" class="layui-input" autocomplete="off">' +
                '</div>' +
                '</div>' +
                '</form>';

            layer.open({
                type: 1,
                title: 'Edit Profile',
                content: content,
                area: ['500px', '400px'],
                success: function() {
                    // Add custom validation rules
                    form.verify({
                        phone: function(value) {
                            if (value && !/^1[3-9]\d{9}$/.test(value)) {
                                return 'Please enter a valid phone number';
                            }
                        }
                    });
                    form.render();
                },
                btn: ['Save', 'Cancel'],
                yes: function(index, layero) {
                    var formData = form.val('editProfileForm');
                    updateProfile(formData, index);
                }
            });
        };

        function updateProfile(formData, layerIndex) {
            layer.load(2);
            $.ajax({
                url: '${pageContext.request.contextPath}/api/profile',
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(formData),
                beforeSend: function(xhr) {
                    var token = $('meta[name="_csrf"]').attr('content');
                    var header = $('meta[name="_csrf_header"]').attr('content');
                    xhr.setRequestHeader(header, token);
                },
                success: function(res) {
                    layer.closeAll('loading');
                    if (res.code === 0) {
                        layer.msg('Update successful');
                        layer.close(layerIndex);
                        loadUserProfile();
                    } else {
                        layer.msg(res.msg || 'Update failed');
                    }
                },
                error: function() {
                    layer.closeAll('loading');
                    layer.msg('Network error');
                }
            });
        }
    });
</script>
</body>
</html>
