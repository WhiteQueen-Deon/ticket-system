<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>Event Management</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css">

    <!-- CSRF Token for AJAX -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <style>
        body {
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
            font-family: "Microsoft YaHei", Arial, sans-serif;
        }

        .header-section {
            background: #fff;
            padding: 20px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
        }

        .header-title {
            font-size: 20px;
            font-weight: normal;
            color: #333;
            margin-bottom: 8px;
        }

        .header-desc {
            color: #666;
            font-size: 14px;
        }

        .search-form {
            background: #fff;
            padding: 20px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
        }

        .events-table {
            background: #fff;
            border: 1px solid #ddd;
        }

        .status-badge {
            padding: 2px 8px;
            border: 1px solid #ccc;
            font-size: 12px;
            display: inline-block;
        }

        .status-active {
            background: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }

        .status-inactive {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }

        .btn-group {
            display: flex;
            gap: 5px;
        }

        .form-section {
            margin-bottom: 15px;
            padding: 15px;
            border: 1px solid #ddd;
            background: #fff;
        }

        .form-section h4 {
            color: #333;
            margin: 0 0 15px 0;
            padding-bottom: 8px;
            border-bottom: 1px solid #ddd;
            font-size: 14px;
            font-weight: normal;
        }

        .layui-form-item .layui-input-block {
            margin-left: 110px;
        }

        .layui-form-label {
            width: 100px;
            font-weight: normal;
        }

        /* Remove all decoration effects */
        .layui-btn:hover {
            /* Remove hover animation */
        }

        .form-section:hover {
            /* Remove hover effect */
        }

        /* Simplify input box style */
        .layui-input:focus, .layui-textarea:focus {
            border-color: #5FB878;
        }

        @media screen and (max-width: 768px) {
            body {
                padding: 10px;
            }

            .layui-form-item .layui-input-block {
                margin-left: 0;
            }

            .layui-form-label {
                width: auto;
                padding: 0 0 5px 0;
                display: block;
            }
        }
    </style>
</head>
<body>

<!-- Header Information -->
<div class="header-section">
    <div class="header-title">Event Management</div>
    <div class="header-desc">Manage event sessions, including creation, editing, deletion and status control</div>
</div>

<!-- Search Form -->
<div class="layui-card search-form">
    <div class="layui-card-body">
        <form class="layui-form" lay-filter="searchForm">
            <div class="layui-row layui-col-space15">
                <div class="layui-col-md4">
                    <input type="text" name="keyword" placeholder="Search event name/description" class="layui-input">
                </div>
                <div class="layui-col-md2">
                    <select name="status" lay-search="">
                        <option value="">All Status</option>
                        <option value="ACTIVE">Active</option>
                        <option value="INACTIVE">Inactive</option>
                    </select>
                </div>
                <div class="layui-col-md6">
                    <button type="button" class="layui-btn" onclick="searchEvents()" style="margin-right: 10px;">
                        Search
                    </button>
                    <button type="button" class="layui-btn layui-btn-normal" onclick="resetSearch()" style="margin-right: 10px;">
                        Reset
                    </button>
                    <button type="button" class="layui-btn layui-btn-warm" onclick="showCreateEventModal()">
                        Create New Event
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Events Table -->
<div class="layui-card events-table">
    <div class="layui-card-header">
        <h3>Event List</h3>
    </div>
    <div class="layui-card-body" style="padding: 0;">
        <table class="layui-table" lay-even lay-skin="nob">
            <thead>
            <tr>
                <th>ID</th>
                <th>Event Name</th>
                <th>Location</th>
                <th>Event Time</th>
                <th>Price</th>
                <th>Total Tickets</th>
                <th>Available Tickets</th>
                <th>Status</th>
                <th>Create Time</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody id="eventsTableBody">
            <!-- Event data will be loaded via AJAX -->
            </tbody>
        </table>

        <!-- Pagination -->
        <div id="pagination" style="padding: 20px; text-align: center;"></div>
    </div>
</div>

<!-- Create/Edit Event Modal -->
<div id="eventFormModal" style="display: none;">
    <div style="padding: 20px;">
        <form class="layui-form" id="eventForm" lay-filter="eventForm">
            <input type="hidden" name="id" id="eventId">

            <!-- Basic Information Section -->
            <div class="form-section">
                <h4>Basic Information</h4>

                <div class="layui-form-item">
                    <label class="layui-form-label">Event Name</label>
                    <div class="layui-input-block">
                        <input type="text" name="eventName" placeholder="Enter event name"
                               autocomplete="off" class="layui-input" lay-verify="required">
                    </div>
                </div>

                <div class="layui-form-item">
                    <label class="layui-form-label">Location</label>
                    <div class="layui-input-block">
                        <input type="text" name="location" placeholder="Enter location"
                               autocomplete="off" class="layui-input" lay-verify="required">
                    </div>
                </div>

                <div class="layui-form-item">
                    <label class="layui-form-label">Description</label>
                    <div class="layui-input-block">
                        <textarea name="description" placeholder="Enter event description"
                                  class="layui-textarea" rows="3"></textarea>
                    </div>
                </div>
            </div>

            <!-- Time & Ticketing Section -->
            <div class="form-section">
                <h4>Time & Ticketing</h4>

                <div class="layui-row layui-col-space15">
                    <div class="layui-col-md6">
                        <div class="layui-form-item">
                            <label class="layui-form-label">Event Time</label>
                            <div class="layui-input-block">
                                <input type="text" name="eventDate" placeholder="Select event time"
                                       autocomplete="off" class="layui-input" lay-verify="required" id="eventDateTime">
                            </div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="layui-form-item">
                            <label class="layui-form-label">Status</label>
                            <div class="layui-input-block">
                                <select name="status" lay-verify="required">
                                    <option value="">Select status</option>
                                    <option value="ACTIVE">Active</option>
                                    <option value="INACTIVE">Inactive</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="layui-row layui-col-space15">
                    <div class="layui-col-md6">
                        <div class="layui-form-item">
                            <label class="layui-form-label">Price (¥)</label>
                            <div class="layui-input-block">
                                <input type="number" name="price" placeholder="Enter price"
                                       autocomplete="off" class="layui-input" lay-verify="required|number" min="0" step="0.01">
                            </div>
                        </div>
                    </div>
                    <div class="layui-col-md6">
                        <div class="layui-form-item">
                            <label class="layui-form-label">Total Tickets</label>
                            <div class="layui-input-block">
                                <input type="number" name="totalQuantity" placeholder="Enter total tickets"
                                       autocomplete="off" class="layui-input" lay-verify="required|number" min="1">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons Section -->
            <div style="text-align: center; padding: 15px 0;">
                <button type="submit" class="layui-btn" lay-submit lay-filter="saveEvent">
                    Save Event
                </button>
                <button type="button" class="layui-btn layui-btn-primary" onclick="layer.closeAll()">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- LayUI JS -->
<script src="${pageContext.request.contextPath}/static/layui/layui.js"></script>

<script>
    layui.use(['layer', 'form', 'laypage', 'laydate'], function(){
        var layer = layui.layer,
            form = layui.form,
            laypage = layui.laypage,
            laydate = layui.laydate;

        var currentPage = 1;
        var pageSize = 15;
        var isEditMode = false;

        // Initialize datetime picker
        laydate.render({
            elem: '#eventDateTime',
            type: 'datetime',
            format: 'yyyy-MM-dd HH:mm:ss'
        });

        // Load events when page loads
        loadEvents();

        // Search events
        window.searchEvents = function() {
            currentPage = 1;
            loadEvents();
        };

        // Reset search
        window.resetSearch = function() {
            document.querySelector('input[name="keyword"]').value = '';
            document.querySelector('select[name="status"]').value = '';
            form.render('select');
            currentPage = 1;
            loadEvents();
        };

        // Show create event modal
        window.showCreateEventModal = function() {
            isEditMode = false;

            // Get modal content HTML
            var modalContent = document.getElementById('eventFormModal').innerHTML;

            layer.open({
                type: 1,
                title: 'Create New Event',
                area: ['800px', '600px'],
                content: modalContent,
                success: function(layero, index) {
                    // Clear form
                    var formElement = layero.find('#eventForm')[0];
                    if (formElement) {
                        formElement.reset();
                        layero.find('#eventId').val('');
                    }

                    // Reinitialize date picker
                    laydate.render({
                        elem: layero.find('#eventDateTime')[0],
                        type: 'datetime',
                        format: 'yyyy-MM-dd HH:mm:ss'
                    });

                    // Re-render form components
                    form.render();

                    // Bind form submit event
                    bindFormSubmit(layero, false);
                },
                cancel: function(index) {
                    layer.close(index);
                }
            });
        };

        // Show edit event modal
        window.showEditEventModal = function(eventId) {
            isEditMode = true;
            loadEventDetail(eventId);
        };

        // Load events list
        function loadEvents() {
            var keyword = document.querySelector('input[name="keyword"]').value;
            var status = document.querySelector('select[name="status"]').value;

            var params = new URLSearchParams({
                page: currentPage - 1,
                size: pageSize
            });

            if (keyword) params.append('keyword', keyword);
            if (status) params.append('status', status);

            // Show loading animation
            var loadIndex = layer.load(1, {shade: [0.1,'#fff']});

            fetch('${pageContext.request.contextPath}/tickets/api/events?' + params.toString())
                .then(response => response.json())
                .then(data => {
                    layer.close(loadIndex);

                    if (data.code === 0) {
                        renderEventsTable(data.data);
                        renderPagination(data.count);
                    } else {
                        layer.msg(data.msg, {icon: 5});
                    }
                })
                .catch(error => {
                    layer.close(loadIndex);
                    layer.msg('Loading failed: ' + error.message, {icon: 5});
                });
        }

        // Render events table
        function renderEventsTable(events) {
            var tbody = document.getElementById('eventsTableBody');

            if (events.length === 0) {
                tbody.innerHTML =
                    '<tr>' +
                    '<td colspan="10" style="text-align: center; padding: 40px; color: #999;">' +
                    'No event data available' +
                    '</td>' +
                    '</tr>';
                return;
            }

            var html = '';
            events.forEach(function(event) {
                var eventTime = new Date(event.eventDate).toLocaleString();
                var createTime = new Date(event.createTime).toLocaleString();
                var statusClass = 'status-' + event.status.toLowerCase();
                var statusText = event.status === 'ACTIVE' ? 'Active' : 'Inactive';
                var soldTickets = (event.totalQuantity || 0) - (event.availableQuantity || 0);

                html +=
                    '<tr>' +
                    '<td>' + event.id + '</td>' +
                    '<td style="font-weight: 600; color: #333;">' + event.eventName + '</td>' +
                    '<td>' + event.location + '</td>' +
                    '<td>' + eventTime + '</td>' +
                    '<td style="color: #e74c3c; font-weight: 600;">¥' + event.price + '</td>' +
                    '<td>' + (event.totalQuantity || 0) + '</td>' +
                    '<td>' + (event.availableQuantity || 0) + '</td>' +
                    '<td><span class="status-badge ' + statusClass + '">' + statusText + '</span></td>' +
                    '<td>' + createTime + '</td>' +
                    '<td>' +
                    '<div class="btn-group">' +
                    '<button class="layui-btn layui-btn-xs" onclick="showEditEventModal(' + event.id + ')">' +
                    'Edit' +
                    '</button>' +
                    '<button class="layui-btn layui-btn-xs layui-btn-normal" onclick="toggleEventStatus(' + event.id + ')">' +
                    (event.status === 'ACTIVE' ? 'Disable' : 'Enable') +
                    '</button>' +
                    '<button class="layui-btn layui-btn-xs layui-btn-danger" onclick="deleteEvent(' + event.id + ')">' +
                    'Delete' +
                    '</button>' +
                    '</div>' +
                    '</td>' +
                    '</tr>';
            });

            tbody.innerHTML = html;
        }

        // Render pagination
        function renderPagination(total) {
            laypage.render({
                elem: 'pagination',
                count: total,
                limit: pageSize,
                curr: currentPage,
                layout: ['count', 'prev', 'page', 'next', 'limit', 'skip'],
                jump: function(obj, first) {
                    if (!first) {
                        currentPage = obj.curr;
                        pageSize = obj.limit;
                        loadEvents();
                    }
                }
            });
        }

        // Load event details
        function loadEventDetail(eventId) {
            var loadIndex = layer.load(1);

            fetch('${pageContext.request.contextPath}/tickets/api/event/' + eventId)
                .then(response => response.json())
                .then(data => {
                    layer.close(loadIndex);

                    if (data.code === 0) {
                        // Get modal content HTML
                        var modalContent = document.getElementById('eventFormModal').innerHTML;

                        // Open edit modal
                        layer.open({
                            type: 1,
                            title: 'Edit Event',
                            area: ['800px', '600px'],
                            content: modalContent,
                            success: function(layero, index) {
                                // Fill form data
                                var event = data.data;

                                // Fill basic fields
                                layero.find('#eventId').val(event.id || '');
                                layero.find('input[name="eventName"]').val(event.eventName || '');
                                layero.find('textarea[name="description"]').val(event.description || '');
                                layero.find('input[name="location"]').val(event.location || '');
                                layero.find('input[name="eventDate"]').val(formatDateTime(event.eventDate) || '');
                                layero.find('input[name="price"]').val(event.price || '');
                                layero.find('input[name="totalQuantity"]').val(event.totalQuantity || '');
                                layero.find('select[name="status"]').val(event.status || '');

                                // Reinitialize date picker
                                laydate.render({
                                    elem: layero.find('#eventDateTime')[0],
                                    type: 'datetime',
                                    format: 'yyyy-MM-dd HH:mm:ss'
                                });

                                // Re-render form components
                                form.render();

                                // Bind form submit event
                                bindFormSubmit(layero, true);

                                console.log('Edit form data filled:', event); // For debugging
                            },
                            cancel: function(index) {
                                layer.close(index);
                            }
                        });
                    } else {
                        layer.msg(data.msg, {icon: 5});
                    }
                })
                .catch(error => {
                    layer.close(loadIndex);
                    layer.msg('Loading failed: ' + error.message, {icon: 5});
                });
        }

        // Bind form submit event
        function bindFormSubmit(layero, isEdit) {
            // Bind save button click event
            layero.find('button[lay-submit]').on('click', function(e) {
                e.preventDefault();

                // Manually collect form data
                var eventData = {
                    id: layero.find('#eventId').val(),
                    eventName: layero.find('input[name="eventName"]').val(),
                    description: layero.find('textarea[name="description"]').val(),
                    location: layero.find('input[name="location"]').val(),
                    eventDate: layero.find('input[name="eventDate"]').val(),
                    price: layero.find('input[name="price"]').val(),
                    totalQuantity: layero.find('input[name="totalQuantity"]').val(),
                    status: layero.find('select[name="status"]').val()
                };

                // Form validation
                if (!eventData.eventName || !eventData.location || !eventData.eventDate ||
                    !eventData.price || !eventData.totalQuantity || !eventData.status) {
                    layer.msg('Please fill in all required fields', {icon: 5});
                    return;
                }

                var url = isEdit ?
                    '${pageContext.request.contextPath}/tickets/api/event/' + eventData.id :
                    '${pageContext.request.contextPath}/tickets/api/event';
                var method = isEdit ? 'PUT' : 'POST';

                // Get CSRF token
                var token = document.querySelector('meta[name="_csrf"]').getAttribute('content');
                var header = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

                var loadIndex = layer.load(1);

                fetch(url, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json',
                        [header]: token
                    },
                    body: JSON.stringify(eventData)
                })
                    .then(response => response.json())
                    .then(data => {
                        layer.close(loadIndex);

                        if (data.code === 0) {
                            layer.closeAll();
                            layer.msg(isEdit ? 'Update successful' : 'Creation successful', {icon: 1}, function() {
                                loadEvents(); // Refresh list
                            });
                        } else {
                            layer.msg(data.msg, {icon: 5});
                        }
                    })
                    .catch(error => {
                        layer.close(loadIndex);
                        layer.msg('Operation failed: ' + error.message, {icon: 5});
                    });
            });

            // Bind cancel button click event
            layero.find('button[type="button"]').on('click', function() {
                layer.closeAll();
            });
        }

        // Format datetime
        function formatDateTime(dateStr) {
            if (!dateStr) return '';
            var date = new Date(dateStr);
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            var hours = String(date.getHours()).padStart(2, '0');
            var minutes = String(date.getMinutes()).padStart(2, '0');
            var seconds = String(date.getSeconds()).padStart(2, '0');
            return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
        }

        // Toggle event status
        window.toggleEventStatus = function(eventId) {
            layer.confirm('Are you sure to toggle this event status?', {
                btn: ['Confirm', 'Cancel'],
                icon: 3,
                title: 'Confirmation'
            }, function(index) {
                // Get CSRF token
                var token = document.querySelector('meta[name="_csrf"]').getAttribute('content');
                var header = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

                fetch('${pageContext.request.contextPath}/tickets/api/event/' + eventId + '/toggle-status', {
                    method: 'POST',
                    headers: {
                        [header]: token
                    }
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.code === 0) {
                            layer.close(index);
                            layer.msg('Status updated successfully', {icon: 1}, function() {
                                loadEvents(); // Refresh list
                            });
                        } else {
                            layer.msg(data.msg, {icon: 5});
                        }
                    })
                    .catch(error => {
                        layer.msg('Operation failed: ' + error.message, {icon: 5});
                    });
            });
        };

        // Delete event
        window.deleteEvent = function(eventId) {
            layer.confirm('Are you sure to delete this event? This cannot be undone!', {
                btn: ['Confirm', 'Cancel'],
                icon: 0,
                title: 'Dangerous Operation'
            }, function(index) {
                // Get CSRF token
                var token = document.querySelector('meta[name="_csrf"]').getAttribute('content');
                var header = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

                fetch('${pageContext.request.contextPath}/tickets/api/event/' + eventId, {
                    method: 'DELETE',
                    headers: {
                        [header]: token
                    }
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.code === 0) {
                            layer.close(index);
                            layer.msg('Deleted successfully', {icon: 1}, function() {
                                loadEvents(); // Refresh list
                            });
                        } else {
                            layer.msg(data.msg, {icon: 5});
                        }
                    })
                    .catch(error => {
                        layer.msg('Operation failed: ' + error.message, {icon: 5});
                    });
            });
        };
    });
</script>

</body>
</html>