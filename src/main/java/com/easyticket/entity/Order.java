package com.easyticket.entity;

import com.fasterxml.jackson.annotation.JsonFormat;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

import javax.persistence.*; // 新增

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "orderNumber cannot be empty")
    private String orderNumber;

//    private Long userId;
//
//    private Long eventId;

    @ManyToOne
    private User user;

    @ManyToOne
    private Event event;

    @NotNull(message = "quantity cannot be empty")
    @Positive(message = "quantity must be greater than 0")
    private Integer quantity;

    @NotNull(message = "totalAmount cannot be empty")
    @Positive(message = "totalAmount must be greater than 0")
    private BigDecimal totalAmount;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime orderDate;
    private String status = "pending";
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime paymentTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime cancellationTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime confirmationTime;

    private String invoicePath;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime createTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+0")
    private LocalDateTime updateTime;


    public Order() {
        this.orderDate = LocalDateTime.now();
        this.createTime = LocalDateTime.now();
        this.updateTime = LocalDateTime.now();
        this.status = "pending";
    }

    public Order(String orderNumber, Long userId, Long eventId,
                 Integer quantity, BigDecimal totalAmount) {
        this();
        this.orderNumber = orderNumber;
//        this.userId = userId;
//        this.eventId = eventId;
        this.quantity = quantity;
        this.totalAmount = totalAmount;
    }

    public Order(String orderNumber, User user, Event event,
                 Integer quantity, BigDecimal totalAmount) {
        this();
        this.orderNumber = orderNumber;
        this.user = user;
        this.event = event;
//        if (user != null) {
//            this.userId = user.getId();
//        }
//        if (event != null) {
//            this.eventId = event.getId();
//        }
        this.quantity = quantity;
        this.totalAmount = totalAmount;
    }

    public enum OrderStatus {
        PENDING("pending", "pending"),
        PAID("paid", "paid"),
        CANCELLED("cancelled", "cancelled"),
        COMPLETED("completed", "completed");

        private final String code;
        private final String description;

        OrderStatus(String code, String description) {
            this.code = code;
            this.description = description;
        }

        public String getCode() {
            return code;
        }

        public String getDescription() {
            return description;
        }

        public static OrderStatus fromCode(String code) {
            for (OrderStatus status : values()) {
                if (status.code.equals(code)) {
                    return status;
                }
            }
            return PENDING;
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }

//    public Long getUserId() {
//        return userId;
//    }
//
//    public void setUserId(Long userId) {
//        this.userId = userId;
//    }
//
//    public Long getEventId() {
//        return eventId;
//    }
//
//    public void setEventId(Long eventId) {
//        this.eventId = eventId;
//    }

    @Transient
    public Long getUserId() {
        return user != null ? user.getId() : null;
    }

    @Transient
    public void setUserId(Long userId) {
        if (this.user == null) this.user = new User();
        this.user.setId(userId);
    }

    @Transient
    public Long getEventId() {
        return event != null ? event.getId() : null;
    }

    @Transient
    public void setEventId(Long eventId) {
        if (this.event == null) this.event = new Event();
        this.event.setId(eventId);
    }


    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
//        if (user != null) {
//            this.userId = user.getId();
//        }
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
//        if (event != null) {
//            this.eventId = event.getId();
//        }
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public LocalDateTime getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.orderDate = orderDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getPaymentTime() {
        return paymentTime;
    }

    public void setPaymentTime(LocalDateTime paymentTime) {
        this.paymentTime = paymentTime;
    }

    public LocalDateTime getCancellationTime() {
        return cancellationTime;
    }

    public void setCancellationTime(LocalDateTime cancellationTime) {
        this.cancellationTime = cancellationTime;
    }

    public LocalDateTime getConfirmationTime() {
        return confirmationTime;
    }

    public void setConfirmationTime(LocalDateTime confirmationTime) {
        this.confirmationTime = confirmationTime;
    }

    public String getInvoicePath() {
        return invoicePath;
    }

    public void setInvoicePath(String invoicePath) {
        this.invoicePath = invoicePath;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public boolean canCancel() {
        return "pending".equals(status);
    }

    public boolean canPay() {
        return "pending".equals(status);
    }

    public boolean canConfirm() {
        return "paid".equals(status);
    }

    public boolean isPaid() {
        return "paid".equals(status) || "completed".equals(status);
    }

    public boolean isExpired(int timeoutMinutes) {
        if (!"pending".equals(status)) {
            return false;
        }
        LocalDateTime expireTime = orderDate.plusMinutes(timeoutMinutes);
        return LocalDateTime.now().isAfter(expireTime);
    }

    public String getStatusDescription() {
        OrderStatus orderStatus = OrderStatus.fromCode(this.status);
        return orderStatus.getDescription();
    }

    public void pay() {
        if (canPay()) {
            this.status = "paid";
            this.paymentTime = LocalDateTime.now();
            this.updateTime = LocalDateTime.now();
        }
    }

    public void cancel() {
        if (canCancel()) {
            this.status = "cancelled";
            this.cancellationTime = LocalDateTime.now();
            this.updateTime = LocalDateTime.now();
        }
    }

    public void confirm() {
        if (canConfirm()) {
            this.status = "completed";
            this.confirmationTime = LocalDateTime.now();
            this.updateTime = LocalDateTime.now();
        }
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Order order = (Order) obj;
        return Objects.equals(id, order.id) &&
               Objects.equals(orderNumber, order.orderNumber);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, orderNumber);
    }

    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", orderNumber='" + orderNumber + '\'' +
//                ", userId=" + userId +
//                ", eventId=" + eventId +
                ", quantity=" + quantity +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                ", orderDate=" + orderDate +
                '}';
    }
}
