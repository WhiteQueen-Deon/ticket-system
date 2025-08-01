package com.easyticket;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Easy Ticket System 主启动类
 * 
 * @author hxp
 * @version 1.0.0
 */
@SpringBootApplication
@MapperScan("com.easyticket.mapper")
@EnableScheduling
@EnableTransactionManagement
public class EasyTicketApplication {

    public static void main(String[] args) {
        System.out.println("=== Easy Ticket System Starting ===");
        SpringApplication.run(EasyTicketApplication.class, args);
        System.out.println("=== Easy Ticket System Started Successfully ===");
    }
} 
