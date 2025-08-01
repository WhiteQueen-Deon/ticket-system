<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>Change Password</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <style>
        .password-container {
            padding: 15px;
            background: #fff;
            border-radius: 2px;
        }

        .password-form {
            max-width: 500px;
            margin: 0 auto;
            padding: 30px;
        }

        .form-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e6e6e6;
        }

        .form-header h2 {
            color: #333;
            margin-bottom: 10px;
        }

        .form-header p {
            color: #666;
            font-size: 14px;
        }

        .security-tips {
            background: #f0f9ff;
            border: 1px solid #91d5ff;
            border-radius: 2px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .security-tips h4 {
            color: #1890ff;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .security-tips ul {
            margin: 0;
            padding-left: 20px;
            color: #666;
            font-size: 12px;
        }

        .security-tips li {
            margin-bottom: 5px;
        }

        .layui-form-item {
            margin-bottom: 20px;
        }

        .form-actions {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e6e6e6;
        }
    </style>
</head>
<body>
<div class="password-container">
    <div class="password-form">
        <div class="form-header">
            <h2>Change Password</h2>
            <p>For your account security, please set a strong password</p>
        </div>

        <div class="security-tips">
            <h4><i class="layui-icon layui-icon-tips"></i> Password Security Tips</h4>
            <ul>
                <li>Password must be at least 6 characters long</li>
                <li>It is recommended to use a combination of letters, numbers, and special characters</li>
                <li>Do not use passwords related to personal information</li>
                <li>Update your password regularly to protect your account</li>
            </ul>
        </div>

        <form class="layui-form" lay-filter="changePasswordForm">
            <div class="layui-form-item">
                <label class="layui-form-label">Current Password <span style="color:red">*</span></label>
                <div class="layui-input-block">
                    <input type="password" name="oldPassword" placeholder="Please enter current password" lay-verify="required" class="layui-input" autocomplete="off">
                </div>
            </div>

            <div class="layui-form-item">
                <label class="layui-form-label">New Password <span style="color:red">*</span></label>
                <div class="layui-input-block">
                    <input type="password" name="newPassword" placeholder="Please enter new password (at least 6 characters)" lay-verify="required|newPassword" class="layui-input" autocomplete="off">
                </div>
            </div>

            <div class="layui-form-item">
                <label class="layui-form-label">Confirm Password <span style="color:red">*</span></label>
                <div class="layui-input-block">
                    <input type="password" name="confirmPassword" placeholder="Please re-enter new password" lay-verify="required|confirmPassword" class="layui-input" autocomplete="off">
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="layui-btn layui-btn-normal" lay-submit lay-filter="submitBtn">
                    <i class="layui-icon layui-icon-ok"></i> Change Password
                </button>
                <button type="reset" class="layui-btn layui-btn-primary">
                    <i class="layui-icon layui-icon-refresh"></i> Reset
                </button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    layui.use(['form', 'layer', 'jquery'], function(){
        var form = layui.form,
            layer = layui.layer,
            $ = layui.jquery;

        // Custom validation rules
        form.verify({
            newPassword: function(value) {
                if (value.length < 6) {
                    return 'New password must be at least 6 characters long';
                }

                // Check if new password is same as old password
                var oldPassword = $('input[name="oldPassword"]').val();
                if (value === oldPassword) {
                    return 'New password cannot be the same as current password';
                }
            },
            confirmPassword: function(value) {
                var newPassword = $('input[name="newPassword"]').val();
                if (value !== newPassword) {
                    return 'The two new passwords do not match';
                }
            }
        });

        // Form submit event
        form.on('submit(submitBtn)', function(data) {
            var formData = data.field;

            // Validate required fields
            if (!formData.oldPassword || !formData.newPassword || !formData.confirmPassword) {
                layer.msg('Please fill out all required fields');
                return false;
            }

            // Validate new password length
            if (formData.newPassword.length < 6) {
                layer.msg('New password must be at least 6 characters long');
                return false;
            }

            // Validate password confirmation
            if (formData.newPassword !== formData.confirmPassword) {
                layer.msg('The two new passwords do not match');
                return false;
            }

            // Validate new password different from old password
            if (formData.newPassword === formData.oldPassword) {
                layer.msg('New password cannot be the same as current password');
                return false;
            }

            changePassword(formData);
            return false;
        });

        function changePassword(formData) {
            layer.load(2);
            $.ajax({
                url: '${pageContext.request.contextPath}/api/change-password',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({
                    oldPassword: formData.oldPassword,
                    newPassword: formData.newPassword
                }),
                beforeSend: function(xhr) {
                    var token = $('meta[name="_csrf"]').attr('content');
                    var header = $('meta[name="_csrf_header"]').attr('content');
                    xhr.setRequestHeader(header, token);
                },
                success: function(res) {
                    layer.closeAll('loading');
                    if (res.code === 0) {
                        layer.alert('Password changed successfully! Please log in again.', {
                            icon: 1,
                            title: 'Success'
                        }, function() {
                            // Redirect to login page after password change
                            window.top.location.href = '${pageContext.request.contextPath}/login?logout';
                        });
                    } else {
                        layer.msg(res.msg || 'Password change failed');
                    }
                },
                error: function(xhr, status, error) {
                    layer.closeAll('loading');
                    if (xhr.status === 400) {
                        layer.msg('Current password is incorrect');
                    } else {
                        layer.msg('Network error, please try again later');
                    }
                }
            });
        }

        // Password strength check
        $('input[name="newPassword"]').on('keyup', function() {
            var password = $(this).val();
            if (password.length > 0) {
                checkPasswordStrength(password);
            }
        });

        function checkPasswordStrength(password) {
            var strength = 0;
            var tips = [];

            // Length check
            if (password.length >= 6) {
                strength += 1;
            } else {
                tips.push('At least 6 characters');
            }

            // Contains number
            if (/\d/.test(password)) {
                strength += 1;
            } else {
                tips.push('Contains number');
            }

            // Contains lowercase letter
            if (/[a-z]/.test(password)) {
                strength += 1;
            } else {
                tips.push('Contains lowercase letter');
            }

            // Contains uppercase letter
            if (/[A-Z]/.test(password)) {
                strength += 1;
            } else {
                tips.push('Contains uppercase letter');
            }

            // Contains special character
            if (/[^A-Za-z0-9]/.test(password)) {
                strength += 1;
            } else {
                tips.push('Contains special character');
            }

            var strengthText = '';
            var strengthColor = '';

            if (strength < 2) {
                strengthText = 'Weak';
                strengthColor = '#FF5722';
            } else if (strength < 4) {
                strengthText = 'Medium';
                strengthColor = '#FF9900';
            } else {
                strengthText = 'Strong';
                strengthColor = '#5FB878';
            }

            // Optional: display password strength tips
        }
    });
</script>
</body>
</html>
