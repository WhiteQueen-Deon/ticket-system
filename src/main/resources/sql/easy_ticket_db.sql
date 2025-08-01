SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for events
-- ----------------------------
DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '场次ID',
  `event_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '场次名称',
  `event_date` datetime NOT NULL COMMENT '场次时间',
  `location` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '场次地点',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '场次描述',
  `price` decimal(10,2) NOT NULL COMMENT '票价',
  `total_quantity` int NOT NULL COMMENT '总票量',
  `available_quantity` int NOT NULL COMMENT '剩余票量',
  `manager_id` bigint NOT NULL COMMENT '管理该场次的经理ID',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_event_name` (`event_name`),
  KEY `idx_event_date` (`event_date`),
  KEY `idx_manager_id` (`manager_id`),
  KEY `idx_available_quantity` (`available_quantity`),
  KEY `idx_events_status` (`status`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='场次表';

-- ----------------------------
-- Records of events
-- ----------------------------
BEGIN;
INSERT INTO `events` (`id`, `event_name`, `event_date`, `location`, `description`, `price`, `total_quantity`, `available_quantity`, `manager_id`, `status`, `create_time`, `update_time`) VALUES (1, '音乐会 - 古典之夜', '2024-02-01 19:30:00', '音乐厅', '一场精彩的古典音乐演出', 150.00, 200, 198, 2, 'ACTIVE', '2025-06-09 22:33:08', '2025-06-10 14:22:30');
INSERT INTO `events` (`id`, `event_name`, `event_date`, `location`, `description`, `price`, `total_quantity`, `available_quantity`, `manager_id`, `status`, `create_time`, `update_time`) VALUES (2, '话剧 - 哈姆雷特', '2024-02-05 20:00:00', '剧院', '莎士比亚经典话剧', 120.00, 150, 149, 2, 'ACTIVE', '2025-06-09 22:33:08', '2025-06-09 22:33:08');
INSERT INTO `events` (`id`, `event_name`, `event_date`, `location`, `description`, `price`, `total_quantity`, `available_quantity`, `manager_id`, `status`, `create_time`, `update_time`) VALUES (3, '电影 - 科幻巨作', '2024-02-10 14:30:00', '电影院', '最新科幻大片首映', 80.00, 300, 297, 3, 'ACTIVE', '2025-06-09 22:33:08', '2025-06-09 22:33:08');
INSERT INTO `events` (`id`, `event_name`, `event_date`, `location`, `description`, `price`, `total_quantity`, `available_quantity`, `manager_id`, `status`, `create_time`, `update_time`) VALUES (4, '演唱会 - 流行之星', '2024-02-15 19:00:00', '体育馆', '知名歌手演唱会', 200.00, 500, 500, 3, 'ACTIVE', '2025-06-09 22:33:08', '2025-06-09 22:33:08');
INSERT INTO `events` (`id`, `event_name`, `event_date`, `location`, `description`, `price`, `total_quantity`, `available_quantity`, `manager_id`, `status`, `create_time`, `update_time`) VALUES (6, '测试1', '2025-06-12 00:00:00', '1213', '321', 12.00, 333, 330, 1, 'INACTIVE', '2025-06-10 14:27:03', '2025-06-10 17:12:15');
COMMIT;

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `event_id` bigint NOT NULL COMMENT '场次ID',
  `quantity` int NOT NULL COMMENT '购票数量',
  `total_amount` decimal(10,2) NOT NULL COMMENT '总金额',
  `order_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订单时间',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '订单状态（pending：待支付，paid：已支付，cancelled：已取消，completed：已完成）',
  `payment_time` datetime DEFAULT NULL COMMENT '支付时间',
  `cancellation_time` datetime DEFAULT NULL COMMENT '取消时间',
  `confirmation_time` datetime DEFAULT NULL COMMENT '确认时间',
  `invoice_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'PDF发票路径',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `idx_order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_event_id` (`event_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order_date` (`order_date`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ----------------------------
-- Records of orders
-- ----------------------------
BEGIN;
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (1, 'ORD20240101001', 4, 1, 2, 300.00, '2025-06-09 22:33:08', 'completed', NULL, NULL, NULL, NULL, '2025-06-09 22:33:08', '2025-06-10 14:12:20');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (2, 'ORD20240101002', 5, 2, 1, 120.00, '2025-06-09 22:33:08', 'pending', NULL, NULL, NULL, NULL, '2025-06-09 22:33:08', '2025-06-09 22:33:08');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (3, 'ORD20240101003', 4, 3, 3, 240.00, '2025-06-09 22:33:08', 'completed', NULL, NULL, NULL, NULL, '2025-06-09 22:33:08', '2025-06-09 22:33:08');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (4, 'ET1749536832495517', 1, 6, 1, 12.00, '2025-06-10 14:27:12', 'paid', '2025-06-10 14:51:59', NULL, NULL, NULL, '2025-06-10 14:27:12', '2025-06-10 14:51:58');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (5, 'ET1749541008649696', 4, 6, 1, 12.00, '2025-06-10 15:36:49', 'paid', '2025-06-10 15:36:53', NULL, NULL, NULL, '2025-06-10 15:36:48', '2025-06-10 15:36:53');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (6, 'ET1749543531400043', 1, 6, 1, 12.00, '2025-06-10 16:18:51', 'paid', '2025-06-10 16:22:21', NULL, NULL, NULL, '2025-06-10 16:18:51', '2025-06-10 16:22:20');
INSERT INTO `orders` (`id`, `order_number`, `user_id`, `event_id`, `quantity`, `total_amount`, `order_date`, `status`, `payment_time`, `cancellation_time`, `confirmation_time`, `invoice_path`, `create_time`, `update_time`) VALUES (7, 'ET1749543774594274', 1, 6, 1, 12.00, '2025-06-10 16:22:55', 'cancelled', NULL, NULL, NULL, NULL, '2025-06-10 16:22:54', '2025-06-10 16:59:44');
COMMIT;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（BCrypt加密）',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `enabled` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否激活（0：未激活，1：已激活）',
  `activation_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '激活令牌',
  `roles` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ROLE_CUSTOMER' COMMENT '角色（逗号分隔）',
  `registration_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO `users` (`id`, `username`, `password`, `email`, `enabled`, `activation_token`, `roles`, `registration_date`, `nickname`, `phone`, `create_time`, `update_time`) VALUES (1, 'admin', '$2a$10$NRzvkF7p2dV/VryckZ0A0uo.JCRqx3vxSp1hGOZIwawshuGaI02yy', 'admin@easyticket.com', 1, NULL, 'ROLE_ADMIN', '2025-06-09 22:33:07', '系统管理员', '', '2025-06-09 22:33:07', '2025-06-10 18:34:24');
INSERT INTO `users` (`id`, `username`, `password`, `email`, `enabled`, `activation_token`, `roles`, `registration_date`, `nickname`, `phone`, `create_time`, `update_time`) VALUES (2, 'manager1', '$2a$10$NRzvkF7p2dV/VryckZ0A0uo.JCRqx3vxSp1hGOZIwawshuGaI02yy', 'manager1@easyticket.com', 1, NULL, 'ROLE_MANAGER', '2025-06-09 22:33:07', '场次经理1', NULL, '2025-06-09 22:33:07', '2025-06-10 18:34:23');
INSERT INTO `users` (`id`, `username`, `password`, `email`, `enabled`, `activation_token`, `roles`, `registration_date`, `nickname`, `phone`, `create_time`, `update_time`) VALUES (3, 'manager2', '$2a$10$NRzvkF7p2dV/VryckZ0A0uo.JCRqx3vxSp1hGOZIwawshuGaI02yy', 'manager2@easyticket.com', 1, NULL, 'ROLE_MANAGER', '2025-06-09 22:33:07', '场次经理2', NULL, '2025-06-09 22:33:07', '2025-06-10 18:34:21');
INSERT INTO `users` (`id`, `username`, `password`, `email`, `enabled`, `activation_token`, `roles`, `registration_date`, `nickname`, `phone`, `create_time`, `update_time`) VALUES (4, 'customer1', '$2a$10$shGqpITxhzuAf5jI22TwgOETF0ZT9i.s2Hem6FphgSZFLnz4htOr6', 'customer1@easyticket.com', 1, NULL, 'ROLE_CUSTOMER', '2025-06-10 15:32:52', '测试客户', '', '2025-06-09 22:33:08', '2025-06-11 11:06:27');
INSERT INTO `users` (`id`, `username`, `password`, `email`, `enabled`, `activation_token`, `roles`, `registration_date`, `nickname`, `phone`, `create_time`, `update_time`) VALUES (5, 'customer2', '$2a$10$NRzvkF7p2dV/VryckZ0A0uo.JCRqx3vxSp1hGOZIwawshuGaI02yy', 'customer2@easyticket.com', 1, NULL, 'ROLE_CUSTOMER', '2025-06-09 22:33:08', '测试客户2', NULL, '2025-06-09 22:33:08', '2025-06-10 18:34:19');
COMMIT;

-- ----------------------------
-- View structure for event_summary
-- ----------------------------
DROP VIEW IF EXISTS `event_summary`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `event_summary` AS select `e`.`id` AS `id`,`e`.`event_name` AS `event_name`,`e`.`event_date` AS `event_date`,`e`.`location` AS `location`,`e`.`price` AS `price`,`e`.`total_quantity` AS `total_quantity`,`e`.`available_quantity` AS `available_quantity`,(`e`.`total_quantity` - `e`.`available_quantity`) AS `sold_quantity`,`u`.`username` AS `manager_name`,`u`.`nickname` AS `manager_nickname` from (`events` `e` left join `users` `u` on((`e`.`manager_id` = `u`.`id`)));

-- ----------------------------
-- View structure for order_summary
-- ----------------------------
DROP VIEW IF EXISTS `order_summary`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `order_summary` AS select `o`.`id` AS `id`,`o`.`order_number` AS `order_number`,`u`.`username` AS `username`,`u`.`nickname` AS `nickname`,`e`.`event_name` AS `event_name`,`e`.`event_date` AS `event_date`,`o`.`quantity` AS `quantity`,`o`.`total_amount` AS `total_amount`,`o`.`status` AS `status`,`o`.`order_date` AS `order_date`,`o`.`payment_time` AS `payment_time` from ((`orders` `o` left join `users` `u` on((`o`.`user_id` = `u`.`id`))) left join `events` `e` on((`o`.`event_id` = `e`.`id`)));

SET FOREIGN_KEY_CHECKS = 1;
