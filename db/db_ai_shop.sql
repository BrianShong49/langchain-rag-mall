/*
SQLyog Community v13.2.0 (64 bit)
MySQL - 8.1.0 : Database - db_ai_shop
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`db_ai_shop` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `db_ai_shop`;

/*Table structure for table `t_address` */

DROP TABLE IF EXISTS `t_address`;

CREATE TABLE `t_address` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `name` varchar(50) NOT NULL COMMENT '收货人',
  `phone` varchar(20) NOT NULL COMMENT '联系电话',
  `address` varchar(255) NOT NULL COMMENT '详细地址',
  `is_default` tinyint DEFAULT '0' COMMENT '是否默认:1是0否',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货地址表';

/*Data for the table `t_address` */

insert  into `t_address`(`id`,`user_id`,`name`,`phone`,`address`,`is_default`,`create_time`,`update_time`) values 
(1,1,'张三','14412512412','江苏省南京市xxxx路',1,'2026-06-29 08:52:22','2026-06-29 08:52:22'),
(2,1,'李四','14412412411','测试地址',0,'2026-06-29 08:52:44','2026-06-29 08:52:44');

/*Table structure for table `t_admin` */

DROP TABLE IF EXISTS `t_admin`;

CREATE TABLE `t_admin` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(64) NOT NULL COMMENT '密码(MD5)',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint DEFAULT '1' COMMENT '状态:1正常0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='管理员表';

/*Data for the table `t_admin` */

insert  into `t_admin`(`id`,`username`,`password`,`nickname`,`avatar`,`status`,`create_time`,`update_time`) values 
(1,'admin','25d55ad283aa400af464c76d713c07ad','超级管理员','/uploads/avatar/35cccdc8e6a744a5927e31e160c696f0.png',1,'2026-06-28 20:35:11','2026-06-29 10:03:08');

/*Table structure for table `t_banner` */

DROP TABLE IF EXISTS `t_banner`;

CREATE TABLE `t_banner` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) DEFAULT NULL COMMENT '标题',
  `image` varchar(255) NOT NULL COMMENT '图片地址',
  `link_type` tinyint DEFAULT '0' COMMENT '链接类型:0无1商品2分类',
  `link_id` int DEFAULT '0' COMMENT '链接ID',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` tinyint DEFAULT '1' COMMENT '状态:1启用0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='轮播图表';

/*Data for the table `t_banner` */



/*Table structure for table `t_cart` */

DROP TABLE IF EXISTS `t_cart`;

CREATE TABLE `t_cart` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '购物车ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` int DEFAULT '1' COMMENT '数量',
  `checked` tinyint DEFAULT '1' COMMENT '是否选中:1是0否',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车表';

/*Data for the table `t_cart` */



/*Table structure for table `t_category` */

DROP TABLE IF EXISTS `t_category`;

CREATE TABLE `t_category` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` tinyint DEFAULT '1' COMMENT '状态:1启用0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';

/*Data for the table `t_category` */



/*Table structure for table `t_chat_message` */

DROP TABLE IF EXISTS `t_chat_message`;

CREATE TABLE `t_chat_message` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `session_id` varchar(64) NOT NULL COMMENT '会话ID',
  `role` varchar(20) NOT NULL COMMENT '角色:user/assistant',
  `content` text NOT NULL COMMENT '消息内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_session` (`user_id`,`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI聊天消息表';

/*Data for the table `t_chat_message` */

insert  into `t_chat_message`(`id`,`user_id`,`session_id`,`role`,`content`,`create_time`) values 
(1,1,'session_001','user','请问你们的退换货政策是什么？','2026-06-10 09:00:00'),
(2,1,'session_001','assistant','您好！我们支持7天无理由退换货，商品需保持原包装完好。如有质量问题，可在15天内申请退换。','2026-06-10 09:00:05'),
(3,1,'session_001','user','运费谁承担？','2026-06-10 09:01:00'),
(4,1,'session_001','assistant','非质量问题退换货，运费由买家承担；质量问题退换货，运费由我们承担。','2026-06-10 09:01:05'),
(5,1,'session_ddf85aa1be7f','user','你好，怎么退货？','2026-06-29 08:25:39'),
(6,1,'session_ddf85aa1be7f','assistant','您好！感谢您的咨询。关于退货流程，一般操作如下：\n1️⃣ 进入小程序「我的」-「我的订单」，找到需退货的订单；\n2️⃣ 点击「申请售后/退货」，选择原因并按提示提交；\n3️⃣ 审核通过后，将商品寄回并填写物流单号；\n4️⃣ 商家签收确认无误后，退款将原路退回。\n\n? 温馨提示：退货商品需保持完好、配件齐全，且通常需在签收后7天内申请。\n\n由于当前暂无具体订单信息，如操作中遇到问题或订单状态特殊，建议您直接点击小程序内的「联系人工客服」，我们将为您快速核实并一对一处理。祝您生活愉快！','2026-06-29 08:25:59'),
(7,1,'session_ce51cbfc0a30','user','关于商品与页面描述不符','2026-06-29 09:00:22'),
(8,1,'session_ce51cbfc0a30','assistant','亲，感谢您的反馈！经核实，您指出的差异确实存在，这是我们页面编辑上的失误，非常抱歉给您造成了误解。您可以直接申请退货退款，来回运费将由我们全额承担。我们会尽快修正页面描述，感谢您的监督！如需协助操作或有其他问题，请随时告诉我哦~','2026-06-29 09:00:38'),
(9,1,'session_ce51cbfc0a30','user','购买后商品降价了，怎么回事','2026-06-29 09:01:26'),
(10,1,'session_ce51cbfc0a30','assistant','亲，很抱歉没能让您在最优惠的时候下单。平台商品价格会随市场促销活动和库存情况动态调整哦。\n\n? **为您提供的解决方案：**\n- **购买7天内**：我们可以为您申请**价格保护**，核实后直接退还差价。\n- **购买超过7天**：建议您按当前优惠价重新下单，同时将原订单申请退货退款（符合平台退换货规则即可）。\n\n您可以提供一下**订单号**，我马上为您查询具体购买时间并协助办理价保或退换流程，您看可以吗？','2026-06-29 09:01:39');

/*Table structure for table `t_knowledge_file` */

DROP TABLE IF EXISTS `t_knowledge_file`;

CREATE TABLE `t_knowledge_file` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '知识库文件ID',
  `file_name` varchar(255) NOT NULL COMMENT '文件名',
  `file_type` varchar(20) NOT NULL COMMENT '文件类型:txt/doc/pdf/markdown',
  `file_path` varchar(500) NOT NULL COMMENT '文件路径',
  `file_size` int DEFAULT '0' COMMENT '文件大小(字节)',
  `chunk_count` int DEFAULT '0' COMMENT '分块数量',
  `status` tinyint DEFAULT '0' COMMENT '状态:0待处理1已向量化2失败',
  `error_msg` varchar(500) DEFAULT NULL COMMENT '错误信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='知识库文件表';

/*Data for the table `t_knowledge_file` */

insert  into `t_knowledge_file`(`id`,`file_name`,`file_type`,`file_path`,`file_size`,`chunk_count`,`status`,`error_msg`,`create_time`,`update_time`) values 
(4,'常见商品问题.md','markdown','D:/uploads14/knowledge/5d2c51896a424d25879b91569cb467f0.md',4445,4,1,NULL,'2026-06-29 08:27:00','2026-06-29 08:27:01'),
(5,'常见售后问题.docx','doc','D:/uploads14/knowledge/0f2caba5851948d4ab9c929f788bead2.docx',15111,6,1,NULL,'2026-06-29 08:27:22','2026-06-29 08:27:22'),
(6,'常见物流问题.txt','txt','D:/uploads14/knowledge/3d6d8bd179824740914928ae72d85434.txt',3207,3,1,NULL,'2026-06-29 08:27:26','2026-06-29 08:27:27'),
(7,'其他问题.pdf','pdf','D:/uploads14/knowledge/d9b6195096ca41338190be2333104105.pdf',473663,6,1,NULL,'2026-06-29 08:27:30','2026-06-29 08:27:30');

/*Table structure for table `t_order` */

DROP TABLE IF EXISTS `t_order`;

CREATE TABLE `t_order` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) NOT NULL COMMENT '订单编号',
  `user_id` int NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额',
  `pay_amount` decimal(10,2) NOT NULL COMMENT '实付金额',
  `status` tinyint DEFAULT '0' COMMENT '状态:0待支付1已支付2已发货3已完成4已取消',
  `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `receiver_address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';

/*Data for the table `t_order` */



/*Table structure for table `t_order_item` */

DROP TABLE IF EXISTS `t_order_item`;

CREATE TABLE `t_order_item` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '订单明细ID',
  `order_id` int NOT NULL COMMENT '订单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片',
  `price` decimal(10,2) NOT NULL COMMENT '单价',
  `quantity` int NOT NULL COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL COMMENT '小计',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';

/*Data for the table `t_order_item` */


/*Table structure for table `t_product` */

DROP TABLE IF EXISTS `t_product`;

CREATE TABLE `t_product` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `category_id` int NOT NULL COMMENT '分类ID',
  `name` varchar(100) NOT NULL COMMENT '商品名称',
  `description` text COMMENT '商品描述',
  `price` decimal(10,2) NOT NULL COMMENT '商品价格',
  `stock` int DEFAULT '0' COMMENT '库存',
  `image` varchar(255) DEFAULT NULL COMMENT '商品主图',
  `images` text COMMENT '商品图片(JSON数组)',
  `sales` int DEFAULT '0' COMMENT '销量',
  `status` tinyint DEFAULT '1' COMMENT '状态:1上架0下架',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表';

/*Data for the table `t_product` */



/*Table structure for table `t_user` */

DROP TABLE IF EXISTS `t_user`;

CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(64) NOT NULL COMMENT '密码(MD5)',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint DEFAULT '1' COMMENT '状态:1正常0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

/*Data for the table `t_user` */

insert  into `t_user`(`id`,`username`,`password`,`phone`,`nickname`,`avatar`,`status`,`create_time`,`update_time`) values 
(1,'user001','e10adc3949ba59abbe56e057f20f883e','13800000001','张三','/uploads/avatar/33737e5abb584c928f6a8cefe96b5a63.jpg',1,'2026-06-28 20:35:11','2026-06-29 08:43:38'),
(2,'user002','e10adc3949ba59abbe56e057f20f883e','13800000002','李四',NULL,1,'2026-06-28 20:35:11','2026-06-28 20:35:11'),
(3,'user003','e10adc3949ba59abbe56e057f20f883e','13800000003','王五',NULL,1,'2026-06-28 20:35:11','2026-06-28 20:35:11'),
(4,'cc','e10adc3949ba59abbe56e057f20f883e',NULL,'cc',NULL,1,'2026-06-29 08:32:58','2026-06-29 08:32:58'),
(5,'jack','25d55ad283aa400af464c76d713c07ad','15541214122','杰克2','/uploads/avatar/ea6f59026ceb43e1a6147d87eee0d9b0.jpg',1,'2026-06-29 08:39:00','2026-06-29 08:42:49');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
