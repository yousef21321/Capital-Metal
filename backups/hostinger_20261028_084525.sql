-- MySQL dump 10.13  Distrib 8.0.46, for Linux (aarch64)
--
-- Host: 127.0.0.1    Database: u176871744_CapitalMetal
-- ------------------------------------------------------
-- Server version	11.8.9-MariaDB-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_logs_user_id_foreign` (`user_id`),
  CONSTRAINT `activity_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `full_name` varchar(150) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `governorate` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `address_line` text DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_user_id_foreign` (`user_id`),
  CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,2,'Regular User','01000000002','Egypt','Cairo','New Cairo','123 Main Street, Apartment 5','11835',1,NULL),(2,1,'youssef','10180259','Egypt','cairo','matarai','37 streat 7masimi kablat','145459',1,NULL);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `affiliate_earnings`
--

DROP TABLE IF EXISTS `affiliate_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `affiliate_earnings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `affiliate_id` bigint(20) unsigned NOT NULL,
  `order_id` bigint(20) unsigned NOT NULL,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `amount` double NOT NULL DEFAULT 0,
  `status` varchar(50) NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `affiliate_earnings_affiliate_id_order_id_unique` (`affiliate_id`,`order_id`),
  KEY `affiliate_earnings_order_id_foreign` (`order_id`),
  CONSTRAINT `affiliate_earnings_affiliate_id_foreign` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `affiliate_earnings_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `affiliate_earnings`
--

LOCK TABLES `affiliate_earnings` WRITE;
/*!40000 ALTER TABLE `affiliate_earnings` DISABLE KEYS */;
/*!40000 ALTER TABLE `affiliate_earnings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `affiliates`
--

DROP TABLE IF EXISTS `affiliates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `affiliates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `referral_code` varchar(100) DEFAULT NULL,
  `commission_percentage` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `affiliates_user_id_unique` (`user_id`),
  UNIQUE KEY `affiliates_referral_code_unique` (`referral_code`),
  CONSTRAINT `affiliates_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `affiliates`
--

LOCK TABLES `affiliates` WRITE;
/*!40000 ALTER TABLE `affiliates` DISABLE KEYS */;
/*!40000 ALTER TABLE `affiliates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('capital_metal_cache_live_egp_to_usd_rate','s:8:\"49.11596\";',1783198212);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_analytics`
--

DROP TABLE IF EXISTS `cart_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_analytics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `total_value` decimal(12,2) DEFAULT NULL,
  `is_converted` tinyint(1) NOT NULL DEFAULT 0,
  `abandoned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cart_analytics_cart_id_unique` (`cart_id`),
  KEY `cart_analytics_user_id_foreign` (`user_id`),
  CONSTRAINT `cart_analytics_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_analytics_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_analytics`
--

LOCK TABLES `cart_analytics` WRITE;
/*!40000 ALTER TABLE `cart_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `license_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_items_cart_id_foreign` (`cart_id`),
  KEY `cart_items_product_id_foreign` (`product_id`),
  CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
INSERT INTO `cart_items` VALUES (15,1,1,2,NULL),(16,1,2,1,NULL),(21,14,1,1,NULL);
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `guest_token` varchar(100) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `carts_user_id_unique` (`user_id`),
  UNIQUE KEY `carts_guest_token_unique` (`guest_token`),
  CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` VALUES (1,2,NULL,NULL,'2026-06-25 20:43:32','2026-06-25 20:43:32'),(2,1,NULL,NULL,'2026-06-25 20:43:45','2026-06-25 20:43:45'),(3,11,NULL,NULL,'2026-06-25 22:56:13','2026-06-25 22:56:13'),(4,6,NULL,NULL,'2026-06-25 23:05:54','2026-06-25 23:05:54'),(5,8,NULL,NULL,'2026-06-26 11:12:30','2026-06-26 11:12:30'),(6,5,NULL,NULL,'2026-06-26 12:23:28','2026-06-26 12:23:28'),(7,4,NULL,NULL,'2026-06-29 12:26:12','2026-06-29 12:26:12'),(8,14,NULL,NULL,'2026-07-04 11:26:27','2026-07-04 11:26:27'),(9,NULL,NULL,NULL,'2026-07-04 19:41:14','2026-07-04 19:41:14'),(10,NULL,NULL,NULL,'2026-07-04 19:43:17','2026-07-04 19:43:17'),(11,NULL,NULL,NULL,'2026-07-04 19:43:21','2026-07-04 19:43:21'),(12,NULL,'guest_abc123',NULL,'2026-07-04 19:43:37','2026-07-04 19:43:37'),(13,NULL,'guest_test_order',NULL,'2026-07-04 19:43:44','2026-07-04 19:43:44'),(14,NULL,'guest_1d122056-9197-445d-b290-be5908668466',NULL,'2026-07-04 19:44:30','2026-07-04 19:44:30');
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_submissions`
--

DROP TABLE IF EXISTS `contact_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_submissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_submissions`
--

LOCK TABLES `contact_submissions` WRITE;
/*!40000 ALTER TABLE `contact_submissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `discount_type` varchar(50) NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT NULL,
  `expiry_date` timestamp NULL DEFAULT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `used_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupons_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES (1,'WELCOME10','percentage',10.00,NULL,'2026-09-25 23:26:13',100,1,'2026-06-25 23:26:13','2026-06-25 23:27:49'),(2,'SAVE50','fixed',50.00,200.00,'2026-08-25 23:26:13',50,4,'2026-06-25 23:26:13','2026-06-26 11:08:16'),(3,'FLASH25','percentage',25.00,500.00,'2026-07-02 23:26:13',20,5,'2026-06-25 23:26:13','2026-06-25 23:26:13'),(4,'FREESHIP','fixed',50.00,NULL,'2026-07-25 23:26:13',NULL,0,'2026-06-25 23:26:13','2026-06-25 23:26:13'),(5,'MEGA100','fixed',100.00,1000.00,'2026-07-10 23:26:13',10,0,'2026-06-25 23:26:13','2026-06-25 23:26:13'),(6,'EXPIRED20','percentage',20.00,NULL,'2026-06-20 23:26:13',50,10,'2026-06-25 23:26:13','2026-06-25 23:26:13'),(7,'LIMITMAX','percentage',15.00,NULL,'2026-12-25 23:26:13',10,10,'2026-06-25 23:26:13','2026-06-25 23:26:13');
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_analytics`
--

DROP TABLE IF EXISTS `customer_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_analytics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_spent` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_refunded` decimal(14,2) NOT NULL DEFAULT 0.00,
  `net_revenue` decimal(14,2) NOT NULL DEFAULT 0.00,
  `average_order_value` decimal(14,2) NOT NULL DEFAULT 0.00,
  `clv` decimal(14,2) NOT NULL DEFAULT 0.00,
  `last_order_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_analytics_user_id_unique` (`user_id`),
  CONSTRAINT `customer_analytics_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_analytics`
--

LOCK TABLES `customer_analytics` WRITE;
/*!40000 ALTER TABLE `customer_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_reports`
--

DROP TABLE IF EXISTS `daily_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_reports` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `report_date` timestamp NOT NULL,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_revenue` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_profit` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_shipping` decimal(14,2) NOT NULL DEFAULT 0.00,
  `new_customers` int(11) NOT NULL DEFAULT 0,
  `conversion_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `daily_reports_report_date_unique` (`report_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_reports`
--

LOCK TABLES `daily_reports` WRITE;
/*!40000 ALTER TABLE `daily_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `daily_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_files`
--

DROP TABLE IF EXISTS `digital_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `digital_files` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `version` varchar(50) DEFAULT '1.0',
  `max_downloads` int(11) DEFAULT 5,
  `link_expiry_days` int(11) DEFAULT 7,
  `license_type` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `digital_files_product_id_foreign` (`product_id`),
  CONSTRAINT `digital_files_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_files`
--

LOCK TABLES `digital_files` WRITE;
/*!40000 ALTER TABLE `digital_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `digital_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `downloads`
--

DROP TABLE IF EXISTS `downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `downloads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint(20) unsigned NOT NULL,
  `download_count` int(11) NOT NULL DEFAULT 0,
  `last_download_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `downloads_order_item_id_foreign` (`order_item_id`),
  CONSTRAINT `downloads_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `downloads`
--

LOCK TABLES `downloads` WRITE;
/*!40000 ALTER TABLE `downloads` DISABLE KEYS */;
/*!40000 ALTER TABLE `downloads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_analytics`
--

DROP TABLE IF EXISTS `financial_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_analytics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `product_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_gateway_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `gross_revenue` decimal(12,2) NOT NULL DEFAULT 0.00,
  `net_profit` decimal(12,2) NOT NULL DEFAULT 0.00,
  `profit_margin` decimal(5,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `financial_analytics_order_id_unique` (`order_id`),
  CONSTRAINT `financial_analytics_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_analytics`
--

LOCK TABLES `financial_analytics` WRITE;
/*!40000 ALTER TABLE `financial_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industor_designers`
--

DROP TABLE IF EXISTS `industor_designers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `industor_designers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `industor_id` bigint(20) unsigned NOT NULL,
  `designer_id` bigint(20) unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `industor_designers_industor_id_designer_id_unique` (`industor_id`,`designer_id`),
  KEY `industor_designers_designer_id_foreign` (`designer_id`),
  CONSTRAINT `industor_designers_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `industor_designers_industor_id_foreign` FOREIGN KEY (`industor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industor_designers`
--

LOCK TABLES `industor_designers` WRITE;
/*!40000 ALTER TABLE `industor_designers` DISABLE KEYS */;
INSERT INTO `industor_designers` VALUES (1,11,8,1,'2026-06-25 22:26:31'),(2,11,9,1,'2026-06-25 22:26:31'),(3,11,10,1,'2026-06-25 22:26:31'),(4,12,8,1,'2026-06-25 22:26:31'),(5,12,10,1,'2026-06-25 22:26:31');
/*!40000 ALTER TABLE `industor_designers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `sku` varchar(100) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `low_stock_alert` int(11) NOT NULL DEFAULT 5,
  `warehouse_location` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_product_id_unique` (`product_id`),
  UNIQUE KEY `inventory_sku_unique` (`sku`),
  CONSTRAINT `inventory_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,1,'CAPITAL-METAL-TS-001',100,10,'Warehouse A'),(2,2,'CAPITAL-METAL-MG-001',200,20,'Warehouse A');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `license_agreements`
--

DROP TABLE IF EXISTS `license_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `license_agreements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `license_type` varchar(50) DEFAULT NULL,
  `agreement_file_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `license_agreements_product_id_foreign` (`product_id`),
  CONSTRAINT `license_agreements_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `license_agreements`
--

LOCK TABLES `license_agreements` WRITE;
/*!40000 ALTER TABLE `license_agreements` DISABLE KEYS */;
/*!40000 ALTER TABLE `license_agreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_06_25_200759_create_personal_access_tokens_table',1),(5,'2026_06_25_210000_create_roles_table',1),(6,'2026_06_25_210001_add_role_id_to_users',1),(7,'2026_06_25_220000_update_users_table',2),(8,'2026_06_25_220001_create_addresses_table',2),(9,'2026_06_25_220002_create_subscription_plans_table',2),(10,'2026_06_25_220003_create_shipping_companies_table',2),(11,'2026_06_25_220004_create_payment_methods_table',2),(12,'2026_06_25_220005_create_traffic_sources_table',2),(13,'2026_06_25_220010_create_products_table',2),(14,'2026_06_25_220011_create_coupons_table',2),(15,'2026_06_25_220012_create_product_images_table',2),(16,'2026_06_25_220013_create_inventory_table',2),(17,'2026_06_25_220014_create_digital_files_table',2),(18,'2026_06_25_220015_create_license_agreements_table',2),(19,'2026_06_25_220020_create_affiliates_table',2),(20,'2026_06_25_220021_create_carts_table',2),(21,'2026_06_25_220022_create_user_subscriptions_table',2),(22,'2026_06_25_220023_create_shipping_rates_table',2),(23,'2026_06_25_220024_create_user_roles_table',2),(24,'2026_06_25_220030_create_orders_table',2),(25,'2026_06_25_220031_create_order_items_table',2),(26,'2026_06_25_220032_create_affiliate_earnings_table',2),(27,'2026_06_25_220033_create_payments_table',2),(28,'2026_06_25_220034_create_refunds_table',2),(29,'2026_06_25_220035_create_reviews_table',2),(30,'2026_06_25_220036_create_wishlist_table',2),(31,'2026_06_25_220037_create_downloads_table',2),(32,'2026_06_25_220038_create_cart_items_table',2),(33,'2026_06_25_220040_create_product_analytics_table',2),(34,'2026_06_25_220041_create_customer_analytics_table',2),(35,'2026_06_25_220042_create_financial_analytics_table',2),(36,'2026_06_25_220043_create_cart_analytics_table',2),(37,'2026_06_25_220044_create_daily_reports_table',2),(38,'2026_06_25_220045_create_activity_logs_table',2),(39,'2026_06_25_220046_create_visitor_sessions_table',2),(40,'2026_06_26_000000_add_coupon_to_orders_table',3),(41,'2026_06_26_010000_extend_subscription_plans_table',3),(42,'2026_06_26_010001_extend_user_subscriptions_table',3),(43,'2026_06_26_010010_create_tickets_table',3),(44,'2026_06_26_010011_create_ticket_status_history_table',3),(45,'2026_06_26_010012_create_industor_designers_table',3),(46,'2026_06_26_010013_create_ticket_attachments_table',3),(47,'2026_06_26_010014_create_notifications_table',3),(48,'2026_06_26_010015_create_store_listings_table',3),(49,'2026_06_26_020000_add_approval_to_user_subscriptions_table',4),(50,'2026_06_26_020010_create_ticket_modification_requests_table',4),(51,'2026_06_26_020020_add_designer_id_to_products_table',4),(52,'2026_06_26_020030_add_accepted_and_qa_claimed_to_tickets_table',5),(53,'2026_06_26_153000_create_saved_cards_table',6),(54,'2026_06_26_160000_add_review_and_penalty_fields_to_tickets_table',7),(55,'2026_06_26_150000_add_paymob_fields_to_payments_table',8),(56,'2026_06_26_150001_add_paymob_fields_to_user_subscriptions_table',8),(57,'2026_06_26_170000_add_single_purchase_to_tickets_and_ticket_id_to_payments',9),(58,'2026_06_26_180000_add_pricing_fields_to_tickets_and_price_history_table',10),(59,'2026_06_29_160000_add_deadline_negotiation_to_tickets',11),(60,'2026_06_29_180000_add_open_negotiation_fields_to_tickets',12),(61,'2026_06_29_190000_add_material_manufacturing_tags_to_products_table',13),(62,'2026_06_29_190001_add_design_file_to_products_table',13),(63,'2026_07_04_120000_create_contact_submissions_table',14),(64,'2026_07_04_130000_add_currency_preference_to_users_table',15),(65,'2026_07_04_140000_create_settings_table',16),(66,'2026_07_04_150000_add_guest_support_to_carts_and_orders',16);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `type` varchar(100) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body` text DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_read_at_index` (`user_id`,`read_at`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,11,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 9}','2026-06-25 22:56:59','2026-06-25 10:56:59'),(2,11,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 10}','2026-06-25 22:56:59','2026-06-25 10:56:59'),(3,11,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 8}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(4,11,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-25 16:56:59'),(5,11,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 2}',NULL,'2026-06-25 14:56:59'),(6,12,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 10}',NULL,'2026-06-25 18:56:59'),(7,12,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 2}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(8,12,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 2}',NULL,'2026-06-25 14:56:59'),(9,12,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 4}','2026-06-25 22:56:59','2026-06-25 19:56:59'),(10,12,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-24 22:56:59'),(11,6,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-25 08:56:59'),(12,6,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 10}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(13,6,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 4}',NULL,'2026-06-25 11:56:59'),(14,6,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 4}','2026-06-25 22:56:59','2026-06-25 07:56:59'),(15,6,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 3}','2026-06-25 22:56:59','2026-06-25 14:56:59'),(16,8,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 6}','2026-07-04 20:08:11','2026-06-25 10:56:59'),(17,8,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 6}','2026-06-25 22:56:59','2026-06-25 09:56:59'),(18,8,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 1}','2026-06-25 22:56:59','2026-06-25 11:56:59'),(19,8,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 2}','2026-06-25 22:56:59','2026-06-25 13:56:59'),(20,8,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 3}','2026-06-25 22:56:59','2026-06-25 15:56:59'),(21,1,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 6}','2026-06-25 22:56:59','2026-06-25 01:56:59'),(22,1,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 11}','2026-07-04 19:57:13','2026-06-25 10:56:59'),(23,1,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 11}','2026-07-04 19:57:13','2026-06-25 14:56:59'),(24,1,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 1}','2026-07-04 19:57:13','2026-06-25 05:56:59'),(25,1,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 9}','2026-07-04 19:57:13','2026-06-25 21:56:59'),(26,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(27,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}','2026-07-04 20:08:01','2026-06-25 23:01:59'),(28,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(29,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(30,11,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 13, \"designer_id\": 8}',NULL,'2026-06-25 23:03:17'),(31,11,'ticket.modification_requested','Designer requested modifications',NULL,'{\"ticket_id\": 13, \"modification_id\": 2}',NULL,'2026-06-25 23:03:52'),(32,8,'ticket.modification.approved','Your modification request was approved',NULL,'{\"ticket_id\": 13}','2026-07-04 20:08:22','2026-06-25 23:04:30'),(33,12,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 8}',NULL,'2026-06-25 23:09:31'),(34,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 7}',NULL,'2026-06-25 23:09:44'),(35,11,'ticket.deadline_set','Designer set a delivery deadline',NULL,'{\"deadline\": \"2026-06-25T23:11:00.000000Z\", \"ticket_id\": 13}',NULL,'2026-06-25 23:10:38'),(36,11,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 13, \"attachment_id\": 6}',NULL,'2026-06-25 23:11:36'),(37,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(38,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(39,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(40,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:13:08'),(41,11,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:13:21'),(42,8,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 13}','2026-07-04 20:08:22','2026-06-25 23:13:21'),(43,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"capital-metal\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(44,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"capital-metal\", \"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:10:03'),(45,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"capital-metal\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(46,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"capital-metal\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(47,11,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 14, \"designer_id\": 8}',NULL,'2026-06-26 11:13:07'),(48,11,'ticket.modification_requested','Designer requested modifications',NULL,'{\"ticket_id\": 14, \"modification_id\": 4}',NULL,'2026-06-26 11:15:44'),(49,8,'ticket.modification.approved','Your modification request was approved',NULL,'{\"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:16:36'),(50,11,'ticket.deadline_set','Designer set a delivery deadline',NULL,'{\"deadline\": \"2026-06-26T11:18:00.000000Z\", \"ticket_id\": 14}',NULL,'2026-06-26 11:17:27'),(51,11,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 14, \"attachment_id\": 7}',NULL,'2026-06-26 11:18:22'),(52,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(53,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(54,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(55,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:19:43'),(56,11,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:20:14'),(57,8,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:20:14'),(58,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 5}','2026-07-04 19:57:13','2026-06-26 12:23:36'),(59,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 6}','2026-07-04 19:57:13','2026-06-26 12:24:05'),(60,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 7}','2026-07-04 19:57:13','2026-06-26 12:24:27'),(61,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 8}','2026-07-04 19:57:13','2026-06-26 12:24:40'),(62,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 9}','2026-07-04 19:57:13','2026-06-26 14:03:36'),(63,5,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 9}',NULL,'2026-06-26 14:04:03'),(64,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 8}',NULL,'2026-06-26 14:04:06'),(65,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 7}',NULL,'2026-06-26 14:04:06'),(66,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 6}',NULL,'2026-06-26 14:04:06'),(67,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 5}',NULL,'2026-06-26 14:04:07'),(68,13,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 3}',NULL,'2026-06-26 14:04:07'),(69,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(70,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(71,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(72,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"2000.00\", \"deadline\": \"2026-07-01T14:06:00.000000Z\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(73,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(74,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}','2026-07-04 20:08:22','2026-06-26 14:07:00'),(75,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(76,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(77,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 15, \"designer_id\": 8}',NULL,'2026-06-26 14:09:00'),(78,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(79,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(80,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(81,5,'ticket.reviewed','Your ticket was reviewed - payment required',NULL,'{\"price\": \"5000.00\", \"deadline\": \"2026-07-01T15:12:00.000000Z\", \"ticket_id\": 16}',NULL,'2026-06-26 15:13:10'),(82,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(83,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(84,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(85,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"50000.00\", \"deadline\": \"2026-07-01T15:20:00.000000Z\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(86,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(87,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}','2026-07-04 20:08:22','2026-06-26 15:20:18'),(88,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(89,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(90,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 17, \"designer_id\": 8}',NULL,'2026-06-28 15:26:45'),(91,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(92,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(93,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(94,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"10000.00\", \"deadline\": \"2026-06-28T16:37:00.000000Z\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(95,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(96,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}','2026-07-04 20:08:22','2026-06-28 16:30:21'),(97,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(98,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(99,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(100,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}','2026-07-04 20:08:22','2026-06-28 16:33:54'),(101,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(102,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(103,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(104,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(105,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:55'),(106,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(107,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(108,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(109,5,'ticket.deadline_approved','Your proposed deadline was approved - set the price',NULL,'{\"deadline\": \"2026-06-29T22:00:00.000000Z\", \"ticket_id\": 19}',NULL,'2026-06-29 12:26:41'),(110,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"50000.00\", \"deadline\": \"2026-06-29T22:00:00.000000Z\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(111,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(112,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}','2026-07-04 20:08:22','2026-06-29 12:27:43'),(113,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(114,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(115,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 19, \"designer_id\": 4}',NULL,'2026-06-29 12:28:43'),(116,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(117,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(118,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(119,5,'ticket.deadline_modified','Tester proposed a new delivery deadline',NULL,'{\"reason\": \"RNMKVLLVLDSMVSD\", \"ticket_id\": 20, \"new_deadline\": \"2026-07-03T10:00:00.000000Z\"}',NULL,'2026-06-29 12:52:52'),(120,3,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(121,6,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(122,7,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(123,5,'ticket.deadline_modified','Tester proposed a new delivery deadline',NULL,'{\"reason\": \"دا  اخر حاجه عشان نلحق\", \"ticket_id\": 20, \"new_deadline\": \"2026-07-01T22:00:00.000000Z\"}',NULL,'2026-06-29 12:54:17'),(124,3,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(125,6,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(126,7,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(127,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"22222212.00\", \"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:13'),(128,4,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(129,8,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}','2026-07-04 20:08:22','2026-06-29 12:59:14'),(130,9,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(131,10,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(132,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(133,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(134,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(135,5,'ticket.deadline_approved','Your proposed deadline was approved - set the price',NULL,'{\"deadline\": \"2026-07-01T13:48:00.000000Z\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:50'),(136,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(137,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(138,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(139,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"2500.00\", \"reason\": \"done\", \"deadline\": \"2026-07-01T15:13:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:13:19'),(140,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(141,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(142,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(143,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"2000.00\", \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(144,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(145,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}','2026-07-04 20:08:22','2026-06-29 15:21:52'),(146,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(147,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(148,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(149,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(150,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(151,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"5000.00\", \"deadline\": \"2026-07-03T10:00:00.000000Z\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(152,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(153,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}','2026-07-04 20:08:22','2026-06-29 15:32:32'),(154,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(155,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(156,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(157,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(158,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(159,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"6666.00\", \"reason\": null, \"deadline\": \"2026-07-08T17:44:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:52'),(160,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(161,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(162,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(163,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"7000.00\", \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}','2026-07-04 20:05:08','2026-06-29 15:42:48'),(164,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(165,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}','2026-07-04 20:08:22','2026-06-29 15:42:48'),(166,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(167,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(168,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(169,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(170,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(171,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"6000.00\", \"deadline\": \"2026-07-03T23:00:00.000000Z\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(172,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(173,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}','2026-07-04 20:08:22','2026-06-29 15:49:54'),(174,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(175,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(176,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(177,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(178,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(179,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"8000.00\", \"reason\": \"الدايرز مشغول\", \"deadline\": \"2026-07-05T16:23:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:03'),(180,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(181,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(182,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(183,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"11000.00\", \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(184,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(185,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}','2026-07-04 20:08:22','2026-06-29 16:25:16'),(186,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(187,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(188,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 28, \"designer_id\": 4}',NULL,'2026-06-29 16:26:11'),(189,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 28, \"attachment_id\": 15}',NULL,'2026-06-29 16:26:29'),(190,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(191,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(192,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(193,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:51'),(194,5,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:27:41'),(195,4,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:27:41'),(196,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 20, \"designer_id\": 4}',NULL,'2026-06-29 16:29:11'),(197,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 18, \"designer_id\": 4}',NULL,'2026-06-29 16:29:31'),(198,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 20, \"attachment_id\": 16}',NULL,'2026-06-29 16:29:49'),(199,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(200,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(201,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(202,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:57'),(203,5,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:30:17'),(204,4,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:30:17'),(205,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 27, \"designer_id\": 4}',NULL,'2026-06-29 16:30:44'),(206,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 18, \"attachment_id\": 17}',NULL,'2026-06-29 16:31:42'),(207,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(208,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(209,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(210,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:32:08'),(211,4,'ticket.qa_rejected','Your design was rejected by QA - please revise',NULL,'{\"reason\": \"التصميم وحش\", \"penalty\": \"1000.00\", \"ticket_id\": 18}',NULL,'2026-06-29 16:32:54'),(212,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 18, \"attachment_id\": 18}',NULL,'2026-06-29 16:35:02'),(213,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(214,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(215,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(216,4,'ticket.qa_rejected','Your design was rejected by QA - please revise',NULL,'{\"reason\": \"وحش برضوا\", \"penalty\": \"200.00\", \"ticket_id\": 18}',NULL,'2026-06-29 16:35:32'),(217,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(218,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(219,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(220,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(221,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(222,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(223,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(224,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(225,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(226,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(227,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(228,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(229,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(230,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(231,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"Capital-Metal\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(232,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"Capital-Metal\", \"new_price\": 5390, \"ticket_id\": 26}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(233,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"Capital-Metal\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(234,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"Capital-Metal\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(235,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(236,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(237,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"Capital-Metal\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(238,1,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}','2026-07-04 19:57:13','2026-07-04 19:57:08'),(239,2,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(240,3,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(241,6,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(242,7,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(243,4,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(244,8,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}','2026-07-04 20:08:22','2026-07-04 19:57:08'),(245,9,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(246,10,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(247,5,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(248,11,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(249,12,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(250,13,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(251,14,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` decimal(12,2) NOT NULL,
  `license_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_product_id_foreign` (`product_id`),
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,1,299.00,NULL),(2,1,2,1,149.00,NULL),(3,2,1,3,299.00,NULL),(4,3,1,1,299.00,NULL),(5,4,1,1,299.00,NULL),(6,4,2,1,149.00,NULL),(7,5,1,1,299.00,NULL),(8,6,3,1,499.00,NULL),(9,7,1,1,299.00,NULL),(10,8,1,1,299.00,NULL),(11,9,1,1,299.00,NULL),(12,10,7,1,1000.00,NULL),(13,11,7,1,1000.00,NULL),(14,12,2,1,149.00,NULL),(15,13,1,2,299.00,NULL);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `guest_name` varchar(255) DEFAULT NULL,
  `guest_phone` varchar(50) DEFAULT NULL,
  `order_number` varchar(100) NOT NULL,
  `affiliate_id` bigint(20) unsigned DEFAULT NULL,
  `currency` varchar(10) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `coupon_id` bigint(20) unsigned DEFAULT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `payment_status` varchar(50) NOT NULL DEFAULT 'pending',
  `order_status` varchar(50) NOT NULL DEFAULT 'pending',
  `shipping_tracking_number` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`),
  KEY `orders_user_id_foreign` (`user_id`),
  KEY `orders_affiliate_id_foreign` (`affiliate_id`),
  KEY `orders_coupon_id_foreign` (`coupon_id`),
  CONSTRAINT `orders_affiliate_id_foreign` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliates` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,2,NULL,NULL,'ORD-6A3D9BE5EC267',NULL,'EGP',448.00,50.00,0.00,NULL,498.00,'pending','pending',NULL,NULL,'2026-06-25 21:21:41','2026-06-25 21:21:41'),(2,1,NULL,NULL,'ORD-6A3D9CCF9DBE2',NULL,'EGP',897.00,50.00,0.00,NULL,947.00,'pending','pending',NULL,NULL,'2026-06-25 21:25:35','2026-06-25 21:25:35'),(3,1,NULL,NULL,'ORD-6A3DB9755D8BA',NULL,'EGP',299.00,50.00,29.90,1,319.10,'pending','pending',NULL,NULL,'2026-06-25 23:27:49','2026-06-25 23:27:49'),(4,2,NULL,NULL,'ORD-6A3E5DA01D1A3',NULL,'EGP',448.00,50.00,50.00,2,448.00,'pending','pending',NULL,NULL,'2026-06-26 11:08:16','2026-06-26 11:08:16'),(5,1,NULL,NULL,'ORD-6A3E67662DC25',NULL,'EGP',299.00,50.00,0.00,NULL,349.00,'pending','pending',NULL,NULL,'2026-06-26 11:49:58','2026-06-26 11:49:58'),(6,1,NULL,NULL,'ORD-6A3E67D457679',NULL,'EGP',499.00,50.00,0.00,NULL,549.00,'pending','pending',NULL,NULL,'2026-06-26 11:51:48','2026-06-26 11:51:48'),(7,1,NULL,NULL,'ORD-6A3E6BAE9197F',NULL,'EGP',299.00,50.00,0.00,NULL,349.00,'pending','pending',NULL,NULL,'2026-06-26 12:08:14','2026-06-26 12:08:14'),(8,1,NULL,NULL,'ORD-6A3E6F209B1E3',NULL,'EGP',299.00,50.00,0.00,NULL,349.00,'pending','pending',NULL,NULL,'2026-06-26 12:22:56','2026-06-26 12:22:56'),(9,8,NULL,NULL,'ORD-6A4141743999F',NULL,'EGP',299.00,50.00,0.00,NULL,349.00,'pending','pending',NULL,NULL,'2026-06-28 15:44:52','2026-06-28 15:44:52'),(10,4,NULL,NULL,'ORD-6A42AB4D59509',NULL,'EGP',1000.00,50.00,0.00,NULL,1050.00,'pending','pending',NULL,NULL,'2026-06-29 17:28:45','2026-06-29 17:28:45'),(11,5,NULL,NULL,'ORD-6A42ABA39669C',NULL,'EGP',1000.00,50.00,0.00,NULL,1050.00,'pending','pending',NULL,NULL,'2026-06-29 17:30:11','2026-06-29 17:30:11'),(12,1,NULL,NULL,'ORD-6A48E7F719D52',NULL,'EGP',149.00,50.00,0.00,NULL,199.00,'pending','pending',NULL,NULL,'2026-07-04 11:01:11','2026-07-04 11:01:11'),(13,NULL,'ضياء عبدالله','01012345678','ORD-6A496274DE885',NULL,'EGP',598.00,0.00,0.00,NULL,598.00,'pending','pending',NULL,NULL,'2026-07-04 19:43:48','2026-07-04 19:43:48');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,'Credit Card','EGP',1,'2026-06-25 20:43:19','2026-06-25 20:43:19'),(2,'Cash on Delivery','EGP',1,'2026-06-25 20:43:19','2026-06-25 20:43:19'),(3,'Bank Transfer','EGP',1,'2026-06-25 20:43:19','2026-06-25 20:43:19'),(4,'PayPal','USD',1,'2026-06-25 20:43:19','2026-06-25 20:43:19');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned DEFAULT NULL,
  `ticket_id` bigint(20) unsigned DEFAULT NULL,
  `payment_method_id` int(10) unsigned DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `paymob_order_id` varchar(100) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `payment_status` varchar(50) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_order_id_foreign` (`order_id`),
  KEY `payments_payment_method_id_foreign` (`payment_method_id`),
  KEY `payments_ticket_id_foreign` (`ticket_id`),
  CONSTRAINT `payments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_payment_method_id_foreign` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE SET NULL,
  CONSTRAINT `payments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth-token','b44d3b090d857e8fafba553de70e4427fc48e9a30cac988c54e4e53b2e8f86d2','[\"*\"]','2026-06-25 20:32:12',NULL,'2026-06-25 20:32:09','2026-06-25 20:32:12'),(4,'App\\Models\\User',1,'auth-token','d7df873a932f177bdfe1b7e646037de9f6586ae6f783b4606867700d6f78142e','[\"*\"]','2026-06-25 20:43:45',NULL,'2026-06-25 20:43:41','2026-06-25 20:43:45'),(5,'App\\Models\\User',2,'auth-token','2637ba7f350668224396f7f70239de438f97ce42d236ecc64840bf9f0231fb24','[\"*\"]','2026-06-25 20:43:50',NULL,'2026-06-25 20:43:50','2026-06-25 20:43:50'),(7,'App\\Models\\User',2,'auth-token','80f42dc2ffe34b69541070de0df0b63759ff2a214d1207a70b501f4cc980ff44','[\"*\"]','2026-06-25 21:21:42',NULL,'2026-06-25 21:21:41','2026-06-25 21:21:42'),(8,'App\\Models\\User',1,'auth-token','1d0d44b23570f0c6b023ebc309b1cdf16fa85829be9510d38a11127a30ba934e','[\"*\"]','2026-06-25 21:21:42',NULL,'2026-06-25 21:21:42','2026-06-25 21:21:42'),(13,'App\\Models\\User',11,'auth-token','9908c79ae7c88d36a1d081202bbd3a91a48545aa43197432a655c33a412d0e6e','[\"*\"]','2026-06-25 22:33:41',NULL,'2026-06-25 22:33:41','2026-06-25 22:33:41'),(14,'App\\Models\\User',11,'auth-token','a5fecc9603b9a23361de94939f2edeeaa608eaf171f064feff3c6875f283992b','[\"*\"]','2026-06-25 22:34:06',NULL,'2026-06-25 22:34:06','2026-06-25 22:34:06'),(17,'App\\Models\\User',8,'auth-token','7eb2fa29c4b7899a375fa4ef9238abf32cfa989c90b9085e772e18fcf0ab63ab','[\"*\"]','2026-06-25 22:57:23',NULL,'2026-06-25 22:57:23','2026-06-25 22:57:23'),(18,'App\\Models\\User',6,'auth-token','144b38ca00e28ea04b331ec0ed8b53eb7c2bdba2ee8f98c60821a79834d2c6b9','[\"*\"]','2026-06-25 22:57:24',NULL,'2026-06-25 22:57:24','2026-06-25 22:57:24'),(19,'App\\Models\\User',1,'auth-token','6a835a13f9feae5976f8ce3e6ac18b3eb3ab48666fb5e8cc04b9fd2c4ee4c31e','[\"*\"]','2026-06-25 22:57:25',NULL,'2026-06-25 22:57:24','2026-06-25 22:57:25'),(20,'App\\Models\\User',8,'auth-token','432c63715d47f9b676488d31334b4baab0c2515f23fa618194d87a6add4221fa','[\"*\"]','2026-06-25 22:57:41',NULL,'2026-06-25 22:57:41','2026-06-25 22:57:41'),(21,'App\\Models\\User',6,'auth-token','9f7f272e7f772acbaee7277924ed635715e5d9b09c53b2d05296954fb092511d','[\"*\"]','2026-06-25 22:57:41',NULL,'2026-06-25 22:57:41','2026-06-25 22:57:41'),(22,'App\\Models\\User',1,'auth-token','dc590d80bc9afb670612baf6b936dcde319c39ddf63dc49a08603cd4a5a48a14','[\"*\"]','2026-06-25 22:57:42',NULL,'2026-06-25 22:57:42','2026-06-25 22:57:42'),(23,'App\\Models\\User',1,'auth-token','c55a9f2fa8441b52a62b66115070ee2e5e463b0ca14f882fd3cce85a92947c49','[\"*\"]','2026-06-25 22:59:13',NULL,'2026-06-25 22:59:13','2026-06-25 22:59:13'),(24,'App\\Models\\User',8,'auth-token','7ba2c42f718fdbf8154a8babea99defa95396c0ed0cd6b9d3f5e9d3e098abdba','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(25,'App\\Models\\User',6,'auth-token','4df743a4a98018861cce60c44f7c68adf7d43dc4892c62dd633349048463771c','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(26,'App\\Models\\User',1,'auth-token','71f1e0129762e5d605079e9eaed0d68d7790fc777ed997f154e6e2652415a8e7','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(42,'App\\Models\\User',2,'auth-token','94e70b08874a0ab7526cc50c8fa8ab97005e1a822df77b7b6acf294f8e460bcf','[\"*\"]','2026-06-25 23:26:32',NULL,'2026-06-25 23:26:32','2026-06-25 23:26:32'),(62,'App\\Models\\User',6,'auth-token','1c05a67b06af18aff964724582ee2dcc7c84b5886aa53efa5ef142d5f2dd33d6','[\"*\"]','2026-06-28 16:30:21',NULL,'2026-06-26 15:12:32','2026-06-28 16:30:21'),(64,'App\\Models\\User',6,'auth-token','ed43bc5de85a83679eae67c7b82c52d3b7eb34e2e682fbee597e196c6174e1c6','[\"*\"]','2026-06-29 16:35:32',NULL,'2026-06-29 12:25:57','2026-06-29 16:35:32'),(65,'App\\Models\\User',4,'auth-token','106e71440915dcf650d1f1aabf02021644334e3813e8807892503da1930d8d0e','[\"*\"]','2026-06-29 17:29:51',NULL,'2026-06-29 12:26:12','2026-06-29 17:29:51'),(71,'App\\Models\\User',1,'auth-token','47fe653866a96156e506010aa283d9b104b8885a3b0e4324f39fae02b5cbeded','[\"*\"]','2026-07-04 12:29:51',NULL,'2026-07-04 12:29:41','2026-07-04 12:29:51'),(75,'App\\Models\\User',1,'auth-token','6aad53996c3a2db03b8299af2d6678422b9086463e26b080fe31eb28359a660b','[\"*\"]','2026-07-04 19:57:13',NULL,'2026-07-04 19:57:03','2026-07-04 19:57:13');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_analytics`
--

DROP TABLE IF EXISTS `product_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_analytics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `total_sales` int(11) NOT NULL DEFAULT 0,
  `total_revenue` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_refunds` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_profit` decimal(14,2) NOT NULL DEFAULT 0.00,
  `conversion_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_analytics_product_id_unique` (`product_id`),
  CONSTRAINT `product_analytics_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_analytics`
--

LOCK TABLES `product_analytics` WRITE;
/*!40000 ALTER TABLE `product_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `product_images_product_id_foreign` (`product_id`),
  CONSTRAINT `product_images_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
INSERT INTO `product_images` VALUES (1,1,'products/1/image-0.png',0),(2,2,'products/2/image-0.png',0),(3,2,'products/2/image-1.png',1),(4,3,'products/3/image-0.png',0),(5,4,'products/4/image-0.png',0),(6,4,'products/4/image-1.png',1),(7,5,'products/5/image-0.png',0),(8,6,'products/6/image-0.png',0),(9,6,'products/6/image-1.png',1),(10,7,'products/7/v5lraQXAbQqCoebLszndVLnlzB2wL3dEFv1SOMyQ.jpg',0);
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `designer_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `product_type` varchar(50) NOT NULL,
  `price_egp` decimal(12,2) NOT NULL DEFAULT 0.00,
  `price_usd` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `publish_date` timestamp NULL DEFAULT NULL,
  `country_availability` text DEFAULT NULL,
  `material` varchar(100) DEFAULT NULL,
  `manufacturing_method` varchar(100) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `design_file_path` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  KEY `products_designer_id_index` (`designer_id`),
  CONSTRAINT `products_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,NULL,'Capital-Metal T-Shirt','capital-metal-t-shirt','Premium cotton t-shirt with Capital-Metal design','physical',299.00,9.99,100.00,'published','2026-06-25 20:43:19',NULL,NULL,NULL,NULL,NULL,'2026-06-25 20:43:19','2026-06-25 20:43:19'),(2,NULL,'Capital-Metal Mug','capital-metal-mug','Ceramic mug with Capital-Metal logo','physical',149.00,4.99,50.00,'published','2026-06-25 20:43:32',NULL,NULL,NULL,NULL,NULL,'2026-06-25 20:43:32','2026-06-25 20:43:32'),(3,NULL,'Capital-Metal Template','capital-metal-template','Digital design template pack','digital',499.00,14.99,0.00,'published','2026-06-25 20:43:32',NULL,NULL,NULL,NULL,NULL,'2026-06-25 20:43:32','2026-06-25 20:43:32'),(4,8,'Modern Logo Pack','premium-logo-pack','A collection of 20 modern logo templates...','digital',499.00,14.99,0.00,'published','2026-06-25 22:56:59',NULL,NULL,NULL,NULL,NULL,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(5,9,'Icon Bundle Pro','icon-bundle-pro','500 vector icons in multiple styles...','digital',299.00,8.99,0.00,'published','2026-06-25 22:56:59',NULL,NULL,NULL,NULL,NULL,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(6,10,'Brochure Templates','brochure-templates-vol1','15 editable brochure templates...','digital',199.00,5.99,0.00,'published','2026-06-25 22:56:59',NULL,NULL,NULL,NULL,NULL,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(7,4,'saddasdsfafasfsfsf.mvm','saddasdsfafasfsfsf-mv','d,sv sdlsdmmvkdsm','digital',1000.00,8.00,0.00,'published','2026-06-29 17:27:58',NULL,'leather','machine_made','[\"dog\"]','products/7/design/yxl2gKASHu6sEJug0XzpXloiVqd7aurnUeCinMIc.jpg','2026-06-29 17:27:58','2026-06-29 17:27:59');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `refunds_order_id_foreign` (`order_id`),
  CONSTRAINT `refunds_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_product_id_foreign` (`product_id`),
  KEY `reviews_user_id_foreign` (`user_id`),
  CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `permissions` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin','Administrator',NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47'),(2,'user','Regular User',NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47'),(3,'tester','Tester',NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47'),(4,'designer','Designer',NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47'),(5,'industor','Industor',NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_cards`
--

DROP TABLE IF EXISTS `saved_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `saved_cards` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `paymob_token` varchar(191) NOT NULL,
  `card_subtype` varchar(50) NOT NULL DEFAULT 'CARD',
  `masked_pan` varchar(30) DEFAULT NULL,
  `holder_name` varchar(255) DEFAULT NULL,
  `expiry_month` varchar(2) DEFAULT NULL,
  `expiry_year` varchar(4) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `saved_cards_user_id_is_default_index` (`user_id`,`is_default`),
  CONSTRAINT `saved_cards_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_cards`
--

LOCK TABLES `saved_cards` WRITE;
/*!40000 ALTER TABLE `saved_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `saved_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('ECEOvu7BLq6fXa8kg21bVruH1HfIKEwGyBIVJBW6',NULL,'172.18.0.1','Avast Antivirus','YTozOntzOjY6Il90b2tlbiI7czo0MDoib1U3Q0dYQWpjeGh3aTBLcGNqYlA5UVZ1YWlIdVhMb25CRUFSUFUweiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjQ6Imh0dHA6Ly8xNzIuMjguMTYwLjE6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1783118750),('ocaajTNQMNkxqBjM74IgqroqdGSQMX6S07caornP',NULL,'172.18.0.1','','YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFpWd2h2SzY1UmlSZkd0cEhLU3NNQU5YZXdsb0ltUGNnM3hnQTFYRyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjQ6Imh0dHA6Ly8xNzIuMjguMTYwLjE6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1783118762);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(100) NOT NULL,
  `value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'egp_to_usd_rate','49.11596','2026-07-04 19:39:57','2026-07-04 19:49:16');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_companies`
--

DROP TABLE IF EXISTS `shipping_companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_companies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `api_endpoint` varchar(255) DEFAULT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_companies`
--

LOCK TABLES `shipping_companies` WRITE;
/*!40000 ALTER TABLE `shipping_companies` DISABLE KEYS */;
INSERT INTO `shipping_companies` VALUES (1,'Aramex','https://api.aramex.com',NULL,1,'2026-06-25 20:43:19','2026-06-25 20:43:19'),(2,'DHL','https://api.dhl.com',NULL,1,'2026-06-25 20:43:19','2026-06-25 20:43:19');
/*!40000 ALTER TABLE `shipping_companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_rates`
--

DROP TABLE IF EXISTS `shipping_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_rates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int(10) unsigned NOT NULL,
  `governorate` varchar(100) DEFAULT NULL,
  `cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `shipping_rates_company_id_foreign` (`company_id`),
  CONSTRAINT `shipping_rates_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `shipping_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_rates`
--

LOCK TABLES `shipping_rates` WRITE;
/*!40000 ALTER TABLE `shipping_rates` DISABLE KEYS */;
INSERT INTO `shipping_rates` VALUES (1,1,'Cairo',50.00),(2,1,'Alexandria',65.00),(3,1,'Giza',50.00),(4,1,'Cairo',50.00),(5,1,'Alexandria',65.00),(6,1,'Giza',50.00),(7,1,'Cairo',50.00),(8,1,'Alexandria',65.00),(9,1,'Giza',50.00),(10,1,'Cairo',50.00),(11,1,'Alexandria',65.00),(12,1,'Giza',50.00),(13,1,'Cairo',50.00),(14,1,'Alexandria',65.00),(15,1,'Giza',50.00),(16,1,'Cairo',50.00),(17,1,'Alexandria',65.00),(18,1,'Giza',50.00),(19,1,'Cairo',50.00),(20,1,'Alexandria',65.00),(21,1,'Giza',50.00),(22,1,'Cairo',50.00),(23,1,'Alexandria',65.00),(24,1,'Giza',50.00),(25,1,'Cairo',50.00),(26,1,'Alexandria',65.00),(27,1,'Giza',50.00),(28,1,'Cairo',50.00),(29,1,'Alexandria',65.00),(30,1,'Giza',50.00),(31,1,'Cairo',50.00),(32,1,'Alexandria',65.00),(33,1,'Giza',50.00);
/*!40000 ALTER TABLE `shipping_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_listings`
--

DROP TABLE IF EXISTS `store_listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_listings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `industor_id` bigint(20) unsigned NOT NULL,
  `attachment_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `store_listings_ticket_id_foreign` (`ticket_id`),
  KEY `store_listings_industor_id_foreign` (`industor_id`),
  KEY `store_listings_attachment_id_foreign` (`attachment_id`),
  CONSTRAINT `store_listings_attachment_id_foreign` FOREIGN KEY (`attachment_id`) REFERENCES `ticket_attachments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `store_listings_industor_id_foreign` FOREIGN KEY (`industor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `store_listings_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_listings`
--

LOCK TABLES `store_listings` WRITE;
/*!40000 ALTER TABLE `store_listings` DISABLE KEYS */;
INSERT INTO `store_listings` VALUES (1,10,12,4,'Safety signage set','Industrial safety signs for a factory...',199.00,'active','2026-06-25 22:56:59','2026-06-25 22:56:59');
/*!40000 ALTER TABLE `store_listings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `duration_days` int(11) DEFAULT NULL,
  `ticket_limit` int(11) NOT NULL DEFAULT 0,
  `can_publish_to_store` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
INSERT INTO `subscription_plans` VALUES (1,'Basic',0.00,'EGP',30,5,0,'2026-06-25 20:43:19','2026-06-25 22:26:30'),(2,'Premium',299.00,'EGP',30,20,1,'2026-06-25 20:43:19','2026-06-25 22:26:30'),(3,'Enterprise',999.00,'EGP',30,100,1,'2026-06-25 20:43:19','2026-06-25 22:26:30');
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_attachments`
--

DROP TABLE IF EXISTS `ticket_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_attachments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `uploaded_by` bigint(20) unsigned NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `file_size` int(10) unsigned NOT NULL,
  `kind` varchar(20) NOT NULL DEFAULT 'delivery',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ticket_attachments_uploaded_by_foreign` (`uploaded_by`),
  KEY `ticket_attachments_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_attachments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_attachments_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_attachments`
--

LOCK TABLES `ticket_attachments` WRITE;
/*!40000 ALTER TABLE `ticket_attachments` DISABLE KEYS */;
INSERT INTO `ticket_attachments` VALUES (1,7,9,'delivery-7.pdf','tickets/7/delivery-7.pdf','application/pdf',220351,'delivery','2026-06-25 22:56:59'),(2,8,10,'delivery-8.pdf','tickets/8/delivery-8.pdf','application/pdf',62435,'delivery','2026-06-25 22:56:59'),(3,9,8,'delivery-9.pdf','tickets/9/delivery-9.pdf','application/pdf',443656,'delivery','2026-06-25 22:56:59'),(4,10,10,'delivery-10.pdf','tickets/10/delivery-10.pdf','application/pdf',450379,'delivery','2026-06-25 22:56:59'),(5,11,9,'delivery-11.pdf','tickets/11/delivery-11.pdf','application/pdf',109577,'delivery','2026-06-25 22:56:59'),(6,13,8,'logo.png','tickets/13/NwhU4jgdkv7j0J1q9bIGPLc6pLFwzWFuFq8nwQlC.png','image/png',164753,'delivery','2026-06-25 23:11:36'),(7,14,8,'dog.jpg','tickets/14/T58u69HawYAk8c7r4H78zj0Dw8ZhbvkyKfV5fe1M.jpg','image/jpeg',7194,'delivery','2026-06-26 11:18:22'),(8,20,5,'dog.jpg','tickets/20/Kg3c7ozVpJsVbnsrYrBmqHNPwC31FFdczEpqSZs6.jpg','image/jpeg',7194,'requirement','2026-06-29 12:51:53'),(9,21,5,'dog.jpg','tickets/21/6jBwYO0jzf8a80GywSABqlAGpXvHZXOhWJMbIZR6.jpg','image/jpeg',7194,'requirement','2026-06-29 13:49:11'),(10,24,5,'dog.jpg','tickets/24/UVHfSUCU6wGqDf2aRaqel0c92ph7EQlznbbZeBfx.jpg','image/jpeg',7194,'requirement','2026-06-29 15:11:43'),(11,25,5,'dog.jpg','tickets/25/dks1FFDgGdabxiR5bXv64NRM9zR8jV6BDWOjR2ye.jpg','image/jpeg',7194,'requirement','2026-06-29 15:27:29'),(12,26,5,'dog.jpg','tickets/26/JqjqcQYgzrKjudApLz1iWEZkZump856l0lHh9ZQW.jpg','image/jpeg',7194,'requirement','2026-06-29 15:41:01'),(13,27,5,'ATT.png','tickets/27/V57D3vieiok80sBetg6Ca3BKuXhHx2Ek1BFe5q4y.png','image/png',104284,'requirement','2026-06-29 15:49:41'),(14,28,5,'dog.jpg','tickets/28/fWKpFb6fbM3BC4wJ89Gjc12UB82TjZ0E28DD67Ba.jpg','image/jpeg',7194,'requirement','2026-06-29 16:22:53'),(15,28,4,'cat.jpg','tickets/28/Bp7hYrgokeZhKViLqjIj1bHkjuGmTrqHZIjlZ4ba.jpg','image/jpeg',86822,'delivery','2026-06-29 16:26:29'),(16,20,4,'cat.jpg','tickets/20/c7lmEW14nWE17uZqBr7AmtUB30ZpnS26q9MQJj3w.jpg','image/jpeg',86822,'delivery','2026-06-29 16:29:49'),(17,18,4,'cat.jpg','tickets/18/ibixRsMebirgdop1KcH9HIfzl2iSrStRKQDMWFoX.jpg','image/jpeg',86822,'delivery','2026-06-29 16:31:42'),(18,18,4,'dog.jpg','tickets/18/jEiZrR3tDbCGUevvdORlQg0QhAaLsHnQSvHMbpNe.jpg','image/jpeg',7194,'delivery','2026-06-29 16:35:02');
/*!40000 ALTER TABLE `ticket_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_deadline_negotiations`
--

DROP TABLE IF EXISTS `ticket_deadline_negotiations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_deadline_negotiations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `round_number` int(11) NOT NULL DEFAULT 1,
  `proposed_by` enum('industor','tester') NOT NULL,
  `proposed_deadline` timestamp NOT NULL,
  `proposed_price` decimal(12,2) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ticket_deadline_negotiations_created_by_foreign` (`created_by`),
  KEY `ticket_deadline_negotiations_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_deadline_negotiations_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_deadline_negotiations_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_deadline_negotiations`
--

LOCK TABLES `ticket_deadline_negotiations` WRITE;
/*!40000 ALTER TABLE `ticket_deadline_negotiations` DISABLE KEYS */;
INSERT INTO `ticket_deadline_negotiations` VALUES (1,19,1,'industor','2026-06-29 22:00:00',NULL,NULL,'accepted',5,'2026-06-29 12:24:23'),(2,20,1,'industor','2026-06-30 10:01:00',NULL,NULL,'pending',5,'2026-06-29 12:51:52'),(3,20,1,'tester','2026-07-03 10:00:00',NULL,'RNMKVLLVLDSMVSD','rejected',6,'2026-06-29 12:52:52'),(4,20,1,'tester','2026-07-01 22:00:00',NULL,'دا  اخر حاجه عشان نلحق','accepted',6,'2026-06-29 12:54:17'),(5,21,1,'industor','2026-07-01 13:48:00',NULL,NULL,'accepted',5,'2026-06-29 13:49:09'),(6,24,0,'industor','2026-06-30 22:00:00',2000.00,NULL,'pending',5,'2026-06-29 15:11:42'),(7,24,1,'tester','2026-07-01 15:13:00',2500.00,'done','rejected',6,'2026-06-29 15:13:19'),(8,24,2,'industor','2026-07-02 15:14:00',2000.00,NULL,'accepted',5,'2026-06-29 15:14:47'),(9,25,0,'industor','2026-07-03 10:00:00',5000.00,NULL,'accepted',5,'2026-06-29 15:27:29'),(10,26,0,'industor','2026-07-03 22:00:00',5555.00,NULL,'pending',5,'2026-06-29 15:41:01'),(11,26,1,'tester','2026-07-08 17:44:00',6666.00,NULL,'rejected',6,'2026-06-29 15:41:52'),(12,26,2,'industor','2026-07-04 15:42:00',7000.00,NULL,'accepted',5,'2026-06-29 15:42:24'),(13,27,0,'industor','2026-07-03 23:00:00',6000.00,NULL,'accepted',5,'2026-06-29 15:49:41'),(14,28,0,'industor','2026-07-03 22:00:00',10000.00,NULL,'pending',5,'2026-06-29 16:22:53'),(15,28,1,'tester','2026-07-05 16:23:00',8000.00,'الدايرز مشغول','rejected',6,'2026-06-29 16:24:03'),(16,28,2,'industor','2026-07-04 16:24:00',11000.00,NULL,'accepted',5,'2026-06-29 16:24:46');
/*!40000 ALTER TABLE `ticket_deadline_negotiations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_modification_requests`
--

DROP TABLE IF EXISTS `ticket_modification_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_modification_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `designer_id` bigint(20) unsigned NOT NULL,
  `description` text NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `industor_response` text DEFAULT NULL,
  `handled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ticket_modification_requests_designer_id_foreign` (`designer_id`),
  KEY `ticket_modification_requests_ticket_id_status_index` (`ticket_id`,`status`),
  CONSTRAINT `ticket_modification_requests_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_modification_requests_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_modification_requests`
--

LOCK TABLES `ticket_modification_requests` WRITE;
/*!40000 ALTER TABLE `ticket_modification_requests` DISABLE KEYS */;
INSERT INTO `ticket_modification_requests` VALUES (1,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-06-25 22:56:59'),(2,13,8,'ssssssssssssssssscccccccccccc','approved','Approved','2026-06-25 23:04:30','2026-06-25 23:03:52'),(3,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-06-26 11:04:52'),(4,14,8,'price : 30$','approved','Approved','2026-06-26 11:16:36','2026-06-26 11:15:44'),(5,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-06-29 11:52:17'),(6,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-06-29 14:57:47'),(7,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-06-29 15:07:32'),(8,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-07-03 22:33:37'),(9,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-07-03 22:34:27'),(10,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-07-04 10:58:34'),(11,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-07-04 19:43:10'),(12,12,8,'Please provide the event date, venue, and logo to include in the poster design.','pending',NULL,NULL,'2026-07-04 19:56:55');
/*!40000 ALTER TABLE `ticket_modification_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_price_history`
--

DROP TABLE IF EXISTS `ticket_price_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_price_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `industor_price` decimal(12,2) DEFAULT NULL,
  `designer_price` decimal(12,2) DEFAULT NULL,
  `change_reason` varchar(30) NOT NULL DEFAULT 'normal',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ticket_price_history_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_price_history_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_price_history`
--

LOCK TABLES `ticket_price_history` WRITE;
/*!40000 ALTER TABLE `ticket_price_history` DISABLE KEYS */;
INSERT INTO `ticket_price_history` VALUES (1,18,10000.00,10000.00,7000.00,'normal','2026-06-28 16:30:21'),(2,18,10000.00,10000.00,7700.00,'urgent_increase','2026-06-28 16:33:54'),(3,19,50000.00,50000.00,35000.00,'normal','2026-06-29 12:27:43'),(4,20,22222212.00,22222212.00,15555548.40,'normal','2026-06-29 12:59:13'),(5,24,2000.00,2000.00,1400.00,'negotiation_agreed','2026-06-29 15:21:52'),(6,25,5000.00,5000.00,3500.00,'negotiation_agreed','2026-06-29 15:32:31'),(7,26,7000.00,7000.00,4900.00,'negotiation_agreed','2026-06-29 15:42:48'),(8,27,6000.00,6000.00,4200.00,'negotiation_agreed','2026-06-29 15:49:54'),(9,28,11000.00,11000.00,7700.00,'negotiation_agreed','2026-06-29 16:25:16'),(10,24,2000.00,2000.00,1540.00,'urgent_increase','2026-07-03 22:34:52'),(11,25,5000.00,5000.00,3850.00,'urgent_increase','2026-07-03 22:34:52'),(12,26,7000.00,7000.00,5390.00,'urgent_increase','2026-07-03 22:34:52');
/*!40000 ALTER TABLE `ticket_price_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_status_history`
--

DROP TABLE IF EXISTS `ticket_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_status_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `from_status` varchar(30) DEFAULT NULL,
  `to_status` varchar(30) NOT NULL,
  `changed_by` bigint(20) unsigned NOT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ticket_status_history_changed_by_foreign` (`changed_by`),
  KEY `ticket_status_history_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_status_history_changed_by_foreign` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_status_history_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_status_history`
--

LOCK TABLES `ticket_status_history` WRITE;
/*!40000 ALTER TABLE `ticket_status_history` DISABLE KEYS */;
INSERT INTO `ticket_status_history` VALUES (1,1,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:42'),(2,2,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:42'),(3,3,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:58'),(4,3,'open','accepted',8,'Ticket accepted by designer','2026-06-25 15:56:58'),(5,4,NULL,'open',12,'Ticket opened for designers','2026-06-25 14:56:58'),(6,4,'open','accepted',9,'Ticket accepted by designer','2026-06-25 15:56:58'),(7,5,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:58'),(8,5,'open','accepted',10,'Ticket accepted by designer','2026-06-25 15:56:58'),(9,5,'accepted','in_progress',10,'Deadline set, work started','2026-06-25 16:56:58'),(10,6,NULL,'open',12,'Ticket opened for designers','2026-06-25 14:56:58'),(11,6,'open','accepted',8,'Ticket accepted by designer','2026-06-25 15:56:58'),(12,6,'accepted','in_progress',8,'Deadline set, work started','2026-06-25 16:56:58'),(13,7,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:58'),(14,7,'open','accepted',9,'Ticket accepted by designer','2026-06-25 15:56:58'),(15,7,'accepted','in_progress',9,'Deadline set, work started','2026-06-25 16:56:58'),(16,7,'in_progress','awaiting_qa',9,'Deliverable uploaded','2026-06-25 18:56:58'),(17,8,NULL,'open',12,'Ticket opened for designers','2026-06-25 14:56:59'),(18,8,'open','accepted',10,'Ticket accepted by designer','2026-06-25 15:56:59'),(19,8,'accepted','in_progress',10,'Deadline set, work started','2026-06-25 16:56:59'),(20,8,'in_progress','awaiting_qa',10,'Deliverable uploaded','2026-06-25 18:56:59'),(21,9,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:59'),(22,9,'open','accepted',8,'Ticket accepted by designer','2026-06-25 15:56:59'),(23,9,'accepted','in_progress',8,'Deadline set, work started','2026-06-25 16:56:59'),(24,9,'in_progress','awaiting_qa',8,'Deliverable uploaded','2026-06-25 18:56:59'),(25,9,'awaiting_qa','completed',7,'Approved by QA','2026-06-25 21:56:59'),(26,10,NULL,'open',12,'Ticket opened for designers','2026-06-25 14:56:59'),(27,10,'open','accepted',10,'Ticket accepted by designer','2026-06-25 15:56:59'),(28,10,'accepted','in_progress',10,'Deadline set, work started','2026-06-25 16:56:59'),(29,10,'in_progress','awaiting_qa',10,'Deliverable uploaded','2026-06-25 18:56:59'),(30,10,'awaiting_qa','completed',6,'Approved by QA','2026-06-25 21:56:59'),(31,11,NULL,'open',11,'Ticket opened for designers','2026-06-25 14:56:59'),(32,11,'open','accepted',9,'Ticket accepted by designer','2026-06-25 15:56:59'),(33,11,'accepted','in_progress',9,'Deadline set, work started','2026-06-25 16:56:59'),(34,11,'in_progress','awaiting_qa',9,'Deliverable uploaded','2026-06-25 18:56:59'),(35,11,'awaiting_qa','rejected_qa',7,'Colors do not match brand guidelines. Please use the official palette.','2026-06-25 20:56:59'),(36,12,NULL,'open',12,'Ticket opened for designers','2026-06-25 14:56:59'),(37,12,'open','accepted',8,'Ticket accepted by designer','2026-06-25 15:56:59'),(38,13,NULL,'open',11,'Ticket opened for designers','2026-06-25 23:01:59'),(39,13,'open','accepted',8,'Ticket accepted by designer','2026-06-25 23:03:17'),(40,13,'accepted','modification_requested',8,'Modification requested','2026-06-25 23:03:52'),(41,13,'modification_requested','accepted',11,NULL,'2026-06-25 23:04:30'),(42,13,'accepted','in_progress',8,NULL,'2026-06-25 23:10:38'),(43,13,'in_progress','awaiting_qa',8,NULL,'2026-06-25 23:11:36'),(44,13,'in_progress','awaiting_qa',8,'Deliverable uploaded; awaiting QA','2026-06-25 23:11:36'),(45,13,'awaiting_qa','completed',6,NULL,'2026-06-25 23:13:21'),(46,14,NULL,'open',11,'Ticket opened for designers','2026-06-26 11:10:03'),(47,14,'open','accepted',8,'Ticket accepted by designer','2026-06-26 11:13:07'),(48,14,'accepted','modification_requested',8,'Modification requested','2026-06-26 11:15:44'),(49,14,'modification_requested','accepted',11,NULL,'2026-06-26 11:16:36'),(50,14,'accepted','in_progress',8,NULL,'2026-06-26 11:17:27'),(51,14,'in_progress','awaiting_qa',8,NULL,'2026-06-26 11:18:22'),(52,14,'in_progress','awaiting_qa',8,'Deliverable uploaded; awaiting QA','2026-06-26 11:18:22'),(53,14,'awaiting_qa','completed',6,NULL,'2026-06-26 11:20:14'),(54,15,NULL,'pending_review',5,'Ticket submitted for tester review','2026-06-26 14:04:59'),(55,15,'pending_review','open',6,NULL,'2026-06-26 14:07:00'),(56,15,'open','accepted',8,'Ticket accepted by designer','2026-06-26 14:09:00'),(57,16,NULL,'pending_review',5,'Single-purchase ticket submitted for tester review','2026-06-26 15:11:54'),(58,16,'pending_review','pending_payment',6,NULL,'2026-06-26 15:13:10'),(59,17,NULL,'pending_review',5,'Ticket submitted for tester review','2026-06-26 15:19:43'),(60,17,'pending_review','open',6,NULL,'2026-06-26 15:20:18'),(61,17,'open','accepted',8,'Ticket accepted by designer','2026-06-28 15:26:45'),(62,18,NULL,'pending_review',5,'Ticket submitted for tester review','2026-06-28 16:29:37'),(63,18,'pending_review','open',6,NULL,'2026-06-28 16:30:21'),(64,19,NULL,'pending_review',5,'Ticket submitted for tester review with proposed deadline','2026-06-29 12:24:23'),(65,19,'pending_review','pending_review',6,'Tester approved the proposed delivery deadline','2026-06-29 12:26:41'),(66,19,'pending_review','open',6,NULL,'2026-06-29 12:27:43'),(67,19,'open','accepted',4,'Ticket accepted by designer','2026-06-29 12:28:43'),(68,20,NULL,'pending_review',5,'Ticket submitted for tester review with proposed deadline','2026-06-29 12:51:52'),(69,20,'pending_review','waiting_industor_approval',6,'Tester proposed a new deadline - awaiting industor approval','2026-06-29 12:52:52'),(70,20,'waiting_industor_approval','pending_review',5,'Industor rejected the tester deadline','2026-06-29 12:53:19'),(71,20,'pending_review','waiting_industor_approval',6,'Tester proposed a new deadline - awaiting industor approval','2026-06-29 12:54:17'),(72,20,'waiting_industor_approval','pending_review',5,'Industor accepted the tester deadline','2026-06-29 12:54:43'),(73,20,'pending_review','open',6,NULL,'2026-06-29 12:59:13'),(74,21,NULL,'pending_review',5,'Ticket submitted for tester review with proposed deadline','2026-06-29 13:49:09'),(75,21,'pending_review','pending_review',6,'Tester approved the proposed delivery deadline','2026-06-29 13:49:50'),(76,1,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:46'),(77,2,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:46'),(78,3,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(79,4,NULL,'approved_by_tester',12,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(80,5,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(81,6,NULL,'approved_by_tester',12,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(82,7,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(83,8,NULL,'approved_by_tester',12,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(84,9,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(85,10,NULL,'approved_by_tester',12,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(86,11,NULL,'approved_by_tester',11,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(87,12,NULL,'approved_by_tester',12,'Ticket approved and opened for designers','2026-06-29 06:57:47'),(88,24,NULL,'pending_tester_review',5,'Ticket submitted for tester review with proposed deadline & price','2026-06-29 15:11:43'),(89,24,'pending_tester_review','waiting_industor_approval',6,NULL,'2026-06-29 15:13:19'),(90,24,'waiting_industor_approval','waiting_tester_review',5,NULL,'2026-06-29 15:14:47'),(91,24,'waiting_tester_review','approved_by_tester',6,NULL,'2026-06-29 15:21:52'),(92,25,NULL,'pending_tester_review',5,'Ticket submitted for tester review with proposed deadline & price','2026-06-29 15:27:29'),(93,25,'pending_tester_review','approved_by_tester',6,NULL,'2026-06-29 15:32:32'),(94,26,NULL,'pending_tester_review',5,'Ticket submitted for tester review with proposed deadline & price','2026-06-29 15:41:01'),(95,26,'pending_tester_review','waiting_industor_approval',6,NULL,'2026-06-29 15:41:52'),(96,26,'waiting_industor_approval','waiting_tester_review',5,NULL,'2026-06-29 15:42:25'),(97,26,'waiting_tester_review','approved_by_tester',6,NULL,'2026-06-29 15:42:48'),(98,27,NULL,'pending_tester_review',5,'Ticket submitted for tester review with proposed deadline & price','2026-06-29 15:49:41'),(99,27,'pending_tester_review','approved_by_tester',6,NULL,'2026-06-29 15:49:54'),(100,28,NULL,'pending_tester_review',5,'Ticket submitted for tester review with proposed deadline & price','2026-06-29 16:22:53'),(101,28,'pending_tester_review','waiting_industor_approval',6,NULL,'2026-06-29 16:24:03'),(102,28,'waiting_industor_approval','waiting_tester_review',5,NULL,'2026-06-29 16:24:46'),(103,28,'waiting_tester_review','approved_by_tester',6,NULL,'2026-06-29 16:25:16'),(104,28,'approved_by_tester','accepted',4,'Ticket accepted by designer','2026-06-29 16:26:11'),(105,28,'accepted','awaiting_qa',4,NULL,'2026-06-29 16:26:29'),(106,28,'accepted','awaiting_qa',4,'Deliverable uploaded; awaiting QA','2026-06-29 16:26:29'),(107,28,'awaiting_qa','completed',6,NULL,'2026-06-29 16:27:41'),(108,20,'approved_by_tester','accepted',4,'Ticket accepted by designer','2026-06-29 16:29:11'),(109,18,'approved_by_tester','accepted',4,'Ticket accepted by designer','2026-06-29 16:29:31'),(110,20,'accepted','awaiting_qa',4,NULL,'2026-06-29 16:29:49'),(111,20,'accepted','awaiting_qa',4,'Deliverable uploaded; awaiting QA','2026-06-29 16:29:49'),(112,20,'awaiting_qa','completed',6,NULL,'2026-06-29 16:30:17'),(113,27,'approved_by_tester','accepted',4,'Ticket accepted by designer','2026-06-29 16:30:44'),(114,18,'accepted','awaiting_qa',4,NULL,'2026-06-29 16:31:42'),(115,18,'accepted','awaiting_qa',4,'Deliverable uploaded after deadline; awaiting QA','2026-06-29 16:31:42'),(116,18,'awaiting_qa','rejected_qa',6,NULL,'2026-06-29 16:32:54'),(117,18,'rejected_qa','awaiting_qa',4,NULL,'2026-06-29 16:35:02'),(118,18,'rejected_qa','awaiting_qa',4,'Deliverable uploaded after deadline; awaiting QA','2026-06-29 16:35:02'),(119,18,'awaiting_qa','rejected_qa',6,NULL,'2026-06-29 16:35:32');
/*!40000 ALTER TABLE `ticket_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `industor_id` bigint(20) unsigned NOT NULL,
  `subscription_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `industor_price` decimal(12,2) DEFAULT NULL,
  `designer_price` decimal(12,2) DEFAULT NULL,
  `price_updated_at` timestamp NULL DEFAULT NULL,
  `urgent_price_applied` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(30) NOT NULL DEFAULT 'new',
  `tester_id` bigint(20) unsigned DEFAULT NULL,
  `reviewed_by` bigint(20) unsigned DEFAULT NULL,
  `designer_id` bigint(20) unsigned DEFAULT NULL,
  `deadline` timestamp NULL DEFAULT NULL,
  `industor_expected_deadline` timestamp NULL DEFAULT NULL,
  `industor_expected_price` decimal(12,2) DEFAULT NULL,
  `tester_suggested_deadline` timestamp NULL DEFAULT NULL,
  `tester_suggested_price` decimal(12,2) DEFAULT NULL,
  `industor_counter_deadline` timestamp NULL DEFAULT NULL,
  `industor_counter_price` decimal(12,2) DEFAULT NULL,
  `final_deadline` timestamp NULL DEFAULT NULL,
  `final_price` decimal(12,2) DEFAULT NULL,
  `deadline_approved_by_industor` tinyint(1) NOT NULL DEFAULT 0,
  `current_negotiation_round` int(11) NOT NULL DEFAULT 0,
  `negotiation_status` varchar(30) NOT NULL DEFAULT 'waiting_tester_review',
  `deadline_negotiation_history` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`deadline_negotiation_history`)),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT NULL,
  `qa_claimed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `review_notes` text DEFAULT NULL,
  `is_published_to_store` tinyint(1) NOT NULL DEFAULT 0,
  `is_late` tinyint(1) NOT NULL DEFAULT 0,
  `penalty` decimal(10,2) DEFAULT NULL,
  `penalty_reason` text DEFAULT NULL,
  `store_listing_id` bigint(20) unsigned DEFAULT NULL,
  `is_single_purchase` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tickets_subscription_id_foreign` (`subscription_id`),
  KEY `tickets_status_index` (`status`),
  KEY `tickets_industor_id_index` (`industor_id`),
  KEY `tickets_designer_id_index` (`designer_id`),
  KEY `tickets_tester_id_index` (`tester_id`),
  KEY `tickets_store_listing_id_foreign` (`store_listing_id`),
  KEY `tickets_reviewed_by_foreign` (`reviewed_by`),
  CONSTRAINT `tickets_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `tickets_industor_id_foreign` FOREIGN KEY (`industor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tickets_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `tickets_store_listing_id_foreign` FOREIGN KEY (`store_listing_id`) REFERENCES `store_listings` (`id`) ON DELETE SET NULL,
  CONSTRAINT `tickets_subscription_id_foreign` FOREIGN KEY (`subscription_id`) REFERENCES `user_subscriptions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `tickets_tester_id_foreign` FOREIGN KEY (`tester_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES (1,11,1,'Logo design for new brand','Need a minimalist logo for a startup brand...',NULL,NULL,NULL,NULL,NULL,0,'approved_by_tester',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:42','2026-06-25 22:56:42'),(2,11,1,'Product packaging concept','Box design for premium tea product...',NULL,NULL,NULL,NULL,NULL,0,'approved_by_tester',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:42','2026-06-25 22:56:42'),(3,11,1,'Social media template pack','10 Instagram post templates for marketing...',NULL,NULL,NULL,NULL,NULL,0,'accepted',NULL,NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:58',NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:58','2026-06-25 22:56:58'),(4,12,2,'Brochure tri-fold design','Marketing brochure for factory tour...',NULL,NULL,NULL,NULL,NULL,0,'accepted',NULL,NULL,9,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:58',NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:58','2026-06-25 22:56:58'),(5,11,1,'3D product render','Photorealistic render of a modern chair...',NULL,NULL,NULL,NULL,NULL,0,'in_progress',NULL,NULL,10,'2026-06-28 22:56:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:58','2026-06-25 16:56:58',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:58','2026-06-25 22:56:58'),(6,12,2,'UI kit for mobile app','Complete Figma UI kit with 50 screens...',NULL,NULL,NULL,NULL,NULL,0,'in_progress',NULL,NULL,8,'2026-06-28 22:56:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:58','2026-06-25 16:56:58',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:58','2026-06-25 22:56:58'),(7,11,1,'Vector icon set','50 line-style icons for a dashboard...',NULL,NULL,NULL,NULL,NULL,0,'awaiting_qa',6,NULL,9,'2026-06-28 22:56:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:58','2026-06-25 16:56:58','2026-06-25 18:56:58','2026-06-25 23:09:44',NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:58','2026-06-25 23:09:44'),(8,12,2,'Brand guideline document','Full brand book with colors and fonts...',NULL,NULL,NULL,NULL,NULL,0,'awaiting_qa',6,NULL,10,'2026-06-28 22:56:59',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:59','2026-06-25 16:56:59','2026-06-25 18:56:59','2026-06-25 23:09:31',NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:59','2026-06-25 23:09:31'),(9,11,1,'Catalog layout design','32-page product catalog...',NULL,NULL,NULL,NULL,NULL,0,'completed',7,NULL,8,'2026-06-28 22:56:59',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:59','2026-06-25 16:56:59','2026-06-25 18:56:59','2026-06-25 19:56:59','2026-06-25 21:56:59',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(10,12,2,'Safety signage set','Industrial safety signs for a factory...',NULL,NULL,NULL,NULL,NULL,0,'completed',6,NULL,10,'2026-06-28 22:56:59',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:59','2026-06-25 16:56:59','2026-06-25 18:56:59','2026-06-25 19:56:59','2026-06-25 21:56:59',NULL,NULL,1,0,NULL,NULL,1,0,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(11,11,1,'Rejected sample design','Test design that got rejected by QA...',NULL,NULL,NULL,NULL,NULL,0,'rejected_qa',7,NULL,9,'2026-06-28 22:56:59',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:59','2026-06-25 16:56:59','2026-06-25 18:56:59','2026-06-25 19:56:59',NULL,'Colors do not match brand guidelines. Please use the official palette.',NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(12,12,2,'Poster design for event','Event poster for a tech conference...',NULL,NULL,NULL,NULL,NULL,0,'modification_requested',NULL,NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 15:56:59',NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 22:56:59','2026-06-25 22:56:59'),(13,11,1,'ssssssssssssssssssssss','sssssssssssssssssssssssssssssss',NULL,NULL,NULL,NULL,NULL,0,'completed',6,NULL,8,'2026-06-25 23:11:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-25 23:04:30','2026-06-25 23:10:38','2026-06-25 23:11:36','2026-06-25 23:13:08','2026-06-25 23:13:20',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-25 23:01:59','2026-06-25 23:13:20'),(14,11,1,'capital-metal','asdfl;fkasdklfjas;lfdkdsjfkvjdsvjkds\ndsoflsdlk.fsdJF',NULL,NULL,NULL,NULL,NULL,0,'completed',6,NULL,8,'2026-06-26 11:18:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,NULL,NULL,NULL,'2026-06-26 11:16:36','2026-06-26 11:17:27','2026-06-26 11:18:22','2026-06-26 11:19:43','2026-06-26 11:20:14',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-26 11:10:03','2026-06-26 11:20:14'),(15,5,9,'vgkvlbhbh000000000','ukjgjkbjnl;kk0000000000000000000',2000.00,NULL,NULL,NULL,NULL,0,'accepted',NULL,6,8,'2026-07-01 14:06:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,'2026-06-26 14:07:00',NULL,NULL,'2026-06-26 14:09:00',NULL,NULL,NULL,NULL,NULL,'2222222222222222222',0,0,NULL,NULL,NULL,0,'2026-06-26 14:04:59','2026-06-26 14:09:00'),(16,5,NULL,'شسينسشزؤةسشنىؤشسنم','ةسسشنبمةىريسنىريسنمىيسنروىسينرىيسنمرىيسم',5000.00,NULL,NULL,NULL,NULL,0,'accepted',NULL,6,NULL,'2026-07-01 15:12:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,'2026-06-26 15:13:10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ASASCS2',0,0,NULL,NULL,NULL,1,'2026-06-26 15:11:54','2026-06-26 15:13:10'),(17,5,9,'alsd,pw222222222222222222222222222221','21LF,SLD;FLDFMSDSSSSSSFDSF',50000.00,NULL,NULL,NULL,NULL,0,'accepted',NULL,6,8,'2026-06-28 15:32:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,'2026-06-28 15:20:18',NULL,NULL,'2026-06-28 15:26:45',NULL,NULL,NULL,NULL,NULL,'SDASCCAS',0,0,NULL,NULL,NULL,0,'2026-06-26 15:19:43','2026-06-28 15:26:45'),(18,5,9,'hjghkbhjkbjkhghjvhvvg','khkj.nlklikhj/kljklhi',10000.00,10000.00,10000.00,7700.00,'2026-06-28 16:33:54',1,'rejected_qa',6,6,4,'2026-06-28 16:46:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'waiting_tester_review',NULL,'2026-06-28 16:42:37',NULL,NULL,'2026-06-29 16:29:31',NULL,'2026-06-29 16:35:02','2026-06-29 16:32:08',NULL,'وحش برضوا','00000000000000000',0,1,200.00,'وحش اوي عدل',NULL,0,'2026-06-28 16:29:37','2026-06-29 16:35:32'),(19,5,9,'dasdadcvfdbf','fdgrw211323gbfbxv',50000.00,50000.00,50000.00,35000.00,'2026-06-29 12:27:43',0,'accepted',NULL,6,4,'2026-06-29 22:00:00','2026-06-29 22:00:00',NULL,NULL,NULL,NULL,NULL,'2026-06-29 22:00:00',NULL,1,0,'waiting_tester_review','[{\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T12:24:23+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"proposed_deadline\": \"2026-06-29T22:00:00+00:00\"}]','2026-06-29 12:27:43',NULL,NULL,'2026-06-29 12:28:43',NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 12:24:23','2026-06-29 12:28:43'),(20,5,9,'.v.cv,xzlc,vZCXL;MDVLAS;,D21W','dsl,dvmal\'qwlwml21,lA,CSAL;CM',22222212.00,22222212.00,22222212.00,15555548.40,'2026-06-29 12:59:13',0,'completed',6,6,4,'2026-07-01 22:00:00','2026-06-30 10:01:00',NULL,'2026-07-01 22:00:00',NULL,NULL,NULL,'2026-07-01 22:00:00',NULL,1,0,'waiting_tester_review','[{\"reason\": null, \"status\": \"pending\", \"created_at\": \"2026-06-29T12:51:52+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"proposed_deadline\": \"2026-06-30T10:01:00+00:00\"}, {\"reason\": \"RNMKVLLVLDSMVSD\", \"status\": \"rejected\", \"created_at\": \"2026-06-29T12:52:52+00:00\", \"created_by\": 6, \"proposed_by\": \"tester\", \"proposed_deadline\": \"2026-07-03T10:00:00+00:00\"}, {\"reason\": \"دا  اخر حاجه عشان نلحق\", \"status\": \"accepted\", \"created_at\": \"2026-06-29T12:54:17+00:00\", \"created_by\": 6, \"proposed_by\": \"tester\", \"proposed_deadline\": \"2026-07-01T22:00:00+00:00\"}]','2026-06-29 12:59:13',NULL,NULL,'2026-06-29 16:29:11',NULL,'2026-06-29 16:29:49','2026-06-29 16:29:57','2026-06-29 16:30:17',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 12:51:52','2026-06-29 16:30:17'),(21,5,9,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,','00000000000000000000000000000000000000000000000',NULL,NULL,NULL,NULL,NULL,0,'pending_tester_review',NULL,NULL,NULL,NULL,'2026-07-01 13:48:00',NULL,NULL,NULL,NULL,NULL,'2026-07-01 13:48:00',NULL,1,0,'waiting_tester_review','[{\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T13:49:09+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"proposed_deadline\": \"2026-07-01T13:48:00+00:00\"}]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 13:49:09','2026-06-29 13:49:50'),(24,5,9,'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm','mmmmmmmmmmmmmssssssssssssssssssssssssssssmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm',2000.00,2000.00,2000.00,1540.00,'2026-07-03 22:34:52',1,'approved_by_tester',NULL,6,NULL,'2026-07-02 15:14:00','2026-06-30 22:00:00',2000.00,NULL,NULL,'2026-07-02 15:14:00',2000.00,'2026-07-02 15:14:00',2000.00,0,2,'approved','[{\"reason\": null, \"status\": \"pending\", \"created_at\": \"2026-06-29T15:11:42+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 2000, \"proposed_deadline\": \"2026-06-30T22:00:00+00:00\"}, {\"reason\": \"done\", \"status\": \"rejected\", \"created_at\": \"2026-06-29T15:13:19+00:00\", \"created_by\": 6, \"proposed_by\": \"tester\", \"round_number\": 1, \"proposed_price\": 2500, \"proposed_deadline\": \"2026-07-01T15:13:00+00:00\"}, {\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T15:14:47+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 2, \"proposed_price\": 2000, \"proposed_deadline\": \"2026-07-02T15:14:00+00:00\"}]','2026-06-29 15:21:52',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 15:11:42','2026-07-03 22:34:52'),(25,5,9,'00000000000','555555555',5000.00,5000.00,5000.00,3850.00,'2026-07-03 22:34:52',1,'approved_by_tester',NULL,6,NULL,'2026-07-03 10:00:00','2026-07-03 10:00:00',5000.00,NULL,NULL,NULL,NULL,'2026-07-03 10:00:00',5000.00,0,0,'approved','[{\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T15:27:29+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 5000, \"proposed_deadline\": \"2026-07-03T10:00:00+00:00\"}]','2026-06-29 15:32:31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 15:27:29','2026-07-03 22:34:52'),(26,5,9,'Capital-Metal','asdlk[adsfkdjkdsjf',7000.00,7000.00,7000.00,5390.00,'2026-07-03 22:34:52',1,'approved_by_tester',NULL,6,NULL,'2026-07-04 15:42:00','2026-07-03 22:00:00',5555.00,NULL,NULL,'2026-07-04 15:42:00',7000.00,'2026-07-04 15:42:00',7000.00,0,2,'approved','[{\"reason\": null, \"status\": \"pending\", \"created_at\": \"2026-06-29T15:41:01+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 5555, \"proposed_deadline\": \"2026-07-03T22:00:00+00:00\"}, {\"reason\": null, \"status\": \"rejected\", \"created_at\": \"2026-06-29T15:41:52+00:00\", \"created_by\": 6, \"proposed_by\": \"tester\", \"round_number\": 1, \"proposed_price\": 6666, \"proposed_deadline\": \"2026-07-08T17:44:00+00:00\"}, {\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T15:42:24+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 2, \"proposed_price\": 7000, \"proposed_deadline\": \"2026-07-04T15:42:00+00:00\"}]','2026-06-29 15:42:48',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 15:41:01','2026-07-03 22:34:52'),(27,5,9,'سسسسسسسسسسسس','يييييييييييييييييييييييي',6000.00,6000.00,6000.00,4200.00,'2026-06-29 15:49:54',0,'accepted',NULL,6,4,'2026-07-03 23:00:00','2026-07-03 23:00:00',6000.00,NULL,NULL,NULL,NULL,'2026-07-03 23:00:00',6000.00,0,0,'approved','[{\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T15:49:41+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 6000, \"proposed_deadline\": \"2026-07-03T23:00:00+00:00\"}]','2026-06-29 15:49:54',NULL,NULL,'2026-06-29 16:30:44',NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 15:49:41','2026-06-29 16:30:44'),(28,5,9,'فارس ديزاااااين','مشروع العمر',11000.00,11000.00,11000.00,7700.00,'2026-06-29 16:25:16',0,'completed',6,6,4,'2026-07-04 16:24:00','2026-07-03 22:00:00',10000.00,NULL,NULL,'2026-07-04 16:24:00',11000.00,'2026-07-04 16:24:00',11000.00,0,2,'approved','[{\"reason\": null, \"status\": \"pending\", \"created_at\": \"2026-06-29T16:22:53+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 10000, \"proposed_deadline\": \"2026-07-03T22:00:00+00:00\"}, {\"reason\": \"الدايرز مشغول\", \"status\": \"rejected\", \"created_at\": \"2026-06-29T16:24:03+00:00\", \"created_by\": 6, \"proposed_by\": \"tester\", \"round_number\": 1, \"proposed_price\": 8000, \"proposed_deadline\": \"2026-07-05T16:23:00+00:00\"}, {\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-06-29T16:24:46+00:00\", \"created_by\": 5, \"proposed_by\": \"industor\", \"round_number\": 2, \"proposed_price\": 11000, \"proposed_deadline\": \"2026-07-04T16:24:00+00:00\"}]','2026-06-29 16:25:16',NULL,NULL,'2026-06-29 16:26:11',NULL,'2026-06-29 16:26:29','2026-06-29 16:26:51','2026-06-29 16:27:41',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-06-29 16:22:53','2026-06-29 16:27:41');
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `traffic_sources`
--

DROP TABLE IF EXISTS `traffic_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `traffic_sources` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `source_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `traffic_sources_source_name_unique` (`source_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `traffic_sources`
--

LOCK TABLES `traffic_sources` WRITE;
/*!40000 ALTER TABLE `traffic_sources` DISABLE KEYS */;
INSERT INTO `traffic_sources` VALUES (1,'Direct'),(3,'Facebook'),(2,'Google'),(4,'Instagram'),(5,'Twitter');
/*!40000 ALTER TABLE `traffic_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_roles_user_id_role_id_unique` (`user_id`,`role_id`),
  KEY `user_roles_role_id_foreign` (`role_id`),
  CONSTRAINT `user_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscriptions`
--

DROP TABLE IF EXISTS `user_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `plan_id` int(10) unsigned NOT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'active',
  `approval_status` varchar(20) NOT NULL DEFAULT 'pending',
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `paymob_transaction_id` varchar(100) DEFAULT NULL,
  `tickets_remaining` int(11) NOT NULL DEFAULT 0,
  `tickets_used` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user_subscriptions_user_id_foreign` (`user_id`),
  KEY `user_subscriptions_plan_id_foreign` (`plan_id`),
  KEY `user_subscriptions_approved_by_foreign` (`approved_by`),
  KEY `user_subscriptions_approval_status_index` (`approval_status`),
  CONSTRAINT `user_subscriptions_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_subscriptions_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_subscriptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
INSERT INTO `user_subscriptions` VALUES (1,11,2,'2026-06-20 22:56:42','2026-07-20 22:56:42','active','approved',1,'2026-06-21 22:56:42',NULL,NULL,15,5),(2,12,3,'2026-06-20 22:56:42','2026-07-20 22:56:42','active','approved',1,'2026-06-21 22:56:42',NULL,NULL,96,4),(3,13,1,'2026-06-20 22:56:42','2026-07-20 22:56:42','cancelled','rejected',1,'2026-06-26 14:04:07',NULL,NULL,5,0),(4,13,2,'2026-06-20 22:56:42','2026-07-20 22:56:42','cancelled','rejected',1,'2026-06-22 22:56:42','Please upgrade to a paid plan for production use.',NULL,20,0),(5,5,2,'2026-06-26 12:23:36','2026-07-26 12:23:36','cancelled','rejected',1,'2026-06-26 14:04:07',NULL,NULL,20,0),(6,5,1,'2026-06-26 12:24:05','2026-07-26 12:24:05','cancelled','rejected',1,'2026-06-26 14:04:06',NULL,NULL,5,0),(7,5,2,'2026-06-26 12:24:27','2026-07-26 12:24:27','cancelled','rejected',1,'2026-06-26 14:04:06',NULL,NULL,20,0),(8,5,3,'2026-06-26 12:24:40','2026-07-26 12:24:40','cancelled','rejected',1,'2026-06-26 14:04:06',NULL,NULL,100,0),(9,5,2,'2026-06-26 14:03:36','2026-07-26 14:03:36','active','approved',1,'2026-06-26 14:04:03',NULL,NULL,9,11),(10,13,1,'2026-06-24 11:52:17','2026-07-24 11:52:17','active','pending',NULL,NULL,NULL,NULL,5,0);
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `two_factor_secret` varchar(255) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expiry` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role_id` bigint(20) unsigned DEFAULT NULL,
  `currency_preference` varchar(3) NOT NULL DEFAULT 'EGP',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin','admin@capitalmetal.com',NULL,'$2y$12$TrEP2FV4sOwfGDIXdF7eHuYpHc5WCSlLy0oH/LPgQckeWXpHiYN3W','01000000001',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-07-04 12:19:41',1,'EGP'),(2,'Regular User','user@capitalmetal.com',NULL,'$2y$12$11FpdzEN1lLDmXAPSRjUzuBdAPY2R4dkycOp0iV7R0MALYFnhTd8u','01000000002',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47',2,'EGP'),(3,'Tester','tester@capitalmetal.com',NULL,'$2y$12$8vdzoNV9wBS.S5Ho0jY0i.4OYAoBvYv399ht6FL8u/2hVdymjViDO','01000000003',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47',3,'EGP'),(4,'Designer','designer@capitalmetal.com',NULL,'$2y$12$Hm.e.W4PQvYjFoyqnvXC/O6BVM2nk8MteGTUepTvzukUTHQw0oH7y','01000000004',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:48','2026-06-25 20:31:48',4,'EGP'),(5,'Industor','industor@capitalmetal.com',NULL,'$2y$12$bT0Hsq2eNE9pLOm2Ah358eBHMPWQsDFg1Y4KGdaQbFb43N.sCuOei','01000000005',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:48','2026-06-25 20:31:48',5,'EGP'),(6,'Tester One','tester1@capitalmetal.com',NULL,'$2y$12$J2ONNaaNCPz3npyJ4jdiheaIuaceWyc25iuT64vCJzh76qDkI.fku','01095731382',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:30','2026-06-25 22:26:30',3,'EGP'),(7,'Tester Two','tester2@capitalmetal.com',NULL,'$2y$12$7v08poTYP2vXriJQ3X0tX.Wl/86uoDL0xo6bU.89zUFBnJGalJOpK','01038509330',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:30','2026-06-25 22:26:30',3,'EGP'),(8,'Designer Ahmed','designer1@capitalmetal.com',NULL,'$2y$12$BVK4mbTMHa7haVeqktawueirQNUBpbU2yNh6pWETWKAxK5rbbJ71O','01037489826',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(9,'Designer Sara','designer2@capitalmetal.com',NULL,'$2y$12$p.c9rRNy6X7JyO3Y3y5mq.E2SEROHEG8vIjAq7f56ffr6ViP21KQG','01027285132',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(10,'Designer Omar','designer3@capitalmetal.com',NULL,'$2y$12$y.DWgpYIi/ilSaJfp0qI.ucJLFOUqdmmJ7CH16IcSg/aYXX4Sw8MK','01045678773',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(11,'Industor Khaled','industor1@capitalmetal.com',NULL,'$2y$12$1f9cJN0reeL1/uMO3z.oWOVC2I1LrlS5JWTxNYlIBaHeGD67bpRca','01099519212',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',5,'EGP'),(12,'Industor Mona','industor2@capitalmetal.com',NULL,'$2y$12$HsSCfLXAHSW1W9CZnJZNsOPvFUoahz6U4kFG5AcTDmjXXrq2mwnzm','01022838284',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',5,'EGP'),(13,'Industor Ali','industor3@capitalmetal.com',NULL,'$2y$12$XSSaePz1A7M8zP.Y26o.kOh3Bp4H6lqwUv.2hcJmtIpZHS1BoWkoe','01035146673',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:56:42','2026-06-25 22:56:42',5,'EGP'),(14,'yousef','yousef@gmail.com',NULL,'$2y$12$cMFhJPoPWbwKUBfA./Gfn.Fl1u50eh0bbzsPGOKL3KQyiFdfsxX3u',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-04 11:26:27','2026-07-04 12:07:04',5,'USD');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_sessions`
--

DROP TABLE IF EXISTS `visitor_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitor_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `traffic_source_id` int(10) unsigned DEFAULT NULL,
  `device_type` varchar(50) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `converted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `visitor_sessions_user_id_foreign` (`user_id`),
  KEY `visitor_sessions_traffic_source_id_foreign` (`traffic_source_id`),
  CONSTRAINT `visitor_sessions_traffic_source_id_foreign` FOREIGN KEY (`traffic_source_id`) REFERENCES `traffic_sources` (`id`) ON DELETE SET NULL,
  CONSTRAINT `visitor_sessions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_sessions`
--

LOCK TABLES `visitor_sessions` WRITE;
/*!40000 ALTER TABLE `visitor_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlist` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wishlist_user_id_product_id_unique` (`user_id`,`product_id`),
  KEY `wishlist_product_id_foreign` (`product_id`),
  CONSTRAINT `wishlist_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `wishlist_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
INSERT INTO `wishlist` VALUES (8,2,1),(2,2,2),(3,2,3),(4,2,4),(5,11,3),(6,11,4),(7,11,5);
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'u176871744_CapitalMetal'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-28  8:45:34
