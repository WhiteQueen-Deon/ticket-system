package com.easyticket.controller;

import com.easyticket.service.InvoiceService;
import com.easyticket.service.UserService;
import com.easyticket.service.TicketService;
import com.easyticket.entity.User;
import com.easyticket.entity.Order;
import com.easyticket.entity.Event;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/api/invoice")
public class InvoiceController {

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private UserService userService;

    @Autowired
    private TicketService ticketService;


    @GetMapping("/download/{orderId}")
    public ResponseEntity<?> downloadInvoice(@PathVariable Long orderId) {
        try {
            // 获取当前登录用户
            String username = SecurityContextHolder.getContext().getAuthentication().getName();
            User currentUser = userService.getUserByUsername(username);

            if (currentUser == null) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 401);
                result.put("msg", "用户未登录");
                return ResponseEntity.ok(result);
            }

            // 从数据库获取真实订单数据
            Order order = ticketService.getOrderById(orderId);

            if (order == null) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 404);
                result.put("msg", "订单不存在");
                return ResponseEntity.ok(result);
            }

            // 检查订单所有权
            if (!order.getUser().getId().equals(currentUser.getId())) {
                Map<String, Object> result = new HashMap<>();
                result.put("code", 403);
                result.put("msg", "无权限访问此订单发票");
                return ResponseEntity.ok(result);
            }

            InvoiceService.InvoiceData invoiceData = createInvoiceFromRealOrder(order);

            // 生成PDF
            byte[] pdfBytes = invoiceService.generateInvoicePdf(invoiceData);

            // 设置响应头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "invoice_" + order.getOrderNumber() + ".pdf");
            headers.setContentLength(pdfBytes.length);

            return new ResponseEntity<>(pdfBytes, headers, HttpStatus.OK);

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 500);
            result.put("msg", "生成发票失败：" + e.getMessage());
            return ResponseEntity.ok(result);
        }
    }

    private InvoiceService.InvoiceData createInvoiceFromRealOrder(Order order) {
        InvoiceService.InvoiceData invoiceData = new InvoiceService.InvoiceData();

        // 基本信息
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        invoiceData.setInvoiceNumber("INV" + order.getId() + now.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        invoiceData.setInvoiceDate(now.format(dateFormatter));
        invoiceData.setOrderNumber(order.getOrderNumber());
        invoiceData.setOrderDate(order.getOrderDate().format(dateFormatter));

        // 客户信息
        User orderUser = order.getUser();
        invoiceData.setCustomerName(orderUser.getNickname() != null ? orderUser.getNickname() : orderUser.getUsername());
        invoiceData.setCustomerPhone(orderUser.getPhone() != null ? orderUser.getPhone() : "未填写");
        invoiceData.setCustomerEmail(orderUser.getEmail() != null ? orderUser.getEmail() : "未填写");

        // 票务信息
        List<InvoiceService.InvoiceData.TicketItem> ticketItems = new ArrayList<>();

        Event event = order.getEvent();
        InvoiceService.InvoiceData.TicketItem ticketItem = new InvoiceService.InvoiceData.TicketItem();
        ticketItem.setEventName(event.getEventName());
        ticketItem.setEventTime(event.getEventDate().format(formatter));
        ticketItem.setPrice(event.getPrice());
        ticketItem.setQuantity(order.getQuantity());
        ticketItem.setSeatInfo(event.getLocation());
        ticketItem.setSubtotal(order.getTotalAmount());

        ticketItems.add(ticketItem);
        invoiceData.setTicketItems(ticketItems);

        // 费用信息
        BigDecimal ticketSubtotal = order.getTotalAmount();
        BigDecimal serviceFee = calculateServiceFee(ticketSubtotal);
        BigDecimal totalAmount = ticketSubtotal.add(serviceFee);

        invoiceData.setSubtotal(ticketSubtotal);
        invoiceData.setServiceFee(serviceFee);
        invoiceData.setTotalAmount(totalAmount);

        // 支付信息
        String paymentMethod = getPaymentMethodByStatus(order.getStatus());
        String paymentStatus = getPaymentStatusText(order.getStatus());
        String paymentTime = getPaymentTimeText(order);

        invoiceData.setPaymentMethod(paymentMethod);
        invoiceData.setPaymentStatus(paymentStatus);
        invoiceData.setPaymentTime(paymentTime);
        invoiceData.setTransactionId("TXN" + order.getId() + order.getOrderDate().format(DateTimeFormatter.ofPattern("yyyyMMdd")));

        // 备注信息
        String remarks = generateRemarksText(order);
        invoiceData.setRemarks(remarks);

        return invoiceData;
    }

    /**
     * 计算服务费
     */
    private BigDecimal calculateServiceFee(BigDecimal ticketAmount) {
        BigDecimal feeRate = new BigDecimal("0.05");
        BigDecimal calculatedFee = ticketAmount.multiply(feeRate);
        BigDecimal minFee = new BigDecimal("10.00");

        return calculatedFee.compareTo(minFee) > 0 ? calculatedFee : minFee;
    }

    /**
     * 根据订单状态获取支付方式
     */
    private String getPaymentMethodByStatus(String status) {
        return switch (status) {
            case "paid", "completed" -> "在线支付";
            case "pending" -> "未支付";
            case "cancelled" -> "已取消";
            default -> "未知";
        };
    }

    /**
     * 获取支付状态文本
     */
    private String getPaymentStatusText(String status) {
        return switch (status) {
            case "paid" -> "已支付";
            case "pending" -> "待支付";
            case "cancelled" -> "已取消";
            case "completed" -> "已完成";
            default -> status;
        };
    }

    /**
     * 获取支付时间文本
     */
    private String getPaymentTimeText(Order order) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        if (order.getPaymentTime() != null) {
            return order.getPaymentTime().format(formatter);
        } else if ("paid".equals(order.getStatus()) || "completed".equals(order.getStatus())) {
            // 如果状态是已支付但没有支付时间，使用订单时间
            return order.getOrderDate().format(formatter);
        } else {
            return "未支付";
        }
    }

    /**
     * 生成备注信息
     */
    private String generateRemarksText(Order order) {
        StringBuilder remarks = new StringBuilder();
        remarks.append("感谢您选择我们的购票服务！");

        if ("paid".equals(order.getStatus()) || "completed".equals(order.getStatus())) {
            remarks.append("请携带有效证件前往活动现场。");
            remarks.append("如需退换票请在演出前24小时联系客服。");
        } else if ("pending".equals(order.getStatus())) {
            remarks.append("请尽快完成支付以确保座位预留。");
        } else if ("cancelled".equals(order.getStatus())) {
            remarks.append("此订单已取消，如有疑问请联系客服。");
        }

        remarks.append("客服电话：123-456-7890");

        return remarks.toString();
    }
}
