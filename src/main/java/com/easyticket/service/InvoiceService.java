package com.easyticket.service;

import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class InvoiceService {

    public byte[] generateInvoicePdf(InvoiceData invoiceData) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        // 创建PDF文档
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc);

        try {
            // 设置中文字体
            PdfFont font = PdfFontFactory.createFont("STSong-Light", "UniGB-UCS2-H", PdfFontFactory.EmbeddingStrategy.PREFER_EMBEDDED);
            document.setFont(font);

            // 标题
            Paragraph title = new Paragraph("购票发票")
                    .setFontSize(20)
                    .setBold()
                    .setTextAlignment(TextAlignment.CENTER)
                    .setMarginBottom(20);
            document.add(title);

            // 发票信息表格
            Table infoTable = new Table(UnitValue.createPercentArray(new float[]{1, 2, 1, 2}))
                    .setWidth(UnitValue.createPercentValue(100))
                    .setMarginBottom(20);

            infoTable.addCell(createCell("发票号码:", true));
            infoTable.addCell(createCell(invoiceData.getInvoiceNumber(), false));
            infoTable.addCell(createCell("开票日期:", true));
            infoTable.addCell(createCell(invoiceData.getInvoiceDate(), false));

            infoTable.addCell(createCell("订单号码:", true));
            infoTable.addCell(createCell(invoiceData.getOrderNumber(), false));
            infoTable.addCell(createCell("购买日期:", true));
            infoTable.addCell(createCell(invoiceData.getOrderDate(), false));

            infoTable.addCell(createCell("客户姓名:", true));
            infoTable.addCell(createCell(invoiceData.getCustomerName(), false));
            infoTable.addCell(createCell("联系电话:", true));
            infoTable.addCell(createCell(invoiceData.getCustomerPhone(), false));

            document.add(infoTable);

            // 购票详情标题
            Paragraph detailTitle = new Paragraph("购票详情")
                    .setFontSize(16)
                    .setBold()
                    .setMarginBottom(10);
            document.add(detailTitle);

            // 购票详情表格
            Table detailTable = new Table(UnitValue.createPercentArray(new float[]{3, 2, 1, 1, 1, 1}))
                    .setWidth(UnitValue.createPercentValue(100))
                    .setMarginBottom(20);

            // 表头
            detailTable.addHeaderCell(createHeaderCell("活动名称"));
            detailTable.addHeaderCell(createHeaderCell("活动时间"));
            detailTable.addHeaderCell(createHeaderCell("票价"));
            detailTable.addHeaderCell(createHeaderCell("数量"));
            detailTable.addHeaderCell(createHeaderCell("座位"));
            detailTable.addHeaderCell(createHeaderCell("小计"));

            // 票务信息
            for (InvoiceData.TicketItem item : invoiceData.getTicketItems()) {
                detailTable.addCell(createCell(item.getEventName(), false));
                detailTable.addCell(createCell(item.getEventTime(), false));
                detailTable.addCell(createCell("￥" + item.getPrice().toString(), false));
                detailTable.addCell(createCell(item.getQuantity().toString(), false));
                detailTable.addCell(createCell(item.getSeatInfo(), false));
                detailTable.addCell(createCell("￥" + item.getSubtotal().toString(), false));
            }

            document.add(detailTable);

            // 费用汇总
            Table summaryTable = new Table(UnitValue.createPercentArray(new float[]{3, 1}))
                    .setWidth(UnitValue.createPercentValue(50))
                    .setHorizontalAlignment(com.itextpdf.layout.properties.HorizontalAlignment.RIGHT)
                    .setMarginBottom(20);

            summaryTable.addCell(createCell("票价小计:", true));
            summaryTable.addCell(createCell("￥" + invoiceData.getSubtotal().toString(), false));

            summaryTable.addCell(createCell("服务费:", true));
            summaryTable.addCell(createCell("￥" + invoiceData.getServiceFee().toString(), false));

            summaryTable.addCell(createCell("总金额:", true).setBackgroundColor(ColorConstants.LIGHT_GRAY));
            summaryTable.addCell(createCell("￥" + invoiceData.getTotalAmount().toString(), true).setBackgroundColor(ColorConstants.LIGHT_GRAY));

            document.add(summaryTable);

            // 支付信息
            Paragraph paymentTitle = new Paragraph("支付信息")
                    .setFontSize(16)
                    .setBold()
                    .setMarginBottom(10);
            document.add(paymentTitle);

            Table paymentTable = new Table(UnitValue.createPercentArray(new float[]{1, 2, 1, 2}))
                    .setWidth(UnitValue.createPercentValue(100))
                    .setMarginBottom(20);

            paymentTable.addCell(createCell("支付方式:", true));
            paymentTable.addCell(createCell(invoiceData.getPaymentMethod(), false));
            paymentTable.addCell(createCell("支付状态:", true));
            paymentTable.addCell(createCell(invoiceData.getPaymentStatus(), false));

            paymentTable.addCell(createCell("支付时间:", true));
            paymentTable.addCell(createCell(invoiceData.getPaymentTime(), false));
            paymentTable.addCell(createCell("交易流水号:", true));
            paymentTable.addCell(createCell(invoiceData.getTransactionId(), false));

            document.add(paymentTable);

            // 备注信息
            if (invoiceData.getRemarks() != null && !invoiceData.getRemarks().isEmpty()) {
                Paragraph remarksTitle = new Paragraph("备注信息")
                        .setFontSize(16)
                        .setBold()
                        .setMarginBottom(10);
                document.add(remarksTitle);

                Paragraph remarks = new Paragraph(invoiceData.getRemarks())
                        .setFontSize(12)
                        .setMarginBottom(20);
                document.add(remarks);
            }

            // 底部信息
            Paragraph footer = new Paragraph("本发票由 Easy Ticket System 自动生成，如有疑问请联系客服。")
                    .setFontSize(10)
                    .setTextAlignment(TextAlignment.CENTER)
                    .setMarginTop(30);
            document.add(footer);

        } finally {
            document.close();
        }

        return baos.toByteArray();
    }

    private Cell createCell(String content, boolean bold) {
        Cell cell = new Cell().add(new Paragraph(content).setFontSize(12));
        if (bold) {
            cell.setBold();
        }
        return cell.setPadding(5);
    }

    private Cell createHeaderCell(String content) {
        return new Cell().add(new Paragraph(content).setFontSize(12).setBold())
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER)
                .setPadding(8);
    }

    // 发票数据传输对象
    public static class InvoiceData {
        private String invoiceNumber;
        private String invoiceDate;
        private String orderNumber;
        private String orderDate;
        private String customerName;
        private String customerPhone;
        private String customerEmail;
        private BigDecimal subtotal;
        private BigDecimal serviceFee;
        private BigDecimal totalAmount;
        private String paymentMethod;
        private String paymentStatus;
        private String paymentTime;
        private String transactionId;
        private String remarks;
        private java.util.List<TicketItem> ticketItems;

        // 构造函数
        public InvoiceData() {}

        public String getInvoiceNumber() { return invoiceNumber; }
        public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

        public String getInvoiceDate() { return invoiceDate; }
        public void setInvoiceDate(String invoiceDate) { this.invoiceDate = invoiceDate; }

        public String getOrderNumber() { return orderNumber; }
        public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }

        public String getOrderDate() { return orderDate; }
        public void setOrderDate(String orderDate) { this.orderDate = orderDate; }

        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }

        public String getCustomerPhone() { return customerPhone; }
        public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

        public String getCustomerEmail() { return customerEmail; }
        public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

        public BigDecimal getSubtotal() { return subtotal; }
        public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

        public BigDecimal getServiceFee() { return serviceFee; }
        public void setServiceFee(BigDecimal serviceFee) { this.serviceFee = serviceFee; }

        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

        public String getPaymentMethod() { return paymentMethod; }
        public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

        public String getPaymentStatus() { return paymentStatus; }
        public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

        public String getPaymentTime() { return paymentTime; }
        public void setPaymentTime(String paymentTime) { this.paymentTime = paymentTime; }

        public String getTransactionId() { return transactionId; }
        public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

        public String getRemarks() { return remarks; }
        public void setRemarks(String remarks) { this.remarks = remarks; }

        public java.util.List<TicketItem> getTicketItems() { return ticketItems; }
        public void setTicketItems(java.util.List<TicketItem> ticketItems) { this.ticketItems = ticketItems; }

        // 票务项目内部类
        public static class TicketItem {
            private String eventName;
            private String eventTime;
            private BigDecimal price;
            private Integer quantity;
            private String seatInfo;
            private BigDecimal subtotal;

            public TicketItem() {}

            public TicketItem(String eventName, String eventTime, BigDecimal price, Integer quantity, String seatInfo) {
                this.eventName = eventName;
                this.eventTime = eventTime;
                this.price = price;
                this.quantity = quantity;
                this.seatInfo = seatInfo;
                this.subtotal = price.multiply(new BigDecimal(quantity));
            }

            // Getters and Setters
            public String getEventName() { return eventName; }
            public void setEventName(String eventName) { this.eventName = eventName; }

            public String getEventTime() { return eventTime; }
            public void setEventTime(String eventTime) { this.eventTime = eventTime; }

            public BigDecimal getPrice() { return price; }
            public void setPrice(BigDecimal price) { this.price = price; }

            public Integer getQuantity() { return quantity; }
            public void setQuantity(Integer quantity) { this.quantity = quantity; }

            public String getSeatInfo() { return seatInfo; }
            public void setSeatInfo(String seatInfo) { this.seatInfo = seatInfo; }

            public BigDecimal getSubtotal() { return subtotal; }
            public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
        }
    }
}
