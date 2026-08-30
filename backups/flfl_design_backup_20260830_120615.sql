-- MySQL dump 10.13  Distrib 8.0.46, for Linux (aarch64)
--
-- Host: localhost    Database: flfl_design
-- ------------------------------------------------------
-- Server version	8.0.46

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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `full_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `governorate` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address_line` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_user_id_foreign` (`user_id`),
  CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,2,'Regular User','01000000002','Egypt','Cairo','New Cairo','123 Main Street, Apartment 5','11835',1,NULL),(2,1,'youssef','10180259','Egypt','cairo','matarai','37 streat 7masimi kablat','145459',0,NULL),(3,15,'يوسف','01111555','Egypt','Cairo','مطريه','37  شارع ترعه','8888',0,NULL),(4,15,'yousef','01023122','Egypt','Cairo','ccccc','37 ترعة الخماسين','23123',1,NULL),(6,16,'yoooosef','01001010010','Egypt','Giza','dasdsd','asdsdasdsad99dsa',NULL,0,NULL),(7,1,'scascsca','0111000','Egypt','Qalyubia','casca','sacscas',NULL,0,NULL),(8,1,'sadss','01001111111','Egypt','Alexandria','sadsdd','asdasdasd','sa',0,NULL),(9,21,'fares','2010558896','Egypt','Assiut','Cairo','6 elabnasy street manshyat elbakry new cairo','3753450',0,NULL),(10,21,'Fares Safwat Sabra','20105569547','Egypt','Minya','Cairo','6 elabnasy street manshyat elbakry new cairo','3753450',1,NULL),(11,22,'Jdjdjd','02929392','Egypt','Gharbia','Uusud','Jrjrjdjd',NULL,1,NULL),(12,1,'test','01022','Egypt','Giza','hbvvggv','test','0511565',1,NULL),(13,16,'Jcjd','Hdjd','Egypt','Cairo','Jdjdjd','Jdjdj','727621',1,NULL);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `affiliate_earnings`
--

DROP TABLE IF EXISTS `affiliate_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `affiliate_earnings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `affiliate_id` bigint unsigned NOT NULL,
  `order_id` bigint unsigned NOT NULL,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `amount` double NOT NULL DEFAULT '0',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `referral_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('flfl_design_cache_illuminate:queue:restart','i:1786554729;',2101914729),('flfl_design_cache_live_egp_to_usd_rate','s:9:\"50.250989\";',1788093477),('flfl_design_cache_stox_areas','a:350:{i:0;a:5:{s:2:\"id\";i:122;s:4:\"name\";s:20:\"10th of Ramadan City\";s:7:\"ar_name\";s:28:\"العاشر من رمضان\";s:7:\"en_name\";s:20:\"10th of Ramadan City\";s:6:\"active\";b:1;}i:1;a:5:{s:2:\"id\";i:320;s:4:\"name\";s:11:\"15 May City\";s:7:\"ar_name\";s:11:\"15 مايو\";s:7:\"en_name\";s:11:\"15 May City\";s:6:\"active\";b:1;}i:2;a:5:{s:2:\"id\";i:290;s:4:\"name\";s:14:\"6th of October\";s:7:\"ar_name\";s:14:\"6 اكتوبر\";s:7:\"en_name\";s:14:\"6th of October\";s:6:\"active\";b:1;}i:3;a:5:{s:2:\"id\";i:331;s:4:\"name\";s:8:\"Abbasiya\";s:7:\"ar_name\";s:16:\"العباسية\";s:7:\"en_name\";s:8:\"Abbasiya\";s:6:\"active\";b:1;}i:4;a:5:{s:2:\"id\";i:270;s:4:\"name\";s:6:\"Abboud\";s:7:\"ar_name\";s:8:\"عبود\";s:7:\"en_name\";s:6:\"Abboud\";s:6:\"active\";b:1;}i:5;a:5:{s:2:\"id\";i:349;s:4:\"name\";s:6:\"Abdeen\";s:7:\"ar_name\";s:12:\"عابدين\";s:7:\"en_name\";s:6:\"Abdeen\";s:6:\"active\";b:1;}i:6;a:5:{s:2:\"id\";i:200;s:4:\"name\";s:5:\"Abnub\";s:7:\"ar_name\";s:10:\"أبنوب\";s:7:\"en_name\";s:5:\"Abnub\";s:6:\"active\";b:1;}i:7;a:5:{s:2:\"id\";i:372;s:4:\"name\";s:10:\"Abo Zaabal\";s:7:\"ar_name\";s:15:\"ابو زعبل\";s:7:\"en_name\";s:10:\"Abo Zaabal\";s:6:\"active\";b:1;}i:8;a:5:{s:2:\"id\";i:111;s:4:\"name\";s:10:\"Abu Hammad\";s:7:\"ar_name\";s:15:\"أبو حماد\";s:7:\"en_name\";s:10:\"Abu Hammad\";s:6:\"active\";b:1;}i:9;a:5:{s:2:\"id\";i:65;s:4:\"name\";s:10:\"Abu Hummus\";s:7:\"ar_name\";s:13:\"أبو حمص\";s:7:\"en_name\";s:10:\"Abu Hummus\";s:6:\"active\";b:1;}i:10;a:5:{s:2:\"id\";i:110;s:4:\"name\";s:9:\"Abu Kebir\";s:7:\"ar_name\";s:15:\"ابو كبير\";s:7:\"en_name\";s:9:\"Abu Kebir\";s:6:\"active\";b:1;}i:11;a:5:{s:2:\"id\";i:281;s:4:\"name\";s:10:\"Abu Nomros\";s:7:\"ar_name\";s:19:\"ابو النمرس\";s:7:\"en_name\";s:10:\"Abu Nomros\";s:6:\"active\";b:1;}i:12;a:5:{s:2:\"id\";i:38;s:4:\"name\";s:7:\"Abu Qir\";s:7:\"ar_name\";s:12:\"ابوقير\";s:7:\"en_name\";s:7:\"Abu Qir\";s:6:\"active\";b:1;}i:13;a:5:{s:2:\"id\";i:191;s:4:\"name\";s:10:\"Abu Qirqas\";s:7:\"ar_name\";s:17:\"ابو قرقاص\";s:7:\"en_name\";s:10:\"Abu Qirqas\";s:6:\"active\";b:1;}i:14;a:5:{s:2:\"id\";i:162;s:4:\"name\";s:9:\"Abu Radis\";s:7:\"ar_name\";s:15:\"ابو رديس\";s:7:\"en_name\";s:9:\"Abu Radis\";s:6:\"active\";b:1;}i:15;a:5:{s:2:\"id\";i:256;s:4:\"name\";s:10:\"Abu Rawash\";s:7:\"ar_name\";s:15:\"ابو رواش\";s:7:\"en_name\";s:10:\"Abu Rawash\";s:6:\"active\";b:1;}i:16;a:5:{s:2:\"id\";i:242;s:4:\"name\";s:9:\"Abu Suwir\";s:7:\"ar_name\";s:15:\"ابو صوير\";s:7:\"en_name\";s:9:\"Abu Suwir\";s:6:\"active\";b:1;}i:17;a:5:{s:2:\"id\";i:12;s:4:\"name\";s:9:\"Abu Tesht\";s:7:\"ar_name\";s:13:\"ابو تشت\";s:7:\"en_name\";s:9:\"Abu Tesht\";s:6:\"active\";b:1;}i:18;a:5:{s:2:\"id\";i:198;s:4:\"name\";s:7:\"Abu Tig\";s:7:\"ar_name\";s:13:\"ابو تيج\";s:7:\"en_name\";s:7:\"Abu Tig\";s:6:\"active\";b:1;}i:19;a:5:{s:2:\"id\";i:163;s:4:\"name\";s:10:\"Abu Zenima\";s:7:\"ar_name\";s:17:\"ابو زنيمة\";s:7:\"en_name\";s:10:\"Abu Zenima\";s:6:\"active\";b:1;}i:20;a:5:{s:2:\"id\";i:66;s:4:\"name\";s:14:\"Abu al-Matamir\";s:7:\"ar_name\";s:23:\"أبو المطامير\";s:7:\"en_name\";s:14:\"Abu al-Matamir\";s:6:\"active\";b:1;}i:21;a:5:{s:2:\"id\";i:83;s:4:\"name\";s:3:\"Aga\";s:7:\"ar_name\";s:6:\"اجا\";s:7:\"en_name\";s:3:\"Aga\";s:6:\"active\";b:1;}i:22;a:5:{s:2:\"id\";i:275;s:4:\"name\";s:6:\"Agouza\";s:7:\"ar_name\";s:14:\"العجوزة\";s:7:\"en_name\";s:6:\"Agouza\";s:6:\"active\";b:1;}i:23;a:5:{s:2:\"id\";i:321;s:4:\"name\";s:11:\"Ain Al-Sira\";s:7:\"ar_name\";s:19:\"عين الصيرة\";s:7:\"en_name\";s:11:\"Ain Al-Sira\";s:6:\"active\";b:1;}i:24;a:5:{s:2:\"id\";i:315;s:4:\"name\";s:9:\"Ain Shams\";s:7:\"ar_name\";s:13:\"عين شمس\";s:7:\"en_name\";s:9:\"Ain Shams\";s:6:\"active\";b:1;}i:25;a:5:{s:2:\"id\";i:18;s:4:\"name\";s:6:\"Akhmim\";s:7:\"ar_name\";s:10:\"اخميم\";s:7:\"en_name\";s:6:\"Akhmim\";s:6:\"active\";b:1;}i:26;a:5:{s:2:\"id\";i:58;s:4:\"name\";s:7:\"Al Ajmi\";s:7:\"ar_name\";s:12:\"العجمي\";s:7:\"en_name\";s:7:\"Al Ajmi\";s:6:\"active\";b:1;}i:27;a:5:{s:2:\"id\";i:142;s:4:\"name\";s:9:\"Al Hamoul\";s:7:\"ar_name\";s:14:\"الحامول\";s:7:\"en_name\";s:9:\"Al Hamoul\";s:6:\"active\";b:1;}i:28;a:5:{s:2:\"id\";i:345;s:4:\"name\";s:8:\"Al Rehab\";s:7:\"ar_name\";s:12:\"الرحاب\";s:7:\"en_name\";s:8:\"Al Rehab\";s:6:\"active\";b:1;}i:29;a:5:{s:2:\"id\";i:31;s:4:\"name\";s:10:\"Al Wardyan\";s:7:\"ar_name\";s:16:\"الورديان\";s:7:\"en_name\";s:10:\"Al Wardyan\";s:6:\"active\";b:1;}i:30;a:5:{s:2:\"id\";i:269;s:4:\"name\";s:11:\"Al-Barajeel\";s:7:\"ar_name\";s:16:\"البراجيل\";s:7:\"en_name\";s:11:\"Al-Barajeel\";s:6:\"active\";b:1;}i:31;a:5:{s:2:\"id\";i:337;s:4:\"name\";s:16:\"Al-Darb al-Ahmar\";s:7:\"ar_name\";s:23:\"الدرب الاحمر\";s:7:\"en_name\";s:16:\"Al-Darb al-Ahmar\";s:6:\"active\";b:1;}i:32;a:5:{s:2:\"id\";i:326;s:4:\"name\";s:12:\"Al-Demerdash\";s:7:\"ar_name\";s:16:\"الدمرداش\";s:7:\"en_name\";s:12:\"Al-Demerdash\";s:6:\"active\";b:1;}i:33;a:5:{s:2:\"id\";i:301;s:4:\"name\";s:10:\"Al-Hussein\";s:7:\"ar_name\";s:12:\"الحسين\";s:7:\"en_name\";s:10:\"Al-Hussein\";s:6:\"active\";b:1;}i:34;a:5:{s:2:\"id\";i:56;s:4:\"name\";s:9:\"Almansheh\";s:7:\"ar_name\";s:14:\"المنشية\";s:7:\"en_name\";s:9:\"Almansheh\";s:6:\"active\";b:1;}i:35;a:5:{s:2:\"id\";i:36;s:4:\"name\";s:7:\"Alsuywf\";s:7:\"ar_name\";s:12:\"السيوف\";s:7:\"en_name\";s:7:\"Alsuywf\";s:6:\"active\";b:1;}i:36;a:5:{s:2:\"id\";i:60;s:4:\"name\";s:6:\"Amreya\";s:7:\"ar_name\";s:16:\"العامريه\";s:7:\"en_name\";s:6:\"Amreya\";s:6:\"active\";b:1;}i:37;a:5:{s:2:\"id\";i:220;s:4:\"name\";s:7:\"Arbaeen\";s:7:\"ar_name\";s:16:\"الأربعين\";s:7:\"en_name\";s:7:\"Arbaeen\";s:6:\"active\";b:1;}i:38;a:5:{s:2:\"id\";i:258;s:4:\"name\";s:11:\"Ard El Lewa\";s:7:\"ar_name\";s:19:\"ارض اللواء\";s:7:\"en_name\";s:11:\"Ard El Lewa\";s:6:\"active\";b:1;}i:39;a:5:{s:2:\"id\";i:15;s:4:\"name\";s:6:\"Armant\";s:7:\"ar_name\";s:10:\"ارمنت\";s:7:\"en_name\";s:6:\"Armant\";s:6:\"active\";b:1;}i:40;a:5:{s:2:\"id\";i:41;s:4:\"name\";s:6:\"Asafra\";s:7:\"ar_name\";s:16:\"العصافره\";s:7:\"en_name\";s:6:\"Asafra\";s:6:\"active\";b:1;}i:41;a:5:{s:2:\"id\";i:101;s:4:\"name\";s:7:\"Ashmoun\";s:7:\"ar_name\";s:10:\"اشمون\";s:7:\"en_name\";s:7:\"Ashmoun\";s:6:\"active\";b:1;}i:42;a:5:{s:2:\"id\";i:377;s:4:\"name\";s:5:\"Aswan\";s:7:\"ar_name\";s:10:\"اسوان\";s:7:\"en_name\";s:5:\"Aswan\";s:6:\"active\";b:1;}i:43;a:5:{s:2:\"id\";i:255;s:4:\"name\";s:5:\"Atfih\";s:7:\"ar_name\";s:10:\"اطفيح\";s:7:\"en_name\";s:5:\"Atfih\";s:6:\"active\";b:1;}i:44;a:5:{s:2:\"id\";i:221;s:4:\"name\";s:6:\"Attaka\";s:7:\"ar_name\";s:10:\"عتاقه\";s:7:\"en_name\";s:6:\"Attaka\";s:6:\"active\";b:1;}i:45;a:5:{s:2:\"id\";i:124;s:4:\"name\";s:10:\"Awlad Saqr\";s:7:\"ar_name\";s:17:\"اولاد صقر\";s:7:\"en_name\";s:10:\"Awlad Saqr\";s:6:\"active\";b:1;}i:46;a:5:{s:2:\"id\";i:54;s:4:\"name\";s:7:\"Azarita\";s:7:\"ar_name\";s:16:\"الازريطه\";s:7:\"en_name\";s:7:\"Azarita\";s:6:\"active\";b:1;}i:47;a:5:{s:2:\"id\";i:350;s:4:\"name\";s:8:\"Azbakeya\";s:7:\"ar_name\";s:16:\"الازبكية\";s:7:\"en_name\";s:8:\"Azbakeya\";s:6:\"active\";b:1;}i:48;a:5:{s:2:\"id\";i:328;s:4:\"name\";s:13:\"Bab El Sharia\";s:7:\"ar_name\";s:21:\"باب الشعرية\";s:7:\"en_name\";s:13:\"Bab El Sharia\";s:6:\"active\";b:1;}i:49;a:5:{s:2:\"id\";i:299;s:4:\"name\";s:9:\"Badr City\";s:7:\"ar_name\";s:17:\"مدينه بدر\";s:7:\"en_name\";s:9:\"Badr City\";s:6:\"active\";b:1;}i:50;a:5:{s:2:\"id\";i:253;s:4:\"name\";s:9:\"Badrashin\";s:7:\"ar_name\";s:16:\"البدرشين\";s:7:\"en_name\";s:9:\"Badrashin\";s:6:\"active\";b:1;}i:51;a:5:{s:2:\"id\";i:105;s:4:\"name\";s:6:\"Bagour\";s:7:\"ar_name\";s:14:\"الباجور\";s:7:\"en_name\";s:6:\"Bagour\";s:6:\"active\";b:1;}i:52;a:5:{s:2:\"id\";i:254;s:4:\"name\";s:14:\"Bahariya Oasis\";s:7:\"ar_name\";s:29:\"الواحات البحرية\";s:7:\"en_name\";s:14:\"Bahariya Oasis\";s:6:\"active\";b:1;}i:53;a:5:{s:2:\"id\";i:57;s:4:\"name\";s:6:\"Bahary\";s:7:\"ar_name\";s:8:\"بحري\";s:7:\"en_name\";s:6:\"Bahary\";s:6:\"active\";b:1;}i:54;a:5:{s:2:\"id\";i:246;s:4:\"name\";s:5:\"Balat\";s:7:\"ar_name\";s:8:\"بلاط\";s:7:\"en_name\";s:5:\"Balat\";s:6:\"active\";b:1;}i:55;a:5:{s:2:\"id\";i:22;s:4:\"name\";s:6:\"Balina\";s:7:\"ar_name\";s:14:\"البلينه\";s:7:\"en_name\";s:6:\"Balina\";s:6:\"active\";b:1;}i:56;a:5:{s:2:\"id\";i:143;s:4:\"name\";s:6:\"Baltim\";s:7:\"ar_name\";s:10:\"بلطيم\";s:7:\"en_name\";s:6:\"Baltim\";s:6:\"active\";b:1;}i:57;a:5:{s:2:\"id\";i:355;s:4:\"name\";s:5:\"Banha\";s:7:\"ar_name\";s:8:\"بنها\";s:7:\"en_name\";s:5:\"Banha\";s:6:\"active\";b:1;}i:58;a:5:{s:2:\"id\";i:267;s:4:\"name\";s:7:\"Bargash\";s:7:\"ar_name\";s:10:\"برقاش\";s:7:\"en_name\";s:7:\"Bargash\";s:6:\"active\";b:1;}i:59;a:5:{s:2:\"id\";i:245;s:4:\"name\";s:5:\"Baris\";s:7:\"ar_name\";s:10:\"باريس\";s:7:\"en_name\";s:5:\"Baris\";s:6:\"active\";b:1;}i:60;a:5:{s:2:\"id\";i:265;s:4:\"name\";s:7:\"Bashtil\";s:7:\"ar_name\";s:10:\"بشتيل\";s:7:\"en_name\";s:7:\"Bashtil\";s:6:\"active\";b:1;}i:61;a:5:{s:2:\"id\";i:153;s:4:\"name\";s:7:\"Basyoun\";s:7:\"ar_name\";s:10:\"بسيون\";s:7:\"en_name\";s:7:\"Basyoun\";s:6:\"active\";b:1;}i:62;a:5:{s:2:\"id\";i:182;s:4:\"name\";s:8:\"Bayadiya\";s:7:\"ar_name\";s:16:\"البياضية\";s:7:\"en_name\";s:8:\"Bayadiya\";s:6:\"active\";b:1;}i:63;a:5:{s:2:\"id\";i:141;s:4:\"name\";s:5:\"Bella\";s:7:\"ar_name\";s:8:\"بيلا\";s:7:\"en_name\";s:5:\"Bella\";s:6:\"active\";b:1;}i:64;a:5:{s:2:\"id\";i:95;s:4:\"name\";s:6:\"Belqas\";s:7:\"ar_name\";s:10:\"بلقاس\";s:7:\"en_name\";s:6:\"Belqas\";s:6:\"active\";b:1;}i:65;a:5:{s:2:\"id\";i:96;s:4:\"name\";s:10:\"Beni Ebeid\";s:7:\"ar_name\";s:15:\"بني عبيد\";s:7:\"en_name\";s:10:\"Beni Ebeid\";s:6:\"active\";b:1;}i:66;a:5:{s:2:\"id\";i:188;s:4:\"name\";s:10:\"Beni Mazar\";s:7:\"ar_name\";s:15:\"بني مزار\";s:7:\"en_name\";s:10:\"Beni Mazar\";s:6:\"active\";b:1;}i:67;a:5:{s:2:\"id\";i:211;s:4:\"name\";s:4:\"Biba\";s:7:\"ar_name\";s:6:\"ببا\";s:7:\"en_name\";s:4:\"Biba\";s:6:\"active\";b:1;}i:68;a:5:{s:2:\"id\";i:121;s:4:\"name\";s:7:\"Bilbeis\";s:7:\"ar_name\";s:10:\"بلبيس\";s:7:\"en_name\";s:7:\"Bilbeis\";s:6:\"active\";b:1;}i:69;a:5:{s:2:\"id\";i:155;s:4:\"name\";s:10:\"Bir El Abd\";s:7:\"ar_name\";s:17:\"بئر العبد\";s:7:\"en_name\";s:10:\"Bir El Abd\";s:6:\"active\";b:1;}i:70;a:5:{s:2:\"id\";i:108;s:4:\"name\";s:13:\"Birket El Sab\";s:7:\"ar_name\";s:19:\"بركة السبع\";s:7:\"en_name\";s:13:\"Birket El Sab\";s:6:\"active\";b:1;}i:71;a:5:{s:2:\"id\";i:35;s:4:\"name\";s:6:\"Bitash\";s:7:\"ar_name\";s:14:\"البيطاش\";s:7:\"en_name\";s:6:\"Bitash\";s:6:\"active\";b:1;}i:72;a:5:{s:2:\"id\";i:62;s:4:\"name\";s:12:\"Borg El Arab\";s:7:\"ar_name\";s:17:\"برج العرب\";s:7:\"en_name\";s:12:\"Borg El Arab\";s:6:\"active\";b:1;}i:73;a:5:{s:2:\"id\";i:278;s:4:\"name\";s:6:\"Boulaq\";s:7:\"ar_name\";s:25:\"بولاق الدكرور\";s:7:\"en_name\";s:6:\"Boulaq\";s:6:\"active\";b:1;}i:74;a:5:{s:2:\"id\";i:298;s:4:\"name\";s:5:\"Bulaq\";s:7:\"ar_name\";s:28:\"بولاق ابو العلا\";s:7:\"en_name\";s:5:\"Bulaq\";s:6:\"active\";b:1;}i:75;a:5:{s:2:\"id\";i:52;s:4:\"name\";s:11:\"Camp Chezar\";s:7:\"ar_name\";s:19:\"كامب شيزار\";s:7:\"en_name\";s:11:\"Camp Chezar\";s:6:\"active\";b:1;}i:76;a:5:{s:2:\"id\";i:51;s:4:\"name\";s:9:\"Cleopatra\";s:7:\"ar_name\";s:18:\"كليوباترا\";s:7:\"en_name\";s:9:\"Cleopatra\";s:6:\"active\";b:1;}i:77;a:5:{s:2:\"id\";i:165;s:4:\"name\";s:5:\"Dahab\";s:7:\"ar_name\";s:6:\"دهب\";s:7:\"en_name\";s:5:\"Dahab\";s:6:\"active\";b:1;}i:78;a:5:{s:2:\"id\";i:261;s:4:\"name\";s:7:\"Dahshur\";s:7:\"ar_name\";s:10:\"دهشور\";s:7:\"en_name\";s:7:\"Dahshur\";s:6:\"active\";b:1;}i:79;a:5:{s:2:\"id\";i:197;s:4:\"name\";s:6:\"Dairut\";s:7:\"ar_name\";s:10:\"ديروط\";s:7:\"en_name\";s:6:\"Dairut\";s:6:\"active\";b:1;}i:80;a:5:{s:2:\"id\";i:248;s:4:\"name\";s:6:\"Dakhla\";s:7:\"ar_name\";s:14:\"الداخلة\";s:7:\"en_name\";s:6:\"Dakhla\";s:6:\"active\";b:1;}i:81;a:5:{s:2:\"id\";i:68;s:4:\"name\";s:9:\"Damanhour\";s:7:\"ar_name\";s:12:\"دمنهور\";s:7:\"en_name\";s:9:\"Damanhour\";s:6:\"active\";b:1;}i:82;a:5:{s:2:\"id\";i:368;s:4:\"name\";s:8:\"Damietta\";s:7:\"ar_name\";s:10:\"دمياط\";s:7:\"en_name\";s:8:\"Damietta\";s:6:\"active\";b:1;}i:83;a:5:{s:2:\"id\";i:20;s:4:\"name\";s:19:\"Dar AISalaam Region\";s:7:\"ar_name\";s:28:\"مركز دار السلام\";s:7:\"en_name\";s:19:\"Dar AISalaam Region\";s:6:\"active\";b:1;}i:84;a:5:{s:2:\"id\";i:340;s:4:\"name\";s:12:\"Dar El Salam\";s:7:\"ar_name\";s:19:\"دار السلام\";s:7:\"en_name\";s:12:\"Dar El Salam\";s:6:\"active\";b:1;}i:85;a:5:{s:2:\"id\";i:5;s:4:\"name\";s:5:\"Daraw\";s:7:\"ar_name\";s:8:\"دراو\";s:7:\"en_name\";s:5:\"Daraw\";s:6:\"active\";b:1;}i:86;a:5:{s:2:\"id\";i:33;s:4:\"name\";s:7:\"Dekhela\";s:7:\"ar_name\";s:14:\"الدخيلة\";s:7:\"en_name\";s:7:\"Dekhela\";s:6:\"active\";b:1;}i:87;a:5:{s:2:\"id\";i:137;s:4:\"name\";s:6:\"Desouq\";s:7:\"ar_name\";s:8:\"دسوق\";s:7:\"en_name\";s:6:\"Desouq\";s:6:\"active\";b:1;}i:88;a:5:{s:2:\"id\";i:84;s:4:\"name\";s:8:\"Dikirnis\";s:7:\"ar_name\";s:10:\"دكرنس\";s:7:\"en_name\";s:8:\"Dikirnis\";s:6:\"active\";b:1;}i:89;a:5:{s:2:\"id\";i:190;s:4:\"name\";s:9:\"Dir Mawas\";s:7:\"ar_name\";s:15:\"دير مواس\";s:7:\"en_name\";s:9:\"Dir Mawas\";s:6:\"active\";b:1;}i:90;a:5:{s:2:\"id\";i:16;s:4:\"name\";s:6:\"Dishna\";s:7:\"ar_name\";s:8:\"دشنا\";s:7:\"en_name\";s:6:\"Dishna\";s:6:\"active\";b:1;}i:91;a:5:{s:2:\"id\";i:119;s:4:\"name\";s:11:\"Diyarb Negm\";s:7:\"ar_name\";s:15:\"ديرب نجم\";s:7:\"en_name\";s:11:\"Diyarb Negm\";s:6:\"active\";b:1;}i:92;a:5:{s:2:\"id\";i:279;s:4:\"name\";s:5:\"Dokki\";s:7:\"ar_name\";s:10:\"الدقي\";s:7:\"en_name\";s:5:\"Dokki\";s:6:\"active\";b:1;}i:93;a:5:{s:2:\"id\";i:307;s:4:\"name\";s:8:\"Downtown\";s:7:\"ar_name\";s:17:\"وسط البلد\";s:7:\"en_name\";s:8:\"Downtown\";s:6:\"active\";b:1;}i:94;a:5:{s:2:\"id\";i:4;s:4:\"name\";s:4:\"Edfu\";s:7:\"ar_name\";s:8:\"ادفو\";s:7:\"en_name\";s:4:\"Edfu\";s:6:\"active\";b:1;}i:95;a:5:{s:2:\"id\";i:67;s:4:\"name\";s:4:\"Edku\";s:7:\"ar_name\";s:8:\"ادكو\";s:7:\"en_name\";s:4:\"Edku\";s:6:\"active\";b:1;}i:96;a:5:{s:2:\"id\";i:174;s:4:\"name\";s:10:\"El Alamein\";s:7:\"ar_name\";s:14:\"العلمين\";s:7:\"en_name\";s:10:\"El Alamein\";s:6:\"active\";b:1;}i:97;a:5:{s:2:\"id\";i:227;s:4:\"name\";s:7:\"El Arab\";s:7:\"ar_name\";s:10:\"العرب\";s:7:\"en_name\";s:7:\"El Arab\";s:6:\"active\";b:1;}i:98;a:5:{s:2:\"id\";i:158;s:4:\"name\";s:8:\"El Arish\";s:7:\"ar_name\";s:12:\"العريش\";s:7:\"en_name\";s:8:\"El Arish\";s:6:\"active\";b:1;}i:99;a:5:{s:2:\"id\";i:376;s:4:\"name\";s:9:\"El Attaba\";s:7:\"ar_name\";s:12:\"العتبة\";s:7:\"en_name\";s:9:\"El Attaba\";s:6:\"active\";b:1;}i:100;a:5:{s:2:\"id\";i:266;s:4:\"name\";s:8:\"El Ayyat\";s:7:\"ar_name\";s:12:\"العياط\";s:7:\"en_name\";s:8:\"El Ayyat\";s:6:\"active\";b:1;}i:101;a:5:{s:2:\"id\";i:202;s:4:\"name\";s:9:\"El Badari\";s:7:\"ar_name\";s:14:\"البداري\";s:7:\"en_name\";s:9:\"El Badari\";s:6:\"active\";b:1;}i:102;a:5:{s:2:\"id\";i:338;s:4:\"name\";s:10:\"El Basatin\";s:7:\"ar_name\";s:16:\"البساتين\";s:7:\"en_name\";s:10:\"El Basatin\";s:6:\"active\";b:1;}i:103;a:5:{s:2:\"id\";i:173;s:4:\"name\";s:8:\"El Dabaa\";s:7:\"ar_name\";s:12:\"الضبعة\";s:7:\"en_name\";s:8:\"El Dabaa\";s:6:\"active\";b:1;}i:104;a:5:{s:2:\"id\";i:224;s:4:\"name\";s:9:\"El Dawahy\";s:7:\"ar_name\";s:14:\"الضواحي\";s:7:\"en_name\";s:9:\"El Dawahy\";s:6:\"active\";b:1;}i:105;a:5:{s:2:\"id\";i:70;s:4:\"name\";s:11:\"El Delengat\";s:7:\"ar_name\";s:16:\"الدلنجات\";s:7:\"en_name\";s:11:\"El Delengat\";s:6:\"active\";b:1;}i:106;a:5:{s:2:\"id\";i:208;s:4:\"name\";s:8:\"El Fashn\";s:7:\"ar_name\";s:10:\"الفشن\";s:7:\"en_name\";s:8:\"El Fashn\";s:6:\"active\";b:1;}i:107;a:5:{s:2:\"id\";i:205;s:4:\"name\";s:7:\"El Fath\";s:7:\"ar_name\";s:10:\"الفتح\";s:7:\"en_name\";s:7:\"El Fath\";s:6:\"active\";b:1;}i:108;a:5:{s:2:\"id\";i:92;s:4:\"name\";s:11:\"El Gamaliya\";s:7:\"ar_name\";s:16:\"الجمالية\";s:7:\"en_name\";s:11:\"El Gamaliya\";s:6:\"active\";b:1;}i:109;a:5:{s:2:\"id\";i:229;s:4:\"name\";s:9:\"El Ganoub\";s:7:\"ar_name\";s:17:\"حي الجنوب\";s:7:\"en_name\";s:9:\"El Ganoub\";s:6:\"active\";b:1;}i:110;a:5:{s:2:\"id\";i:201;s:4:\"name\";s:11:\"El Ghanayem\";s:7:\"ar_name\";s:14:\"الغنايم\";s:7:\"en_name\";s:11:\"El Ghanayem\";s:6:\"active\";b:1;}i:111;a:5:{s:2:\"id\";i:175;s:4:\"name\";s:8:\"El Hamam\";s:7:\"ar_name\";s:12:\"الحمام\";s:7:\"en_name\";s:8:\"El Hamam\";s:6:\"active\";b:1;}i:112;a:5:{s:2:\"id\";i:157;s:4:\"name\";s:10:\"El Hassana\";s:7:\"ar_name\";s:12:\"الحسنة\";s:7:\"en_name\";s:10:\"El Hassana\";s:6:\"active\";b:1;}i:113;a:5:{s:2:\"id\";i:291;s:4:\"name\";s:12:\"El Hawamdeya\";s:7:\"ar_name\";s:18:\"الحوامدية\";s:7:\"en_name\";s:12:\"El Hawamdeya\";s:6:\"active\";b:1;}i:114;a:5:{s:2:\"id\";i:113;s:4:\"name\";s:13:\"El Husseiniya\";s:7:\"ar_name\";s:16:\"الحسينية\";s:7:\"en_name\";s:13:\"El Husseiniya\";s:6:\"active\";b:1;}i:115;a:5:{s:2:\"id\";i:117;s:4:\"name\";s:13:\"El Ibrahimiya\";s:7:\"ar_name\";s:22:\"الابراهيميه\";s:7:\"en_name\";s:13:\"El Ibrahimiya\";s:6:\"active\";b:1;}i:116;a:5:{s:2:\"id\";i:192;s:4:\"name\";s:7:\"El Idwa\";s:7:\"ar_name\";s:12:\"العدوة\";s:7:\"en_name\";s:7:\"El Idwa\";s:6:\"active\";b:1;}i:117;a:5:{s:2:\"id\";i:146;s:4:\"name\";s:19:\"El Mahalla El Kubra\";s:7:\"ar_name\";s:25:\"المحلة الكبرى\";s:7:\"en_name\";s:19:\"El Mahalla El Kubra\";s:6:\"active\";b:1;}i:118;a:5:{s:2:\"id\";i:225;s:4:\"name\";s:9:\"El Manakh\";s:7:\"ar_name\";s:12:\"المناخ\";s:7:\"en_name\";s:9:\"El Manakh\";s:6:\"active\";b:1;}i:119;a:5:{s:2:\"id\";i:80;s:4:\"name\";s:11:\"El Mansoura\";s:7:\"ar_name\";s:16:\"المنصورة\";s:7:\"en_name\";s:11:\"El Mansoura\";s:6:\"active\";b:1;}i:120;a:5:{s:2:\"id\";i:86;s:4:\"name\";s:10:\"El Manzala\";s:7:\"ar_name\";s:14:\"المنزلة\";s:7:\"en_name\";s:10:\"El Manzala\";s:6:\"active\";b:1;}i:121;a:5:{s:2:\"id\";i:316;s:4:\"name\";s:7:\"El Marg\";s:7:\"ar_name\";s:10:\"المرج\";s:7:\"en_name\";s:7:\"El Marg\";s:6:\"active\";b:1;}i:122;a:5:{s:2:\"id\";i:342;s:4:\"name\";s:9:\"El Masara\";s:7:\"ar_name\";s:14:\"المعصرة\";s:7:\"en_name\";s:9:\"El Masara\";s:6:\"active\";b:1;}i:123;a:5:{s:2:\"id\";i:379;s:4:\"name\";s:11:\"El Matareya\";s:7:\"ar_name\";s:14:\"المطرية\";s:7:\"en_name\";s:11:\"El Matareya\";s:6:\"active\";b:1;}i:124;a:5:{s:2:\"id\";i:91;s:4:\"name\";s:18:\"El Matareya Region\";s:7:\"ar_name\";s:23:\"مركز المطرية\";s:7:\"en_name\";s:18:\"El Matareya Region\";s:6:\"active\";b:1;}i:125;a:5:{s:2:\"id\";i:339;s:4:\"name\";s:11:\"El Mokattam\";s:7:\"ar_name\";s:12:\"المقطم\";s:7:\"en_name\";s:11:\"El Mokattam\";s:6:\"active\";b:1;}i:126;a:5:{s:2:\"id\";i:374;s:4:\"name\";s:11:\"El Montazah\";s:7:\"ar_name\";s:14:\"المنتزه\";s:7:\"en_name\";s:11:\"El Montazah\";s:6:\"active\";b:1;}i:127;a:5:{s:2:\"id\";i:351;s:4:\"name\";s:8:\"El Muski\";s:7:\"ar_name\";s:12:\"المسكي\";s:7:\"en_name\";s:8:\"El Muski\";s:6:\"active\";b:1;}i:128;a:5:{s:2:\"id\";i:178;s:4:\"name\";s:10:\"El Negaila\";s:7:\"ar_name\";s:14:\"النجيلة\";s:7:\"en_name\";s:10:\"El Negaila\";s:6:\"active\";b:1;}i:129;a:5:{s:2:\"id\";i:329;s:4:\"name\";s:8:\"El Nozha\";s:7:\"ar_name\";s:27:\"النزهة الجديدة\";s:7:\"en_name\";s:8:\"El Nozha\";s:6:\"active\";b:1;}i:130;a:5:{s:2:\"id\";i:282;s:4:\"name\";s:11:\"El Omraniya\";s:7:\"ar_name\";s:18:\"العمرانية\";s:7:\"en_name\";s:11:\"El Omraniya\";s:6:\"active\";b:1;}i:131;a:5:{s:2:\"id\";i:360;s:4:\"name\";s:22:\"El Qanater El Khayreya\";s:7:\"ar_name\";s:29:\"القناطر الخيرية\";s:7:\"en_name\";s:22:\"El Qanater El Khayreya\";s:6:\"active\";b:1;}i:132;a:5:{s:2:\"id\";i:126;s:4:\"name\";s:10:\"El Qanayat\";s:7:\"ar_name\";s:16:\"القنايات\";s:7:\"en_name\";s:10:\"El Qanayat\";s:6:\"active\";b:1;}i:133;a:5:{s:2:\"id\";i:239;s:4:\"name\";s:10:\"El Qantara\";s:7:\"ar_name\";s:14:\"القنطرة\";s:7:\"en_name\";s:10:\"El Qantara\";s:6:\"active\";b:1;}i:134;a:5:{s:2:\"id\";i:240;s:4:\"name\";s:22:\"El Qantara El Sharqiya\";s:7:\"ar_name\";s:21:\"القنطرة شرق\";s:7:\"en_name\";s:22:\"El Qantara El Sharqiya\";s:6:\"active\";b:1;}i:135;a:5:{s:2:\"id\";i:125;s:4:\"name\";s:9:\"El Qurein\";s:7:\"ar_name\";s:12:\"القرين\";s:7:\"en_name\";s:9:\"El Qurein\";s:6:\"active\";b:1;}i:136;a:5:{s:2:\"id\";i:132;s:4:\"name\";s:9:\"El Qusair\";s:7:\"ar_name\";s:12:\"القصير\";s:7:\"en_name\";s:9:\"El Qusair\";s:6:\"active\";b:1;}i:137;a:5:{s:2:\"id\";i:196;s:4:\"name\";s:9:\"El Qusiya\";s:7:\"ar_name\";s:14:\"القوصية\";s:7:\"en_name\";s:9:\"El Qusiya\";s:6:\"active\";b:1;}i:138;a:5:{s:2:\"id\";i:55;s:4:\"name\";s:7:\"El Raml\";s:7:\"ar_name\";s:19:\"محطه الرمل\";s:7:\"en_name\";s:7:\"El Raml\";s:6:\"active\";b:1;}i:139;a:5:{s:2:\"id\";i:280;s:4:\"name\";s:7:\"El Saff\";s:7:\"ar_name\";s:8:\"الصف\";s:7:\"en_name\";s:7:\"El Saff\";s:6:\"active\";b:1;}i:140;a:5:{s:2:\"id\";i:309;s:4:\"name\";s:8:\"El Salam\";s:7:\"ar_name\";s:23:\"مدينة السلام\";s:7:\"en_name\";s:8:\"El Salam\";s:6:\"active\";b:1;}i:141;a:5:{s:2:\"id\";i:333;s:4:\"name\";s:15:\"El Sayeda Aisha\";s:7:\"ar_name\";s:23:\"السيدة عائشة\";s:7:\"en_name\";s:15:\"El Sayeda Aisha\";s:6:\"active\";b:1;}i:142;a:5:{s:2:\"id\";i:332;s:4:\"name\";s:16:\"El Sayeda Nafisa\";s:7:\"ar_name\";s:23:\"السيدة نفيسة\";s:7:\"en_name\";s:16:\"El Sayeda Nafisa\";s:6:\"active\";b:1;}i:143;a:5:{s:2:\"id\";i:334;s:4:\"name\";s:16:\"El Sayeda Zeinab\";s:7:\"ar_name\";s:21:\"السيدة زينب\";s:7:\"en_name\";s:16:\"El Sayeda Zeinab\";s:6:\"active\";b:1;}i:144;a:5:{s:2:\"id\";i:89;s:4:\"name\";s:15:\"El Senbellawein\";s:7:\"ar_name\";s:20:\"السنبلاوين\";s:7:\"en_name\";s:15:\"El Senbellawein\";s:6:\"active\";b:1;}i:145;a:5:{s:2:\"id\";i:325;s:4:\"name\";s:12:\"El Sharabiya\";s:7:\"ar_name\";s:16:\"الشرابية\";s:7:\"en_name\";s:12:\"El Sharabiya\";s:6:\"active\";b:1;}i:146;a:5:{s:2:\"id\";i:228;s:4:\"name\";s:8:\"El Sharq\";s:7:\"ar_name\";s:15:\"حي الشرق\";s:7:\"en_name\";s:8:\"El Sharq\";s:6:\"active\";b:1;}i:147;a:5:{s:2:\"id\";i:106;s:4:\"name\";s:10:\"El Shohada\";s:7:\"ar_name\";s:14:\"الشهداء\";s:7:\"en_name\";s:10:\"El Shohada\";s:6:\"active\";b:1;}i:148;a:5:{s:2:\"id\";i:346;s:4:\"name\";s:10:\"El Shorouk\";s:7:\"ar_name\";s:23:\"مدينة الشروق\";s:7:\"en_name\";s:10:\"El Shorouk\";s:6:\"active\";b:1;}i:149;a:5:{s:2:\"id\";i:149;s:4:\"name\";s:8:\"El Sunta\";s:7:\"ar_name\";s:12:\"السنطة\";s:7:\"en_name\";s:8:\"El Sunta\";s:6:\"active\";b:1;}i:150;a:5:{s:2:\"id\";i:294;s:4:\"name\";s:9:\"El Tebbin\";s:7:\"ar_name\";s:12:\"التبين\";s:7:\"en_name\";s:9:\"El Tebbin\";s:6:\"active\";b:1;}i:151;a:5:{s:2:\"id\";i:169;s:4:\"name\";s:6:\"El Tor\";s:7:\"ar_name\";s:17:\"طور سيناء\";s:7:\"en_name\";s:6:\"El Tor\";s:6:\"active\";b:1;}i:152;a:5:{s:2:\"id\";i:357;s:4:\"name\";s:8:\"El Ubour\";s:7:\"ar_name\";s:12:\"العبور\";s:7:\"en_name\";s:8:\"El Ubour\";s:6:\"active\";b:1;}i:153;a:5:{s:2:\"id\";i:264;s:4:\"name\";s:9:\"El Warraq\";s:7:\"ar_name\";s:12:\"الوراق\";s:7:\"en_name\";s:9:\"El Warraq\";s:6:\"active\";b:1;}i:154;a:5:{s:2:\"id\";i:209;s:4:\"name\";s:8:\"El Wasta\";s:7:\"ar_name\";s:14:\"الواسطى\";s:7:\"en_name\";s:8:\"El Wasta\";s:6:\"active\";b:1;}i:155;a:5:{s:2:\"id\";i:324;s:4:\"name\";s:8:\"El Weili\";s:7:\"ar_name\";s:12:\"الويلي\";s:7:\"en_name\";s:8:\"El Weili\";s:6:\"active\";b:1;}i:156;a:5:{s:2:\"id\";i:295;s:4:\"name\";s:8:\"El Zaher\";s:7:\"ar_name\";s:12:\"الظاهر\";s:7:\"en_name\";s:8:\"El Zaher\";s:6:\"active\";b:1;}i:157;a:5:{s:2:\"id\";i:232;s:4:\"name\";s:8:\"El Zarqa\";s:7:\"ar_name\";s:14:\"الزرقاء\";s:7:\"en_name\";s:8:\"El Zarqa\";s:6:\"active\";b:1;}i:158;a:5:{s:2:\"id\";i:300;s:4:\"name\";s:17:\"El Zawya El Hamra\";s:7:\"ar_name\";s:29:\"الزاوية الحمراء\";s:7:\"en_name\";s:17:\"El Zawya El Hamra\";s:6:\"active\";b:1;}i:159;a:5:{s:2:\"id\";i:226;s:4:\"name\";s:8:\"El Zohur\";s:7:\"ar_name\";s:12:\"الزهور\";s:7:\"en_name\";s:8:\"El Zohur\";s:6:\"active\";b:1;}i:160;a:5:{s:2:\"id\";i:184;s:4:\"name\";s:4:\"Esna\";s:7:\"ar_name\";s:8:\"اسنا\";s:7:\"en_name\";s:4:\"Esna\";s:6:\"active\";b:1;}i:161;a:5:{s:2:\"id\";i:327;s:4:\"name\";s:14:\"Ezbet Al-Nakhl\";s:7:\"ar_name\";s:19:\"عزبة النخل\";s:7:\"en_name\";s:14:\"Ezbet Al-Nakhl\";s:6:\"active\";b:1;}i:162;a:5:{s:2:\"id\";i:285;s:4:\"name\";s:6:\"Faisal\";s:7:\"ar_name\";s:8:\"فيصل\";s:7:\"en_name\";s:6:\"Faisal\";s:6:\"active\";b:1;}i:163;a:5:{s:2:\"id\";i:112;s:4:\"name\";s:6:\"Faqous\";s:7:\"ar_name\";s:10:\"فاقوس\";s:7:\"en_name\";s:6:\"Faqous\";s:6:\"active\";b:1;}i:164;a:5:{s:2:\"id\";i:249;s:4:\"name\";s:7:\"Farafra\";s:7:\"ar_name\";s:16:\"الفرافرة\";s:7:\"en_name\";s:7:\"Farafra\";s:6:\"active\";b:1;}i:165;a:5:{s:2:\"id\";i:231;s:4:\"name\";s:8:\"Faraskur\";s:7:\"ar_name\";s:14:\"فارسكور\";s:7:\"en_name\";s:8:\"Faraskur\";s:6:\"active\";b:1;}i:166;a:5:{s:2:\"id\";i:11;s:4:\"name\";s:7:\"Farshut\";s:7:\"ar_name\";s:10:\"فرشوط\";s:7:\"en_name\";s:7:\"Farshut\";s:6:\"active\";b:1;}i:167;a:5:{s:2:\"id\";i:238;s:4:\"name\";s:5:\"Fayid\";s:7:\"ar_name\";s:8:\"فايد\";s:7:\"en_name\";s:5:\"Fayid\";s:6:\"active\";b:1;}i:168;a:5:{s:2:\"id\";i:347;s:4:\"name\";s:16:\"Fifth Settlement\";s:7:\"ar_name\";s:25:\"التجمع الخامس\";s:7:\"en_name\";s:16:\"Fifth Settlement\";s:6:\"active\";b:1;}i:169;a:5:{s:2:\"id\";i:310;s:4:\"name\";s:14:\"First assembly\";s:7:\"ar_name\";s:23:\"التجمع الاول\";s:7:\"en_name\";s:14:\"First assembly\";s:6:\"active\";b:1;}i:170;a:5:{s:2:\"id\";i:139;s:4:\"name\";s:4:\"Fowa\";s:7:\"ar_name\";s:6:\"فوة\";s:7:\"en_name\";s:4:\"Fowa\";s:6:\"active\";b:1;}i:171;a:5:{s:2:\"id\";i:336;s:4:\"name\";s:6:\"Fustat\";s:7:\"ar_name\";s:14:\"الفسطاط\";s:7:\"en_name\";s:6:\"Fustat\";s:6:\"active\";b:1;}i:172;a:5:{s:2:\"id\";i:94;s:4:\"name\";s:6:\"Gamasa\";s:7:\"ar_name\";s:8:\"جمصة\";s:7:\"en_name\";s:6:\"Gamasa\";s:6:\"active\";b:1;}i:173;a:5:{s:2:\"id\";i:219;s:4:\"name\";s:7:\"Ganayen\";s:7:\"ar_name\";s:14:\"الجناين\";s:7:\"en_name\";s:7:\"Ganayen\";s:6:\"active\";b:1;}i:174;a:5:{s:2:\"id\";i:322;s:4:\"name\";s:11:\"Garden City\";s:7:\"ar_name\";s:19:\"جاردن سيتي\";s:7:\"en_name\";s:11:\"Garden City\";s:6:\"active\";b:1;}i:175;a:5:{s:2:\"id\";i:14;s:4:\"name\";s:15:\"Gebtu or Coptos\";s:7:\"ar_name\";s:6:\"قفط\";s:7:\"en_name\";s:15:\"Gebtu or Coptos\";s:6:\"active\";b:1;}i:176;a:5:{s:2:\"id\";i:314;s:4:\"name\";s:6:\"Ghamra\";s:7:\"ar_name\";s:8:\"غمرة\";s:7:\"en_name\";s:6:\"Ghamra\";s:6:\"active\";b:1;}i:177;a:5:{s:2:\"id\";i:365;s:4:\"name\";s:4:\"Giza\";s:7:\"ar_name\";s:12:\"الجيزة\";s:7:\"en_name\";s:4:\"Giza\";s:6:\"active\";b:1;}i:178;a:5:{s:2:\"id\";i:46;s:4:\"name\";s:5:\"Gleem\";s:7:\"ar_name\";s:8:\"جليم\";s:7:\"en_name\";s:5:\"Gleem\";s:6:\"active\";b:1;}i:179;a:5:{s:2:\"id\";i:133;s:4:\"name\";s:5:\"Gouna\";s:7:\"ar_name\";s:12:\"الجونة\";s:7:\"en_name\";s:5:\"Gouna\";s:6:\"active\";b:1;}i:180;a:5:{s:2:\"id\";i:312;s:4:\"name\";s:17:\"Hada\'iq El Qobbah\";s:7:\"ar_name\";s:21:\"حدائق القبة\";s:7:\"en_name\";s:17:\"Hada\'iq El Qobbah\";s:6:\"active\";b:1;}i:181;a:5:{s:2:\"id\";i:375;s:4:\"name\";s:16:\"Hadayek El Ahram\";s:7:\"ar_name\";s:25:\"حدائق الاهرام\";s:7:\"en_name\";s:16:\"Hadayek El Ahram\";s:6:\"active\";b:1;}i:182;a:5:{s:2:\"id\";i:318;s:4:\"name\";s:17:\"Hammamat El Kobba\";s:7:\"ar_name\";s:23:\"حمامات القبة\";s:7:\"en_name\";s:17:\"Hammamat El Kobba\";s:6:\"active\";b:1;}i:183;a:5:{s:2:\"id\";i:34;s:4:\"name\";s:10:\"Hannoville\";s:7:\"ar_name\";s:18:\"الهانوفيل\";s:7:\"en_name\";s:10:\"Hannoville\";s:6:\"active\";b:1;}i:184;a:5:{s:2:\"id\";i:370;s:4:\"name\";s:5:\"Haram\";s:7:\"ar_name\";s:10:\"الهرم\";s:7:\"en_name\";s:5:\"Haram\";s:6:\"active\";b:1;}i:185;a:5:{s:2:\"id\";i:304;s:4:\"name\";s:6:\"Helwan\";s:7:\"ar_name\";s:10:\"حلوان\";s:7:\"en_name\";s:6:\"Helwan\";s:6:\"active\";b:1;}i:186;a:5:{s:2:\"id\";i:123;s:4:\"name\";s:5:\"Hihya\";s:7:\"ar_name\";s:8:\"ههيا\";s:7:\"en_name\";s:5:\"Hihya\";s:6:\"active\";b:1;}i:187;a:5:{s:2:\"id\";i:73;s:4:\"name\";s:9:\"Hosh Essa\";s:7:\"ar_name\";s:15:\"حوش عيسى\";s:7:\"en_name\";s:9:\"Hosh Essa\";s:6:\"active\";b:1;}i:188;a:5:{s:2:\"id\";i:128;s:4:\"name\";s:8:\"Hurghada\";s:7:\"ar_name\";s:14:\"الغردقة\";s:7:\"en_name\";s:8:\"Hurghada\";s:6:\"active\";b:1;}i:189;a:5:{s:2:\"id\";i:214;s:4:\"name\";s:8:\"Ibsheway\";s:7:\"ar_name\";s:10:\"ابشوي\";s:7:\"en_name\";s:8:\"Ibsheway\";s:6:\"active\";b:1;}i:190;a:5:{s:2:\"id\";i:210;s:4:\"name\";s:8:\"Ihnasiya\";s:7:\"ar_name\";s:12:\"اهنسيا\";s:7:\"en_name\";s:8:\"Ihnasiya\";s:6:\"active\";b:1;}i:191;a:5:{s:2:\"id\";i:272;s:4:\"name\";s:6:\"Imbaba\";s:7:\"ar_name\";s:12:\"امبابة\";s:7:\"en_name\";s:6:\"Imbaba\";s:6:\"active\";b:1;}i:192;a:5:{s:2:\"id\";i:71;s:4:\"name\";s:13:\"Itay El Barud\";s:7:\"ar_name\";s:25:\"ايتاى البارود\";s:7:\"en_name\";s:13:\"Itay El Barud\";s:6:\"active\";b:1;}i:193;a:5:{s:2:\"id\";i:217;s:4:\"name\";s:4:\"Itsa\";s:7:\"ar_name\";s:8:\"اطسا\";s:7:\"en_name\";s:4:\"Itsa\";s:6:\"active\";b:1;}i:194;a:5:{s:2:\"id\";i:21;s:4:\"name\";s:5:\"Jerja\";s:7:\"ar_name\";s:8:\"جرجا\";s:7:\"en_name\";s:5:\"Jerja\";s:6:\"active\";b:1;}i:195;a:5:{s:2:\"id\";i:25;s:4:\"name\";s:7:\"Juhayna\";s:7:\"ar_name\";s:10:\"جهينه\";s:7:\"en_name\";s:7:\"Juhayna\";s:6:\"active\";b:1;}i:196;a:5:{s:2:\"id\";i:64;s:4:\"name\";s:14:\"Kafr Al-Dawwar\";s:7:\"ar_name\";s:19:\"كفر الدوار\";s:7:\"en_name\";s:14:\"Kafr Al-Dawwar\";s:6:\"active\";b:1;}i:197;a:5:{s:2:\"id\";i:234;s:4:\"name\";s:15:\"Kafr El Battikh\";s:7:\"ar_name\";s:19:\"كفر البطيخ\";s:7:\"en_name\";s:15:\"Kafr El Battikh\";s:6:\"active\";b:1;}i:198;a:5:{s:2:\"id\";i:148;s:4:\"name\";s:13:\"Kafr El Zayat\";s:7:\"ar_name\";s:19:\"كفر الزيات\";s:7:\"en_name\";s:13:\"Kafr El Zayat\";s:6:\"active\";b:1;}i:199;a:5:{s:2:\"id\";i:292;s:4:\"name\";s:12:\"Kafr Ghataty\";s:7:\"ar_name\";s:17:\"كفر غطاطي\";s:7:\"en_name\";s:12:\"Kafr Ghataty\";s:6:\"active\";b:1;}i:200;a:5:{s:2:\"id\";i:236;s:4:\"name\";s:9:\"Kafr Saad\";s:7:\"ar_name\";s:13:\"كفر سعد\";s:7:\"en_name\";s:9:\"Kafr Saad\";s:6:\"active\";b:1;}i:201;a:5:{s:2:\"id\";i:118;s:4:\"name\";s:9:\"Kafr Saqr\";s:7:\"ar_name\";s:13:\"كفر صقر\";s:7:\"en_name\";s:9:\"Kafr Saqr\";s:6:\"active\";b:1;}i:202;a:5:{s:2:\"id\";i:359;s:4:\"name\";s:10:\"Kafr Shukr\";s:7:\"ar_name\";s:13:\"كفر شكر\";s:7:\"en_name\";s:10:\"Kafr Shukr\";s:6:\"active\";b:1;}i:203;a:5:{s:2:\"id\";i:243;s:4:\"name\";s:8:\"Kasaseen\";s:7:\"ar_name\";s:16:\"القصاصين\";s:7:\"en_name\";s:8:\"Kasaseen\";s:6:\"active\";b:1;}i:204;a:5:{s:2:\"id\";i:335;s:4:\"name\";s:7:\"Katamia\";s:7:\"ar_name\";s:16:\"القطامية\";s:7:\"en_name\";s:7:\"Katamia\";s:6:\"active\";b:1;}i:205;a:5:{s:2:\"id\";i:288;s:4:\"name\";s:7:\"Kerdasa\";s:7:\"ar_name\";s:12:\"كرداسة\";s:7:\"en_name\";s:7:\"Kerdasa\";s:6:\"active\";b:1;}i:206;a:5:{s:2:\"id\";i:358;s:4:\"name\";s:6:\"Khanka\";s:7:\"ar_name\";s:14:\"الخانكة\";s:7:\"en_name\";s:6:\"Khanka\";s:6:\"active\";b:1;}i:207;a:5:{s:2:\"id\";i:247;s:4:\"name\";s:12:\"Kharga Oasis\";s:7:\"ar_name\";s:14:\"الخارجة\";s:7:\"en_name\";s:12:\"Kharga Oasis\";s:6:\"active\";b:1;}i:208;a:5:{s:2:\"id\";i:363;s:4:\"name\";s:6:\"Khusus\";s:7:\"ar_name\";s:12:\"الخصوص\";s:7:\"en_name\";s:6:\"Khusus\";s:6:\"active\";b:1;}i:209;a:5:{s:2:\"id\";i:32;s:4:\"name\";s:7:\"Kilo 21\";s:7:\"ar_name\";s:11:\"كيلو 21\";s:7:\"en_name\";s:7:\"Kilo 21\";s:6:\"active\";b:1;}i:210;a:5:{s:2:\"id\";i:274;s:4:\"name\";s:7:\"Kit Kat\";s:7:\"ar_name\";s:17:\"الكيت كات\";s:7:\"en_name\";s:7:\"Kit Kat\";s:6:\"active\";b:1;}i:211;a:5:{s:2:\"id\";i:302;s:4:\"name\";s:14:\"Kobri al-Qubba\";s:7:\"ar_name\";s:21:\"كوبري القبه\";s:7:\"en_name\";s:14:\"Kobri al-Qubba\";s:6:\"active\";b:1;}i:212;a:5:{s:2:\"id\";i:72;s:4:\"name\";s:10:\"Kom Hamada\";s:7:\"ar_name\";s:17:\"كوم حمادة\";s:7:\"en_name\";s:10:\"Kom Hamada\";s:6:\"active\";b:1;}i:213;a:5:{s:2:\"id\";i:3;s:4:\"name\";s:8:\"Kom Ombo\";s:7:\"ar_name\";s:15:\"كوم امبو\";s:7:\"en_name\";s:8:\"Kom Ombo\";s:6:\"active\";b:1;}i:214;a:5:{s:2:\"id\";i:150;s:4:\"name\";s:6:\"Kotoor\";s:7:\"ar_name\";s:8:\"قطور\";s:7:\"en_name\";s:6:\"Kotoor\";s:6:\"active\";b:1;}i:215;a:5:{s:2:\"id\";i:45;s:4:\"name\";s:6:\"Lauren\";s:7:\"ar_name\";s:10:\"لوران\";s:7:\"en_name\";s:6:\"Lauren\";s:6:\"active\";b:1;}i:216;a:5:{s:2:\"id\";i:344;s:4:\"name\";s:5:\"Maadi\";s:7:\"ar_name\";s:14:\"المعادى\";s:7:\"en_name\";s:5:\"Maadi\";s:6:\"active\";b:1;}i:217;a:5:{s:2:\"id\";i:341;s:4:\"name\";s:8:\"Madinaty\";s:7:\"ar_name\";s:12:\"مدينتي\";s:7:\"en_name\";s:8:\"Madinaty\";s:6:\"active\";b:1;}i:218;a:5:{s:2:\"id\";i:193;s:4:\"name\";s:8:\"Maghagha\";s:7:\"ar_name\";s:10:\"مغاغة\";s:7:\"en_name\";s:8:\"Maghagha\";s:6:\"active\";b:1;}i:219;a:5:{s:2:\"id\";i:69;s:4:\"name\";s:11:\"Mahmoudiyah\";s:7:\"ar_name\";s:18:\"المحمودية\";s:7:\"en_name\";s:11:\"Mahmoudiyah\";s:6:\"active\";b:1;}i:220;a:5:{s:2:\"id\";i:189;s:4:\"name\";s:7:\"Mallawi\";s:7:\"ar_name\";s:8:\"ملوي\";s:7:\"en_name\";s:7:\"Mallawi\";s:6:\"active\";b:1;}i:221;a:5:{s:2:\"id\";i:40;s:4:\"name\";s:7:\"Mamoura\";s:7:\"ar_name\";s:16:\"المعموره\";s:7:\"en_name\";s:7:\"Mamoura\";s:6:\"active\";b:1;}i:222;a:5:{s:2:\"id\";i:19;s:4:\"name\";s:7:\"ManShaa\";s:7:\"ar_name\";s:14:\"المنشأة\";s:7:\"en_name\";s:7:\"ManShaa\";s:6:\"active\";b:1;}i:223;a:5:{s:2:\"id\";i:39;s:4:\"name\";s:7:\"Mandara\";s:7:\"ar_name\";s:14:\"المندره\";s:7:\"en_name\";s:7:\"Mandara\";s:6:\"active\";b:1;}i:224;a:5:{s:2:\"id\";i:199;s:4:\"name\";s:8:\"Manfalut\";s:7:\"ar_name\";s:12:\"منفلوط\";s:7:\"en_name\";s:8:\"Manfalut\";s:6:\"active\";b:1;}i:225;a:5:{s:2:\"id\";i:284;s:4:\"name\";s:6:\"Manial\";s:7:\"ar_name\";s:12:\"المنيل\";s:7:\"en_name\";s:6:\"Manial\";s:6:\"active\";b:1;}i:226;a:5:{s:2:\"id\";i:257;s:4:\"name\";s:12:\"Manial Shiha\";s:7:\"ar_name\";s:17:\"منيل شيحه\";s:7:\"en_name\";s:12:\"Manial Shiha\";s:6:\"active\";b:1;}i:227;a:5:{s:2:\"id\";i:277;s:4:\"name\";s:20:\"Mansha\'at al-Qanater\";s:7:\"ar_name\";s:25:\"منشأة القناطر\";s:7:\"en_name\";s:20:\"Mansha\'at al-Qanater\";s:6:\"active\";b:1;}i:228;a:5:{s:2:\"id\";i:313;s:4:\"name\";s:16:\"Mansheya Al-Sadr\";s:7:\"ar_name\";s:21:\"منشية الصدر\";s:7:\"en_name\";s:16:\"Mansheya Al-Sadr\";s:6:\"active\";b:1;}i:229;a:5:{s:2:\"id\";i:252;s:4:\"name\";s:19:\"Mansheyet al-Bakari\";s:7:\"ar_name\";s:25:\"منشية البكاري\";s:7:\"en_name\";s:19:\"Mansheyet al-Bakari\";s:6:\"active\";b:1;}i:230;a:5:{s:2:\"id\";i:323;s:4:\"name\";s:15:\"Manshiyat Naser\";s:7:\"ar_name\";s:19:\"منشية ناصر\";s:7:\"en_name\";s:15:\"Manshiyat Naser\";s:6:\"active\";b:1;}i:231;a:5:{s:2:\"id\";i:286;s:4:\"name\";s:10:\"Mansourieh\";s:7:\"ar_name\";s:18:\"المنصورية\";s:7:\"en_name\";s:10:\"Mansourieh\";s:6:\"active\";b:1;}i:232;a:5:{s:2:\"id\";i:24;s:4:\"name\";s:8:\"Maragheh\";s:7:\"ar_name\";s:14:\"المراغه\";s:7:\"en_name\";s:8:\"Maragheh\";s:6:\"active\";b:1;}i:233;a:5:{s:2:\"id\";i:129;s:4:\"name\";s:10:\"Marsa Alam\";s:7:\"ar_name\";s:15:\"مرسي علم\";s:7:\"en_name\";s:10:\"Marsa Alam\";s:6:\"active\";b:1;}i:234;a:5:{s:2:\"id\";i:115;s:4:\"name\";s:16:\"Mashtool El Souk\";s:7:\"ar_name\";s:21:\"مشتول السوق\";s:7:\"en_name\";s:16:\"Mashtool El Souk\";s:6:\"active\";b:1;}i:235;a:5:{s:2:\"id\";i:186;s:4:\"name\";s:5:\"Matai\";s:7:\"ar_name\";s:8:\"مطاي\";s:7:\"en_name\";s:5:\"Matai\";s:6:\"active\";b:1;}i:236;a:5:{s:2:\"id\";i:30;s:4:\"name\";s:3:\"Max\";s:7:\"ar_name\";s:12:\"الماكس\";s:7:\"en_name\";s:3:\"Max\";s:6:\"active\";b:1;}i:237;a:5:{s:2:\"id\";i:102;s:4:\"name\";s:6:\"Menouf\";s:7:\"ar_name\";s:8:\"منوف\";s:7:\"en_name\";s:6:\"Menouf\";s:6:\"active\";b:1;}i:238;a:5:{s:2:\"id\";i:171;s:4:\"name\";s:12:\"Mersa Matruh\";s:7:\"ar_name\";s:19:\"مرسى مطروح\";s:7:\"en_name\";s:12:\"Mersa Matruh\";s:6:\"active\";b:1;}i:239;a:5:{s:2:\"id\";i:42;s:4:\"name\";s:5:\"Miami\";s:7:\"ar_name\";s:10:\"ميامي\";s:7:\"en_name\";s:5:\"Miami\";s:6:\"active\";b:1;}i:240;a:5:{s:2:\"id\";i:114;s:4:\"name\";s:13:\"Minya El Qamh\";s:7:\"ar_name\";s:19:\"منيا القمح\";s:7:\"en_name\";s:13:\"Minya El Qamh\";s:6:\"active\";b:1;}i:241;a:5:{s:2:\"id\";i:88;s:4:\"name\";s:14:\"Minyet El Nasr\";s:7:\"ar_name\";s:19:\"منية النصر\";s:7:\"en_name\";s:14:\"Minyet El Nasr\";s:6:\"active\";b:1;}i:242;a:5:{s:2:\"id\";i:330;s:4:\"name\";s:15:\"Misr Al-Jadidah\";s:7:\"ar_name\";s:21:\"مصر الجديدة\";s:7:\"en_name\";s:15:\"Misr Al-Jadidah\";s:6:\"active\";b:1;}i:243;a:5:{s:2:\"id\";i:343;s:4:\"name\";s:15:\"Misr Al-Qadimah\";s:7:\"ar_name\";s:21:\"مصر القديمة\";s:7:\"en_name\";s:15:\"Misr Al-Qadimah\";s:6:\"active\";b:1;}i:244;a:5:{s:2:\"id\";i:81;s:4:\"name\";s:9:\"Mit Ghamr\";s:7:\"ar_name\";s:13:\"ميت غمر\";s:7:\"en_name\";s:9:\"Mit Ghamr\";s:6:\"active\";b:1;}i:245;a:5:{s:2:\"id\";i:273;s:4:\"name\";s:8:\"Mit Oqba\";s:7:\"ar_name\";s:15:\"ميت عقبة\";s:7:\"en_name\";s:8:\"Mit Oqba\";s:6:\"active\";b:1;}i:246;a:5:{s:2:\"id\";i:97;s:4:\"name\";s:10:\"Mit Salsil\";s:7:\"ar_name\";s:19:\"ميت سلسبيل\";s:7:\"en_name\";s:10:\"Mit Salsil\";s:6:\"active\";b:1;}i:247;a:5:{s:2:\"id\";i:276;s:4:\"name\";s:11:\"Mohandessin\";s:7:\"ar_name\";s:18:\"المهندسين\";s:7:\"en_name\";s:11:\"Mohandessin\";s:6:\"active\";b:1;}i:248;a:5:{s:2:\"id\";i:59;s:4:\"name\";s:11:\"Moharam Bek\";s:7:\"ar_name\";s:13:\"محرم بك\";s:7:\"en_name\";s:11:\"Moharam Bek\";s:6:\"active\";b:1;}i:249;a:5:{s:2:\"id\";i:308;s:4:\"name\";s:16:\"Mosaset Al Zakah\";s:7:\"ar_name\";s:23:\"مؤسسة الزكاة\";s:7:\"en_name\";s:16:\"Mosaset Al Zakah\";s:6:\"active\";b:1;}i:250;a:5:{s:2:\"id\";i:283;s:4:\"name\";s:5:\"Munib\";s:7:\"ar_name\";s:12:\"المنيب\";s:7:\"en_name\";s:5:\"Munib\";s:6:\"active\";b:1;}i:251;a:5:{s:2:\"id\";i:138;s:4:\"name\";s:7:\"Mutubas\";s:7:\"ar_name\";s:10:\"مطوبس\";s:7:\"en_name\";s:7:\"Mutubas\";s:6:\"active\";b:1;}i:252;a:5:{s:2:\"id\";i:82;s:4:\"name\";s:7:\"Nabaroh\";s:7:\"ar_name\";s:10:\"نبروه\";s:7:\"en_name\";s:7:\"Nabaroh\";s:6:\"active\";b:1;}i:253;a:5:{s:2:\"id\";i:8;s:4:\"name\";s:11:\"Nag Hammadi\";s:7:\"ar_name\";s:17:\"نجع حمادي\";s:7:\"en_name\";s:11:\"Nag Hammadi\";s:6:\"active\";b:1;}i:254;a:5:{s:2:\"id\";i:297;s:4:\"name\";s:5:\"Nahda\";s:7:\"ar_name\";s:12:\"النهضة\";s:7:\"en_name\";s:5:\"Nahda\";s:6:\"active\";b:1;}i:255;a:5:{s:2:\"id\";i:44;s:4:\"name\";s:5:\"Najib\";s:7:\"ar_name\";s:8:\"نجيب\";s:7:\"en_name\";s:5:\"Najib\";s:6:\"active\";b:1;}i:256;a:5:{s:2:\"id\";i:156;s:4:\"name\";s:5:\"Nakhl\";s:7:\"ar_name\";s:6:\"نخل\";s:7:\"en_name\";s:5:\"Nakhl\";s:6:\"active\";b:1;}i:257;a:5:{s:2:\"id\";i:10;s:4:\"name\";s:6:\"Naqada\";s:7:\"ar_name\";s:10:\"نقادة\";s:7:\"en_name\";s:6:\"Naqada\";s:6:\"active\";b:1;}i:258;a:5:{s:2:\"id\";i:319;s:4:\"name\";s:9:\"Nasr City\";s:7:\"ar_name\";s:17:\"مدينة نصر\";s:7:\"en_name\";s:9:\"Nasr City\";s:6:\"active\";b:1;}i:259;a:5:{s:2:\"id\";i:212;s:4:\"name\";s:6:\"Nasser\";s:7:\"ar_name\";s:8:\"ناصر\";s:7:\"en_name\";s:6:\"Nasser\";s:6:\"active\";b:1;}i:260;a:5:{s:2:\"id\";i:78;s:4:\"name\";s:12:\"Natrn Valley\";s:7:\"ar_name\";s:23:\"وادي النطرون\";s:7:\"en_name\";s:12:\"Natrn Valley\";s:6:\"active\";b:1;}i:261;a:5:{s:2:\"id\";i:61;s:4:\"name\";s:16:\"New Borg El Arab\";s:7:\"ar_name\";s:32:\"برج العرب الجديدة\";s:7:\"en_name\";s:16:\"New Borg El Arab\";s:6:\"active\";b:1;}i:262;a:5:{s:2:\"id\";i:352;s:4:\"name\";s:9:\"New Cairo\";s:7:\"ar_name\";s:29:\"القاهرة الجديدة\";s:7:\"en_name\";s:9:\"New Cairo\";s:6:\"active\";b:1;}i:263;a:5:{s:2:\"id\";i:233;s:4:\"name\";s:12:\"New Damietta\";s:7:\"ar_name\";s:25:\"دمياط الجديدة\";s:7:\"en_name\";s:12:\"New Damietta\";s:6:\"active\";b:1;}i:264;a:5:{s:2:\"id\";i:194;s:4:\"name\";s:9:\"New Minya\";s:7:\"ar_name\";s:27:\"المنيا الجديدة\";s:7:\"en_name\";s:9:\"New Minya\";s:6:\"active\";b:1;}i:265;a:5:{s:2:\"id\";i:29;s:4:\"name\";s:11:\"North Coast\";s:7:\"ar_name\";s:27:\"الساحل الشمالي\";s:7:\"en_name\";s:11:\"North Coast\";s:6:\"active\";b:1;}i:266;a:5:{s:2:\"id\";i:6;s:4:\"name\";s:10:\"Nuba Naser\";s:7:\"ar_name\";s:19:\"نصر النوبة\";s:7:\"en_name\";s:10:\"Nuba Naser\";s:6:\"active\";b:1;}i:267;a:5:{s:2:\"id\";i:77;s:4:\"name\";s:9:\"Nubariyah\";s:7:\"ar_name\";s:18:\"النوبارية\";s:7:\"en_name\";s:9:\"Nubariyah\";s:6:\"active\";b:1;}i:268;a:5:{s:2:\"id\";i:164;s:4:\"name\";s:7:\"Nuweiba\";s:7:\"ar_name\";s:10:\"نويبع\";s:7:\"en_name\";s:7:\"Nuweiba\";s:6:\"active\";b:1;}i:269;a:5:{s:2:\"id\";i:296;s:4:\"name\";s:5:\"Orabi\";s:7:\"ar_name\";s:10:\"عرابي\";s:7:\"en_name\";s:5:\"Orabi\";s:6:\"active\";b:1;}i:270;a:5:{s:2:\"id\";i:251;s:4:\"name\";s:5:\"Ossim\";s:7:\"ar_name\";s:10:\"اوسيم\";s:7:\"en_name\";s:5:\"Ossim\";s:6:\"active\";b:1;}i:271;a:5:{s:2:\"id\";i:223;s:4:\"name\";s:9:\"Port Fuad\";s:7:\"ar_name\";s:15:\"بور فؤاد\";s:7:\"en_name\";s:9:\"Port Fuad\";s:6:\"active\";b:1;}i:272;a:5:{s:2:\"id\";i:366;s:4:\"name\";s:9:\"Port Said\";s:7:\"ar_name\";s:14:\"بورسعيد\";s:7:\"en_name\";s:9:\"Port Said\";s:6:\"active\";b:1;}i:273;a:5:{s:2:\"id\";i:364;s:4:\"name\";s:4:\"Qaha\";s:7:\"ar_name\";s:6:\"قها\";s:7:\"en_name\";s:4:\"Qaha\";s:6:\"active\";b:1;}i:274;a:5:{s:2:\"id\";i:371;s:4:\"name\";s:5:\"Qalaa\";s:7:\"ar_name\";s:12:\"القلعة\";s:7:\"en_name\";s:5:\"Qalaa\";s:6:\"active\";b:1;}i:275;a:5:{s:2:\"id\";i:356;s:4:\"name\";s:6:\"Qalyub\";s:7:\"ar_name\";s:10:\"قليوب\";s:7:\"en_name\";s:6:\"Qalyub\";s:6:\"active\";b:1;}i:276;a:5:{s:2:\"id\";i:9;s:4:\"name\";s:4:\"Qena\";s:7:\"ar_name\";s:6:\"قنا\";s:7:\"en_name\";s:4:\"Qena\";s:6:\"active\";b:1;}i:277;a:5:{s:2:\"id\";i:140;s:4:\"name\";s:5:\"Qilin\";s:7:\"ar_name\";s:8:\"قلين\";s:7:\"en_name\";s:5:\"Qilin\";s:6:\"active\";b:1;}i:278;a:5:{s:2:\"id\";i:100;s:4:\"name\";s:6:\"Quesna\";s:7:\"ar_name\";s:12:\"قويسنا\";s:7:\"en_name\";s:6:\"Quesna\";s:6:\"active\";b:1;}i:279;a:5:{s:2:\"id\";i:180;s:4:\"name\";s:5:\"Qurna\";s:7:\"ar_name\";s:12:\"القرنة\";s:7:\"en_name\";s:5:\"Qurna\";s:6:\"active\";b:1;}i:280;a:5:{s:2:\"id\";i:13;s:4:\"name\";s:3:\"Qus\";s:7:\"ar_name\";s:6:\"قوص\";s:7:\"en_name\";s:3:\"Qus\";s:6:\"active\";b:1;}i:281;a:5:{s:2:\"id\";i:160;s:4:\"name\";s:5:\"Rafah\";s:7:\"ar_name\";s:6:\"رفح\";s:7:\"en_name\";s:5:\"Rafah\";s:6:\"active\";b:1;}i:282;a:5:{s:2:\"id\";i:76;s:4:\"name\";s:9:\"Rahmaniya\";s:7:\"ar_name\";s:18:\"الرحمانية\";s:7:\"en_name\";s:9:\"Rahmaniya\";s:6:\"active\";b:1;}i:283;a:5:{s:2:\"id\";i:369;s:4:\"name\";s:6:\"Ramsis\";s:7:\"ar_name\";s:10:\"رمسيس\";s:7:\"en_name\";s:6:\"Ramsis\";s:6:\"active\";b:1;}i:284;a:5:{s:2:\"id\";i:235;s:4:\"name\";s:10:\"Ras El Bar\";s:7:\"ar_name\";s:15:\"راس البر\";s:7:\"en_name\";s:10:\"Ras El Bar\";s:6:\"active\";b:1;}i:285;a:5:{s:2:\"id\";i:130;s:4:\"name\";s:10:\"Ras Ghareb\";s:7:\"ar_name\";s:15:\"راس غارب\";s:7:\"en_name\";s:10:\"Ras Ghareb\";s:6:\"active\";b:1;}i:286;a:5:{s:2:\"id\";i:166;s:4:\"name\";s:8:\"Ras Sidr\";s:7:\"ar_name\";s:13:\"رأس صدر\";s:7:\"en_name\";s:8:\"Ras Sidr\";s:6:\"active\";b:1;}i:287;a:5:{s:2:\"id\";i:136;s:4:\"name\";s:6:\"Riyadh\";s:7:\"ar_name\";s:12:\"الرياض\";s:7:\"en_name\";s:6:\"Riyadh\";s:6:\"active\";b:1;}i:288;a:5:{s:2:\"id\";i:306;s:4:\"name\";s:12:\"Rod El Farag\";s:7:\"ar_name\";s:17:\"روض الفرج\";s:7:\"en_name\";s:12:\"Rod El Farag\";s:6:\"active\";b:1;}i:289;a:5:{s:2:\"id\";i:75;s:4:\"name\";s:7:\"Rosetta\";s:7:\"ar_name\";s:8:\"رشيد\";s:7:\"en_name\";s:7:\"Rosetta\";s:6:\"active\";b:1;}i:290;a:5:{s:2:\"id\";i:48;s:4:\"name\";s:6:\"Roshdy\";s:7:\"ar_name\";s:8:\"رشدي\";s:7:\"en_name\";s:6:\"Roshdy\";s:6:\"active\";b:1;}i:291;a:5:{s:2:\"id\";i:104;s:4:\"name\";s:5:\"Sadat\";s:7:\"ar_name\";s:14:\"السادات\";s:7:\"en_name\";s:5:\"Sadat\";s:6:\"active\";b:1;}i:292;a:5:{s:2:\"id\";i:131;s:4:\"name\";s:6:\"Safaga\";s:7:\"ar_name\";s:10:\"سفاجا\";s:7:\"en_name\";s:6:\"Safaga\";s:6:\"active\";b:1;}i:293;a:5:{s:2:\"id\";i:262;s:4:\"name\";s:13:\"Saft El Laban\";s:7:\"ar_name\";s:17:\"صفط اللبن\";s:7:\"en_name\";s:13:\"Saft El Laban\";s:6:\"active\";b:1;}i:294;a:5:{s:2:\"id\";i:203;s:4:\"name\";s:11:\"Sahel Selim\";s:7:\"ar_name\";s:17:\"ساحل سليم\";s:7:\"en_name\";s:11:\"Sahel Selim\";s:6:\"active\";b:1;}i:295;a:5:{s:2:\"id\";i:168;s:4:\"name\";s:15:\"Saint Catherine\";s:7:\"ar_name\";s:21:\"سانت كاترين\";s:7:\"en_name\";s:15:\"Saint Catherine\";s:6:\"active\";b:1;}i:296;a:5:{s:2:\"id\";i:116;s:4:\"name\";s:6:\"Salhia\";s:7:\"ar_name\";s:16:\"الصالحية\";s:7:\"en_name\";s:6:\"Salhia\";s:6:\"active\";b:1;}i:297;a:5:{s:2:\"id\";i:172;s:4:\"name\";s:6:\"Sallum\";s:7:\"ar_name\";s:12:\"السلوم\";s:7:\"en_name\";s:6:\"Sallum\";s:6:\"active\";b:1;}i:298;a:5:{s:2:\"id\";i:187;s:4:\"name\";s:7:\"Samalut\";s:7:\"ar_name\";s:12:\"سمالوط\";s:7:\"en_name\";s:7:\"Samalut\";s:6:\"active\";b:1;}i:299;a:5:{s:2:\"id\";i:151;s:4:\"name\";s:8:\"Samanoud\";s:7:\"ar_name\";s:10:\"سمنود\";s:7:\"en_name\";s:8:\"Samanoud\";s:6:\"active\";b:1;}i:300;a:5:{s:2:\"id\";i:47;s:4:\"name\";s:11:\"San Stefano\";s:7:\"ar_name\";s:21:\"سان ستيفانو\";s:7:\"en_name\";s:11:\"San Stefano\";s:6:\"active\";b:1;}i:301;a:5:{s:2:\"id\";i:87;s:4:\"name\";s:6:\"Sandob\";s:7:\"ar_name\";s:10:\"سندوب\";s:7:\"en_name\";s:6:\"Sandob\";s:6:\"active\";b:1;}i:302;a:5:{s:2:\"id\";i:27;s:4:\"name\";s:7:\"Saqlata\";s:7:\"ar_name\";s:12:\"ساقلتا\";s:7:\"en_name\";s:7:\"Saqlata\";s:6:\"active\";b:1;}i:303;a:5:{s:2:\"id\";i:260;s:4:\"name\";s:7:\"Saqqara\";s:7:\"ar_name\";s:10:\"سقارة\";s:7:\"en_name\";s:7:\"Saqqara\";s:6:\"active\";b:1;}i:304;a:5:{s:2:\"id\";i:103;s:4:\"name\";s:12:\"Sers El Lyan\";s:7:\"ar_name\";s:19:\"سرس الليان\";s:7:\"en_name\";s:12:\"Sers El Lyan\";s:6:\"active\";b:1;}i:305;a:5:{s:2:\"id\";i:259;s:4:\"name\";s:10:\"Shabramant\";s:7:\"ar_name\";s:14:\"شبرامنت\";s:7:\"en_name\";s:10:\"Shabramant\";s:6:\"active\";b:1;}i:306;a:5:{s:2:\"id\";i:134;s:4:\"name\";s:17:\"Shalateen& Halaib\";s:7:\"ar_name\";s:26:\"حلايب و شلاتين\";s:7:\"en_name\";s:17:\"Shalateen& Halaib\";s:6:\"active\";b:1;}i:307;a:5:{s:2:\"id\";i:167;s:4:\"name\";s:15:\"Sharm El Sheikh\";s:7:\"ar_name\";s:17:\"شرم الشيخ\";s:7:\"en_name\";s:15:\"Sharm El Sheikh\";s:6:\"active\";b:1;}i:308;a:5:{s:2:\"id\";i:53;s:4:\"name\";s:6:\"Shatby\";s:7:\"ar_name\";s:14:\"الشاطبي\";s:7:\"en_name\";s:6:\"Shatby\";s:6:\"active\";b:1;}i:309;a:5:{s:2:\"id\";i:99;s:4:\"name\";s:14:\"Shbeen El Koom\";s:7:\"ar_name\";s:19:\"شبين الكوم\";s:7:\"en_name\";s:14:\"Shbeen El Koom\";s:6:\"active\";b:1;}i:310;a:5:{s:2:\"id\";i:289;s:4:\"name\";s:17:\"Sheikh Zayed City\";s:7:\"ar_name\";s:19:\"الشيخ زايد\";s:7:\"en_name\";s:17:\"Sheikh Zayed City\";s:6:\"active\";b:1;}i:311;a:5:{s:2:\"id\";i:159;s:4:\"name\";s:13:\"Sheikh Zuweid\";s:7:\"ar_name\";s:19:\"الشيخ زويد\";s:7:\"en_name\";s:13:\"Sheikh Zuweid\";s:6:\"active\";b:1;}i:312;a:5:{s:2:\"id\";i:93;s:4:\"name\";s:7:\"Sherbin\";s:7:\"ar_name\";s:10:\"شربين\";s:7:\"en_name\";s:7:\"Sherbin\";s:6:\"active\";b:1;}i:313;a:5:{s:2:\"id\";i:362;s:4:\"name\";s:17:\"Shibin El Qanater\";s:7:\"ar_name\";s:23:\"شبين القناطر\";s:7:\"en_name\";s:17:\"Shibin El Qanater\";s:6:\"active\";b:1;}i:314;a:5:{s:2:\"id\";i:305;s:4:\"name\";s:6:\"Shubra\";s:7:\"ar_name\";s:15:\"شبرا مصر\";s:7:\"en_name\";s:6:\"Shubra\";s:6:\"active\";b:1;}i:315;a:5:{s:2:\"id\";i:354;s:4:\"name\";s:16:\"Shubra El Kheima\";s:7:\"ar_name\";s:21:\"شبرا الخيمة\";s:7:\"en_name\";s:16:\"Shubra El Kheima\";s:6:\"active\";b:1;}i:316;a:5:{s:2:\"id\";i:74;s:4:\"name\";s:10:\"Shubrakhit\";s:7:\"ar_name\";s:14:\"شبراخيت\";s:7:\"en_name\";s:10:\"Shubrakhit\";s:6:\"active\";b:1;}i:317;a:5:{s:2:\"id\";i:177;s:4:\"name\";s:12:\"Sidi Barrani\";s:7:\"ar_name\";s:19:\"سيدي براني\";s:7:\"en_name\";s:12:\"Sidi Barrani\";s:6:\"active\";b:1;}i:318;a:5:{s:2:\"id\";i:43;s:4:\"name\";s:17:\"Sidi Bishr Bahari\";s:7:\"ar_name\";s:24:\"سيدي بشر بحري\";s:7:\"en_name\";s:17:\"Sidi Bishr Bahari\";s:6:\"active\";b:1;}i:319;a:5:{s:2:\"id\";i:378;s:4:\"name\";s:16:\"Sidi Bishr Qebli\";s:7:\"ar_name\";s:24:\"سيدى بشر قبلى\";s:7:\"en_name\";s:16:\"Sidi Bishr Qebli\";s:6:\"active\";b:1;}i:320;a:5:{s:2:\"id\";i:49;s:4:\"name\";s:10:\"Sidi Gaber\";s:7:\"ar_name\";s:17:\"سيدي جابر\";s:7:\"en_name\";s:10:\"Sidi Gaber\";s:6:\"active\";b:1;}i:321;a:5:{s:2:\"id\";i:144;s:4:\"name\";s:10:\"Sidi Salem\";s:7:\"ar_name\";s:17:\"سيدي سالم\";s:7:\"en_name\";s:10:\"Sidi Salem\";s:6:\"active\";b:1;}i:322;a:5:{s:2:\"id\";i:215;s:4:\"name\";s:8:\"Sinnuris\";s:7:\"ar_name\";s:10:\"سنورس\";s:7:\"en_name\";s:8:\"Sinnuris\";s:6:\"active\";b:1;}i:323;a:5:{s:2:\"id\";i:176;s:4:\"name\";s:10:\"Siwa Oasis\";s:7:\"ar_name\";s:8:\"سيوة\";s:7:\"en_name\";s:10:\"Siwa Oasis\";s:6:\"active\";b:1;}i:324;a:5:{s:2:\"id\";i:287;s:4:\"name\";s:13:\"Smart Village\";s:7:\"ar_name\";s:25:\"القرية الذكية\";s:7:\"en_name\";s:13:\"Smart Village\";s:6:\"active\";b:1;}i:325;a:5:{s:2:\"id\";i:373;s:4:\"name\";s:6:\"Smouha\";s:7:\"ar_name\";s:10:\"سموحة\";s:7:\"en_name\";s:6:\"Smouha\";s:6:\"active\";b:1;}i:326;a:5:{s:2:\"id\";i:204;s:4:\"name\";s:5:\"Sodfa\";s:7:\"ar_name\";s:8:\"صدفا\";s:7:\"en_name\";s:5:\"Sodfa\";s:6:\"active\";b:1;}i:327;a:5:{s:2:\"id\";i:50;s:4:\"name\";s:8:\"Sporting\";s:7:\"ar_name\";s:14:\"سبورتنج\";s:7:\"en_name\";s:8:\"Sporting\";s:6:\"active\";b:1;}i:328;a:5:{s:2:\"id\";i:367;s:4:\"name\";s:4:\"Suez\";s:7:\"ar_name\";s:12:\"السويس\";s:7:\"en_name\";s:4:\"Suez\";s:6:\"active\";b:1;}i:329;a:5:{s:2:\"id\";i:207;s:4:\"name\";s:7:\"Sumusta\";s:7:\"ar_name\";s:10:\"سمسطا\";s:7:\"en_name\";s:7:\"Sumusta\";s:6:\"active\";b:1;}i:330;a:5:{s:2:\"id\";i:23;s:4:\"name\";s:5:\"Tahta\";s:7:\"ar_name\";s:8:\"طهطا\";s:7:\"en_name\";s:5:\"Tahta\";s:6:\"active\";b:1;}i:331;a:5:{s:2:\"id\";i:107;s:4:\"name\";s:4:\"Tala\";s:7:\"ar_name\";s:6:\"تلا\";s:7:\"en_name\";s:4:\"Tala\";s:6:\"active\";b:1;}i:332;a:5:{s:2:\"id\";i:85;s:4:\"name\";s:6:\"Talkha\";s:7:\"ar_name\";s:8:\"طلخا\";s:7:\"en_name\";s:6:\"Talkha\";s:6:\"active\";b:1;}i:333;a:5:{s:2:\"id\";i:26;s:4:\"name\";s:4:\"Tama\";s:7:\"ar_name\";s:6:\"طما\";s:7:\"en_name\";s:4:\"Tama\";s:6:\"active\";b:1;}i:334;a:5:{s:2:\"id\";i:216;s:4:\"name\";s:6:\"Tamiya\";s:7:\"ar_name\";s:10:\"طامية\";s:7:\"en_name\";s:6:\"Tamiya\";s:6:\"active\";b:1;}i:335;a:5:{s:2:\"id\";i:147;s:4:\"name\";s:5:\"Tanta\";s:7:\"ar_name\";s:8:\"طنطا\";s:7:\"en_name\";s:5:\"Tanta\";s:6:\"active\";b:1;}i:336;a:5:{s:2:\"id\";i:241;s:4:\"name\";s:13:\"Tell El Kebir\";s:7:\"ar_name\";s:21:\"التل الكبير\";s:7:\"en_name\";s:13:\"Tell El Kebir\";s:6:\"active\";b:1;}i:337;a:5:{s:2:\"id\";i:90;s:4:\"name\";s:15:\"Temay El Amdeed\";s:7:\"ar_name\";s:21:\"نمى الامديد\";s:7:\"en_name\";s:15:\"Temay El Amdeed\";s:6:\"active\";b:1;}i:338;a:5:{s:2:\"id\";i:348;s:4:\"name\";s:16:\"Third Settlement\";s:7:\"ar_name\";s:25:\"التجمع الثالث\";s:7:\"en_name\";s:16:\"Third Settlement\";s:6:\"active\";b:1;}i:339;a:5:{s:2:\"id\";i:183;s:4:\"name\";s:4:\"Todd\";s:7:\"ar_name\";s:10:\"الطود\";s:7:\"en_name\";s:4:\"Todd\";s:6:\"active\";b:1;}i:340;a:5:{s:2:\"id\";i:361;s:4:\"name\";s:4:\"Tukh\";s:7:\"ar_name\";s:6:\"طوخ\";s:7:\"en_name\";s:4:\"Tukh\";s:6:\"active\";b:1;}i:341;a:5:{s:2:\"id\";i:268;s:4:\"name\";s:6:\"Wardan\";s:7:\"ar_name\";s:10:\"وردان\";s:7:\"en_name\";s:6:\"Wardan\";s:6:\"active\";b:1;}i:342;a:5:{s:2:\"id\";i:311;s:4:\"name\";s:11:\"Wees bridge\";s:7:\"ar_name\";s:19:\"جسر السويس\";s:7:\"en_name\";s:11:\"Wees bridge\";s:6:\"active\";b:1;}i:343;a:5:{s:2:\"id\";i:120;s:4:\"name\";s:7:\"Zagazig\";s:7:\"ar_name\";s:16:\"الزقازيق\";s:7:\"en_name\";s:7:\"Zagazig\";s:6:\"active\";b:1;}i:344;a:5:{s:2:\"id\";i:271;s:4:\"name\";s:7:\"Zamalek\";s:7:\"ar_name\";s:14:\"الزمالك\";s:7:\"en_name\";s:7:\"Zamalek\";s:6:\"active\";b:1;}i:345;a:5:{s:2:\"id\";i:152;s:4:\"name\";s:5:\"Zefta\";s:7:\"ar_name\";s:8:\"زفتى\";s:7:\"en_name\";s:5:\"Zefta\";s:6:\"active\";b:1;}i:346;a:5:{s:2:\"id\";i:317;s:4:\"name\";s:7:\"Zeitoun\";s:7:\"ar_name\";s:25:\"حدائق الزيتون\";s:7:\"en_name\";s:7:\"Zeitoun\";s:6:\"active\";b:1;}i:347;a:5:{s:2:\"id\";i:181;s:4:\"name\";s:6:\"Zinnia\";s:7:\"ar_name\";s:14:\"الزينية\";s:7:\"en_name\";s:6:\"Zinnia\";s:6:\"active\";b:1;}i:348;a:5:{s:2:\"id\";i:303;s:4:\"name\";s:11:\"future city\";s:7:\"ar_name\";s:27:\"مدينه المستقبل\";s:7:\"en_name\";s:11:\"future city\";s:6:\"active\";b:1;}i:349;a:5:{s:2:\"id\";i:37;s:4:\"name\";s:4:\"ibis\";s:7:\"ar_name\";s:8:\"ابيس\";s:7:\"en_name\";s:4:\"ibis\";s:6:\"active\";b:1;}}',1786561401);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `total_value` decimal(12,2) DEFAULT NULL,
  `is_converted` tinyint(1) NOT NULL DEFAULT '0',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `variant_id` bigint unsigned DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `license_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_items_cart_id_foreign` (`cart_id`),
  KEY `cart_items_product_id_foreign` (`product_id`),
  CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
INSERT INTO `cart_items` VALUES (160,128,11,NULL,1,NULL),(161,128,14,NULL,1,NULL),(162,128,13,NULL,1,NULL),(185,148,14,NULL,1,NULL),(187,143,36,NULL,1,NULL),(220,8,36,NULL,1,NULL),(224,196,64,NULL,1,NULL),(249,333,14,NULL,1,NULL);
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `guest_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `carts_user_id_unique` (`user_id`),
  UNIQUE KEY `carts_guest_token_unique` (`guest_token`),
  CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=356 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` VALUES (1,2,NULL,NULL,'2026-06-25 20:43:32','2026-06-25 20:43:32'),(2,1,NULL,NULL,'2026-06-25 20:43:45','2026-06-25 20:43:45'),(3,11,NULL,NULL,'2026-06-25 22:56:13','2026-06-25 22:56:13'),(4,6,NULL,NULL,'2026-06-25 23:05:54','2026-06-25 23:05:54'),(5,8,NULL,NULL,'2026-06-26 11:12:30','2026-06-26 11:12:30'),(6,5,NULL,NULL,'2026-06-26 12:23:28','2026-06-26 12:23:28'),(7,4,NULL,NULL,'2026-06-29 12:26:12','2026-06-29 12:26:12'),(8,14,NULL,NULL,'2026-07-04 11:26:27','2026-07-04 11:26:27'),(9,NULL,NULL,NULL,'2026-07-04 19:41:14','2026-07-04 19:41:14'),(10,NULL,NULL,NULL,'2026-07-04 19:43:17','2026-07-04 19:43:17'),(11,NULL,NULL,NULL,'2026-07-04 19:43:21','2026-07-04 19:43:21'),(12,NULL,'guest_abc123',NULL,'2026-07-04 19:43:37','2026-07-04 19:43:37'),(14,NULL,'guest_1d122056-9197-445d-b290-be5908668466',NULL,'2026-07-04 19:44:30','2026-07-04 19:44:30'),(15,NULL,'guest_2ef1906b-1554-4fd6-b223-84f1a18ed603',NULL,'2026-07-20 10:46:44','2026-07-20 10:46:44'),(16,NULL,'guest_c7f110fc-1083-4467-bd9f-17d80b664c97',NULL,'2026-07-20 10:46:46','2026-07-20 10:46:46'),(17,NULL,'guest_fa8128cb-97ae-407d-a2fe-64d6dff9c668',NULL,'2026-07-20 10:52:06','2026-07-20 10:52:06'),(18,NULL,'guest_c40705b4-d3cb-4c07-9c0f-981aeb1371e0',NULL,'2026-07-20 11:54:06','2026-07-20 11:54:06'),(19,NULL,'guest_9497ae49-fa2c-45c5-8fa5-db68d9f76c39',NULL,'2026-07-20 12:24:17','2026-07-20 12:24:17'),(20,NULL,'guest_71acde60-7c2c-4677-b6c3-537f7344ccb8',NULL,'2026-07-20 13:45:37','2026-07-20 13:45:37'),(21,NULL,'guest_08beabfb-907d-4ec2-9132-72af1ebff32d',NULL,'2026-07-20 13:45:43','2026-07-20 13:45:43'),(22,NULL,'guest_07640753-2fb7-4abc-b6ed-7f3cd6ec1b2d',NULL,'2026-07-20 13:58:01','2026-07-20 13:58:01'),(23,NULL,'guest_8aa9e3ad-6bbe-4059-bb44-ef07037fb45b',NULL,'2026-07-20 16:27:58','2026-07-20 16:27:58'),(24,NULL,'guest_b01735a3-64f1-4cb9-8316-0e24295600f6',NULL,'2026-07-20 18:26:44','2026-07-20 18:26:44'),(25,NULL,'guest_861e5214-198a-4b5f-8e53-e481be753919',NULL,'2026-07-20 21:20:51','2026-07-20 21:20:51'),(26,NULL,'guest_8311c8ae-8c6a-4fde-80ad-d3675311e3cc',NULL,'2026-07-21 04:27:24','2026-07-21 04:27:24'),(27,NULL,'guest_2d42f86f-ac9e-49b9-92aa-d4d500e4e7d1',NULL,'2026-07-21 06:27:10','2026-07-21 06:27:10'),(28,NULL,'guest_67200426-2159-4cff-9e51-c36ee92c2e43',NULL,'2026-07-21 06:44:27','2026-07-21 06:44:27'),(29,NULL,'guest_835a3879-a02f-420e-8fd5-b5c766093091',NULL,'2026-07-21 09:29:06','2026-07-21 09:29:06'),(30,NULL,'guest_08e59f45-de5d-4a13-9658-929567ceadfe',NULL,'2026-07-21 09:47:35','2026-07-21 09:47:35'),(31,NULL,'guest_5aac47f6-43b1-45df-95a6-9eb2acc2da1f',NULL,'2026-07-21 12:37:07','2026-07-21 12:37:07'),(32,NULL,'guest_c058cd84-288c-48a4-b772-222689fc772c',NULL,'2026-07-21 18:27:34','2026-07-21 18:27:34'),(33,NULL,'guest_accbc7bd-32b8-49d0-86f6-776b5998aae3',NULL,'2026-07-22 06:46:02','2026-07-22 06:46:02'),(34,NULL,'test-guest-123',NULL,'2026-07-22 06:59:29','2026-07-22 06:59:29'),(35,NULL,'test-guest-456',NULL,'2026-07-22 07:00:41','2026-07-22 07:00:41'),(36,15,NULL,NULL,'2026-07-22 07:13:41','2026-07-22 07:13:41'),(37,NULL,'guest_15cbabcc-af0a-4e82-a7b1-6929322b085d',NULL,'2026-07-22 07:15:51','2026-07-22 07:15:51'),(38,NULL,'test-no-address-999',NULL,'2026-07-22 07:21:10','2026-07-22 07:21:10'),(39,16,NULL,NULL,'2026-07-22 08:01:25','2026-07-22 08:01:25'),(40,NULL,'guest_c999a834-7662-4bb6-af66-54151758757b',NULL,'2026-07-22 09:41:02','2026-07-22 09:41:02'),(41,NULL,'test-ship-123',NULL,'2026-07-22 12:24:40','2026-07-22 12:24:40'),(42,NULL,'guest_7c5020bb-c1e6-49a1-ae64-e9058891df0e',NULL,'2026-07-22 21:54:25','2026-07-22 21:54:25'),(44,NULL,'guest_a607a3ad-748b-4137-867e-e94b98fa0130',NULL,'2026-07-24 14:48:20','2026-07-24 14:48:20'),(45,NULL,'guest_f00b15c5-7162-4784-83be-28c02390189f',NULL,'2026-07-25 00:52:38','2026-07-25 00:52:38'),(46,NULL,'guest_a1070bbc-534a-414a-8ae4-310c6a45e5cb',NULL,'2026-07-25 22:55:26','2026-07-25 22:55:26'),(47,NULL,'guest_37e0c0a2-59e6-4ea3-bf29-8447c8438ada',NULL,'2026-07-26 04:42:59','2026-07-26 04:42:59'),(48,NULL,'guest_dc5b09a6-7d31-458a-afa2-fcd2435d3553',NULL,'2026-07-26 06:09:46','2026-07-26 06:09:46'),(49,NULL,'guest_de724ded-c86e-4e72-9039-7896d2853521',NULL,'2026-07-26 06:27:35','2026-07-26 06:27:35'),(50,NULL,'guest_d9795756-912c-4a9e-8d62-69c455714055',NULL,'2026-07-26 12:36:56','2026-07-26 12:36:56'),(51,NULL,'guest_059c6dab-3d6e-4b5e-9c1b-857c5e971563',NULL,'2026-07-26 13:23:15','2026-07-26 13:23:15'),(52,NULL,'guest_2f7ea3c9-78f6-4078-b61d-3b5cf4f8277c',NULL,'2026-07-26 16:21:23','2026-07-26 16:21:23'),(53,NULL,'guest_775548a1-7619-49ca-95fd-49c659fb7422',NULL,'2026-07-26 20:08:28','2026-07-26 20:08:28'),(54,NULL,'guest_2f1de318-608e-4581-b85c-a84afed7f70c',NULL,'2026-07-26 21:31:50','2026-07-26 21:31:50'),(55,NULL,'guest_1bcaa755-e0c5-4112-b970-074f9419986e',NULL,'2026-07-26 21:52:40','2026-07-26 21:52:40'),(56,NULL,'guest_a4c41817-b5dd-4113-ae39-3a05e8ebdde7',NULL,'2026-07-27 08:25:01','2026-07-27 08:25:01'),(57,3,NULL,NULL,'2026-07-27 09:54:10','2026-07-27 09:54:10'),(58,NULL,'guest_4ac59526-ebd9-4fed-9caf-73c616c6212b',NULL,'2026-07-27 17:32:39','2026-07-27 17:32:39'),(59,NULL,'guest_3845d80c-7b71-4cd0-99c6-a1b067bf5298',NULL,'2026-07-27 17:58:40','2026-07-27 17:58:40'),(60,NULL,'guest_81085cc2-28e7-43f8-9aec-ddce9099c601',NULL,'2026-07-27 17:58:44','2026-07-27 17:58:44'),(61,NULL,'guest_95650d81-2116-4b9a-be70-096689306352',NULL,'2026-07-27 17:58:48','2026-07-27 17:58:48'),(62,NULL,'guest_c9ce5e52-5799-417f-b79b-5db91338883a',NULL,'2026-07-27 17:58:51','2026-07-27 17:58:51'),(63,NULL,'guest_9206ee1c-6379-4c9b-ad1c-9038c4157d39',NULL,'2026-07-27 19:14:14','2026-07-27 19:14:14'),(64,NULL,'guest_160bf64a-4c4c-4bc8-8a68-9c8b7dbf48de',NULL,'2026-07-27 19:14:18','2026-07-27 19:14:18'),(65,NULL,'guest_157e568a-73d9-45f0-b056-df763d3c09c1',NULL,'2026-07-27 19:14:22','2026-07-27 19:14:22'),(66,NULL,'guest_96c54d6c-2b87-471f-8f03-40fe14f5b6c2',NULL,'2026-07-28 00:23:51','2026-07-28 00:23:51'),(67,NULL,'guest_ab142e06-7855-44a1-8911-1a2ffdb0dac1',NULL,'2026-07-28 00:25:01','2026-07-28 00:25:01'),(68,NULL,'guest_acad8d62-18cb-4b8a-a172-283a0117f1dd',NULL,'2026-07-28 05:55:03','2026-07-28 05:55:03'),(69,NULL,'guest_d1500bf2-3e17-4370-88a9-dad7510c4fb7',NULL,'2026-07-28 06:09:19','2026-07-28 06:09:19'),(70,NULL,'guest_468b78c9-53c1-4543-a3a5-1942d3cb345b',NULL,'2026-07-28 11:04:13','2026-07-28 11:04:13'),(71,NULL,'guest_14efde15-548f-4353-959b-3c9566ff7f4d',NULL,'2026-07-28 18:12:06','2026-07-28 18:12:06'),(72,NULL,'guest_a3b787b8-93c5-4cc1-9f3c-5f7c7404040d',NULL,'2026-07-30 03:46:39','2026-07-30 03:46:39'),(73,NULL,'guest_253fc943-457b-4c91-b805-7ce1ac07737a',NULL,'2026-07-30 07:18:01','2026-07-30 07:18:01'),(74,NULL,'guest_334247b9-b68d-4347-9fda-f0760bfa5f0c',NULL,'2026-07-30 16:04:19','2026-07-30 16:04:19'),(75,NULL,'guest_6439d60c-2476-43d6-8668-780c9546211b',NULL,'2026-07-30 20:35:35','2026-07-30 20:35:35'),(76,NULL,'guest_9bddb3af-45dc-451b-ad54-334e7051ded2',NULL,'2026-07-30 20:35:35','2026-07-30 20:35:35'),(77,NULL,'guest_b44191c5-34f6-4345-a89c-1c274ecc91b8',NULL,'2026-07-30 21:02:53','2026-07-30 21:02:53'),(78,NULL,'guest_28bf7a72-e68b-4262-b3b6-f4701f6698ee',NULL,'2026-07-30 21:57:43','2026-07-30 21:57:43'),(79,NULL,'guest_255d8871-c5d1-459e-90cd-48e9a017ba22',NULL,'2026-07-30 21:57:43','2026-07-30 21:57:43'),(80,NULL,'guest_3745ccfd-5d7a-421c-8dd7-d2e90b02694a',NULL,'2026-07-30 21:59:30','2026-07-30 21:59:30'),(81,NULL,'guest_ed2ef993-5def-41d2-bebd-87aa7a267933',NULL,'2026-07-30 23:10:18','2026-07-30 23:10:18'),(82,NULL,'guest_cf17fddd-5b23-4379-bafc-33267ef85518',NULL,'2026-07-31 03:43:26','2026-07-31 03:43:26'),(83,NULL,'guest_f10c61da-414c-4ec2-bd6b-e895ec955f66',NULL,'2026-07-31 09:19:58','2026-07-31 09:19:58'),(84,NULL,'guest_b3e9fedf-a6b2-45f3-9dae-2430ca19f058',NULL,'2026-07-31 15:26:39','2026-07-31 15:26:39'),(85,NULL,'guest_4efdd57b-3a08-4adc-ab4e-7be795ef0775',NULL,'2026-08-01 09:08:11','2026-08-01 09:08:11'),(86,NULL,'guest_a6602082-251d-439e-9b2b-b9bcc6087117',NULL,'2026-08-01 13:14:21','2026-08-01 13:14:21'),(87,NULL,'guest_1637f237-d5c9-4151-b439-edf1ff034d5c',NULL,'2026-08-01 13:16:53','2026-08-01 13:16:53'),(88,NULL,'guest_4db1f5ac-b421-4947-b94c-b3c92c3d9d88',NULL,'2026-08-01 13:19:05','2026-08-01 13:19:05'),(90,NULL,'guest_dev_test',NULL,'2026-08-01 13:19:42','2026-08-01 13:19:42'),(91,NULL,'guest_vartest',NULL,'2026-08-01 13:20:15','2026-08-01 13:20:15'),(92,NULL,'guest_07091fe7-1dcb-4ce8-a01a-8dc797b690a5',NULL,'2026-08-01 13:29:00','2026-08-01 13:29:00'),(93,NULL,'guest_5ffd239e-a72a-47b3-a7aa-c87c7496f0e6',NULL,'2026-08-01 13:32:10','2026-08-01 13:32:10'),(94,NULL,'guest_0703edc7-378d-4028-bd6a-32f3c1021367',NULL,'2026-08-01 13:32:26','2026-08-01 13:32:26'),(95,NULL,'guest_cors_test',NULL,'2026-08-01 13:32:55','2026-08-01 13:32:55'),(96,NULL,'guest_origin_test',NULL,'2026-08-01 13:33:16','2026-08-01 13:33:16'),(97,NULL,'guest_origin_test2',NULL,'2026-08-01 13:34:26','2026-08-01 13:34:26'),(98,NULL,'guest_verify',NULL,'2026-08-01 13:34:47','2026-08-01 13:34:47'),(99,NULL,'guest_verify2',NULL,'2026-08-01 13:34:47','2026-08-01 13:34:47'),(100,NULL,'guest_bust_1785591661',NULL,'2026-08-01 13:41:01','2026-08-01 13:41:01'),(101,NULL,'guest_bust2',NULL,'2026-08-01 13:41:01','2026-08-01 13:41:01'),(102,NULL,'guest_now_1785592066',NULL,'2026-08-01 13:47:47','2026-08-01 13:47:47'),(103,NULL,'guest_cb1',NULL,'2026-08-01 13:48:38','2026-08-01 13:48:38'),(104,NULL,'guest_cb2',NULL,'2026-08-01 13:48:39','2026-08-01 13:48:39'),(105,NULL,'guest_9e503091-6168-4a1a-98bf-0ac0c2339fa7',NULL,'2026-08-01 13:48:58','2026-08-01 13:48:58'),(106,NULL,'guest_915d6e13-5f4d-46fc-ac19-c3423b411c0e',NULL,'2026-08-01 13:49:05','2026-08-01 13:49:05'),(107,NULL,'guest_92c608f1-3c43-445f-a427-d50ad56708dd',NULL,'2026-08-01 13:49:38','2026-08-01 13:49:38'),(108,NULL,'guest_5f512660-79ed-4f58-815f-0fba8861187f',NULL,'2026-08-01 13:50:14','2026-08-01 13:50:14'),(109,NULL,'guest_e06c539d-cddd-405e-b27f-81df63e4e8b1',NULL,'2026-08-01 13:50:25','2026-08-01 13:50:25'),(116,19,NULL,NULL,'2026-08-01 14:08:53','2026-08-01 14:08:53'),(117,NULL,'guest_1bec8dbc-40e4-4936-83df-1e0ca636dab6',NULL,'2026-08-01 14:16:47','2026-08-01 14:16:47'),(118,NULL,'guest_4fd9d024-3840-4c59-a6bd-86d2f73a7532',NULL,'2026-08-01 14:34:26','2026-08-01 14:34:26'),(119,NULL,'guest_b6972957-d5c1-46df-b05d-1ccbce614b47',NULL,'2026-08-01 15:31:51','2026-08-01 15:31:51'),(121,NULL,'guest_17ed8449-31e8-4d70-a78e-20a517a87341',NULL,'2026-08-01 18:11:49','2026-08-01 18:11:49'),(122,NULL,'guest_c9935006-f7ad-4ddf-a616-7849dedba2cd',NULL,'2026-08-01 22:11:28','2026-08-01 22:11:28'),(123,NULL,'guest_5d764596-79af-425a-8a34-0a43a15bf238',NULL,'2026-08-02 23:47:03','2026-08-02 23:47:03'),(124,NULL,'guest_8ba5a556-570b-433a-a62c-fb1598156a86',NULL,'2026-08-03 00:35:54','2026-08-03 00:35:54'),(125,NULL,'guest_d86ab354-15f1-42b9-a2f9-72e1a0b364a9',NULL,'2026-08-03 00:35:58','2026-08-03 00:35:58'),(126,NULL,'guest_d534f1af-81c9-4fb5-b06c-6c53785ac66a',NULL,'2026-08-03 12:20:20','2026-08-03 12:20:20'),(127,NULL,'guest_b2855e36-d295-4e48-b813-143534515274',NULL,'2026-08-03 12:29:59','2026-08-03 12:29:59'),(128,NULL,'guest_c52afc91-53d2-4b5b-8bf9-d944a5f5b0da',NULL,'2026-08-03 12:32:33','2026-08-03 12:32:33'),(129,NULL,'guest_1d5bc148-2249-4d27-916c-469afef909ee',NULL,'2026-08-03 12:40:58','2026-08-03 12:40:58'),(130,NULL,'guest_ccd0fb24-2120-42e4-b29e-e54feec7520e',NULL,'2026-08-03 12:42:55','2026-08-03 12:42:55'),(131,NULL,'probe-1',NULL,'2026-08-03 13:09:47','2026-08-03 13:09:47'),(132,NULL,'probe-2',NULL,'2026-08-03 13:12:53','2026-08-03 13:12:53'),(133,NULL,'guest_dd33862b-2ed4-4efb-8961-1ebf442a32fe',NULL,'2026-08-03 13:17:42','2026-08-03 13:17:42'),(135,NULL,'guest_1a94c945-096a-4e2f-be7b-b632ab16659e',NULL,'2026-08-03 13:26:05','2026-08-03 13:26:05'),(136,NULL,'guest_62f4eac4-96c5-4f63-9821-c87f4f2ee1ea',NULL,'2026-08-03 15:37:00','2026-08-03 15:37:00'),(137,NULL,'guest_d0b80dfa-8b5b-477a-8915-f629a189a8b0',NULL,'2026-08-03 19:10:26','2026-08-03 19:10:26'),(138,NULL,'guest_a1872548-1516-4c02-8b10-e81bd2b650a7',NULL,'2026-08-03 21:48:54','2026-08-03 21:48:54'),(140,NULL,'guest_e0438f13-05d7-4f3c-987f-3cd6b5e08ef0',NULL,'2026-08-03 23:06:53','2026-08-03 23:06:53'),(141,NULL,'guest_c7151fbe-bfc9-425a-b0eb-d8b227279489',NULL,'2026-08-03 23:06:53','2026-08-03 23:06:53'),(142,NULL,'guest_e742dc0e-ee60-4249-b2ad-9c8ac976bd6c',NULL,'2026-08-04 04:07:17','2026-08-04 04:07:17'),(143,NULL,'guest_fca3fe14-6e80-4666-95eb-783ef3f3b3d6',NULL,'2026-08-04 09:13:08','2026-08-04 09:13:08'),(144,NULL,'guest_07daeecb-cae8-458a-bf9b-f77fad5be014',NULL,'2026-08-04 15:59:53','2026-08-04 15:59:53'),(145,NULL,'guest_89f5c45d-cbe1-495b-bc46-afc4791973f9',NULL,'2026-08-04 19:42:47','2026-08-04 19:42:47'),(146,NULL,'guest_c52b8f9d-4175-4d5a-882f-c37286fa9e92',NULL,'2026-08-05 20:36:53','2026-08-05 20:36:53'),(147,20,NULL,NULL,'2026-08-05 21:15:34','2026-08-05 21:15:34'),(148,21,NULL,NULL,'2026-08-05 21:18:52','2026-08-05 21:18:52'),(149,NULL,'guest_3b839e66-3ee2-479d-a809-7d513d9e91e6',NULL,'2026-08-06 01:31:44','2026-08-06 01:31:44'),(150,NULL,'guest_de38516c-cff2-4d8f-9b74-3c880460f38d',NULL,'2026-08-06 08:52:28','2026-08-06 08:52:28'),(151,NULL,'guest_fb4bc828-b72c-4aeb-b8d6-005f61579011',NULL,'2026-08-06 14:47:32','2026-08-06 14:47:32'),(152,NULL,'guest_ab996556-4ec3-428c-b1c7-97aa7e6b0bfe',NULL,'2026-08-06 19:14:11','2026-08-06 19:14:11'),(153,22,NULL,NULL,'2026-08-06 19:14:41','2026-08-06 19:14:41'),(154,NULL,'guest_c3e5026f-1590-446b-9da4-fbe016703507',NULL,'2026-08-06 19:15:00','2026-08-06 19:15:00'),(155,NULL,'guest_1f033b06-a4ef-4924-9a8c-17a1f692263f',NULL,'2026-08-07 00:40:10','2026-08-07 00:40:10'),(156,NULL,'guest_b12960df-866a-4aba-b5b0-ba9cf692aa56',NULL,'2026-08-07 09:41:31','2026-08-07 09:41:31'),(157,NULL,'guest_7fd24e28-a1d3-4a07-8149-cb89fdcc9ff9',NULL,'2026-08-07 09:41:31','2026-08-07 09:41:31'),(158,NULL,'guest_957190d5-5fe1-4636-831f-95495dcbea3f',NULL,'2026-08-07 09:45:58','2026-08-07 09:45:58'),(159,NULL,'guest_3e90f431-63da-4ca4-94f4-de1dacd31d8e',NULL,'2026-08-07 16:17:20','2026-08-07 16:17:20'),(160,NULL,'guest_993a7c7b-42b8-45b8-a9ae-dbe452164d59',NULL,'2026-08-07 17:45:11','2026-08-07 17:45:11'),(161,NULL,'guest_11ac7d4a-1420-409c-9df3-34cbfb4b46c0',NULL,'2026-08-07 19:26:44','2026-08-07 19:26:44'),(162,NULL,'guest_30ca77fe-2729-4d43-a9d4-c5fa7fd470bd',NULL,'2026-08-07 20:13:14','2026-08-07 20:13:14'),(163,NULL,'guest_9494347d-9801-4df3-a912-d140ba7e01e2',NULL,'2026-08-07 20:31:55','2026-08-07 20:31:55'),(164,NULL,'guest_0a6f7b49-c69c-44ff-84cd-943066c190fe',NULL,'2026-08-07 20:32:00','2026-08-07 20:32:00'),(165,NULL,'guest_480b93e6-de9e-40ed-bf3d-8c9a97abf495',NULL,'2026-08-07 20:44:19','2026-08-07 20:44:19'),(166,NULL,'guest_a7edc7b3-c876-47cc-b5d4-e9b8f63cf9c0',NULL,'2026-08-07 20:51:08','2026-08-07 20:51:08'),(167,NULL,'guest_20642292-6ce3-48c6-a6d1-d433f2902772',NULL,'2026-08-07 20:53:23','2026-08-07 20:53:23'),(168,23,NULL,NULL,'2026-08-07 21:06:21','2026-08-07 21:06:21'),(171,24,NULL,NULL,'2026-08-07 21:47:13','2026-08-07 21:47:13'),(175,NULL,'guest_c4ec364f-5329-4dc0-a3d6-88c783ab444b',NULL,'2026-08-07 21:50:46','2026-08-07 21:50:46'),(176,28,NULL,NULL,'2026-08-07 22:48:52','2026-08-07 22:48:52'),(177,NULL,'guest_52aaa911-b473-4720-a7dd-b22b124acfe9',NULL,'2026-08-07 22:55:06','2026-08-07 22:55:06'),(178,10,NULL,NULL,'2026-08-07 22:55:16','2026-08-07 22:55:16'),(179,NULL,'guest_7fb9c7bf-4b13-4fb1-9d46-1075d5a18ba5',NULL,'2026-08-08 10:18:55','2026-08-08 10:18:55'),(180,NULL,'guest_22ce9f95-b245-449e-b2ba-e2f8c5bc5af7',NULL,'2026-08-08 10:18:55','2026-08-08 10:18:55'),(181,NULL,'guest_2018904a-fb46-4d71-928c-664676ed939d',NULL,'2026-08-08 10:19:02','2026-08-08 10:19:02'),(182,NULL,'guest_7342a262-daa0-4924-9de8-5c7554a4c171',NULL,'2026-08-08 10:34:02','2026-08-08 10:34:02'),(183,NULL,'guest_1cb49dcb-5695-4fba-a19a-33d859d4a3f2',NULL,'2026-08-08 11:36:23','2026-08-08 11:36:23'),(184,NULL,'guest_19eeb1fa-72e8-494d-b439-7b98f6b648b2',NULL,'2026-08-08 14:11:30','2026-08-08 14:11:30'),(186,NULL,'guest_484490ff-a038-4585-9741-5c9b2156d454',NULL,'2026-08-08 21:39:35','2026-08-08 21:39:35'),(187,NULL,'guest_98042dce-d180-4408-97d8-c353845cf0d4',NULL,'2026-08-08 22:17:54','2026-08-08 22:17:54'),(188,NULL,'guest_9142818d-2f03-42af-b1d8-d3d555a53eb9',NULL,'2026-08-09 00:52:03','2026-08-09 00:52:03'),(189,NULL,'guest_ef8ccca0-8e60-4841-8660-ffc3f8c64d37',NULL,'2026-08-09 00:52:21','2026-08-09 00:52:21'),(190,NULL,'guest_8b84b993-9bd7-4875-b174-4d3c9f02ccd3',NULL,'2026-08-09 08:02:11','2026-08-09 08:02:11'),(191,9,NULL,NULL,'2026-08-09 13:34:36','2026-08-09 13:34:36'),(192,NULL,'guest_4f02788a-7a52-40f1-b35e-9ea1dbbceee2',NULL,'2026-08-10 02:03:43','2026-08-10 02:03:43'),(193,NULL,'guest_a89a1f8e-fedd-4687-8771-209074130056',NULL,'2026-08-10 04:44:05','2026-08-10 04:44:05'),(194,NULL,'guest_07c6e45a-70d7-40c7-a083-542bbb9db582',NULL,'2026-08-10 12:39:40','2026-08-10 12:39:40'),(195,NULL,'guest_4eb2906f-1107-4a19-ab09-43a3f254b856',NULL,'2026-08-10 22:12:13','2026-08-10 22:12:13'),(196,NULL,'guest_2108fa28-1648-4259-aca1-97be63dc582f',NULL,'2026-08-11 10:36:04','2026-08-11 10:36:04'),(197,NULL,'guest_e537731a-284e-4239-8f09-8f1d1b127e63',NULL,'2026-08-11 11:34:04','2026-08-11 11:34:04'),(198,NULL,'guest_92b55a25-3b50-4c8b-8a56-3e56c19c63c0',NULL,'2026-08-11 11:45:24','2026-08-11 11:45:24'),(199,NULL,'guest_b4790efc-1304-44d9-9015-5db2ebaf8045',NULL,'2026-08-11 11:45:49','2026-08-11 11:45:49'),(200,NULL,'guest_9a0df71c-8cec-48d1-8420-90ae4c7e2ce8',NULL,'2026-08-11 11:45:50','2026-08-11 11:45:50'),(201,NULL,'guest_3abc3ab1-3fe2-4e65-a43b-b0e96ec463b4',NULL,'2026-08-11 11:47:33','2026-08-11 11:47:33'),(202,NULL,'guest_faf57944-d529-42c6-89f7-59b5c93b19a2',NULL,'2026-08-11 11:52:47','2026-08-11 11:52:47'),(203,NULL,'guest_13b58f82-ff5d-4c61-89bc-878afa6640c8',NULL,'2026-08-11 11:52:56','2026-08-11 11:52:56'),(204,NULL,'guest_821119e5-562f-4b78-8e4c-b7bc3c2eb714',NULL,'2026-08-11 12:02:12','2026-08-11 12:02:12'),(205,NULL,'guest_c9b47712-bc0e-4e37-bdbd-11f2a49134c1',NULL,'2026-08-11 21:31:17','2026-08-11 21:31:17'),(206,NULL,'guest_3dc2ac7b-49b3-4544-a137-93b14180dceb',NULL,'2026-08-12 08:05:15','2026-08-12 08:05:15'),(207,NULL,'guest_5d73aef1-f558-47c6-bedf-372f2dd9d332',NULL,'2026-08-12 14:10:38','2026-08-12 14:10:38'),(208,NULL,'guest_c4185064-1e20-46e9-9895-d904bc35b052',NULL,'2026-08-12 15:18:35','2026-08-12 15:18:35'),(209,NULL,'guest_29177191-5e86-4f49-b572-4dcfe264f60f',NULL,'2026-08-12 15:18:36','2026-08-12 15:18:36'),(210,NULL,'guest_d696a546-18ae-4f6a-9c0b-7c026ad5b33e',NULL,'2026-08-12 15:18:39','2026-08-12 15:18:39'),(211,NULL,'guest_32887482-240d-4cd2-bd34-c002f5d15871',NULL,'2026-08-12 15:19:00','2026-08-12 15:19:00'),(212,NULL,'guest_b9d8298e-6519-4ddc-bbc6-af69af0a2e3e',NULL,'2026-08-12 18:28:44','2026-08-12 18:28:44'),(213,NULL,'guest_5cf84641-c044-44a1-823f-0bb26b3b34e8',NULL,'2026-08-12 19:30:42','2026-08-12 19:30:42'),(215,NULL,'guest_b158afc4-a2ef-4e18-8679-ded058d3bc23',NULL,'2026-08-12 21:00:20','2026-08-12 21:00:20'),(216,NULL,'guest_f831aba1-9ef0-4689-b7ce-0dda7850059b',NULL,'2026-08-12 21:00:20','2026-08-12 21:00:20'),(217,NULL,'guest_3d4bd4f7-6277-4225-b939-0b0cfb71bc2b',NULL,'2026-08-12 21:00:20','2026-08-12 21:00:20'),(218,NULL,'guest_b7ba711f-f121-4de0-8d2a-a82f9921536b',NULL,'2026-08-12 21:00:41','2026-08-12 21:00:41'),(219,NULL,'guest_174166d6-8799-4a1f-9510-be17689547e9',NULL,'2026-08-12 21:00:44','2026-08-12 21:00:44'),(220,29,NULL,NULL,'2026-08-12 21:54:37','2026-08-12 21:54:37'),(221,NULL,'guest_270bc1f9-b201-49e2-8398-82599502c13b',NULL,'2026-08-13 09:26:32','2026-08-13 09:26:32'),(222,NULL,'guest_f5d21f64-a14e-49c9-b46d-c8456c529c0c',NULL,'2026-08-13 09:26:56','2026-08-13 09:26:56'),(223,NULL,'guest_3ffe73d4-6157-4de6-8aee-3b73aac1aaa1',NULL,'2026-08-13 09:31:42','2026-08-13 09:31:42'),(224,NULL,'guest_ea144c08-c2b7-4285-82b3-c57beadc615d',NULL,'2026-08-13 09:58:05','2026-08-13 09:58:05'),(225,NULL,'guest_b909c481-2e84-4e89-b523-af9174c57c22',NULL,'2026-08-13 10:35:04','2026-08-13 10:35:04'),(226,NULL,'guest_829f04a4-9158-4698-922a-5a93ec8508bc',NULL,'2026-08-13 14:03:39','2026-08-13 14:03:39'),(227,NULL,'guest_433bff7e-9d27-4900-8a97-00c01a71ff92',NULL,'2026-08-13 15:10:19','2026-08-13 15:10:19'),(228,NULL,'guest_2d833b08-dfc1-4a55-a383-44536a70b5a4',NULL,'2026-08-13 15:10:34','2026-08-13 15:10:34'),(229,NULL,'guest_5e7c251b-e433-47cd-ba06-d9019fe2ec93',NULL,'2026-08-13 17:06:45','2026-08-13 17:06:45'),(230,NULL,'guest_95d80fe9-a03f-45d2-a4de-b83489581639',NULL,'2026-08-13 18:56:55','2026-08-13 18:56:55'),(231,NULL,'guest_256d8e37-cf3d-4647-9889-7da940057c6e',NULL,'2026-08-14 03:42:14','2026-08-14 03:42:14'),(232,NULL,'guest_49bfce65-f8bb-4adb-8f6c-ce8f39974e9c',NULL,'2026-08-14 05:11:24','2026-08-14 05:11:24'),(233,NULL,'guest_088f125a-4bf0-4c67-96c6-662841d7cca1',NULL,'2026-08-14 08:00:34','2026-08-14 08:00:34'),(234,NULL,'guest_38a5f286-5b9e-42ac-ad23-4b528b6c7c85',NULL,'2026-08-14 08:00:34','2026-08-14 08:00:34'),(235,NULL,'guest_ec789cde-d89e-4c54-814b-53852b9e81fa',NULL,'2026-08-14 08:00:50','2026-08-14 08:00:50'),(236,NULL,'guest_cc4faf87-0503-4a3b-9964-e3c2582ab79c',NULL,'2026-08-14 08:56:54','2026-08-14 08:56:54'),(238,NULL,'guest_8adfd903-50d3-4e7c-9e9c-80e79bbef2cc',NULL,'2026-08-14 09:30:29','2026-08-14 09:30:29'),(239,30,NULL,NULL,'2026-08-14 14:23:32','2026-08-14 14:23:32'),(240,NULL,'guest_fe72ebc5-52b7-428d-bcc2-a039725255f9',NULL,'2026-08-14 18:43:20','2026-08-14 18:43:20'),(241,7,NULL,NULL,'2026-08-14 18:50:32','2026-08-14 18:50:32'),(242,NULL,'guest_a2df3b2d-ad75-441f-a6dc-c5fb563783b2',NULL,'2026-08-14 19:43:19','2026-08-14 19:43:19'),(243,NULL,'guest_cf370ce3-9d6b-441b-ba31-da4c394b2ec6',NULL,'2026-08-14 19:48:12','2026-08-14 19:48:12'),(244,NULL,'guest_bfa6f174-3835-4702-b45b-b7663178aece',NULL,'2026-08-14 19:48:57','2026-08-14 19:48:57'),(245,NULL,'guest_be05b5c8-fbe6-4cc5-855d-90ff0398dce5',NULL,'2026-08-14 19:48:57','2026-08-14 19:48:57'),(246,NULL,'guest_1f9d624d-6c48-4287-9c80-8cc54d95392c',NULL,'2026-08-14 19:48:57','2026-08-14 19:48:57'),(247,NULL,'guest_dee911fc-bda9-48d6-81b5-274928a61c6f',NULL,'2026-08-14 19:48:58','2026-08-14 19:48:58'),(248,NULL,'guest_be8818c9-59fd-4ea0-b6d9-f1e0700c5bc5',NULL,'2026-08-14 20:42:51','2026-08-14 20:42:51'),(249,NULL,'guest_4d62f758-06a6-43e9-bea3-22a81cf6bd3f',NULL,'2026-08-14 20:47:33','2026-08-14 20:47:33'),(250,NULL,'guest_12ec371c-34a7-4769-b805-31e82becaa2f',NULL,'2026-08-15 08:01:05','2026-08-15 08:01:05'),(251,NULL,'guest_013cf259-cf69-4cc9-8b49-b8131788d357',NULL,'2026-08-15 08:01:20','2026-08-15 08:01:20'),(252,NULL,'guest_6ac06908-b9c0-4c5c-bde5-045b9f1fcd5f',NULL,'2026-08-15 08:01:21','2026-08-15 08:01:21'),(253,NULL,'guest_cf821c71-1a08-4043-a0ad-18c18318e9fd',NULL,'2026-08-15 10:33:09','2026-08-15 10:33:09'),(254,NULL,'guest_19d36110-9d3c-4249-a51c-cc3efd25975d',NULL,'2026-08-15 11:52:02','2026-08-15 11:52:02'),(255,NULL,'guest_88d9db5d-3ffd-42af-9954-baa0ed6d3054',NULL,'2026-08-15 14:02:38','2026-08-15 14:02:38'),(256,NULL,'guest_5ec68d9f-4701-4dd0-995e-7cf900b590a9',NULL,'2026-08-15 17:32:50','2026-08-15 17:32:50'),(257,NULL,'guest_66125a6f-6689-4df7-8352-d88ed9202ed8',NULL,'2026-08-15 17:43:45','2026-08-15 17:43:45'),(258,NULL,'guest_36a6c94d-865b-4436-af7a-d09890e1cdb9',NULL,'2026-08-15 20:07:12','2026-08-15 20:07:12'),(259,NULL,'guest_b8573762-45e2-40ad-b777-f9f56f21cbda',NULL,'2026-08-15 21:04:55','2026-08-15 21:04:55'),(260,NULL,'guest_504675c9-0c22-44f4-9f09-8611ce62574a',NULL,'2026-08-15 23:41:57','2026-08-15 23:41:57'),(261,NULL,'guest_af2a7170-7606-4a8e-889e-5164aaa2abb3',NULL,'2026-08-16 00:11:12','2026-08-16 00:11:12'),(262,NULL,'guest_03b5eae2-45e4-49ac-be74-80ec10717692',NULL,'2026-08-16 00:11:12','2026-08-16 00:11:12'),(263,NULL,'guest_aa813ffc-d036-4912-8339-6d4df2a9c9e9',NULL,'2026-08-16 01:06:42','2026-08-16 01:06:42'),(265,NULL,'guest_b30a8696-6fb2-4e31-9944-c95e5ff2bf49',NULL,'2026-08-16 01:28:27','2026-08-16 01:28:27'),(266,NULL,'guest_d943f5a6-5b1e-4bc9-acae-de97d26418c8',NULL,'2026-08-16 06:14:26','2026-08-16 06:14:26'),(267,NULL,'guest_734e45f9-ab9e-4d67-965e-6067f8cd3428',NULL,'2026-08-16 08:30:20','2026-08-16 08:30:20'),(268,NULL,'guest_eca67977-ac70-47f6-8f22-a3b9f81fed43',NULL,'2026-08-16 10:28:23','2026-08-16 10:28:23'),(269,NULL,'guest_598297b4-daf9-4fca-82f6-35aeb5b9a2ac',NULL,'2026-08-16 14:25:44','2026-08-16 14:25:44'),(270,NULL,'guest_0f55f82f-51c4-4b62-b105-0b424eb6da16',NULL,'2026-08-16 17:22:36','2026-08-16 17:22:36'),(271,NULL,'guest_3992ed64-ec1c-40b5-9171-e05d17e106c3',NULL,'2026-08-16 18:32:03','2026-08-16 18:32:03'),(272,NULL,'guest_fa4e0f1b-46de-44b3-8343-e36b21ccea97',NULL,'2026-08-16 22:29:10','2026-08-16 22:29:10'),(273,NULL,'guest_096d46ff-09cc-4395-8c67-8c675942340d',NULL,'2026-08-17 00:33:31','2026-08-17 00:33:31'),(274,NULL,'guest_5b16549b-436f-4042-9159-d5f457dc5209',NULL,'2026-08-17 05:35:39','2026-08-17 05:35:39'),(275,NULL,'guest_d384b7f5-a7cc-4e8a-b11c-f9967d373557',NULL,'2026-08-17 08:00:19','2026-08-17 08:00:19'),(276,NULL,'guest_eadb6479-bb0b-4b63-8ff7-72d9d561329e',NULL,'2026-08-17 08:00:19','2026-08-17 08:00:19'),(277,NULL,'guest_b1a9c2f0-97f4-482d-bf62-41840d60a4a4',NULL,'2026-08-17 08:00:34','2026-08-17 08:00:34'),(278,NULL,'guest_e41d6eac-09db-47c0-ac73-fbd016a65898',NULL,'2026-08-17 08:00:56','2026-08-17 08:00:56'),(279,NULL,'guest_a2370cf8-d081-4644-8ae5-164645f1f525',NULL,'2026-08-17 08:01:42','2026-08-17 08:01:42'),(280,NULL,'guest_e3dcf4f7-b2b0-497b-b4fb-51b5059bdd46',NULL,'2026-08-17 08:01:42','2026-08-17 08:01:42'),(281,NULL,'guest_e7c686c8-cbed-4681-9a1a-b506541e7c46',NULL,'2026-08-17 08:21:49','2026-08-17 08:21:49'),(282,NULL,'guest_af762168-176f-4799-91de-3a299c5c946f',NULL,'2026-08-17 19:52:25','2026-08-17 19:52:25'),(283,NULL,'guest_9a041a34-cb1c-4e1f-98f1-56031c8a3f6e',NULL,'2026-08-18 04:38:15','2026-08-18 04:38:15'),(284,NULL,'guest_3727e54e-7ced-4d36-b8e3-72bd3b8c0a97',NULL,'2026-08-18 08:01:58','2026-08-18 08:01:58'),(285,NULL,'guest_d4953467-41d4-4aec-b10a-f68bc17ebf89',NULL,'2026-08-18 08:19:21','2026-08-18 08:19:21'),(286,NULL,'guest_c3031912-a348-46ed-b5cc-9531e2e0da66',NULL,'2026-08-18 23:26:12','2026-08-18 23:26:12'),(287,NULL,'guest_8dfc423a-fa05-45f2-aec9-5d6136ab85ed',NULL,'2026-08-19 08:27:18','2026-08-19 08:27:18'),(288,NULL,'guest_e8275847-1eb8-49df-bb35-bd7a64e1a850',NULL,'2026-08-19 08:27:28','2026-08-19 08:27:28'),(289,NULL,'guest_8eaa0379-0fa6-4607-83d1-ca44f7505b93',NULL,'2026-08-19 15:14:07','2026-08-19 15:14:07'),(290,NULL,'guest_017cc241-b3d9-4fc0-9127-0208ddaa3f66',NULL,'2026-08-20 11:09:55','2026-08-20 11:09:55'),(291,NULL,'guest_11bfec79-c4b3-489f-b76d-d6c4b7004043',NULL,'2026-08-20 11:30:26','2026-08-20 11:30:26'),(292,NULL,'guest_b92511c8-9c10-429d-943f-29a7a7412690',NULL,'2026-08-20 11:30:33','2026-08-20 11:30:33'),(293,NULL,'guest_faaee895-6bea-4f12-ad68-d322a47cfe65',NULL,'2026-08-20 12:23:31','2026-08-20 12:23:31'),(294,NULL,'guest_2f1a9e03-d6ae-4e0e-8107-f9fa826450b4',NULL,'2026-08-21 11:37:03','2026-08-21 11:37:03'),(295,NULL,'guest_fd42cb84-c295-4311-adc8-2d3d75058110',NULL,'2026-08-21 11:37:35','2026-08-21 11:37:35'),(296,NULL,'guest_0d9760cc-6f86-4137-9a52-ac3573ba6655',NULL,'2026-08-21 20:57:24','2026-08-21 20:57:24'),(297,NULL,'guest_ba0891c2-7183-4ce7-9246-5b8903055228',NULL,'2026-08-22 00:49:25','2026-08-22 00:49:25'),(298,NULL,'guest_0a5e8f63-e4d4-4bcb-8747-9efa161fde2d',NULL,'2026-08-22 09:58:00','2026-08-22 09:58:00'),(299,NULL,'guest_b67c9bfd-6031-4a92-a73b-6f176162068e',NULL,'2026-08-22 11:25:59','2026-08-22 11:25:59'),(300,NULL,'guest_cdd5419f-973e-48d3-ac67-329fa1aeb10d',NULL,'2026-08-22 11:26:12','2026-08-22 11:26:12'),(301,NULL,'guest_7c2aff40-b5f2-4cf4-a2e0-2235554ca1c8',NULL,'2026-08-22 13:00:44','2026-08-22 13:00:44'),(302,NULL,'guest_bc090646-b626-4c27-a47a-18e9e6e08d48',NULL,'2026-08-22 13:53:50','2026-08-22 13:53:50'),(303,NULL,'guest_a1915509-bfd6-49c7-bca4-685e5e44f16e',NULL,'2026-08-22 14:12:56','2026-08-22 14:12:56'),(304,NULL,'guest_0ecbbdaf-98eb-4bb1-b35e-00377a741787',NULL,'2026-08-22 14:26:54','2026-08-22 14:26:54'),(305,NULL,'guest_cd13e042-e949-41dc-836e-deb1e0a34a53',NULL,'2026-08-22 16:28:56','2026-08-22 16:28:56'),(306,NULL,'guest_77a43d48-bb50-438c-9e03-ed82c5d800a5',NULL,'2026-08-22 18:47:26','2026-08-22 18:47:26'),(307,NULL,'guest_11342170-47d5-41fd-86c0-5a89e59ccab7',NULL,'2026-08-22 18:47:36','2026-08-22 18:47:36'),(308,NULL,'guest_78a02945-6b76-41f0-92eb-69c344af2f2d',NULL,'2026-08-22 19:11:26','2026-08-22 19:11:26'),(309,NULL,'guest_44966bf0-8e36-424c-a481-f7d33d949244',NULL,'2026-08-22 21:56:50','2026-08-22 21:56:50'),(310,NULL,'guest_6221aed8-eb84-4706-be2e-b682bfdae948',NULL,'2026-08-23 06:19:00','2026-08-23 06:19:00'),(311,NULL,'guest_aa8f3d3c-6dc7-4e94-a9e2-2d92e085512c',NULL,'2026-08-23 07:53:33','2026-08-23 07:53:33'),(312,NULL,'guest_10776372-0a3f-4c90-8c61-775eb4823123',NULL,'2026-08-23 22:54:06','2026-08-23 22:54:06'),(313,NULL,'guest_59a831c4-d5c6-4f6b-b917-0b9d12cd22ee',NULL,'2026-08-24 05:49:50','2026-08-24 05:49:50'),(314,NULL,'guest_cf5d99f3-ab1f-4ec1-b043-e3e78e541cf9',NULL,'2026-08-24 11:47:25','2026-08-24 11:47:25'),(315,NULL,'guest_ca5b4a9a-2efe-4ad0-a6d3-bebcf70f2047',NULL,'2026-08-24 14:11:45','2026-08-24 14:11:45'),(316,NULL,'guest_f194748b-38e4-4adb-b5ff-d4fe3d00e86b',NULL,'2026-08-24 16:04:38','2026-08-24 16:04:38'),(317,NULL,'guest_caf9c4f9-cb5a-4924-a302-c0490763e8a9',NULL,'2026-08-24 16:15:16','2026-08-24 16:15:16'),(318,NULL,'guest_953cd516-2d66-4236-8d38-6ff735f2d521',NULL,'2026-08-24 16:25:58','2026-08-24 16:25:58'),(320,NULL,'guest_a4241bdc-0877-4811-85d7-c91775863668',NULL,'2026-08-24 19:07:12','2026-08-24 19:07:12'),(321,NULL,'guest_6d5e6f84-fb5c-4881-b731-f281445ede65',NULL,'2026-08-24 21:36:45','2026-08-24 21:36:45'),(322,NULL,'guest_a1f06a90-e3e0-417e-9ac0-51594d889e5e',NULL,'2026-08-24 21:43:34','2026-08-24 21:43:34'),(323,NULL,'guest_07d77390-3016-44f9-991f-6e8c68569ab5',NULL,'2026-08-24 23:12:23','2026-08-24 23:12:23'),(324,NULL,'guest_9a187d83-6eb8-4015-969f-26c1d352a570',NULL,'2026-08-25 05:04:47','2026-08-25 05:04:47'),(325,NULL,'guest_76721752-594e-4f71-b6ad-e4923ae4d79c',NULL,'2026-08-25 05:09:56','2026-08-25 05:09:56'),(326,NULL,'guest_016de130-b3ca-4ca1-b3b2-8240afafbb7b',NULL,'2026-08-25 10:15:38','2026-08-25 10:15:38'),(327,NULL,'guest_c564d946-46ab-4575-8e13-0325d5ba9677',NULL,'2026-08-25 11:03:43','2026-08-25 11:03:43'),(328,NULL,'guest_e1e0d794-2324-4994-beb8-448fbc1368ee',NULL,'2026-08-25 11:06:29','2026-08-25 11:06:29'),(329,NULL,'guest_9dd770dd-5f04-44d4-9fa2-fa4f42208a14',NULL,'2026-08-25 11:06:36','2026-08-25 11:06:36'),(330,NULL,'guest_165b61ee-a106-4809-b80b-8c500a2e251d',NULL,'2026-08-25 11:07:37','2026-08-25 11:07:37'),(331,NULL,'guest_24a0eec3-e9ef-46cf-a6c8-14d962bb7b8d',NULL,'2026-08-25 11:22:12','2026-08-25 11:22:12'),(332,NULL,'guest_14249892-5a80-4d10-8d57-90e8b678de0e',NULL,'2026-08-25 12:26:14','2026-08-25 12:26:14'),(333,NULL,'guest_52f7f41b-c4c6-45dd-a3fd-98315d9bed42',NULL,'2026-08-25 13:58:50','2026-08-25 13:58:50'),(334,NULL,'guest_6dd543b6-dc19-4044-ac14-0a6d134f7261',NULL,'2026-08-25 18:30:48','2026-08-25 18:30:48'),(335,NULL,'guest_7fecb804-300f-4a46-a246-3f17f5e90a47',NULL,'2026-08-25 19:23:32','2026-08-25 19:23:32'),(336,NULL,'guest_f77b5e76-ceb1-4e85-93f3-9d8da9ad488e',NULL,'2026-08-25 22:26:49','2026-08-25 22:26:49'),(337,NULL,'guest_544be459-9564-44e3-b5bc-36a2986a8c7f',NULL,'2026-08-26 04:56:56','2026-08-26 04:56:56'),(338,NULL,'guest_0a6f9a3a-a4f2-4206-9b8b-1efef9d700f7',NULL,'2026-08-26 04:57:28','2026-08-26 04:57:28'),(339,NULL,'guest_b98475f2-9d16-43c6-8cf6-4a6f3f27703a',NULL,'2026-08-26 07:37:05','2026-08-26 07:37:05'),(340,NULL,'guest_13add946-a650-4841-9bbf-904af37a9b3f',NULL,'2026-08-26 09:56:59','2026-08-26 09:56:59'),(341,NULL,'guest_43f23ebf-eeb5-4f29-9499-703e4a084dd8',NULL,'2026-08-26 16:32:16','2026-08-26 16:32:16'),(342,NULL,'guest_4ed391f8-6baa-4af5-8bf9-859c0e3aea7b',NULL,'2026-08-26 20:56:56','2026-08-26 20:56:56'),(343,NULL,'guest_5f4a580d-2fa9-4233-a625-cf70bf560e34',NULL,'2026-08-27 06:40:51','2026-08-27 06:40:51'),(344,NULL,'guest_d99e5b58-018b-43cb-92b8-f023131f2015',NULL,'2026-08-27 17:33:40','2026-08-27 17:33:40'),(345,NULL,'guest_6e61b2a8-849a-4731-93fc-817e24d73f7d',NULL,'2026-08-28 01:43:39','2026-08-28 01:43:39'),(346,NULL,'guest_11c5fdf2-0814-4a90-af82-48c0f3013526',NULL,'2026-08-28 06:26:11','2026-08-28 06:26:11'),(347,NULL,'guest_99916965-c62c-461d-a48d-115603536ca2',NULL,'2026-08-28 21:22:48','2026-08-28 21:22:48'),(348,NULL,'guest_1ef25bfb-452b-410e-8db1-77ebe9418bc9',NULL,'2026-08-28 21:39:52','2026-08-28 21:39:52'),(349,NULL,'guest_8001be98-37a1-458b-96c3-fda8a9aac972',NULL,'2026-08-28 22:54:29','2026-08-28 22:54:29'),(350,NULL,'guest_4c1a0290-9b5c-498b-af06-6f2ffdda06a5',NULL,'2026-08-29 00:18:23','2026-08-29 00:18:23'),(351,NULL,'guest_7933c220-ca52-4cd2-acee-2907232e66a7',NULL,'2026-08-29 00:28:00','2026-08-29 00:28:00'),(352,NULL,'guest_9096b2f3-6b2a-4200-bbe1-dddfe2cbb1f7',NULL,'2026-08-29 08:27:43','2026-08-29 08:27:43'),(353,NULL,'guest_451c3c1f-343c-4db6-a60e-802c4f4d0277',NULL,'2026-08-29 18:34:30','2026-08-29 18:34:30'),(354,NULL,'guest_0523d465-9975-40cc-bf7c-e605df260a7e',NULL,'2026-08-30 04:14:34','2026-08-30 04:14:34'),(355,NULL,'guest_3e37f3f8-f651-499d-8944-363c113ffa49',NULL,'2026-08-30 09:43:05','2026-08-30 09:43:05');
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_submissions`
--

DROP TABLE IF EXISTS `contact_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_submissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT NULL,
  `expiry_date` timestamp NULL DEFAULT NULL,
  `usage_limit` int DEFAULT NULL,
  `used_count` int NOT NULL DEFAULT '0',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `total_orders` int NOT NULL DEFAULT '0',
  `total_spent` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_refunded` decimal(14,2) NOT NULL DEFAULT '0.00',
  `net_revenue` decimal(14,2) NOT NULL DEFAULT '0.00',
  `average_order_value` decimal(14,2) NOT NULL DEFAULT '0.00',
  `clv` decimal(14,2) NOT NULL DEFAULT '0.00',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `report_date` timestamp NOT NULL,
  `total_orders` int NOT NULL DEFAULT '0',
  `total_revenue` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_profit` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_shipping` decimal(14,2) NOT NULL DEFAULT '0.00',
  `new_customers` int NOT NULL DEFAULT '0',
  `conversion_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
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
-- Table structure for table `digital_file_urls`
--

DROP TABLE IF EXISTS `digital_file_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `digital_file_urls` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `digital_file_id` bigint unsigned NOT NULL,
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `digital_file_urls_digital_file_id_foreign` (`digital_file_id`),
  CONSTRAINT `digital_file_urls_digital_file_id_foreign` FOREIGN KEY (`digital_file_id`) REFERENCES `digital_files` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_file_urls`
--

LOCK TABLES `digital_file_urls` WRITE;
/*!40000 ALTER TABLE `digital_file_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `digital_file_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_files`
--

DROP TABLE IF EXISTS `digital_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `digital_files` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '1.0',
  `max_downloads` int DEFAULT '5',
  `link_expiry_days` int DEFAULT '7',
  `license_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `digital_files_product_id_foreign` (`product_id`),
  CONSTRAINT `digital_files_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_files`
--

LOCK TABLES `digital_files` WRITE;
/*!40000 ALTER TABLE `digital_files` DISABLE KEYS */;
INSERT INTO `digital_files` VALUES (20,78,'products/78/design/FDT0008.pdf','1.0',5,7,'commercial',NULL),(21,79,'products/79/design/FDT0009.pdf','1.0',5,7,'commercial',NULL),(22,80,'products/80/design/FDT0010.pdf','1.0',5,7,'commercial',NULL),(23,81,'products/81/design/FDT0011.pdf','1.0',5,7,'commercial',NULL),(24,82,'products/82/design/FDT0012.pdf','1.0',5,7,'commercial',NULL);
/*!40000 ALTER TABLE `digital_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `downloads`
--

DROP TABLE IF EXISTS `downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `downloads` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint unsigned NOT NULL,
  `download_count` int NOT NULL DEFAULT '0',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `payment_gateway_fee` decimal(12,2) NOT NULL DEFAULT '0.00',
  `gross_revenue` decimal(12,2) NOT NULL DEFAULT '0.00',
  `net_profit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `profit_margin` decimal(5,2) NOT NULL DEFAULT '0.00',
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
-- Table structure for table `hero_images`
--

DROP TABLE IF EXISTS `hero_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hero_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alt_text` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `media_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'image',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hero_images`
--

LOCK TABLES `hero_images` WRITE;
/*!40000 ALTER TABLE `hero_images` DISABLE KEYS */;
INSERT INTO `hero_images` VALUES (2,'hero/RfZBUXiqQUCLqbc1UHDqD9sxphLZK6M3ymzjUi0s.webp',NULL,NULL,'image',0,'2026-07-21 06:27:04','2026-07-21 06:27:04');
/*!40000 ALTER TABLE `hero_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industor_designers`
--

DROP TABLE IF EXISTS `industor_designers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `industor_designers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `industor_id` bigint unsigned NOT NULL,
  `designer_id` bigint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stock_quantity` int NOT NULL DEFAULT '0',
  `low_stock_alert` int NOT NULL DEFAULT '5',
  `warehouse_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_product_id_unique` (`product_id`),
  UNIQUE KEY `inventory_sku_unique` (`sku`),
  CONSTRAINT `inventory_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (3,11,'FDT0001',100,10,NULL),(6,14,'FDM0001',50,5,NULL),(7,13,'FDT0002',50,5,NULL),(8,15,'FDS0001',25,5,NULL),(12,16,'FDC0001',0,5,NULL),(14,31,'FDT003',0,5,NULL),(15,32,'FDP0001',0,5,NULL),(16,33,'FDT0005',0,5,NULL),(17,35,'FDT0006',0,5,NULL),(18,37,'FDT0007',0,5,NULL),(26,63,'FDT0008',0,5,NULL),(27,64,'FDT0009',0,5,NULL),(28,65,'FDT0010',0,5,NULL),(30,66,'FDT0011',0,5,NULL),(31,67,'FDT0012',0,5,NULL),(32,68,'FDT0013',0,5,NULL),(33,69,'FDT0014',0,5,NULL),(34,70,'FDT0015',0,5,NULL),(35,71,'FDT0016',0,5,NULL),(36,72,'FDT0017',0,5,NULL),(37,73,'FDT0019',0,5,NULL),(38,74,'FDT0020',0,5,NULL),(39,75,'FDT0021',0,5,NULL),(40,76,'FDT0022',0,5,NULL);
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemon_squeezy_customers`
--

DROP TABLE IF EXISTS `lemon_squeezy_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lemon_squeezy_customers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `billable_id` bigint unsigned NOT NULL,
  `billable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lemon_squeezy_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trial_ends_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lemon_squeezy_customers_billable_id_billable_type_unique` (`billable_id`,`billable_type`),
  UNIQUE KEY `lemon_squeezy_customers_lemon_squeezy_id_unique` (`lemon_squeezy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemon_squeezy_customers`
--

LOCK TABLES `lemon_squeezy_customers` WRITE;
/*!40000 ALTER TABLE `lemon_squeezy_customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemon_squeezy_customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemon_squeezy_license_key_instances`
--

DROP TABLE IF EXISTS `lemon_squeezy_license_key_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lemon_squeezy_license_key_instances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `identifier` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_key_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lemon_squeezy_license_key_instances_identifier_unique` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemon_squeezy_license_key_instances`
--

LOCK TABLES `lemon_squeezy_license_key_instances` WRITE;
/*!40000 ALTER TABLE `lemon_squeezy_license_key_instances` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemon_squeezy_license_key_instances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemon_squeezy_license_keys`
--

DROP TABLE IF EXISTS `lemon_squeezy_license_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lemon_squeezy_license_keys` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lemon_squeezy_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `disabled` tinyint(1) NOT NULL,
  `activation_limit` int DEFAULT NULL,
  `instances_count` int NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lemon_squeezy_license_keys_lemon_squeezy_id_unique` (`lemon_squeezy_id`),
  UNIQUE KEY `lemon_squeezy_license_keys_license_key_unique` (`license_key`),
  KEY `lemon_squeezy_license_keys_order_id_index` (`order_id`),
  KEY `lemon_squeezy_license_keys_product_id_index` (`product_id`),
  CONSTRAINT `lemon_squeezy_license_keys_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `lemon_squeezy_orders` (`lemon_squeezy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemon_squeezy_license_keys`
--

LOCK TABLES `lemon_squeezy_license_keys` WRITE;
/*!40000 ALTER TABLE `lemon_squeezy_license_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemon_squeezy_license_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemon_squeezy_orders`
--

DROP TABLE IF EXISTS `lemon_squeezy_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lemon_squeezy_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `billable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `billable_id` bigint unsigned NOT NULL,
  `lemon_squeezy_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `identifier` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `variant_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_number` int NOT NULL,
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` int NOT NULL,
  `discount_total` int NOT NULL,
  `tax` int NOT NULL,
  `total` int NOT NULL,
  `tax_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `receipt_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refunded` tinyint(1) NOT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `ordered_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lemon_squeezy_orders_lemon_squeezy_id_unique` (`lemon_squeezy_id`),
  UNIQUE KEY `lemon_squeezy_orders_identifier_unique` (`identifier`),
  UNIQUE KEY `lemon_squeezy_orders_order_number_unique` (`order_number`),
  KEY `lemon_squeezy_orders_billable_type_billable_id_index` (`billable_type`,`billable_id`),
  KEY `lemon_squeezy_orders_product_id_index` (`product_id`),
  KEY `lemon_squeezy_orders_variant_id_index` (`variant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemon_squeezy_orders`
--

LOCK TABLES `lemon_squeezy_orders` WRITE;
/*!40000 ALTER TABLE `lemon_squeezy_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemon_squeezy_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemon_squeezy_subscriptions`
--

DROP TABLE IF EXISTS `lemon_squeezy_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lemon_squeezy_subscriptions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `billable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `billable_id` bigint unsigned NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lemon_squeezy_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `variant_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_brand` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `card_last_four` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pause_mode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pause_resumes_at` timestamp NULL DEFAULT NULL,
  `trial_ends_at` timestamp NULL DEFAULT NULL,
  `renews_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lemon_squeezy_subscriptions_lemon_squeezy_id_unique` (`lemon_squeezy_id`),
  KEY `lemon_squeezy_subscriptions_billable_type_billable_id_index` (`billable_type`,`billable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemon_squeezy_subscriptions`
--

LOCK TABLES `lemon_squeezy_subscriptions` WRITE;
/*!40000 ALTER TABLE `lemon_squeezy_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemon_squeezy_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `license_agreements`
--

DROP TABLE IF EXISTS `license_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `license_agreements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `license_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agreement_file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
-- Table structure for table `main_categories`
--

DROP TABLE IF EXISTS `main_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `main_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `main_categories_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `main_categories`
--

LOCK TABLES `main_categories` WRITE;
/*!40000 ALTER TABLE `main_categories` DISABLE KEYS */;
INSERT INTO `main_categories` VALUES (3,'Digital Products','digital-product',NULL,'main-categories/tQH4zuX0lfDVx6lsrGJ5IgOtNDAB5kjYqnmMNPoX.webp',1,0,'2026-08-24 21:09:46','2026-08-30 11:46:43'),(4,'Physical Products','physical-product',NULL,'main-categories/gFbYfbToCrq9bhSCu1PNJz5pdBhkPOgQEiYQZthp.webp',1,0,'2026-08-24 21:12:55','2026-08-30 11:54:12');
/*!40000 ALTER TABLE `main_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manufacturing_methods`
--

DROP TABLE IF EXISTS `manufacturing_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manufacturing_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `manufacturing_methods_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manufacturing_methods`
--

LOCK TABLES `manufacturing_methods` WRITE;
/*!40000 ALTER TABLE `manufacturing_methods` DISABLE KEYS */;
INSERT INTO `manufacturing_methods` VALUES (1,'cnc','CNC',1,1,'2026-07-20 10:45:32','2026-07-20 10:45:32'),(2,'laser_cut','Laser Cut',1,2,'2026-07-20 10:45:32','2026-07-20 10:45:32'),(3,'hand_crafted','Hand Crafted',1,3,'2026-07-20 10:45:32','2026-07-20 10:45:32'),(4,'meta','metal',1,0,'2026-07-20 20:15:31','2026-07-20 20:15:31');
/*!40000 ALTER TABLE `manufacturing_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_manufacturing_method`
--

DROP TABLE IF EXISTS `material_manufacturing_method`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_manufacturing_method` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `manufacturing_method_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mat_method_unique` (`material_id`,`manufacturing_method_id`),
  KEY `material_manufacturing_method_manufacturing_method_id_foreign` (`manufacturing_method_id`),
  CONSTRAINT `material_manufacturing_method_manufacturing_method_id_foreign` FOREIGN KEY (`manufacturing_method_id`) REFERENCES `manufacturing_methods` (`id`) ON DELETE CASCADE,
  CONSTRAINT `material_manufacturing_method_material_id_foreign` FOREIGN KEY (`material_id`) REFERENCES `materials` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_manufacturing_method`
--

LOCK TABLES `material_manufacturing_method` WRITE;
/*!40000 ALTER TABLE `material_manufacturing_method` DISABLE KEYS */;
INSERT INTO `material_manufacturing_method` VALUES (1,1,1),(2,1,2),(3,1,3),(5,2,1),(4,2,2),(10,2,3),(6,3,1),(7,3,2),(8,3,3);
/*!40000 ALTER TABLE `material_manufacturing_method` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materials`
--

DROP TABLE IF EXISTS `materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materials` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `materials_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materials`
--

LOCK TABLES `materials` WRITE;
/*!40000 ALTER TABLE `materials` DISABLE KEYS */;
INSERT INTO `materials` VALUES (1,'wood','Wood',1,1,'2026-07-20 10:45:32','2026-07-20 10:45:32'),(2,'acrylic','Acrylic',1,2,'2026-07-20 10:45:32','2026-07-20 10:45:32'),(3,'wood_acrylic','Wood + Acrylic',1,3,'2026-07-20 10:45:32','2026-07-20 10:45:32');
/*!40000 ALTER TABLE `materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_06_25_200759_create_personal_access_tokens_table',1),(5,'2026_06_25_210000_create_roles_table',1),(6,'2026_06_25_210001_add_role_id_to_users',1),(7,'2026_06_25_220000_update_users_table',2),(8,'2026_06_25_220001_create_addresses_table',2),(9,'2026_06_25_220002_create_subscription_plans_table',2),(10,'2026_06_25_220003_create_shipping_companies_table',2),(11,'2026_06_25_220004_create_payment_methods_table',2),(12,'2026_06_25_220005_create_traffic_sources_table',2),(13,'2026_06_25_220010_create_products_table',2),(14,'2026_06_25_220011_create_coupons_table',2),(15,'2026_06_25_220012_create_product_images_table',2),(16,'2026_06_25_220013_create_inventory_table',2),(17,'2026_06_25_220014_create_digital_files_table',2),(18,'2026_06_25_220015_create_license_agreements_table',2),(19,'2026_06_25_220020_create_affiliates_table',2),(20,'2026_06_25_220021_create_carts_table',2),(21,'2026_06_25_220022_create_user_subscriptions_table',2),(22,'2026_06_25_220023_create_shipping_rates_table',2),(23,'2026_06_25_220024_create_user_roles_table',2),(24,'2026_06_25_220030_create_orders_table',2),(25,'2026_06_25_220031_create_order_items_table',2),(26,'2026_06_25_220032_create_affiliate_earnings_table',2),(27,'2026_06_25_220033_create_payments_table',2),(28,'2026_06_25_220034_create_refunds_table',2),(29,'2026_06_25_220035_create_reviews_table',2),(30,'2026_06_25_220036_create_wishlist_table',2),(31,'2026_06_25_220037_create_downloads_table',2),(32,'2026_06_25_220038_create_cart_items_table',2),(33,'2026_06_25_220040_create_product_analytics_table',2),(34,'2026_06_25_220041_create_customer_analytics_table',2),(35,'2026_06_25_220042_create_financial_analytics_table',2),(36,'2026_06_25_220043_create_cart_analytics_table',2),(37,'2026_06_25_220044_create_daily_reports_table',2),(38,'2026_06_25_220045_create_activity_logs_table',2),(39,'2026_06_25_220046_create_visitor_sessions_table',2),(40,'2026_06_26_000000_add_coupon_to_orders_table',3),(41,'2026_06_26_010000_extend_subscription_plans_table',3),(42,'2026_06_26_010001_extend_user_subscriptions_table',3),(43,'2026_06_26_010010_create_tickets_table',3),(44,'2026_06_26_010011_create_ticket_status_history_table',3),(45,'2026_06_26_010012_create_industor_designers_table',3),(46,'2026_06_26_010013_create_ticket_attachments_table',3),(47,'2026_06_26_010014_create_notifications_table',3),(48,'2026_06_26_010015_create_store_listings_table',3),(49,'2026_06_26_020000_add_approval_to_user_subscriptions_table',4),(50,'2026_06_26_020010_create_ticket_modification_requests_table',4),(51,'2026_06_26_020020_add_designer_id_to_products_table',4),(52,'2026_06_26_020030_add_accepted_and_qa_claimed_to_tickets_table',5),(53,'2026_06_26_153000_create_saved_cards_table',6),(54,'2026_06_26_160000_add_review_and_penalty_fields_to_tickets_table',7),(55,'2026_06_26_150000_add_paymob_fields_to_payments_table',8),(56,'2026_06_26_150001_add_paymob_fields_to_user_subscriptions_table',8),(57,'2026_06_26_170000_add_single_purchase_to_tickets_and_ticket_id_to_payments',9),(58,'2026_06_26_180000_add_pricing_fields_to_tickets_and_price_history_table',10),(59,'2026_06_29_160000_add_deadline_negotiation_to_tickets',11),(60,'2026_06_29_180000_add_open_negotiation_fields_to_tickets',12),(61,'2026_06_29_190000_add_material_manufacturing_tags_to_products_table',13),(62,'2026_06_29_190001_add_design_file_to_products_table',13),(63,'2026_07_04_120000_create_contact_submissions_table',14),(64,'2026_07_04_130000_add_currency_preference_to_users_table',15),(65,'2026_07_04_140000_create_settings_table',16),(66,'2026_07_04_150000_add_guest_support_to_carts_and_orders',16),(67,'2026_07_20_000000_create_materials_table',17),(68,'2026_07_20_000001_create_manufacturing_methods_table',18),(69,'2026_07_20_000002_create_material_manufacturing_method_table',19),(70,'2026_07_04_160000_add_guest_address_to_orders_table',1),(71,'2026_07_13_160200_create_hero_images_table',1),(72,'2026_07_13_170000_add_type_sample_to_products_table',1),(73,'2026_07_13_190000_add_discount_percent_to_subscription_plans_table',1),(74,'2026_07_13_200000_add_commission_columns_to_products_table',1),(75,'2026_07_13_210000_add_tester_review_columns_to_products_table',1),(76,'2026_07_15_224245_add_guest_token_to_orders_table',1),(77,'2026_07_15_230000_add_ticket_id_to_products_table',1),(78,'2026_07_16_000000_add_google_fields_to_users_table',1),(79,'2026_07_16_010000_add_media_type_to_hero_images_table',1),(80,'2026_07_20_000010_add_num_order_to_tickets_table',20),(81,'2026_07_20_100000_create_product_variants_table',21),(82,'2026_07_20_100001_create_product_variant_images_table',21),(83,'2026_07_21_100000_add_stox_fields_to_products_table',22),(84,'2026_07_21_110000_add_stox_category_color_to_products_table',23),(85,'2026_07_22_100000_add_stox_product_id_to_products_table',24),(86,'2026_07_22_110000_add_stox_order_id_to_orders_table',25),(87,'2026_07_22_120000_add_missing_columns_to_orders_table',26),(88,'2026_07_22_071209_add_google_auth_columns_to_users_table',27),(89,'2026_07_22_120606_add_stox_product_id_to_product_variants_table',28),(90,'2026_07_22_121914_restructure_shipping_rates_table',29),(91,'2026_07_30_000001_create_jobs_table',30),(92,'2026_07_30_100000_create_digital_file_urls_table',30),(93,'2026_07_30_110000_make_digital_files_file_url_nullable',30),(94,'2023_01_16_000001_create_customers_table',31),(95,'2023_01_16_000002_create_subscriptions_table',31),(96,'2023_01_16_000003_create_orders_table',31),(97,'2023_01_16_000004_create_license_keys_table',31),(98,'2023_01_16_000005_create_license_key_instances_table',31),(99,'2026_07_30_120000_add_lemonsqueezy_ids_to_products_table',31),(100,'2026_08_01_000001_add_guest_email_to_orders_table',32),(101,'2026_08_24_100000_add_fake_price_to_products_and_variants_table',33),(102,'2026_08_24_200000_create_main_categories_table',34),(103,'2026_08_25_100000_add_star_rating_and_sold_count_to_products_and_variants_table',35);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `data` json DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_read_at_index` (`user_id`,`read_at`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,11,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 9}','2026-06-25 22:56:59','2026-06-25 10:56:59'),(2,11,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 10}','2026-06-25 22:56:59','2026-06-25 10:56:59'),(3,11,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 8}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(4,11,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-25 16:56:59'),(5,11,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 2}',NULL,'2026-06-25 14:56:59'),(6,12,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 10}',NULL,'2026-06-25 18:56:59'),(7,12,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 2}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(8,12,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 2}',NULL,'2026-06-25 14:56:59'),(9,12,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 4}','2026-06-25 22:56:59','2026-06-25 19:56:59'),(10,12,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-24 22:56:59'),(11,6,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 7}',NULL,'2026-06-25 08:56:59'),(12,6,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 10}','2026-06-25 22:56:59','2026-06-25 04:56:59'),(13,6,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 4}',NULL,'2026-06-25 11:56:59'),(14,6,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 4}','2026-06-25 22:56:59','2026-06-25 07:56:59'),(15,6,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 3}','2026-06-25 22:56:59','2026-06-25 14:56:59'),(16,8,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 6}','2026-07-04 20:08:11','2026-06-25 10:56:59'),(17,8,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 6}','2026-06-25 22:56:59','2026-06-25 09:56:59'),(18,8,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 1}','2026-06-25 22:56:59','2026-06-25 11:56:59'),(19,8,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 2}','2026-06-25 22:56:59','2026-06-25 13:56:59'),(20,8,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 3}','2026-06-25 22:56:59','2026-06-25 15:56:59'),(21,1,'ticket.opened','New ticket available','New ticket available - check your dashboard for details.','{\"ticket_id\": 6}','2026-06-25 22:56:59','2026-06-25 01:56:59'),(22,1,'ticket.accepted','A designer accepted your ticket','A designer accepted your ticket - check your dashboard for details.','{\"ticket_id\": 11}','2026-07-04 19:57:13','2026-06-25 10:56:59'),(23,1,'ticket.deadline_set','Designer set a delivery deadline','Designer set a delivery deadline - check your dashboard for details.','{\"ticket_id\": 11}','2026-07-04 19:57:13','2026-06-25 14:56:59'),(24,1,'ticket.uploaded','Deliverable uploaded - awaiting QA','Deliverable uploaded - awaiting QA - check your dashboard for details.','{\"ticket_id\": 1}','2026-07-04 19:57:13','2026-06-25 05:56:59'),(25,1,'subscription.approved','Your subscription was approved','Your subscription was approved - check your dashboard for details.','{\"ticket_id\": 9}','2026-07-04 19:57:13','2026-06-25 21:56:59'),(26,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(27,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}','2026-07-04 20:08:01','2026-06-25 23:01:59'),(28,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(29,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"ssssssssssssssssssssss\", \"ticket_id\": 13}',NULL,'2026-06-25 23:01:59'),(30,11,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 13, \"designer_id\": 8}',NULL,'2026-06-25 23:03:17'),(31,11,'ticket.modification_requested','Designer requested modifications',NULL,'{\"ticket_id\": 13, \"modification_id\": 2}',NULL,'2026-06-25 23:03:52'),(32,8,'ticket.modification.approved','Your modification request was approved',NULL,'{\"ticket_id\": 13}','2026-07-04 20:08:22','2026-06-25 23:04:30'),(33,12,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 8}',NULL,'2026-06-25 23:09:31'),(34,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 7}',NULL,'2026-06-25 23:09:44'),(35,11,'ticket.deadline_set','Designer set a delivery deadline',NULL,'{\"deadline\": \"2026-06-25T23:11:00.000000Z\", \"ticket_id\": 13}',NULL,'2026-06-25 23:10:38'),(36,11,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 13, \"attachment_id\": 6}',NULL,'2026-06-25 23:11:36'),(37,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(38,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(39,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:11:36'),(40,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:13:08'),(41,11,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 13}',NULL,'2026-06-25 23:13:21'),(42,8,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 13}','2026-07-04 20:08:22','2026-06-25 23:13:21'),(43,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"flfl-design\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(44,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"flfl-design\", \"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:10:03'),(45,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"flfl-design\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(46,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"flfl-design\", \"ticket_id\": 14}',NULL,'2026-06-26 11:10:03'),(47,11,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 14, \"designer_id\": 8}',NULL,'2026-06-26 11:13:07'),(48,11,'ticket.modification_requested','Designer requested modifications',NULL,'{\"ticket_id\": 14, \"modification_id\": 4}',NULL,'2026-06-26 11:15:44'),(49,8,'ticket.modification.approved','Your modification request was approved',NULL,'{\"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:16:36'),(50,11,'ticket.deadline_set','Designer set a delivery deadline',NULL,'{\"deadline\": \"2026-06-26T11:18:00.000000Z\", \"ticket_id\": 14}',NULL,'2026-06-26 11:17:27'),(51,11,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 14, \"attachment_id\": 7}',NULL,'2026-06-26 11:18:22'),(52,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(53,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(54,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:18:22'),(55,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:19:43'),(56,11,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 14}',NULL,'2026-06-26 11:20:14'),(57,8,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 14}','2026-07-04 20:08:22','2026-06-26 11:20:14'),(58,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 5}','2026-07-04 19:57:13','2026-06-26 12:23:36'),(59,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 6}','2026-07-04 19:57:13','2026-06-26 12:24:05'),(60,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 7}','2026-07-04 19:57:13','2026-06-26 12:24:27'),(61,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 8}','2026-07-04 19:57:13','2026-06-26 12:24:40'),(62,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 9}','2026-07-04 19:57:13','2026-06-26 14:03:36'),(63,5,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 9}',NULL,'2026-06-26 14:04:03'),(64,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 8}',NULL,'2026-06-26 14:04:06'),(65,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 7}',NULL,'2026-06-26 14:04:06'),(66,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 6}',NULL,'2026-06-26 14:04:06'),(67,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 5}',NULL,'2026-06-26 14:04:07'),(68,13,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 3}',NULL,'2026-06-26 14:04:07'),(69,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(70,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(71,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:04:59'),(72,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"2000.00\", \"deadline\": \"2026-07-01T14:06:00.000000Z\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(73,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(74,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}','2026-07-04 20:08:22','2026-06-26 14:07:00'),(75,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(76,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"vgkvlbhbh000000000\", \"ticket_id\": 15}',NULL,'2026-06-26 14:07:00'),(77,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 15, \"designer_id\": 8}',NULL,'2026-06-26 14:09:00'),(78,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(79,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(80,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"شسينسشزؤةسشنىؤشسنم\", \"ticket_id\": 16}',NULL,'2026-06-26 15:11:54'),(81,5,'ticket.reviewed','Your ticket was reviewed - payment required',NULL,'{\"price\": \"5000.00\", \"deadline\": \"2026-07-01T15:12:00.000000Z\", \"ticket_id\": 16}',NULL,'2026-06-26 15:13:10'),(82,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(83,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(84,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:19:43'),(85,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"50000.00\", \"deadline\": \"2026-07-01T15:20:00.000000Z\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(86,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(87,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}','2026-07-04 20:08:22','2026-06-26 15:20:18'),(88,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(89,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"alsd,pw222222222222222222222222222221\", \"ticket_id\": 17}',NULL,'2026-06-26 15:20:18'),(90,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Ahmed\", \"ticket_id\": 17, \"designer_id\": 8}',NULL,'2026-06-28 15:26:45'),(91,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(92,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(93,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:29:37'),(94,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"10000.00\", \"deadline\": \"2026-06-28T16:37:00.000000Z\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(95,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(96,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}','2026-07-04 20:08:22','2026-06-28 16:30:21'),(97,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(98,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:30:21'),(99,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(100,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}','2026-07-04 20:08:22','2026-06-28 16:33:54'),(101,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(102,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"new_price\": 7700, \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(103,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(104,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:54'),(105,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"hjghkbhjkbjkhghjvhvvg\", \"ticket_id\": 18}',NULL,'2026-06-28 16:33:55'),(106,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(107,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(108,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:24:23'),(109,5,'ticket.deadline_approved','Your proposed deadline was approved - set the price',NULL,'{\"deadline\": \"2026-06-29T22:00:00.000000Z\", \"ticket_id\": 19}',NULL,'2026-06-29 12:26:41'),(110,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"50000.00\", \"deadline\": \"2026-06-29T22:00:00.000000Z\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(111,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(112,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}','2026-07-04 20:08:22','2026-06-29 12:27:43'),(113,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(114,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"dasdadcvfdbf\", \"ticket_id\": 19}',NULL,'2026-06-29 12:27:43'),(115,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 19, \"designer_id\": 4}',NULL,'2026-06-29 12:28:43'),(116,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(117,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(118,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:51:52'),(119,5,'ticket.deadline_modified','Tester proposed a new delivery deadline',NULL,'{\"reason\": \"RNMKVLLVLDSMVSD\", \"ticket_id\": 20, \"new_deadline\": \"2026-07-03T10:00:00.000000Z\"}',NULL,'2026-06-29 12:52:52'),(120,3,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(121,6,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(122,7,'ticket.deadline_rejected','Industor rejected the proposed deadline',NULL,'{\"reason\": null, \"ticket_id\": 20}',NULL,'2026-06-29 12:53:19'),(123,5,'ticket.deadline_modified','Tester proposed a new delivery deadline',NULL,'{\"reason\": \"دا  اخر حاجه عشان نلحق\", \"ticket_id\": 20, \"new_deadline\": \"2026-07-01T22:00:00.000000Z\"}',NULL,'2026-06-29 12:54:17'),(124,3,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(125,6,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(126,7,'ticket.deadline_accepted','Industor accepted the delivery deadline',NULL,'{\"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:54:43'),(127,5,'ticket.reviewed','Your ticket was reviewed and approved',NULL,'{\"price\": \"22222212.00\", \"deadline\": \"2026-07-01T22:00:00.000000Z\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:13'),(128,4,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(129,8,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}','2026-07-04 20:08:22','2026-06-29 12:59:14'),(130,9,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(131,10,'ticket.opened','New ticket available',NULL,'{\"title\": \".v.cv,xzlc,vZCXL;MDVLAS;,D21W\", \"ticket_id\": 20}',NULL,'2026-06-29 12:59:14'),(132,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(133,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(134,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:09'),(135,5,'ticket.deadline_approved','Your proposed deadline was approved - set the price',NULL,'{\"deadline\": \"2026-07-01T13:48:00.000000Z\", \"ticket_id\": 21}',NULL,'2026-06-29 13:49:50'),(136,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(137,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(138,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:11:43'),(139,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"2500.00\", \"reason\": \"done\", \"deadline\": \"2026-07-01T15:13:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:13:19'),(140,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(141,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(142,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"2000.00\", \"reason\": null, \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:14:47'),(143,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"2000.00\", \"deadline\": \"2026-07-02T15:14:00.000000Z\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(144,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(145,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}','2026-07-04 20:08:22','2026-06-29 15:21:52'),(146,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(147,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-06-29 15:21:52'),(148,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(149,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(150,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:27:29'),(151,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"5000.00\", \"deadline\": \"2026-07-03T10:00:00.000000Z\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(152,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(153,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}','2026-07-04 20:08:22','2026-06-29 15:32:32'),(154,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(155,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-06-29 15:32:32'),(156,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(157,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(158,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:01'),(159,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"6666.00\", \"reason\": null, \"deadline\": \"2026-07-08T17:44:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:41:52'),(160,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(161,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(162,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"7000.00\", \"reason\": null, \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:25'),(163,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"7000.00\", \"deadline\": \"2026-07-04T15:42:00.000000Z\", \"ticket_id\": 26}','2026-07-04 20:05:08','2026-06-29 15:42:48'),(164,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(165,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}','2026-07-04 20:08:22','2026-06-29 15:42:48'),(166,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(167,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-06-29 15:42:48'),(168,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(169,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(170,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:41'),(171,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"6000.00\", \"deadline\": \"2026-07-03T23:00:00.000000Z\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(172,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(173,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}','2026-07-04 20:08:22','2026-06-29 15:49:54'),(174,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(175,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"سسسسسسسسسسسس\", \"ticket_id\": 27}',NULL,'2026-06-29 15:49:54'),(176,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(177,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(178,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:22:53'),(179,5,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"8000.00\", \"reason\": \"الدايرز مشغول\", \"deadline\": \"2026-07-05T16:23:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:03'),(180,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(181,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(182,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"11000.00\", \"reason\": null, \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:24:46'),(183,5,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"11000.00\", \"deadline\": \"2026-07-04T16:24:00.000000Z\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(184,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(185,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}','2026-07-04 20:08:22','2026-06-29 16:25:16'),(186,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(187,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"فارس ديزاااااين\", \"ticket_id\": 28}',NULL,'2026-06-29 16:25:16'),(188,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 28, \"designer_id\": 4}',NULL,'2026-06-29 16:26:11'),(189,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 28, \"attachment_id\": 15}',NULL,'2026-06-29 16:26:29'),(190,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(191,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(192,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:29'),(193,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:26:51'),(194,5,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:27:41'),(195,4,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 28}',NULL,'2026-06-29 16:27:41'),(196,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 20, \"designer_id\": 4}',NULL,'2026-06-29 16:29:11'),(197,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 18, \"designer_id\": 4}',NULL,'2026-06-29 16:29:31'),(198,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 20, \"attachment_id\": 16}',NULL,'2026-06-29 16:29:49'),(199,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(200,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(201,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:49'),(202,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:29:57'),(203,5,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:30:17'),(204,4,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 20}',NULL,'2026-06-29 16:30:17'),(205,5,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 27, \"designer_id\": 4}',NULL,'2026-06-29 16:30:44'),(206,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 18, \"attachment_id\": 17}',NULL,'2026-06-29 16:31:42'),(207,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(208,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(209,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:31:42'),(210,5,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:32:08'),(211,4,'ticket.qa_rejected','Your design was rejected by QA - please revise',NULL,'{\"reason\": \"التصميم وحش\", \"penalty\": \"1000.00\", \"ticket_id\": 18}',NULL,'2026-06-29 16:32:54'),(212,5,'ticket.uploaded','Deliverable uploaded - awaiting QA',NULL,'{\"ticket_id\": 18, \"attachment_id\": 18}',NULL,'2026-06-29 16:35:02'),(213,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(214,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(215,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 18}',NULL,'2026-06-29 16:35:02'),(216,4,'ticket.qa_rejected','Your design was rejected by QA - please revise',NULL,'{\"reason\": \"وحش برضوا\", \"penalty\": \"200.00\", \"ticket_id\": 18}',NULL,'2026-06-29 16:35:32'),(217,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(218,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(219,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(220,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"new_price\": 1540, \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(221,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(222,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(223,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm\", \"ticket_id\": 24}',NULL,'2026-07-03 22:34:52'),(224,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(225,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(226,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(227,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"00000000000\", \"new_price\": 3850, \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(228,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(229,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(230,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"00000000000\", \"ticket_id\": 25}',NULL,'2026-07-03 22:34:52'),(231,4,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"FlFl Design\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(232,8,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"FlFl Design\", \"new_price\": 5390, \"ticket_id\": 26}','2026-07-04 20:08:22','2026-07-03 22:34:52'),(233,9,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"FlFl Design\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(234,10,'ticket.price_increased','Ticket price increased 10% (urgent)',NULL,'{\"title\": \"FlFl Design\", \"new_price\": 5390, \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(235,3,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(236,6,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(237,7,'ticket.urgent','Ticket became urgent & price adjusted',NULL,'{\"title\": \"FlFl Design\", \"ticket_id\": 26}',NULL,'2026-07-03 22:34:52'),(238,1,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}','2026-07-04 19:57:13','2026-07-04 19:57:08'),(239,2,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(240,3,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(241,6,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(242,7,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(243,4,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(244,8,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}','2026-07-04 20:08:22','2026-07-04 19:57:08'),(245,9,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(246,10,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(247,5,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(248,11,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(249,12,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(250,13,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(251,14,'system','System Maintenance Tonight','The system will be down for maintenance at 2 AM. Please save your work.','{\"system\": true}',NULL,'2026-07-04 19:57:08'),(252,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 11}','2026-07-28 06:09:14','2026-07-26 21:27:38'),(253,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test\", \"ticket_id\": 29}',NULL,'2026-07-27 09:53:42'),(254,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test\", \"ticket_id\": 29}',NULL,'2026-07-27 09:53:42'),(255,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test\", \"ticket_id\": 29}',NULL,'2026-07-27 09:53:42'),(256,5,'ticket.negotiation_agreed','Price & deadline agreed - payment required',NULL,'{\"price\": \"2000.00\", \"deadline\": \"2026-07-28T09:53:00.000000Z\", \"ticket_id\": 29}',NULL,'2026-07-27 09:54:18'),(257,5,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 11}',NULL,'2026-07-28 06:33:23'),(258,13,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 10}',NULL,'2026-07-28 06:33:27'),(259,15,'payment.success','Payment received via LemonSqueezy',NULL,'{\"order_id\": 92, \"order_number\": \"ORD-6A7647A6399E4\"}',NULL,'2026-08-07 21:22:36'),(260,15,'payment.success','Payment received via LemonSqueezy',NULL,'{\"order_id\": 91, \"order_number\": \"ORD-6A7644A6DFA41\"}',NULL,'2026-08-07 21:23:43'),(261,15,'payment.success','Payment received via LemonSqueezy',NULL,'{\"order_id\": 70, \"order_number\": \"ORD-6A70998D9579C\"}',NULL,'2026-08-07 21:24:54'),(262,15,'payment.success','Payment received',NULL,'{\"order_id\": 69, \"order_number\": \"ORD-6A709978C1FF4\"}',NULL,'2026-08-07 21:31:29'),(263,15,'payment.success','Payment received',NULL,'{\"order_id\": 69, \"order_number\": \"ORD-6A709978C1FF4\"}',NULL,'2026-08-07 21:31:58'),(264,15,'payment.success','Payment received',NULL,'{\"order_id\": 93, \"order_number\": \"ORD-6A764F42650CB\"}',NULL,'2026-08-07 21:35:57'),(265,15,'payment.success','Payment received',NULL,'{\"order_id\": 93, \"order_number\": \"ORD-6A764F42650CB\"}',NULL,'2026-08-07 21:35:57'),(266,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 12}',NULL,'2026-08-07 22:12:05'),(267,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 13}',NULL,'2026-08-07 22:12:17'),(268,1,'subscription.pending','New subscription awaiting approval',NULL,'{\"user_id\": 5, \"subscription_id\": 14}',NULL,'2026-08-07 22:12:27'),(269,5,'subscription.approved','Subscription approved & payment received',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 14}',NULL,'2026-08-07 22:17:56'),(270,1,'subscription.paid','Subscription paid & auto-approved',NULL,'{\"user_id\": 5, \"subscription_id\": 14}',NULL,'2026-08-07 22:17:56'),(275,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 16}',NULL,'2026-08-07 22:19:35'),(276,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Enterprise\", \"subscription_id\": 17}',NULL,'2026-08-07 22:19:50'),(277,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 18}',NULL,'2026-08-07 22:19:56'),(278,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Basic\", \"subscription_id\": 19}',NULL,'2026-08-07 22:20:02'),(279,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 20}',NULL,'2026-08-07 22:20:15'),(281,5,'subscription.approved','Subscription approved & payment received',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 20}',NULL,'2026-08-07 22:30:26'),(282,1,'subscription.paid','Subscription paid & auto-approved',NULL,'{\"user_id\": 5, \"subscription_id\": 20}',NULL,'2026-08-07 22:30:26'),(283,5,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 20, \"tickets_remaining\": 20}',NULL,'2026-08-07 22:31:33'),(284,5,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 20, \"tickets_remaining\": 20}',NULL,'2026-08-07 22:31:36'),(285,5,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 20, \"tickets_remaining\": 10}',NULL,'2026-08-07 22:31:43'),(286,5,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 20, \"tickets_remaining\": 0}',NULL,'2026-08-07 22:37:06'),(287,5,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Enterprise\", \"subscription_id\": 22}',NULL,'2026-08-07 22:37:24'),(288,11,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 7}',NULL,'2026-08-09 13:35:19'),(289,11,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 7}',NULL,'2026-08-09 13:35:29'),(290,9,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 7}',NULL,'2026-08-09 13:35:29'),(291,5,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 22}',NULL,'2026-08-14 14:19:02'),(292,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 30}',NULL,'2026-08-14 14:30:30'),(293,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 30}',NULL,'2026-08-14 14:30:30'),(294,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 30}',NULL,'2026-08-14 14:30:30'),(295,30,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"500.00\", \"reason\": null, \"deadline\": \"2026-08-15T14:37:00.000000Z\", \"ticket_id\": 30}',NULL,'2026-08-14 14:41:17'),(296,30,'ticket.negotiation_agreed','Price & deadline agreed - payment required',NULL,'{\"price\": \"500.00\", \"deadline\": \"2026-08-15T14:37:00.000000Z\", \"ticket_id\": 30}',NULL,'2026-08-14 14:41:38'),(297,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 31}',NULL,'2026-08-14 14:56:19'),(298,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 31}',NULL,'2026-08-14 14:56:19'),(299,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 31}',NULL,'2026-08-14 14:56:19'),(300,30,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"700.00\", \"reason\": null, \"deadline\": \"2026-08-18T14:58:00.000000Z\", \"ticket_id\": 31}',NULL,'2026-08-14 14:58:57'),(301,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"700.00\", \"reason\": null, \"deadline\": \"2026-08-16T14:59:00.000000Z\", \"ticket_id\": 31}',NULL,'2026-08-14 14:59:41'),(302,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"700.00\", \"reason\": null, \"deadline\": \"2026-08-16T14:59:00.000000Z\", \"ticket_id\": 31}',NULL,'2026-08-14 14:59:41'),(303,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"700.00\", \"reason\": null, \"deadline\": \"2026-08-16T14:59:00.000000Z\", \"ticket_id\": 31}',NULL,'2026-08-14 14:59:41'),(304,30,'ticket.negotiation_agreed','Price & deadline agreed - payment required',NULL,'{\"price\": \"700.00\", \"deadline\": \"2026-08-16T14:59:00.000000Z\", \"ticket_id\": 31}',NULL,'2026-08-14 15:00:38'),(305,30,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Premium\", \"subscription_id\": 23}',NULL,'2026-08-14 15:01:37'),(306,30,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 23}',NULL,'2026-08-14 15:02:12'),(307,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:03:48'),(308,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:03:48'),(309,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:03:48'),(310,30,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"1080.00\", \"reason\": null, \"deadline\": \"2026-08-15T15:05:00.000000Z\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:08'),(311,30,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"1080.00\", \"deadline\": \"2026-08-15T15:05:00.000000Z\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:29'),(312,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:29'),(313,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:29'),(314,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:29'),(315,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"test3\", \"ticket_id\": 32}',NULL,'2026-08-14 15:06:29'),(316,30,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Admin\", \"ticket_id\": 32, \"designer_id\": 1}',NULL,'2026-08-14 15:08:19'),(317,1,'ticket.cancelled','A ticket you were working on was cancelled',NULL,'{\"ticket_id\": 32}',NULL,'2026-08-14 15:11:45'),(318,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:12:43'),(319,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:12:43'),(320,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:12:43'),(321,30,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"1080.00\", \"deadline\": \"2026-08-15T15:12:00.000000Z\", \"ticket_id\": 33}',NULL,'2026-08-14 15:14:12'),(322,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:14:12'),(323,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:14:12'),(324,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:14:12'),(325,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"test4\", \"ticket_id\": 33}',NULL,'2026-08-14 15:14:12'),(326,30,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer\", \"ticket_id\": 33, \"designer_id\": 4}',NULL,'2026-08-14 15:14:32'),(327,30,'ticket.uploaded','New deliverables have been uploaded',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:13'),(328,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:13'),(329,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:13'),(330,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:13'),(331,30,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:22'),(332,30,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:48'),(333,4,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 33}',NULL,'2026-08-14 15:15:48'),(334,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:38:48'),(335,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:38:48'),(336,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:38:48'),(337,30,'ticket.negotiation_agreed','Price & deadline agreed - ticket is now available',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-15T18:38:00.000000Z\", \"ticket_id\": 34}',NULL,'2026-08-14 18:40:23'),(338,4,'ticket.opened','New ticket available',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:40:23'),(339,8,'ticket.opened','New ticket available',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:40:23'),(340,9,'ticket.opened','New ticket available',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:40:23'),(341,10,'ticket.opened','New ticket available',NULL,'{\"title\": \"test5\", \"ticket_id\": 34}',NULL,'2026-08-14 18:40:23'),(342,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test6\", \"ticket_id\": 35}',NULL,'2026-08-14 18:42:12'),(343,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test6\", \"ticket_id\": 35}',NULL,'2026-08-14 18:42:12'),(344,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test6\", \"ticket_id\": 35}',NULL,'2026-08-14 18:42:12'),(345,30,'ticket.negotiation_agreed','Price & deadline agreed - payment required',NULL,'{\"price\": \"1000.00\", \"deadline\": \"2026-08-29T18:41:00.000000Z\", \"ticket_id\": 35}',NULL,'2026-08-14 18:42:36'),(346,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"asds\", \"ticket_id\": 36}',NULL,'2026-08-14 18:48:53'),(347,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"asds\", \"ticket_id\": 36}',NULL,'2026-08-14 18:48:53'),(348,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"asds\", \"ticket_id\": 36}',NULL,'2026-08-14 18:48:53'),(349,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"1800.00\", \"deadline\": \"2026-08-14T18:52:00.000000Z\", \"ticket_id\": 36}',NULL,'2026-08-14 18:58:07'),(350,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test7\", \"ticket_id\": 37}',NULL,'2026-08-14 19:02:02'),(351,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test7\", \"ticket_id\": 37}',NULL,'2026-08-14 19:02:02'),(352,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test7\", \"ticket_id\": 37}',NULL,'2026-08-14 19:02:02'),(353,30,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"1080.00\", \"reason\": \"معلش\", \"deadline\": \"2026-08-18T19:03:00.000000Z\", \"ticket_id\": 37}',NULL,'2026-08-14 19:03:44'),(354,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"1080.00\", \"reason\": null, \"deadline\": \"2026-08-15T19:03:00.000000Z\", \"ticket_id\": 37}',NULL,'2026-08-14 19:04:09'),(355,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"1080.00\", \"reason\": null, \"deadline\": \"2026-08-15T19:03:00.000000Z\", \"ticket_id\": 37}',NULL,'2026-08-14 19:04:09'),(356,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"1080.00\", \"reason\": null, \"deadline\": \"2026-08-15T19:03:00.000000Z\", \"ticket_id\": 37}',NULL,'2026-08-14 19:04:09'),(357,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"1080.00\", \"deadline\": \"2026-08-15T19:03:00.000000Z\", \"ticket_id\": 37}',NULL,'2026-08-14 19:04:25'),(358,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test8\", \"ticket_id\": 38}',NULL,'2026-08-14 19:12:10'),(359,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test8\", \"ticket_id\": 38}',NULL,'2026-08-14 19:12:10'),(360,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test8\", \"ticket_id\": 38}',NULL,'2026-08-14 19:12:10'),(361,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-17T19:11:00.000000Z\", \"ticket_id\": 38}',NULL,'2026-08-14 19:12:26'),(362,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test9\", \"ticket_id\": 39}',NULL,'2026-08-14 19:19:00'),(363,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test9\", \"ticket_id\": 39}',NULL,'2026-08-14 19:19:00'),(364,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test9\", \"ticket_id\": 39}',NULL,'2026-08-14 19:19:00'),(365,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-14T19:25:00.000000Z\", \"ticket_id\": 39}',NULL,'2026-08-14 19:19:12'),(366,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test10\", \"ticket_id\": 40}',NULL,'2026-08-14 19:23:27'),(367,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test10\", \"ticket_id\": 40}',NULL,'2026-08-14 19:23:27'),(368,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test10\", \"ticket_id\": 40}',NULL,'2026-08-14 19:23:27'),(369,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-14T19:28:00.000000Z\", \"ticket_id\": 40}',NULL,'2026-08-14 19:23:37'),(370,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test11\", \"ticket_id\": 41}',NULL,'2026-08-14 19:26:56'),(371,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test11\", \"ticket_id\": 41}',NULL,'2026-08-14 19:26:56'),(372,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test11\", \"ticket_id\": 41}',NULL,'2026-08-14 19:26:56'),(373,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-14T19:32:00.000000Z\", \"ticket_id\": 41}',NULL,'2026-08-14 19:27:08'),(374,30,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 23, \"tickets_remaining\": 16}',NULL,'2026-08-14 19:36:07'),(375,30,'subscription.tickets_updated','Your subscription ticket balance was updated',NULL,'{\"subscription_id\": 23, \"tickets_remaining\": 0}',NULL,'2026-08-14 19:36:14'),(376,30,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Basic\", \"subscription_id\": 24}',NULL,'2026-08-14 19:37:11'),(377,30,'subscription.rejected','Your subscription was rejected',NULL,'{\"reason\": null, \"subscription_id\": 24}',NULL,'2026-08-14 19:37:31'),(378,30,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Enterprise\", \"subscription_id\": 25}',NULL,'2026-08-14 19:53:06'),(379,30,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Enterprise\", \"subscription_id\": 26}',NULL,'2026-08-14 19:58:06'),(380,30,'subscription.pending','Subscription created — waiting for payment',NULL,'{\"plan_name\": \"Enterprise\", \"subscription_id\": 27}',NULL,'2026-08-14 19:58:37'),(381,30,'subscription.approved','Your subscription was approved',NULL,'{\"subscription_id\": 27}',NULL,'2026-08-14 20:01:54'),(382,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 42}',NULL,'2026-08-14 20:07:59'),(383,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 42}',NULL,'2026-08-14 20:07:59'),(384,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test1\", \"ticket_id\": 42}',NULL,'2026-08-14 20:07:59'),(385,30,'ticket.suggestion_received','Tester sent a price & deadline proposal',NULL,'{\"price\": \"1020.00\", \"reason\": null, \"deadline\": \"2026-08-18T21:00:00.000000Z\", \"ticket_id\": 42}',NULL,'2026-08-14 20:09:20'),(386,3,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"850.00\", \"reason\": null, \"deadline\": \"2026-08-19T20:10:00.000000Z\", \"ticket_id\": 42}',NULL,'2026-08-14 20:10:47'),(387,6,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"850.00\", \"reason\": null, \"deadline\": \"2026-08-19T20:10:00.000000Z\", \"ticket_id\": 42}',NULL,'2026-08-14 20:10:47'),(388,7,'ticket.counter_received','Industor sent a counter-proposal',NULL,'{\"price\": \"850.00\", \"reason\": null, \"deadline\": \"2026-08-19T20:10:00.000000Z\", \"ticket_id\": 42}',NULL,'2026-08-14 20:10:47'),(389,30,'ticket.negotiation_agreed_plan','Price & deadline agreed - discounted payment required',NULL,'{\"price\": \"850.00\", \"deadline\": \"2026-08-19T20:10:00.000000Z\", \"ticket_id\": 42}',NULL,'2026-08-14 20:10:56'),(390,30,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Omar\", \"ticket_id\": 42, \"designer_id\": 10}',NULL,'2026-08-14 20:15:36'),(391,30,'ticket.uploaded','New deliverables have been uploaded',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:15:46'),(392,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:15:46'),(393,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:15:46'),(394,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:15:46'),(395,30,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:16:56'),(396,30,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:16:59'),(397,10,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 42}',NULL,'2026-08-14 20:16:59'),(398,3,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 43}',NULL,'2026-08-14 20:21:03'),(399,6,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 43}',NULL,'2026-08-14 20:21:03'),(400,7,'ticket.pending_review','New ticket awaiting review',NULL,'{\"title\": \"test2\", \"ticket_id\": 43}',NULL,'2026-08-14 20:21:03'),(401,30,'ticket.negotiation_agreed','Price & deadline agreed - payment required',NULL,'{\"price\": \"900.00\", \"deadline\": \"2026-08-16T20:20:00.000000Z\", \"ticket_id\": 43}',NULL,'2026-08-14 20:21:23'),(402,30,'ticket.accepted','A designer accepted your ticket',NULL,'{\"designer\": \"Designer Sara\", \"ticket_id\": 43, \"designer_id\": 9}',NULL,'2026-08-14 20:23:05'),(403,30,'ticket.uploaded','New deliverables have been uploaded',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:23:40'),(404,3,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:23:40'),(405,6,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:23:40'),(406,7,'ticket.awaiting_qa','New design awaiting review',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:23:40'),(407,30,'ticket.qa_claimed','Your design is under QA review',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:24:05'),(408,30,'ticket.completed','Your design was approved and delivered',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:24:06'),(409,9,'ticket.completed','Your design was approved by QA',NULL,'{\"ticket_id\": 43}',NULL,'2026-08-14 20:24:06');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `variant_id` bigint unsigned DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `price` decimal(12,2) NOT NULL,
  `license_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_product_id_foreign` (`product_id`),
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `guest_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_governorate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_address_line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_postal_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address_id` bigint unsigned DEFAULT NULL,
  `order_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `affiliate_id` bigint unsigned DEFAULT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `coupon_id` bigint unsigned DEFAULT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `payment_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `order_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `shipping_tracking_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stox_order_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned DEFAULT NULL,
  `ticket_id` bigint unsigned DEFAULT NULL,
  `payment_method_id` int unsigned DEFAULT NULL,
  `transaction_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymob_order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_order_id_foreign` (`order_id`),
  KEY `payments_payment_method_id_foreign` (`payment_method_id`),
  KEY `payments_ticket_id_foreign` (`ticket_id`),
  CONSTRAINT `payments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_payment_method_id_foreign` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE SET NULL,
  CONSTRAINT `payments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (33,NULL,NULL,NULL,NULL,'574170058',2000.00,'EGP','pending',NULL),(34,NULL,NULL,NULL,NULL,'574170260',2000.00,'EGP','pending',NULL),(35,NULL,NULL,NULL,NULL,'574216117',2000.00,'EGP','pending',NULL),(113,NULL,NULL,NULL,'200010401','582863349',29900.00,'EGP','paid',NULL),(115,NULL,NULL,NULL,'511274826','582872041',20.00,'EGP','paid',NULL),(125,NULL,NULL,NULL,NULL,'587386874',500.00,'EGP','pending',NULL),(126,NULL,NULL,NULL,NULL,'587558232',1000.00,'EGP','pending',NULL),(127,NULL,NULL,NULL,NULL,'587561544',1000.00,'EGP','pending',NULL),(128,NULL,NULL,NULL,NULL,'587571259',1800.00,'EGP','pending',NULL),(129,NULL,NULL,NULL,NULL,'587572089',1000.00,'EGP','pending',NULL),(130,NULL,NULL,NULL,NULL,'587576698',1080.00,'EGP','pending',NULL),(131,NULL,NULL,NULL,'200010401','587616567',1500.00,'EGP','paid','2026-08-14 19:59:53'),(132,NULL,42,NULL,NULL,'587631149',850.00,'EGP','pending',NULL),(133,NULL,43,NULL,NULL,'587639165',900.00,'EGP','pending',NULL);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth-token','b44d3b090d857e8fafba553de70e4427fc48e9a30cac988c54e4e53b2e8f86d2','[\"*\"]','2026-06-25 20:32:12',NULL,'2026-06-25 20:32:09','2026-06-25 20:32:12'),(4,'App\\Models\\User',1,'auth-token','d7df873a932f177bdfe1b7e646037de9f6586ae6f783b4606867700d6f78142e','[\"*\"]','2026-06-25 20:43:45',NULL,'2026-06-25 20:43:41','2026-06-25 20:43:45'),(5,'App\\Models\\User',2,'auth-token','2637ba7f350668224396f7f70239de438f97ce42d236ecc64840bf9f0231fb24','[\"*\"]','2026-06-25 20:43:50',NULL,'2026-06-25 20:43:50','2026-06-25 20:43:50'),(7,'App\\Models\\User',2,'auth-token','80f42dc2ffe34b69541070de0df0b63759ff2a214d1207a70b501f4cc980ff44','[\"*\"]','2026-06-25 21:21:42',NULL,'2026-06-25 21:21:41','2026-06-25 21:21:42'),(8,'App\\Models\\User',1,'auth-token','1d0d44b23570f0c6b023ebc309b1cdf16fa85829be9510d38a11127a30ba934e','[\"*\"]','2026-06-25 21:21:42',NULL,'2026-06-25 21:21:42','2026-06-25 21:21:42'),(13,'App\\Models\\User',11,'auth-token','9908c79ae7c88d36a1d081202bbd3a91a48545aa43197432a655c33a412d0e6e','[\"*\"]','2026-06-25 22:33:41',NULL,'2026-06-25 22:33:41','2026-06-25 22:33:41'),(14,'App\\Models\\User',11,'auth-token','a5fecc9603b9a23361de94939f2edeeaa608eaf171f064feff3c6875f283992b','[\"*\"]','2026-06-25 22:34:06',NULL,'2026-06-25 22:34:06','2026-06-25 22:34:06'),(17,'App\\Models\\User',8,'auth-token','7eb2fa29c4b7899a375fa4ef9238abf32cfa989c90b9085e772e18fcf0ab63ab','[\"*\"]','2026-06-25 22:57:23',NULL,'2026-06-25 22:57:23','2026-06-25 22:57:23'),(18,'App\\Models\\User',6,'auth-token','144b38ca00e28ea04b331ec0ed8b53eb7c2bdba2ee8f98c60821a79834d2c6b9','[\"*\"]','2026-06-25 22:57:24',NULL,'2026-06-25 22:57:24','2026-06-25 22:57:24'),(19,'App\\Models\\User',1,'auth-token','6a835a13f9feae5976f8ce3e6ac18b3eb3ab48666fb5e8cc04b9fd2c4ee4c31e','[\"*\"]','2026-06-25 22:57:25',NULL,'2026-06-25 22:57:24','2026-06-25 22:57:25'),(20,'App\\Models\\User',8,'auth-token','432c63715d47f9b676488d31334b4baab0c2515f23fa618194d87a6add4221fa','[\"*\"]','2026-06-25 22:57:41',NULL,'2026-06-25 22:57:41','2026-06-25 22:57:41'),(21,'App\\Models\\User',6,'auth-token','9f7f272e7f772acbaee7277924ed635715e5d9b09c53b2d05296954fb092511d','[\"*\"]','2026-06-25 22:57:41',NULL,'2026-06-25 22:57:41','2026-06-25 22:57:41'),(22,'App\\Models\\User',1,'auth-token','dc590d80bc9afb670612baf6b936dcde319c39ddf63dc49a08603cd4a5a48a14','[\"*\"]','2026-06-25 22:57:42',NULL,'2026-06-25 22:57:42','2026-06-25 22:57:42'),(23,'App\\Models\\User',1,'auth-token','c55a9f2fa8441b52a62b66115070ee2e5e463b0ca14f882fd3cce85a92947c49','[\"*\"]','2026-06-25 22:59:13',NULL,'2026-06-25 22:59:13','2026-06-25 22:59:13'),(24,'App\\Models\\User',8,'auth-token','7ba2c42f718fdbf8154a8babea99defa95396c0ed0cd6b9d3f5e9d3e098abdba','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(25,'App\\Models\\User',6,'auth-token','4df743a4a98018861cce60c44f7c68adf7d43dc4892c62dd633349048463771c','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(26,'App\\Models\\User',1,'auth-token','71f1e0129762e5d605079e9eaed0d68d7790fc777ed997f154e6e2652415a8e7','[\"*\"]','2026-06-25 22:59:42',NULL,'2026-06-25 22:59:42','2026-06-25 22:59:42'),(42,'App\\Models\\User',2,'auth-token','94e70b08874a0ab7526cc50c8fa8ab97005e1a822df77b7b6acf294f8e460bcf','[\"*\"]','2026-06-25 23:26:32',NULL,'2026-06-25 23:26:32','2026-06-25 23:26:32'),(62,'App\\Models\\User',6,'auth-token','1c05a67b06af18aff964724582ee2dcc7c84b5886aa53efa5ef142d5f2dd33d6','[\"*\"]','2026-06-28 16:30:21',NULL,'2026-06-26 15:12:32','2026-06-28 16:30:21'),(64,'App\\Models\\User',6,'auth-token','ed43bc5de85a83679eae67c7b82c52d3b7eb34e2e682fbee597e196c6174e1c6','[\"*\"]','2026-06-29 16:35:32',NULL,'2026-06-29 12:25:57','2026-06-29 16:35:32'),(65,'App\\Models\\User',4,'auth-token','106e71440915dcf650d1f1aabf02021644334e3813e8807892503da1930d8d0e','[\"*\"]','2026-06-29 17:29:51',NULL,'2026-06-29 12:26:12','2026-06-29 17:29:51'),(71,'App\\Models\\User',1,'auth-token','47fe653866a96156e506010aa283d9b104b8885a3b0e4324f39fae02b5cbeded','[\"*\"]','2026-07-04 12:29:51',NULL,'2026-07-04 12:29:41','2026-07-04 12:29:51'),(75,'App\\Models\\User',1,'auth-token','6aad53996c3a2db03b8299af2d6678422b9086463e26b080fe31eb28359a660b','[\"*\"]','2026-07-04 19:57:13',NULL,'2026-07-04 19:57:03','2026-07-04 19:57:13'),(88,'App\\Models\\User',1,'test','489c77db63dc614433da8e9cc21ca6415e5e58c204bc33b28e4e3f89f8f80e93','[\"*\"]',NULL,NULL,'2026-07-21 19:12:59','2026-07-21 19:12:59'),(89,'App\\Models\\User',1,'test','d712c5d6ed5487c247062e9d1f9efe9012fef16d5b6942eb5f500d84d10679b8','[\"*\"]','2026-07-21 20:11:16',NULL,'2026-07-21 19:13:18','2026-07-21 20:11:16'),(92,'App\\Models\\User',15,'test','5e5c656c93da456ec5e3281461a5626db28d71b16587a7fb56d5fc46539cf8a4','[\"*\"]','2026-07-22 12:34:21',NULL,'2026-07-22 07:42:38','2026-07-22 12:34:21'),(95,'App\\Models\\User',1,'auth-token','3c84b4b31b5c8c4d049d5c666dc6b38d3015d56a2bed45f60352580e34bed7d0','[\"*\"]','2026-07-22 12:56:08',NULL,'2026-07-22 12:34:26','2026-07-22 12:56:08'),(108,'App\\Models\\User',4,'auth-token','e7ebc869517a975e071bce5e7bafff850572b6594d02dab38349f99b246b9e6c','[\"*\"]',NULL,NULL,'2026-07-28 00:23:55','2026-07-28 00:23:55'),(119,'App\\Models\\User',1,'auth-token','ffa69e9e9781ef1ab9dbfda2d54e3e5d0c0d53f3dc24881ef744281a43bee361','[\"*\"]','2026-07-28 11:09:05',NULL,'2026-07-28 11:01:31','2026-07-28 11:09:05'),(120,'App\\Models\\User',1,'auth-token','1c1e1977953b08f76b6ee6665d7d81f2ef7d23cefbcf2fdbcb99302de8ef0c13','[\"*\"]','2026-07-28 18:14:29',NULL,'2026-07-28 18:13:39','2026-07-28 18:14:29'),(124,'App\\Models\\User',4,'test-token','81fa51ba0739bd22af73bb53ecf1edaa208e7f9c665704154d342bbeb1329667','[\"*\"]','2026-07-30 19:37:02',NULL,'2026-07-30 18:56:40','2026-07-30 19:37:02'),(125,'App\\Models\\User',1,'admin-test','21d33ce7659cafbbbffd699ceeebd8fddb2e7652c5cd12e9a369060fd6779667','[\"*\"]','2026-07-30 18:59:44',NULL,'2026-07-30 18:57:05','2026-07-30 18:59:44'),(133,'App\\Models\\User',1,'auth-token','45ebdac10503dfac64a74b77b3ea281c9d0999633c32ab5b96ffe3059c7c7d20','[\"*\"]','2026-07-31 21:16:23',NULL,'2026-07-30 21:55:10','2026-07-31 21:16:23'),(136,'App\\Models\\User',2,'auth-token','ffc6bdf437cbc5bc01f78c5738adf350e2f6b3cc14eb16dc030f9a373a56d781','[\"*\"]','2026-08-01 17:19:09',NULL,'2026-08-01 14:05:47','2026-08-01 17:19:09'),(143,'App\\Models\\User',15,'auth-token','6401f9923375fe9176949a5490a73c735bf29af4562b32444b5d99788b93bd37','[\"*\"]','2026-08-03 13:53:07',NULL,'2026-08-03 13:27:45','2026-08-03 13:53:07'),(144,'App\\Models\\User',2,'auth-token','0858a31689071a922b96b805399ccb6a185e2b371e9e0c952513125cd142850a','[\"*\"]',NULL,NULL,'2026-08-03 13:28:20','2026-08-03 13:28:20'),(145,'App\\Models\\User',2,'auth-token','6bfdee9b2c754899ee583a956c953fe10ce1db253206e86e3875344d8eb231b9','[\"*\"]',NULL,NULL,'2026-08-03 13:28:28','2026-08-03 13:28:28'),(146,'App\\Models\\User',2,'auth-token','d17f17c6036a4c6a3b5479e960c1c9251f0bc93fb4b074d46591192dcebd7afe','[\"*\"]',NULL,NULL,'2026-08-03 13:28:33','2026-08-03 13:28:33'),(166,'App\\Models\\User',1,'auth-token','60bcd5143adad9f5e3c6d91b96f92256592bbbdfae10fa811725a02701396a46','[\"*\"]',NULL,NULL,'2026-08-07 22:17:27','2026-08-07 22:17:27'),(167,'App\\Models\\User',1,'auth-token','0b1f1df1c9f9bed56ba197ab8dacc51eb15100004a2c4a70b5898159f7a43b50','[\"*\"]','2026-08-07 22:50:47',NULL,'2026-08-07 22:17:30','2026-08-07 22:50:47'),(168,'App\\Models\\User',1,'auth-token','5339888cab49b3f1bde1f2d92215b13a9f1ca10a99ac7195a7720f3b6317d1ea','[\"*\"]','2026-08-07 22:17:43',NULL,'2026-08-07 22:17:42','2026-08-07 22:17:43'),(170,'App\\Models\\User',5,'auth-token','ff9b0a394fe3dd794113d47d0c6f3cb76d621f18f204f674f113b784de15aae7','[\"*\"]','2026-08-07 22:18:00',NULL,'2026-08-07 22:18:00','2026-08-07 22:18:00'),(171,'App\\Models\\User',11,'auth-token','7e6d56db62df444573e2ca8745d11f4fec245b26534681428795f41a531aaed4','[\"*\"]','2026-08-07 22:50:47',NULL,'2026-08-07 22:18:19','2026-08-07 22:50:47'),(172,'App\\Models\\User',5,'auth-token','72803bfcfb4d6bc045166eeeba6e9fc9f8690a5b08ee5ecb6486e6bea407a0da','[\"*\"]','2026-08-07 22:19:23',NULL,'2026-08-07 22:19:18','2026-08-07 22:19:23'),(183,'App\\Models\\User',25,'auth-token','72baccefaed1027ba5861645ac99674e730e147570e8e90cd531c7b8ddbb4f0f','[\"*\"]',NULL,NULL,'2026-08-07 22:40:52','2026-08-07 22:40:52'),(184,'App\\Models\\User',27,'auth-token','a4221c3749b07d74a979d95b431eebba0045a82bb8570ae614b029152706c791','[\"*\"]',NULL,NULL,'2026-08-07 22:42:48','2026-08-07 22:42:48'),(185,'App\\Models\\User',1,'auth-token','4a737526d9fdadee09ac0d9d47f012d219f585f0f665c01149faf61370366232','[\"*\"]','2026-08-12 21:37:32',NULL,'2026-08-07 22:45:11','2026-08-12 21:37:32'),(193,'App\\Models\\User',5,'impersonate-1786143047','423f7ea66a93f2740fc7592408b7c156efbaf72f086fa9ce1c0dd7438a8dbe18','[\"*\"]',NULL,NULL,'2026-08-07 22:50:47','2026-08-07 22:50:47'),(194,'App\\Models\\User',5,'impersonate-1786143047','8ae89255b24e83446711a0ac37be9f387aa599ce13d95506e7cdb3a80e6f9cbb','[\"*\"]','2026-08-07 22:50:47',NULL,'2026-08-07 22:50:47','2026-08-07 22:50:47'),(196,'App\\Models\\User',1,'auth-token','aa5a15025be30d759a8602d7df0b32b107c2e0c894e20722b7169f0e860e954c','[\"*\"]','2026-08-07 22:53:39',NULL,'2026-08-07 22:52:29','2026-08-07 22:53:39'),(198,'App\\Models\\User',28,'impersonate-1786143263','8f65ac22b2da367933ab09cc7af571f91f24babb2ed7f8c330896256b396bd9c','[\"*\"]','2026-08-07 22:54:24',NULL,'2026-08-07 22:54:23','2026-08-07 22:54:24'),(199,'App\\Models\\User',28,'impersonate-1786143279','e078e68ed37e030528a460c9f286078a6eed80329370f5117da22cf58da76b0e','[\"*\"]','2026-08-07 22:54:40',NULL,'2026-08-07 22:54:39','2026-08-07 22:54:40'),(200,'App\\Models\\User',14,'impersonate-1786143290','29c2442c514237e4d298e2c7ea8e2cd3a7f48353eaa08cc63034996a2b719bda','[\"*\"]','2026-08-07 22:55:08',NULL,'2026-08-07 22:54:50','2026-08-07 22:55:08'),(201,'App\\Models\\User',10,'impersonate-1786143316','80f0bc032cedee517c355c4299aaae13f185beef16492dfbfb315dcfb66ff57c','[\"*\"]','2026-08-07 22:55:23',NULL,'2026-08-07 22:55:16','2026-08-07 22:55:23'),(202,'App\\Models\\User',1,'auth-token','961e3d5a3729a5a987969d5e608384e812ca1375b86650b3eca9b9e9c3d7c5a6','[\"*\"]','2026-08-08 10:18:48',NULL,'2026-08-08 10:17:56','2026-08-08 10:18:48'),(206,'App\\Models\\User',9,'impersonate-1786282475','4d67cefcbfed661082d46e9493000adf27c5727caa27f217557e4a1983b5c195','[\"*\"]','2026-08-09 13:35:03',NULL,'2026-08-09 13:34:35','2026-08-09 13:35:03'),(207,'App\\Models\\User',6,'impersonate-1786282512','06c11134caeebf5105e38f8785fb6a31f3eb466dcfcf18f7ad9888e1862458b4','[\"*\"]','2026-08-09 13:35:29',NULL,'2026-08-09 13:35:12','2026-08-09 13:35:29'),(208,'App\\Models\\User',9,'impersonate-1786282537','42312da3b5e596ca46ed54d29be3818d355aedf5b8d5541967ebec7507897950','[\"*\"]','2026-08-09 13:35:54',NULL,'2026-08-09 13:35:37','2026-08-09 13:35:54'),(209,'App\\Models\\User',11,'impersonate-1786282577','72164f76080fafab13610acad8d4b57fbd27f3bae6045904d78cee1c1a162045','[\"*\"]','2026-08-09 13:36:29',NULL,'2026-08-09 13:36:17','2026-08-09 13:36:29'),(210,'App\\Models\\User',1,'auth-token','0e7aa4d84dcdfde2ca14ae015a89e55d5df2528ab8882881de9b37ec2c2d60e6','[\"*\"]','2026-08-16 16:26:41',NULL,'2026-08-10 12:38:17','2026-08-16 16:26:41'),(213,'App\\Models\\User',1,'diag','b3116838fc5ca41b5a02b95f2776216c3f143dd5edfb21e670eace0d233ca896','[\"*\"]',NULL,NULL,'2026-08-12 18:41:07','2026-08-12 18:41:07'),(214,'App\\Models\\User',1,'diag2','3a0c7a7cbe6f6bab7c8ed2d1d5a3e79dc826a6fdb2ab031d0425422f3facdef5','[\"*\"]',NULL,NULL,'2026-08-12 18:41:24','2026-08-12 18:41:24'),(215,'App\\Models\\User',1,'auth-token','c010098a4dcdec33581a1b67a0cc2d5328fb95c8cef2799f7f3562466fe4e042','[\"*\"]','2026-08-14 18:58:15',NULL,'2026-08-12 19:31:01','2026-08-14 18:58:15'),(219,'App\\Models\\User',1,'auth-token','61f528ccbcd4c2d294a591b33e60e5b158b3e39ca9f95b5ae5242d0585b19212','[\"*\"]','2026-08-14 08:58:29',NULL,'2026-08-14 08:57:28','2026-08-14 08:58:29'),(226,'App\\Models\\User',2,'auth-token','78fb17ada7a1e6ba34f0f2cd158dadb183aa2d10eb022ebb0421dba87327b232','[\"*\"]','2026-08-28 15:16:38',NULL,'2026-08-14 09:31:22','2026-08-28 15:16:38'),(235,'App\\Models\\User',1,'auth-token','7236ca9b05b93d64ac2bc4c0b9764004e0030acd35e203ed23af96b22c339194','[\"*\"]','2026-08-14 15:22:03',NULL,'2026-08-14 15:19:22','2026-08-14 15:22:03'),(238,'App\\Models\\User',3,'auth-token','ee94cc2dbf1b44c52ab830f0ab0e0bd1beb6ad4ae95e7f219da75a957305116a','[\"*\"]','2026-08-17 23:00:06',NULL,'2026-08-14 18:39:00','2026-08-17 23:00:06'),(240,'App\\Models\\User',30,'impersonate-1786733120','ef93603e38b9b3d6eee2ae336463fa30750d4a60705e58ea5ba50d315e0ebdea','[\"*\"]','2026-08-14 18:50:19',NULL,'2026-08-14 18:45:20','2026-08-14 18:50:19'),(241,'App\\Models\\User',7,'impersonate-1786733432','bf0f892c9f46ad7fe0358c6fc9effd647705ec97bcf832cf4acfabec0360c05b','[\"*\"]','2026-08-14 18:54:03',NULL,'2026-08-14 18:50:32','2026-08-14 18:54:03'),(242,'App\\Models\\User',30,'impersonate-1786733652','58567a1c1bca210378b0bbe0889faca1aefe64e130143320b2032679517ea589','[\"*\"]','2026-08-14 18:56:51',NULL,'2026-08-14 18:54:12','2026-08-14 18:56:51'),(243,'App\\Models\\User',7,'impersonate-1786733819','73e30f90797e759a2cc11185acf15fdbe547d6c931ecf331307d70f3a9262c40','[\"*\"]','2026-08-14 18:58:07',NULL,'2026-08-14 18:56:59','2026-08-14 18:58:07'),(245,'App\\Models\\User',1,'auth-token','8dc14f9b5a4f0c6e0a0a9afac0fa48b384b18f5bfe04b2632a4b47d0ad68ebbf','[\"*\"]','2026-08-14 20:23:59',NULL,'2026-08-14 18:59:41','2026-08-14 20:23:59'),(246,'App\\Models\\User',8,'impersonate-1786733990','d573090c894912543c4f0fa571ce63929224c90cd6162f8db67d3ab1c592f7ed','[\"*\"]','2026-08-14 19:00:01',NULL,'2026-08-14 18:59:50','2026-08-14 19:00:01'),(247,'App\\Models\\User',30,'impersonate-1786734008','fe602bbcac000c9c18cbbe4e28faa61c95fe25566561fbb4463e34c012608ee4','[\"*\"]','2026-08-14 19:09:52',NULL,'2026-08-14 19:00:08','2026-08-14 19:09:52'),(248,'App\\Models\\User',9,'impersonate-1786734607','b7e6703db7f52e2b37b500912e2b32db9d68f7aecaab7058095cc14000b175ee','[\"*\"]','2026-08-14 19:19:39',NULL,'2026-08-14 19:10:07','2026-08-14 19:19:39'),(249,'App\\Models\\User',30,'impersonate-1786735197','b6831567588579670732c1ab9d6718b7e24f56b571055daec0b05ad60c2dcad6','[\"*\"]','2026-08-14 19:32:16',NULL,'2026-08-14 19:19:57','2026-08-14 19:32:16'),(250,'App\\Models\\User',30,'impersonate-1786735948','15d9aef8a2eabb23015f0746318da5268cdd29ff0ff94a990798987a2a4243a7','[\"*\"]','2026-08-14 19:39:04',NULL,'2026-08-14 19:32:28','2026-08-14 19:39:04'),(251,'App\\Models\\User',1,'auth-token','1dd1bda21895687c0d146d6d5f9061ef6865b59a091db00cf7e46f4e34ed9867','[\"*\"]','2026-08-14 19:40:28',NULL,'2026-08-14 19:35:38','2026-08-14 19:40:28'),(252,'App\\Models\\User',7,'impersonate-1786736458','03b8ed8a0c34809c61abc53f611e43d7795483a7ad4c5cf741814854c9f803e0','[\"*\"]','2026-08-14 20:01:41',NULL,'2026-08-14 19:40:58','2026-08-14 20:01:41'),(254,'App\\Models\\User',7,'impersonate-1786738112','98acec5b5a9f695cfbf323c02b3ae9abfeb7c56e1ba772368beebcbfe7a9c47b','[\"*\"]','2026-08-14 20:14:45',NULL,'2026-08-14 20:08:32','2026-08-14 20:14:45'),(255,'App\\Models\\User',10,'impersonate-1786738493','7ee674a79b2af4bebdb400394a16c644413b16fb3abd9e0853f86c8aed842441','[\"*\"]','2026-08-14 20:16:30',NULL,'2026-08-14 20:14:53','2026-08-14 20:16:30'),(256,'App\\Models\\User',7,'impersonate-1786738612','fd9097dcf297f5311ce4584b0047112ab86c7ce143e70042b24fd3807caa4ac9','[\"*\"]','2026-08-14 20:19:54',NULL,'2026-08-14 20:16:52','2026-08-14 20:19:54'),(257,'App\\Models\\User',7,'impersonate-1786738817','6fd3d2b2c65e4c8212d805f32aaf349aba34b5a000781b806ed6fab45c7ddc34','[\"*\"]','2026-08-14 20:22:52',NULL,'2026-08-14 20:20:17','2026-08-14 20:22:52'),(258,'App\\Models\\User',9,'impersonate-1786738980','246cee590b0a182ed7dbe76f4b9a77ac99130a00068dab8dfc95510ebdcafbfb','[\"*\"]','2026-08-14 20:23:40',NULL,'2026-08-14 20:23:00','2026-08-14 20:23:40'),(259,'App\\Models\\User',7,'impersonate-1786739039','957f2412e0268b52e07ac6aba89d3a039f14e6eab044e7def395ea12814f7126','[\"*\"]','2026-08-14 20:34:55',NULL,'2026-08-14 20:23:59','2026-08-14 20:34:55'),(268,'App\\Models\\User',16,'auth-token','3c48ea1413573c3c4be321873ab746adbe19ac566b06f12550dea71dff0ead11','[\"*\"]','2026-08-24 21:53:18',NULL,'2026-08-20 13:54:35','2026-08-24 21:53:18'),(269,'App\\Models\\User',16,'auth-token','610df12a8968219ad67ff52110248ddef885125373533f153608cb898abe2590','[\"*\"]','2026-08-29 23:20:00',NULL,'2026-08-29 18:37:05','2026-08-29 23:20:00'),(270,'App\\Models\\User',16,'auth-token','03dad98feea72194e4213983e43caf6284e60c855d59d16193a3df503bd2e64b','[\"*\"]','2026-08-30 12:05:46',NULL,'2026-08-30 11:38:11','2026-08-30 12:05:46');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_analytics`
--

DROP TABLE IF EXISTS `product_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_analytics` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `total_sales` int NOT NULL DEFAULT '0',
  `total_revenue` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_refunds` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_profit` decimal(14,2) NOT NULL DEFAULT '0.00',
  `conversion_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `product_images_product_id_foreign` (`product_id`),
  CONSTRAINT `product_images_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
INSERT INTO `product_images` VALUES (14,11,'products/11/QT3j2ZZHJ2VrbSjNAAtt972PH6H5CgnppwhlahWX.webp',0),(15,11,'products/11/xPLdsUfBIIdHaxmUwEHzMsWdc736iv5whtmo7GDg.webp',0),(16,11,'products/11/vXTBXqge3mWmMv45r8FX1uMxDV3idChnRAaGUh68.webp',0),(20,13,'products/13/iSjcWbd4hxufgYeJOILftJSBg928WA7sCZXBHIbw.webp',0),(21,13,'products/13/x7hYiVrMZfVHE2MaLdvHVFjbEj4woUcopRn8XKCb.webp',0),(22,13,'products/13/gAz6Px9zZwTJdnXozwg1GYOojdeC1XD90nOQWVIm.webp',0),(23,14,'products/14/bcvt5iPU5FblOozTTFVNxnzzdNIeqLHjLAkaLHJ2.webp',0),(24,14,'products/14/qWiIqnPW9kr0J4anqbEENxICNcvDb5xoVfXVKemm.webp',0),(25,14,'products/14/uL7s6Tzd7051hdBwsSlW7Fzy2a5dEXodXfZ2BfE4.webp',0),(26,15,'products/15/tugJdXTrait3kmV4pVtpYZrTvpjqdAqjSWCR8ahR.webp',0),(27,15,'products/15/93dpQ9Q7HiIY1IVvoSziJjFtUVJHT2sDhEljveJ3.webp',4),(28,15,'products/15/GRFl8hMUgOZuOJBA0Edx1jTYDLfQdpLeKKguCkru.webp',3),(29,15,'products/15/DNeAu6YmudDzMdbYEq91Ngq0hPFXNZDZI72hbJ9r.webp',2),(30,15,'products/15/3exJMrxVUBug7jey6AriwvKt9gjBJEs50BQc9FPj.webp',1),(31,16,'products/16/W6LEzxQiMuR32IvUEYCJYZk1vXHogzPZBLg9U9UW.webp',0),(32,16,'products/16/RSwirmohx1zqEiXEEZTloDdhzz5Ox1U23q3VCyDC.webp',3),(33,16,'products/16/NTkKjxmdktRsQSKf6prYily0mCbC6LJD0I3i1nEL.webp',2),(34,16,'products/16/BDKxH99TxO9o6xuC8XuOKnWdOQ586VCPn0S493Y9.webp',1),(39,31,'products/31/tKJtQ43cBtGCcqC3EqTHeg248qAiSooiKZnNKsln.webp',0),(40,31,'products/31/AmuqbVVUXhB4IdfavdjHKHAbdcyP1eNan23ATnN2.webp',0),(41,31,'products/31/HTVjNqdUrSBKx3l5HN0OYs5pwsj3NCV52vilghcH.webp',0),(42,31,'products/31/hcOljaV5x99JKQ6yOPLHVm4dfXwpVHm1iIY5XYPv.webp',0),(43,31,'products/31/HhSSPCfpJsxVhHDUECyM4f1eN6VgPsdMXM1SersA.webp',0),(44,32,'products/32/SRYtC4X6XEu1r4AqwE7w3q2r4uLB4xMg0kiFPKHa.webp',0),(45,32,'products/32/NtMDY4GVit9TqiGlb4KS8rsKUHfzGUimHR3uexec.webp',1),(46,33,'products/33/HH9vU9HFzDOCfYhMkJsQpakLHl6rrTZpjZZMhJdE.webp',0),(47,34,'products/34/LzMhlnB7uLbYOjYyN1G88NdoVOt7nuvxzToJvyB4.webp',0),(48,34,'products/34/3IASOhU2mCRkmwIPqCB7MksJmxiO9BfBqy9BlOgz.webp',1),(49,35,'products/35/mF6eqwSx2QIJGNU1ZkOGMjXmUo3csrkTvDPVOKVp.webp',0),(50,35,'products/35/79KmXNCCae4YpNkodc88UFMhyqJBD3hjilRbXNAq.webp',1),(51,35,'products/35/WFS81XKKrfJvwbcygylMbyGwcjPXYJn4XtZSoRgX.webp',2),(52,35,'products/35/cQmT8HS2Mtmgcx91Uqo1VnFb30BFwoLFCxu6quOX.webp',3),(53,35,'products/35/oSLFTVGj9YKDyvxCBJ3xFdyzp1iDsCldPKPntU3v.webp',4),(54,33,'products/33/aFrbFFUDalPOhRDtCXcRUw7GMWPvxfNJKKWqJRUa.webp',4),(55,33,'products/33/VfAoug7zm33xAvUntB5PY7zLEdUfK3fLjUdLW2Eg.webp',3),(56,33,'products/33/UQt01z9nTMGMAPL21HiuwjaNuQA9WEXsRtP3eLTB.webp',2),(57,33,'products/33/BWuykFGCHjodUlbbRvClhn0y1oFTa0e8dT20fJSr.webp',1),(58,36,'products/36/yfQmgZY8jwNmittUFIJAD8KSzsKaijQcnln3uVmx.webp',0),(59,36,'products/36/ZQsyFyDm46BkxLqMp2QBtAoj2gtSmUg3MfuIjky0.webp',1),(60,37,'products/37/p921hTWm2EgOSqfSG1dWJrGwru0mdO48dJwVnTWx.webp',0),(61,37,'products/37/Oce8SPDQBh2vFeymaKivhwox3hof2c3y4W8KwGDW.webp',1),(62,37,'products/37/w0mlYMkUKfUbbYZncCBDUPFaTCMeSmGcY7E04vRS.webp',2),(63,38,'products/38/d5eKWdGHGCKbwcmoet0RTuoFiv0SlWqVvErZvNuN.webp',0),(64,38,'products/38/rCOC6XErxcrW1dk9qKn0jFaLyadk7tlT9fJIfRwT.webp',1),(133,63,'products/63/Fn5Ms2MWqozFlPcdTZsAW8hKDKJbtXvfkntLo47A.webp',0),(134,63,'products/63/sQbssPu0DI8A5poC32JWJIW21Wth6YMGGKTdy8cT.webp',1),(135,63,'products/63/i26jrelHS4dw5b9HN07qQgoOXOtgCeF87XcmZ50e.webp',2),(136,63,'products/63/srVCe0YMkXANQnh0W6clcje4lkFJcNKTw2aDniFx.webp',3),(137,63,'products/63/79bXiOSQN8u5F5cbj0x2Fm9DmsUAhUGWVYUuQLmo.webp',4),(138,64,'products/64/p1mzvi7igYC7g1qeOylbG6iBKkthFfnsfAPBF0dn.webp',0),(139,64,'products/64/Y8OyeFSC9qz5ow7MVv6wymm92ky3yb00ylVSW8xx.webp',1),(140,64,'products/64/74aVkrC80OQoMnkTj1c5Wqju0wLAqp0E6LbZRW6L.webp',2),(141,64,'products/64/KV8TryGUgQNhTSjUfzFsAlfdqcCJLmClbET8y9P6.webp',3),(142,64,'products/64/2J3vycwhdGRDErb5FVkJD1NFslSo18ff9nm6skbj.webp',4),(143,65,'products/65/wnqATR6AG4cz7r97UAf26RZn80SeAw4yf1xuSwYS.webp',1),(144,65,'products/65/41jdeji7ajqpr9s01yxy5k0tgrR6e9BCwAZBx00S.webp',2),(145,65,'products/65/wLBgDQefBgaidQ1QgUHWK12N80aRptyRSgYkvRBG.webp',3),(146,65,'products/65/W37el0yy38JwSwLjREeVJ5Wxq0z8UTSwJxaQQH2O.webp',0),(147,66,'products/66/iK9vAqkBwxoqx2MforcsDLLJQzm5HRW8GxLCnuvY.webp',0),(148,66,'products/66/H5SxYV1CmIX4uC1xo4VuvMhPlIj4BmPs7LoMyzDP.webp',0),(149,66,'products/66/hKK7chmRfgF6F7uFcd6qlpcVxfWaEP1zeVXx4j0E.webp',0),(150,66,'products/66/UsbWtNNLyJUdZhQ1mfXfc6RSzUWEBYC5Mz4T8lhJ.webp',0),(151,67,'products/67/AHs5bbPASql7IlUKiZeHpMKG2n7AuHRQavJI97yO.webp',0),(152,67,'products/67/meA8JRebStnzibIKCvTidbez5e9z4ewb1TNTtWlF.webp',1),(153,67,'products/67/39mVdG8dldw504Xujbr7xVIDUZ8r301mLpcvREvT.webp',2),(154,67,'products/67/GL1dkAWsmQQpjyg28M0wMbxGAgJaGfrGlbFs0nCS.webp',3),(155,67,'products/67/RWInxZ2LCQNOESgSUcRPOLOIc4RpdEsd1Y2Q50Gp.webp',4),(156,67,'products/67/yYXluDzyBaauxT12yFwMJ8aNo61xOsIyoWI24D5v.webp',5),(157,67,'products/67/bgad98Qzs0IWXdmgBRmopURSeD3kXeZQm8YCNXna.webp',6),(158,67,'products/67/oOefDb6Zn2ypjyusIyWOWwKj7y5yoaaA8wx4876y.webp',7),(159,68,'products/68/2UjxrjdqW9WkCvQsOoTckGcH3rmKqfXrujPUWO69.webp',0),(160,68,'products/68/A8xxEPNwUpm5e2t0Qtuynbm7xUpXoFrAA3LRlllx.webp',0),(161,68,'products/68/W7XeP7SbIJtjEnDJRW2mD77R11qTUpovvIBd0CJM.webp',0),(162,68,'products/68/Y0gplnkjFrCvXMLP0a6baZKcUQmWSWeLVykRKlkJ.webp',0),(163,69,'products/69/ac6tUjd7JW9jA7t6ljtWFct55uIIVMQ22w90qjeM.webp',0),(164,69,'products/69/n8DwB32VkzP184YDmLTdOifaGqL8axZdzx7FLkw8.webp',1),(165,69,'products/69/xQ2vKRMMYV9gOxwnrI1lAksKoWmCUQmpEq2gYpEw.webp',2),(166,69,'products/69/vq14Tm8805jCZN5H0HINNCeRMmGU1zWwaId1CP8O.webp',3),(167,70,'products/70/AmvrxefGqG4MXUfi6HzPGyuYwXoFSASrP19Rez0u.webp',0),(168,70,'products/70/TVW0mYrV5GHC6QPnbRj6mTtiTrGshDfH2nrc4UEL.webp',1),(169,70,'products/70/2U6j8Xj448jP4XWIhQqO1FKOxdFdScu3y8c5H4Wl.webp',2),(170,70,'products/70/VShJBfWTNlYXcqbwR1EqN8FjyzLu6Kj61UcK1vHL.webp',3),(171,71,'products/71/K3wYpQGgZyAsu5G74mY6ZA6QbkiLANq8rFXeAXcT.webp',0),(172,71,'products/71/E4w5UvEwZWPIombqhO1z9GnIB0nr73C1bEUMwdlJ.webp',1),(173,71,'products/71/lx0rCRYIaXqRQMGnQG90ofYBYggxjoR1Aa8Cd5NB.webp',2),(174,71,'products/71/oL0Y6ggNajEjr5MTlSqR1DYE6jJ4iIWggKlbRAnW.webp',3),(175,71,'products/71/Wyf3JiYwJYR93hGfOiJa69o1pHNk3xvlGm7NNhnO.webp',4),(176,72,'products/72/Yw8jKBq3hgWraCiTYyi2zMSvv6BXGgxLIt2c2cc2.webp',0),(177,72,'products/72/nINGRSgrPYnZLfgHu92VpaHvtdbQSwKa5n0VqMEU.webp',1),(178,72,'products/72/OaJA7afPbXVJBPU7N9xiq2WjodlBoFhkm1hX11Ce.webp',2),(179,72,'products/72/7VoMqJsdgzs1vhNVUkl3tGh55hjFHbQMVTvnMzZU.webp',3),(180,73,'products/73/IvORKPMAOQAYsq6Equ3Y9xEJifdIs5SGTCqNGzrZ.webp',0),(181,73,'products/73/ApK46K1r2PvIql8GZmi7gu09kp3XtEHLLssR0edZ.webp',1),(182,73,'products/73/GL8ceL8KeeJWrdX3vfV1z2LkiU84Hh0z8jCVQuVD.webp',2),(183,73,'products/73/I5X7nCV5PATPgsF5ESHx2R4803AhPkC18qRceLdr.webp',3),(184,73,'products/73/AITwABpO446gwh1x0nftcxN9AGn0u2NmQyG0cTDl.webp',4),(185,73,'products/73/j301BCJsJ50MwI28IiHIMceS1WEcttcPKTcQH1co.webp',5),(186,74,'products/74/HpMTncsQpmR63r4o9C0PCabmsmaUzRN13eoxxAbs.webp',0),(187,74,'products/74/VIUxVbupUi88Od7MCO1vhAbOkHiiDIOVURjYe0e4.webp',1),(188,74,'products/74/wBN8UYBMu7jAlAx0AfRl7FyGj1D46w94tOkuPeQG.webp',2),(189,74,'products/74/VZ6jNKx3h7x0qDMbJhkXvWg7TwiPgxfRaHfjb8tG.webp',3),(190,74,'products/74/ZmKgT617KWMqTVxva5CmEdzcCdi3DAmOHcoz0eGD.webp',4),(191,75,'products/75/S4KNlawTALWNX2IfMwyUCBuQGw42BZM8D5qebJg7.webp',0),(192,75,'products/75/8tVtOHJYTw43YVedfLK5Rta0ud2vMZPbJ3vXyls7.webp',1),(193,75,'products/75/OEaUfgRBVGB8R4ngoSmjdnaUhtXhNDXyqmjJxljF.webp',2),(194,75,'products/75/54X1P0QjATg6QMenaNB63tIJxK5mSLNCW6pl8bWt.webp',3),(195,75,'products/75/w1Jt80WCIVEFucUei0kzipCezlLMmcccDKPqmJ5N.webp',4),(196,76,'products/76/ikZ4k9vR5FRddPBJ93fQgCDeatLJNh2d6KmTfgI8.webp',0),(197,76,'products/76/wcH5EbVbYAk79B58SNW3Dh0hsZrILMhiiCOTY6vB.webp',1),(198,76,'products/76/1qjzyHjm1GaQ0qONJHSCv7s9lmqNz2OxHGZdg2zb.webp',2),(199,76,'products/76/iThpoUdJKALEJkowmTMvzEoej8xOjvRJliKudDVI.webp',3),(201,78,'products/78/ReQDTgnsXHAuA1eSDUFUxdBLFdzafvEpZP5UhMrs.webp',0),(202,78,'products/78/rYY271OKaAbEPvRdxJ2GCKEytlyaRncsfYdWlT6U.webp',1),(203,78,'products/78/NKgbPGtsEiKvQ0s1DSsyhdN2k3INjBbuXQdrhIQ4.webp',2),(204,78,'products/78/dKeYwSSpLgwTYdYrqu13CqKEFOR0RnLFOCWnBEZC.webp',3),(205,78,'products/78/SIgHZJo080tvOC6LRVviJWUdVQCznLJGXFPr6zrV.webp',4),(206,79,'products/79/T7AGBBKbMj6WYKzgA92Uq3SvyJSPnsDvLDHM999B.webp',0),(207,79,'products/79/sBIhIpP6bxk1LWRztt3aUAuB6ZZYR5ym3kLXYuuc.webp',1),(208,79,'products/79/NdZjg3cYRlk9M3qr63YQi5DMlB3xcfuOUsAav6Mp.webp',2),(209,79,'products/79/VyHrmlhe0RpKOcm8F4OQO3kdXkQlXdSBa4j0lpB8.webp',3),(210,79,'products/79/O77JdIKw3duOi6KwmIr5PVkkw66KWYzGQrTifzzC.webp',4),(211,79,'products/79/68ftI7CAIrSK6oY9V8CgtrNkOHUsYO7AOwHUDz9y.webp',5),(212,80,'products/80/vk3qtzrteL5iiBdy47wS1jZPw9Nr5pZAH9qTHwda.webp',0),(213,80,'products/80/UbjgQwxOMwk2PlZYShUfYp7NKXQRVHC75DLO2Z2b.webp',1),(214,80,'products/80/QVTcTCFFP3Kmf4Qzx5p82Mp6eSitWz52HBuBKVAz.webp',2),(215,80,'products/80/BvCe2ddYihMObnRmBqVACs5Iwb9XoeiXgzUjiWRo.webp',3),(216,80,'products/80/nH5OLFFSfBgMSceQrWL8u84DwCxoyj4F6z4Mvqy7.webp',4),(217,80,'products/80/ZqxMyEt2WnIgMjkdQW9xbsK5cFA1THobplm6k07W.webp',5),(218,81,'products/81/SmbS02WFkNgkK782wFRoqgzbEd3fZjFZ0ImJb1Ve.webp',0),(219,81,'products/81/5r7U7tMRSHVlGTjroxwy0CbPWVV3Sf46Xf52EQta.webp',1),(220,81,'products/81/uwDPnsqT9Zwo97e6Kcx7JHNHxhfo1fJIusmPXqvt.webp',2),(221,81,'products/81/WTBdzSaowubWqNhHdeNicCC5Npq2PGNi8uRkZn7N.webp',3),(222,81,'products/81/Tt65EFbRXG7AzgtOcjuMVCbHCBUZn7YAmztPEsqA.webp',4),(223,81,'products/81/NIutaOXYsPaQTyhNNW5sNzLCnm3zNXbC6zZfSzqI.webp',5),(224,82,'products/82/YW7XtkYwUUc7Tt0hMsjxsKkeg1jCXrU9bA5rWkfM.webp',0),(225,82,'products/82/vtKt7ckLZNDWUlC6EXJUKmv5jHqnWNrv2OKJZPky.webp',1),(226,82,'products/82/XdIhFiZyXwmw1kTWLP1PoGgN0i2CjKxiqHhvpkH0.webp',2),(227,82,'products/82/BEvDZuDAjzW1SDCKFNckhmfagssy0ErWI3a7kWor.webp',3),(228,82,'products/82/DclVYrnESVKl7IqmhUZGdqWrXYLHhV7DIdkUjaCt.webp',4);
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variant_images`
--

DROP TABLE IF EXISTS `product_variant_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variant_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `variant_id` bigint unsigned NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `product_variant_images_variant_id_foreign` (`variant_id`),
  CONSTRAINT `product_variant_images_variant_id_foreign` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variant_images`
--

LOCK TABLES `product_variant_images` WRITE;
/*!40000 ALTER TABLE `product_variant_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variant_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price_egp` decimal(12,2) NOT NULL DEFAULT '0.00',
  `price_usd` decimal(12,2) NOT NULL DEFAULT '0.00',
  `fake_price_egp` decimal(12,2) DEFAULT NULL,
  `fake_price_usd` decimal(12,2) DEFAULT NULL,
  `star_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `sold_count` int NOT NULL DEFAULT '0',
  `cost` decimal(12,2) DEFAULT NULL,
  `sku` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stox_product_id` bigint unsigned DEFAULT NULL,
  `material` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacturing_method` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stock_quantity` int DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_variants_product_id_foreign` (`product_id`),
  CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (3,13,'Acrylic',NULL,2499.90,50.21,NULL,NULL,4.10,105,2000.00,'FDT0002A',19322,'acrylic','cnc',NULL,1,0,'2026-07-21 01:21:04','2026-08-25 11:40:46');
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `designer_id` bigint unsigned DEFAULT NULL,
  `main_category_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `product_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price_egp` decimal(12,2) NOT NULL DEFAULT '0.00',
  `price_usd` decimal(12,2) NOT NULL DEFAULT '0.00',
  `fake_price_egp` decimal(12,2) DEFAULT NULL,
  `fake_price_usd` decimal(12,2) DEFAULT NULL,
  `star_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `sold_count` int NOT NULL DEFAULT '0',
  `platform_commission_egp` decimal(12,2) DEFAULT NULL,
  `platform_commission_usd` decimal(12,2) DEFAULT NULL,
  `designer_price_egp` decimal(12,2) DEFAULT NULL,
  `designer_price_usd` decimal(12,2) DEFAULT NULL,
  `tester_suggested_price_egp` decimal(12,2) DEFAULT NULL,
  `tester_suggested_price_usd` decimal(12,2) DEFAULT NULL,
  `tester_comment` text COLLATE utf8mb4_unicode_ci,
  `tested_by` bigint unsigned DEFAULT NULL,
  `tested_at` timestamp NULL DEFAULT NULL,
  `cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `publish_date` timestamp NULL DEFAULT NULL,
  `country_availability` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `material` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacturing_method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type_sample` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tags` json DEFAULT NULL,
  `design_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ticket_id` bigint unsigned DEFAULT NULL,
  `stox_product_id` bigint unsigned DEFAULT NULL,
  `lemonsqueezy_product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lemonsqueezy_variant_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  KEY `products_designer_id_index` (`designer_id`),
  KEY `products_main_category_id_foreign` (`main_category_id`),
  CONSTRAINT `products_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_main_category_id_foreign` FOREIGN KEY (`main_category_id`) REFERENCES `main_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (11,NULL,4,'Monstera Shadows','Monstera-Shadows','- Add a touch of modern tropical elegance to your space with this stunning three-panel wall art triptych.\n- Premium Craftsmanship: Expertly crafted from two distinct layers of wood, creating a beautiful 3D relief effect that brings depth and organic texture to your walls.\n- Dimensions: 110 x 60 cm (total coverage), making it the perfect statement size for living rooms, bedrooms, or office entryways.\n- The Design: Featuring the iconic split-leaf Monstera, the piece beautifully contrasts a rich matte-black base layer with a warm, natural-toned wooden top frame.','physical',1199.00,23.57,2000.00,30.00,4.10,293,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,600.00,'published','2026-07-20 00:00:00',NULL,'wood','cnc','Tableau',NULL,NULL,NULL,17474,NULL,NULL,'2026-07-21 01:12:40','2026-08-25 11:40:46'),(13,NULL,4,'Monstera Deliciosa','Harmony','- Bring spiritual peace and breathtaking artistry into your home with this elegant two-panel Islamic wall art diptych.\n- Intricate Arabesque Background: The golden inscriptions are set against a dramatic, laser-cut black background featuring a complex Islamic geometric lattice pattern, offering a magnificent contrast.\n- Dimensions: 60 x 100 cm, perfectly proportioned to serve as a serene focal point for your living room, entryway, or dedicated prayer space.','physical',999.00,19.64,1500.00,NULL,4.20,348,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,500.00,'published','2026-07-20 00:00:00',NULL,'wood','laser_cut','Tableau',NULL,NULL,NULL,17475,NULL,NULL,'2026-07-21 01:19:37','2026-08-25 11:40:46'),(14,NULL,4,'Global Layers','Global-Layers','- Transform any wall into a breathtaking masterpiece with this premium, multi-layered 3D wooden world map.\n- Multi-Dimensional Depth: Meticulously crafted from multiple layers of high-quality wood, creating an exceptional 3D topographical effect that brings the globe to life.\n- Grand Statement Size: Available in a majestic 200 x 110 cm dimension, making it the ultimate focal point for luxury living rooms, corporate offices, or travel-inspired spaces','physical',4999.00,98.28,6000.00,110.00,4.70,483,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,3500.00,'published','2026-07-20 00:00:00',NULL,'wood','cnc','World Map',NULL,NULL,NULL,17476,NULL,NULL,'2026-07-21 01:25:04','2026-08-25 11:40:46'),(15,NULL,4,'Chrono Prism','Chrono-Prism','- Elevate your home or workspace with this avant-garde, luxury desk clock—a true sculptural masterpiece that blurs the line between functional timepiece and modern art.\n- Versatile Luxury: A stunning statement piece that effortlessly adapts to its surroundings—whether catching the warm glow of a bedside lamp on a wooden nightstand, sitting elegantly among perfumes on a marble vanity, or standing bold on an industrial concrete desk.\n- Crystalline Outer Shell: Encased in an ultra-clear, heavy-gauge geometric acrylic frame that beautifully refracts ambient light along its polished, crystalline edges.','physical',3999.00,78.62,4500.00,100.00,4.40,43,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2800.00,'published','2026-07-20 00:00:00',NULL,'acrylic','cnc','Table Clock',NULL,NULL,NULL,17477,NULL,NULL,'2026-07-21 01:27:41','2026-08-25 11:40:46'),(16,NULL,4,'Timber River','timber-river','- Bring the tranquil rhythm of nature into your home with this handcrafted 3D wooden wall clock.\n- Bold Readability: Outfitted with raised, 3D matte-black Arabic numerals and sleek matching hands, creating a striking contrast that catches the eye from any angle.\n- Dimensions: 40 x 40 cm, a versatile and balanced size that effortlessly elevates mid-century credenzas, hallway consoles, or living room walls.','physical',550.00,10.76,900.00,15.00,4.40,482,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,'published','2026-07-20 00:00:00',NULL,'wood','cnc','Clock',NULL,NULL,NULL,17473,NULL,NULL,'2026-07-21 01:33:31','2026-08-25 11:40:46'),(31,NULL,4,'Celestial Balance','Celestial-Balance','- Embrace the timeless harmony of day and night with this captivating circular 3D wooden wall art piece.\r\n- Beautifully splits into two hemispheres—the upper half features a radiant sun, while the lower half showcases a serene crescent moon nestled among twinkling stars.\r\n- Dimensions: 40 x 40 cm, featuring a sleek round frame with a central wooden divider bar.','physical',550.00,10.72,850.00,15.00,4.30,275,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,17537,NULL,NULL,'2026-07-24 18:59:03','2026-08-25 11:40:46'),(32,NULL,4,'Family Roots','Family-Roots','- Turn your cherished family memories into a living piece of art with this grand, multi-piece wooden family tree photo collage.\r\n- Interactive Memory Display: Features an intricate, sprawling wooden tree design with multiple integrated picture frames designed to showcase your favorite moments with loved ones.\r\n- Detailed Accents: Comes with decorative laser-cut wooden blossoms, flying birds, and a cozy nest, adding depth and narrative to your wall.','physical',2999.00,58.96,5000.00,65.00,4.00,387,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1500.00,'published',NULL,NULL,'wood_acrylic','laser_cut','Personal Tableau',NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-24 19:11:48','2026-08-25 11:40:46'),(33,NULL,4,'Islamic Trio','islamicIslamic-Trio','- Each medallion is encircled by a delicately laser-cut Islamic geometric lattice pattern, adding an airy, dimensional texture to your wall.\r\n- Dimensions: 60 x 60 cm (per panel), offering versatile arrangement options—display them side-by-side or in a dynamic triangular grouping to elevate living rooms, entryways, or prayer spaces.','physical',599.00,11.78,1000.00,17.00,4.20,387,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,'published',NULL,NULL,'wood','laser_cut','Tableau',NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-27 23:29:18','2026-08-25 11:40:46'),(34,4,3,'Islamic Trio Digital','islamic-trio-digital','- Dimensions: 60 x 60 cm (per panel), offering versatile arrangement options—display them side-by-side or in a dynamic triangular grouping to elevate living rooms, entryways, or prayer spaces.','digital',499.00,9.81,800.00,NULL,4.70,365,75.00,0.00,425.00,0.00,NULL,NULL,NULL,3,'2026-07-28 00:30:50',0.00,'published','2026-07-28 00:28:05',NULL,'wood','CNC',NULL,NULL,'products/34/design/gEvKINjszpMFMers6aUilFuUwoO58vLWTH7TIHmr.pdf',NULL,NULL,'1286557','2012793','2026-07-28 00:28:05','2026-08-25 11:40:46'),(35,NULL,4,'Kaaba Sanctuary','Kaaba-Sanctuary','- Bring the sacred presence and tranquil majesty of the Holy Kaaba into your home with this striking 3D-effect wooden wall art.\r\n- Crafted from precision laser-cut matte black wood combined with layered brick textures and draped curtain contours for an opulent, architectural finish.\r\n- Dimensions: 60 x 60 cm, serving as a deeply spiritual and sophisticated focal point for modern living rooms, entryways, or personal prayer spaces.','physical',799.00,15.71,1200.00,20.00,4.40,451,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,'published',NULL,NULL,'wood','cnc',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-28 01:02:34','2026-08-25 11:40:46'),(36,4,3,'Kaaba Sanctuary Digital','kaaba-sanctuary-digital','- Dimensions: 60 x 60 cm, serving as a deeply spiritual and sophisticated focal point for modern living rooms, entryways, or personal prayer spaces.','digital',999.00,19.64,1500.00,25.00,4.90,300,150.00,0.00,850.00,0.00,NULL,NULL,NULL,3,'2026-07-28 01:15:39',0.00,'published','2026-07-28 01:14:50',NULL,'wood','CNC',NULL,'[\"Islamic\"]','products/36/design/olFZxNRraHYw16BHek8MQOOsDpaUXUPuEVEQHEQK.pdf',NULL,NULL,'1286557','2012793','2026-07-28 01:14:50','2026-08-25 11:40:46'),(37,NULL,4,'Four Quls Harmony','Four-Quls-Harmony','- Dimensions: 60 x 60 cm, creating a balanced and powerful focal point for living rooms, hallways, or personal prayer spaces.\r\n- Modern Heritage: The ancient geometric Kufic style offers a clean, contemporary aesthetic that effortlessly bridges traditional Islamic art with minimalist modern interior design.\r\n- Enfold your home in spiritual protection and architectural elegance with this breathtaking Square Kufic wall art set.','physical',999.00,19.64,1500.00,24.00,4.50,145,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-28 01:29:05','2026-08-25 11:40:46'),(38,4,3,'Four Quls Harmony Digital','four-quls-harmony-digital','- Dimensions: 60 x 60 cm, creating a balanced and powerful focal point for living rooms, hallways, or personal prayer spaces.','digital',800.00,15.73,1400.00,25.00,4.70,52,150.00,0.00,850.00,0.00,NULL,NULL,NULL,3,'2026-07-28 01:37:39',0.00,'published','2026-07-28 01:35:24',NULL,'wood','CNC',NULL,NULL,'products/38/design/96SKYhfEgT0xtdwxNo0xPYx7yNrNDwmQZNrdvjkG.pdf',NULL,NULL,'1286557','2012793','2026-07-28 01:35:24','2026-08-25 11:40:46'),(63,NULL,4,'Sunrise Ridge','Sunrise-Ridge','- Infuse your home with the calming warmth of early dawn through this sleek, vertical 3D wooden landscape tableau.\r\n- Crafted with layered wooden paneling, creating a rich contrast between natural warm wood tones and deep, matte-black mountain silhouettes encased in a matching black frame.\r\n- Dimensions: 60 x 20 cm, a slender vertical footprint specially designed to illuminate narrow wall spaces, columns, entryways, or compact office nooks.','physical',699.00,13.74,1200.00,17.00,4.20,198,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,400.00,'published',NULL,NULL,'wood','laser_cut','Tableau',NULL,NULL,NULL,19317,NULL,NULL,'2026-08-08 10:38:52','2026-08-25 11:40:46'),(64,NULL,4,'Alpine Horizon','Alpine-Horizon','- Immerse your space in the tranquil grandeur of the wilderness with this multi-layered wooden mountain landscape.\r\n- Showcases a stunning contrast of warm cedar-toned sky grain, crisp light birch mountain faces, and deep slate-grey pine silhouettes.\r\n- Dimensions: 60 x 40 cm, ideal for creating a rustic yet modern atmosphere in living rooms, executive offices, or cozy reading corners.','physical',1199.00,23.57,2000.00,30.00,4.80,301,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,700.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19318,NULL,NULL,'2026-08-08 10:51:25','2026-08-25 11:40:46'),(65,NULL,4,'Tribal Symmetry','Tribal-Symmetry','- Elevate your space with the rhythmic charm and organic texture of this 3-piece Southwestern geometric wall art triptych.\r\n- Features three distinct, laser-cut panels showcasing intricate tribal diamond motifs inspired by Southwestern and ethnic art.\r\n- Dimensions: 60 x 60 cm total display coverage (60 x 15 cm per panel).','physical',899.00,17.67,1400.00,22.00,4.60,444,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,450.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19320,NULL,NULL,'2026-08-08 10:59:14','2026-08-25 11:40:46'),(66,NULL,4,'Fluid Contours','Fluid-Contours','- Bring refined Scandinavian minimalism and Japandi elegance to your walls with this abstract 3-piece wooden triptych.\r\n- Features smooth, flowing organic shapes that create a calm, artistic visual rhythm across all three panels.\r\n- Dimensions: 40 x 90 cm total display coverage (40 x 26 cm per panel), making it a versatile choice above bedroom headboards, hallway consoles, or sofa backdrops.','physical',999.00,19.64,1500.00,25.00,4.70,233,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,600.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-08 11:08:52','2026-08-25 11:40:46'),(67,NULL,4,'Botanical Rhythm','Botanical-Rhythm','- Bring mid-century artistic flair and organic elegance to your walls with this 3-piece abstract botanical triptych.\r\n- Features fluid, cutout-style floral silhouettes that capture the essence of modern nature and mid-century art.\r\n- Dimensions: 40 x 90 cm total display coverage (40 x 26 cm per panel), making it a versatile arrangement above bed headboards, sofa backdrops, or cozy reading corners.','physical',1199.00,23.57,1600.00,30.00,4.60,432,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,600.00,'published',NULL,NULL,NULL,NULL,'Tableau',NULL,NULL,NULL,19323,NULL,NULL,'2026-08-08 11:28:42','2026-08-25 11:40:46'),(68,NULL,4,'Rhythmic Motion','Rhythmic-Motion','- Bring energy, expression, and fluid movement to your walls with this captivating abstract figurative wooden tableau.\r\n- Showcases fluid, intertwined human silhouettes in motion, evoking classic modernist dance and expressionist art forms.\r\n- Dimensions: 60 x 30 cm, a slender vertical format that serves as an artistic focal point for galleries, living spaces, or creative studios.','physical',599.00,11.78,900.00,15.00,4.90,111,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19325,NULL,NULL,'2026-08-08 11:39:27','2026-08-25 11:40:46'),(69,NULL,4,'Monstera Canopy','Monstera-Canopy','- Bring the fresh, vibrant spirit of the tropics into your living space with this exquisite 3-piece Monstera wall art triptych.\r\n- Features laser-cut Monstera leaf silhouettes with highlighted, light-toned inner veins that pop against a warm natural wood background.\r\n- Dimensions: 40 x 90 cm total display coverage (40 x 26 cm per panel), making it a perfect statement arrangement over bed headboards, sofas, or entry consoles.','physical',1199.00,23.57,1600.00,30.00,4.10,233,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,600.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19326,NULL,NULL,'2026-08-08 11:47:24','2026-08-25 11:40:46'),(70,NULL,4,'Desert Botanicals','Desert-Botanicals','- Bring the playful, resilient charm of desert nature into your home with this delightful 4-piece potted succulent wall art set.\r\n- Features four distinct laser-cut potted cacti and succulents whose leaves and stems playfully extend beyond their rectangular borders for a lively, dimensional effect.\r\n- Dimensions: 40 x 95 cm total display coverage across all 4 pieces, perfect for horizontal alignment over kitchen counters, dining tables, hallways, or coffee corners.','physical',999.00,19.64,1400.00,25.00,4.30,424,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,700.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19327,NULL,NULL,'2026-08-08 11:53:58','2026-08-25 11:40:46'),(71,NULL,4,'Abstract Equilibrium','Abstract-Equilibrium','- Bring refined Scandinavian minimalism and Japandi harmony to your walls with this abstract 2-piece wooden diptych.\r\n- Features a duo of abstract compositions—one panel displaying bold vertical architectural lines, while the other showcases stacked, balanced semicircular forms.\r\n- Dimensions: 40 x 65 cm total display coverage across both panels (2-piece set), ideal for hallway consoles, office walls, or living room accents.','physical',799.00,15.71,1200.00,22.00,4.40,461,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,450.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19328,NULL,NULL,'2026-08-08 11:59:19','2026-08-25 11:40:46'),(72,NULL,4,'Geometric Plumes','Geometric-Plumes','- Add a touch of modern bohemian sophistication and light, organic harmony to your space with this 3-piece geometric feather wall triptych.\r\n- Features three distinct feather motifs meticulously designed with sharp geometric facets, linear patterns, and intricate laser-cut cutouts.\r\n- Dimensions: 60 x 110 cm total display coverage (60 x 30 cm per panel), creating a grand statement piece above sofa backdrops, bed headboards, or dining room walls.','physical',999.00,19.64,1500.00,25.00,4.20,453,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,650.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19329,NULL,NULL,'2026-08-08 12:04:58','2026-08-25 11:40:46'),(73,NULL,4,'Eternal Embrace','Eternal-Embrace','- Bring emotional warmth, human connection, and modern artistic soul to your walls with this abstract 2-piece wooden diptych.\r\n- Features two deeply symbolic panels celebrating togetherness—one depicting reaching hands crossing contrasting tones, and the other showcasing a stylized, textured embrace.\r\n- Dimensions: 40 x 65 cm total display coverage across both panels (40 x 26 cm per panel), serving as a heartwarming focal point above bedroom headboards, living room consoles, or cozy lounge areas.','physical',899.00,17.67,1500.00,25.00,4.80,468,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,650.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19330,NULL,NULL,'2026-08-08 12:10:12','2026-08-25 11:40:46'),(74,NULL,4,'Nordic Chevron','Nordic-Chevron','- Elevate your home with a striking balance of geometric structure and Scandinavian warmth through this 3-piece wooden wall art arrangement.\r\n- Features a prominent central square panel flanked by two sleek diamond-shaped accent panels for a dynamic, balanced layout.\r\n- Dimensions: 40 x 100 cm total display coverage across all 3 panels, making it an eye-catching focal point above entryway benches, consoles, or living room seating.','physical',999.00,19.64,1500.00,25.00,4.60,307,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,600.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19331,NULL,NULL,'2026-08-08 12:14:57','2026-08-25 11:40:46'),(75,NULL,4,'Savannah Horizon','Savannah-Horizon','- Bring the breathtaking magic and warm glow of an African safari sunset into your home with this stunning horizontal wooden silhouette tableau.\r\n- Features intricate laser-cut silhouettes of giraffes and iconic acacia trees set against a radiant, golden-yellow setting sun.\r\n- Dimensions: 80 x 30 cm, a panoramic horizontal format designed to crown living room sofas, bed headboards, or hallway consoles.','physical',899.00,17.67,1300.00,25.00,4.60,130,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19332,NULL,NULL,'2026-08-08 12:19:54','2026-08-25 11:40:46'),(76,NULL,4,'Tiger\'s Emerald Gaze','Tiger\'s-Emerald-Gaze','- Capture the fierce beauty, intensity, and regal power of the wild with this extraordinary multi-layered 3D wooden tiger face tableau.\r\n- Features a dramatic close-up portrait of a tiger, showcasing precision laser-cut stripe patterns and layered facial contours.\r\n- Dimensions: 80 x 40 cm, a striking horizontal statement piece ideal for executive offices, modern living rooms, or gaming setups.','physical',1100.00,21.63,1800.00,30.00,4.30,208,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,700.00,'published',NULL,NULL,'wood','cnc','Tableau',NULL,NULL,NULL,19333,NULL,NULL,'2026-08-08 12:27:41','2026-08-25 11:40:46'),(78,1,3,'Sunrise Ridge Digital','sunrise-ridge-digital','- Infuse your home with the calming warmth of early dawn through this sleek, vertical 3D wooden landscape tableau.\r\n- Crafted with layered wooden paneling, creating a rich contrast between natural warm wood tones and deep, matte-black mountain silhouettes encased in a matching black frame.\r\n- Dimensions: 60 x 20 cm, a slender vertical footprint specially designed to illuminate narrow wall spaces, columns, entryways, or compact office nooks.','digital',499.00,9.81,800.00,15.00,4.60,284,75.00,0.00,425.00,0.00,NULL,NULL,NULL,1,'2026-08-13 20:37:38',0.00,'published','2026-08-13 20:37:14',NULL,'wood_acrylic','laser_cut',NULL,NULL,'products/78/design/FDT0008.pdf',NULL,NULL,NULL,'2012793','2026-08-13 20:37:14','2026-08-25 11:40:46'),(79,1,3,'Alpine Horizon Digital','alpine-horizon-digital','- Immerse your space in the tranquil grandeur of the wilderness with this multi-layered wooden mountain landscape.\r\n- Showcases a stunning contrast of warm cedar-toned sky grain, crisp light birch mountain faces, and deep slate-grey pine silhouettes.\r\n- Dimensions: 60 x 40 cm, ideal for creating a rustic yet modern atmosphere in living rooms, executive offices, or cozy reading corners.','digital',999.00,19.64,1500.00,25.00,4.30,28,180.00,0.00,1020.00,0.00,NULL,NULL,NULL,1,'2026-08-13 20:40:11',0.00,'published','2026-08-13 20:40:02',NULL,'wood','laser_cut',NULL,NULL,'products/79/design/FDT0009.pdf',NULL,NULL,NULL,'2012793','2026-08-13 20:40:02','2026-08-25 11:40:46'),(80,1,3,'Tribal Symmetry Digital','tribal-symmetry-digital','- Elevate your space with the rhythmic charm and organic texture of this 3-piece Southwestern geometric wall art triptych.\r\n- Features three distinct, laser-cut panels showcasing intricate tribal diamond motifs inspired by Southwestern and ethnic art.\r\n- Dimensions: 60 x 60 cm total display coverage (60 x 15 cm per panel).','digital',299.00,5.88,550.00,8.00,4.70,473,37.50,0.00,212.50,0.00,NULL,NULL,NULL,1,'2026-08-13 20:43:28',0.00,'published','2026-08-13 20:43:20',NULL,'wood','laser_cut',NULL,NULL,'products/80/design/FDT0010.pdf',NULL,NULL,NULL,'2012793','2026-08-13 20:43:20','2026-08-25 11:40:46'),(81,1,3,'Fluid Contours Digital','fluid-contours-digital','- Bring refined Scandinavian minimalism and Japandi elegance to your walls with this abstract 3-piece wooden triptych.\r\n- Features smooth, flowing organic shapes that create a calm, artistic visual rhythm across all three panels.\r\n- Dimensions: 40 x 90 cm total display coverage (40 x 26 cm per panel), making it a versatile choice above bedroom headboards, hallway consoles, or sofa backdrops.','digital',399.00,7.84,700.00,12.00,4.60,238,60.00,0.00,340.00,0.00,NULL,NULL,NULL,1,'2026-08-13 20:45:53',0.00,'published','2026-08-13 20:45:29',NULL,'wood','laser_cut',NULL,NULL,'products/81/design/FDT0011.pdf',NULL,NULL,NULL,'2012793','2026-08-13 20:45:29','2026-08-25 11:40:46'),(82,1,3,'Botanical Rhythm Digital','botanical-rhythm-digital','- Bring mid-century artistic flair and organic elegance to your walls with this 3-piece abstract botanical triptych.\r\n- Features fluid, cutout-style floral silhouettes that capture the essence of modern nature and mid-century art.\r\n- Dimensions: 40 x 90 cm total display coverage (40 x 26 cm per panel), making it a versatile arrangement above bed headboards, sofa backdrops, or cozy reading corners.','digital',599.00,11.78,900.00,20.00,4.20,266,90.00,0.00,510.00,0.00,NULL,NULL,NULL,1,'2026-08-13 20:47:58',0.00,'published','2026-08-13 20:47:51',NULL,'wood','laser_cut',NULL,NULL,'products/82/design/FDT0012.pdf',NULL,NULL,NULL,'2012793','2026-08-13 20:47:51','2026-08-25 11:40:46');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `rating` int DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `paymob_token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_subtype` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CARD',
  `masked_pan` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `holder_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiry_month` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiry_year` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
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
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
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
INSERT INTO `sessions` VALUES ('1A0AMRxdRgK5WnihfGgiflis8tq5KPjdrd6f0bKW',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTEFlT0RUWEZlMnptREhTa2RwUGY3RldSdDI5SnZsODZXTmRWNjFvTSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777799),('1DQY3SvPxKUx2uWNJvylhQ9OsC4tVDOxhz62gcIQ',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiM055ZUxHTFpWNUlvVFRiN3N5U0JTQlhIeUpXNXZ4UTRnZEtVOW0wVCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779322),('1tAfQV4v9LS8bniQYi24ZV5pEdmdoHcuMGvrk3WK',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiNGJHVUtiWFVRYlE5UmFUY2hnczRLdlNZdXFBQ0lHZktsYWxrd0lUUCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTM6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvZmx1aWQtY29udG91cnMtZGlnaXRhIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787827790),('4H7BrKauF0Yo0qXBDjriqOVkkirI49fv18WaDeWS',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 16; SM-S948B Build/BP4A.251205.006; ) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/151.0.7922.199 Mobile Safari/537.36 WA4A/2.26.33.74','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUHptUDFpNWNOdUZxYkpVQ2RPVlR5MlA4bFlzcDhSa1poWTRHSUVqaCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779050),('4xoibmUlxHuOiW9ojqKLbxhvULhVh0xFDUjxKvj2',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZjFmdnFKSUJqQWJ3anY3Sk02QUlOYUhzeW5xUmJ3NEhQbUNWeEpkMCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779486),('600zO96sVJN67mQsQqKn553XxIiomaFtWZxLMVU5',NULL,'172.18.0.1','WhatsApp/2.23.20.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQllYZXJjWlRBcWZ4VGNiU1R5NlI5b0V4dVBVekFoZkZlQXc1U3lUZSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YWwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852099),('7NtdRCfbgshgg7Or6ZPNB26HXoXEAU2PH5HrY5vw',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiT2RBc1V1N0V6cmt1U0NhSjlCdWoySXBvVWNtOWtFeVNtemhyOFQ5SyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779570),('7rbI7oNdV663Rj5AoRfan4yP2Q2EnNgG174uT5vZ',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSllONk1qZEY3dUZQUHBHbW5LVGszaElLbzJMYWZEb0xCcGhsUE55SyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777997),('8j7AduJRspvso6iW2fJJxle63tCGiOSuw0QOHgva',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUVAwcFFHZDB2eGI4alNqZkFrVElvWlFCV2RFNHhHSzNTRVA1SEVOTCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTM6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvYWxwaW5lLWhvcml6b24tZGlnaXRhIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787886644),('8niPMGA4Om3JmnVMlVhDP5fSGLudTsSD0WQwNw4T',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWdJUEl5NWszT3Y3NTJxZjBRZWNKUERaZFdkaUdNOE5FYXppeXV2eiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDc6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvUmh5dGhtaWMtTW90aW9uIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787863924),('8oLOs7PpAiUZgPag1r4Uv4N1F3eVVJhewsuNRYDD',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiODRTVjRRVms1OEpIcVF3RGJra0IxVmZmdnlJU1pDWURnQlJzQllyWCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6OTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YT91dG1fbWVkaXVtPW9yZ2FuaWMmdXRtX3NvdXJjZT1QaW50ZXJlc3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852018),('8RZpagGwlQnbx9NIMIPbT601hsva4BhhrFxaT1kv',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWGdPR2pxSkNqdGR6WUhkaWxGYkt5MldzVHA3aHNLMDZTM2hMQUFkRiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788029463),('93F7Htm8MaSmddDUgq3c0aRxC12Aev9x6dVAYxV6',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVHJZVHNOaDhEcHZadlY3OFJoT1hDODFuTDBHZEZ0UmdOVUZzRFlrWCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787860114),('9KO61Uw2dFspkxWFKNR4Bui4VWDKLOu6mB2zXyVP',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3QxdGFCMkJETGs3eEgzQ3d0ZWtNREFTanhBQ3VldDNLQnp3ZEFnayI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779021),('9obPTmkE26KHCfNIMypufiYSoxQpsKwc9nRKxHNH',NULL,'172.18.0.1','Googlebot-Image/1.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWmJic2Faa2VLMUtSTU9acEtXZFdISmYxcFJ5TEhEZ282TDlUVWZkaiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDc6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvUmh5dGhtaWMtTW90aW9uIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1788022172),('ajj91tAt0u60WvghH9avsYJFIusKpOHMlHDXaVpj',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoicHdSVXlCdFlqSTdBTHFZaFlid29TT3ZuQUJZRUhjcDV4UURoaVdmViI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777935),('AOn6VoatZllgHLegLcBhzPxD7No5D0UFnAXZfkLu',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoidlFEb0lFNnhqc0NRNUFOZ0hUYTF2TW5mNWpXTG92VmJnczFVMHM5TyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779467),('aXnBhqeYlISwgJr5UkwmO7dQxe9lAv4rBsir3pDE',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoic0Q0cHpGUHVnUEN1NUhJbjNSam44T2I4U0VnbkQwcXZoR3VpVU8zbCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778689),('B3Pw1k6TCueGOF7ed63Rv6Lh03aZSZNq1wsWrmpa',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVcwZGtwWGNGZVdPWDBERU9YRkFEbE9TM1lJTHRTdXpOYk1KR1V2aiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787973143),('b55m186UeIirqpCs5sI3AAnrVJHvq2LEzOA7g1A7',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSndvSDdDT1NSUU5mV096QzFGN0dLV2theGhmMWxBTGlXMTZONE5hWiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6OTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YT91dG1fbWVkaXVtPW9yZ2FuaWMmdXRtX3NvdXJjZT1QaW50ZXJlc3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852029),('b8bqVVTLDa912iNGwVxk04iIzCotZtPgpPXoo5ws',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiY25ySzRWYXdaekJJUmQ4ZUloQ1NnTElwYjZmTkxrSGJMbkIxV01jSSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788007020),('bIcW4TXy80d9kxKGXKehlbqiujYJa2yQxs4tIVf2',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiN3NIUkp1TnJVZkdNNk5uY1NVVUQ0TFZEdW05WjlvekVBb3FXUE1XbyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787836738),('cPzaCWf2831FfXhDQ1MkJ7MkYlTQhZK25SPSBVsG',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzk1UlFadm9PNVlhUmZwTHlueTZFSHUzN0xRUEttVndFMUVkVXZqUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787774690),('CSZg1jqUXf8TcpmcRDuNkCJaD1GiU6rQD40497e7',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQWVZRXBnS1h1V0lRcUszUGpSamd5UVp2RjlqeVFQZGhLUkYyWXREMSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vZmFjZWJvb2svcHJvZHVjdHMueG1sIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1788071827),('diyqjjwW7fsxpTjwLMj4sUAPpKcQFr9ykasbBd6z',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiamtCcU5mQU16QVJEeEh1eUFlcmUwNjNmT2xoVnM2TkNIMGxsMVRGVyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787829538),('dtLdk3k2BPYh0Zjp8AZhOdjIasGJOxK543YOeH1c',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGJLVFBXZkRZa0Y3d1JSTUtCUlI1RzM3QUxQd3gzSGxCVTNST3BQTCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvYm90YW5pY2FsLXJoeXRobS1kaWdpdGEiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787828879),('dwikPYcbyVDed2hDoIPBcqSE6qtaaYLWjYYEQPNS',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmdGMndQZGVaSUh6UTNVakE4REU0ZFUxYWhvVlo1UkJaOHdMd2NpayI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788086528),('e5WYlZw4jVZjgcnCWocNuJAmpX9nVDX7MDoy7ZRt',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSkxHZU5VYnJ3YjBFWEllVmt0elJ3WFk0dVVaSVBYSkQzbzJpaUZURiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779188),('E6KG5Pg016hsO6PS3aIpkmR41eIWt69xhMDy8nHR',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiOXZ3eWp5b3BwcjJwVFVOQjJZVE80ekw1NHlvYktiUlE3WHhMS25TeSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778124),('e9qt5IdZAlyP5iZ3NQC88byj8U2EOr0IjJ1scAWE',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRzV0cTUxNFRtTmV3eWVnT0drTmpXQ2Rab3ZzU1dRSDlYYUJQVllVciI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778202),('eAbIBvzMziyMvwo6t2fnA1qHvmGM3cQbsve3iVbw',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiemxLanlBNTNuSUkzNmlxQU1EZld2cmprZVZSMk1jT05UWnZqYm9OYSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777800),('eQ08vERKQLLdozbb4PxzguHuM7ooBeBSvDEyzYua',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWFlSm9ybTFVR0xieWthRjg1VGFlczR4dm9BTFhhT0Zod2ZxcVo4SCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778186),('etLCg8ZvWcqPVm5EzaYI2gxOqNIMrKFHYbhwSiT3',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ3ViRktBUTJxc213cHpmR0NZM2xjZjNuNkxtM0NqbHNSUVBRc1NhayI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779597),('g4N4IPJYyKBJKSCKElVlmJ2f7uuQhpf4ukJVp1oI',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1BFSU9hbG5KUVY3cU82dFlrNUF4RWF0T0J6NVlHOWNYa0VMbkNtVSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779198),('H0wap7Az6z2pmyGu5bfmowvloZ5dSfLKkVyZkjXd',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoicFhZc0V6ZEJMY1BSVmpQb296dkxCTXdLYVdpM3NaN09DUWJNWEQweCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787918434),('hHbhtGjdGNm5WjN3mh9Nj7VZHpHF34AoeJZXQPhy',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWjhQSkRZYzk2Y0p0YTVjNGhFRmZybzNTYUR3clZGenc3VWpmQ2pMVyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787852018),('HquegATYq0ipRRtyEcDNoKKLWAyK4j6ZChJuuHR2',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoibk5MWGRIRlJRZDFsQTZPRTRFcENjaHMyWGZqSURRdFdvZnVIQkMySiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778355),('hsb89O5uND4zFfThKOJ89RQVmSfeDaXmhAxuD8l9',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTXFubG5tYnJhem9lUEFrUUViVXFtUFE1aURHZ1lKQTc0RXRFNmxqcSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vZmFjZWJvb2svcHJvZHVjdHMueG1sIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787899097),('i7nuiBpdJ8w3qxwD5laYqVHyYxnE3lhahR4CrkPR',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRXV1dnFTUnNzN01FajZnWTRXTWZFT05ROVdWT0lXb1I0VU1xMVdnUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777918),('IjroUeNge57yQE49VtkHiuDRw7Pu9zT4iYcHqOpc',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 16;) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiblFaREs4MXZ3bXhjMzBIVkFWcWh0VTlFbTB3bkE3QnJnWkJkUVM5YyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YWwiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852097),('iXsaOrF0SNWoXIXIvY9ajHlYJtKsujnktZ9BUbJ2',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVnY0eER5bGVLNm1pSHpjbHdTV1dLZm9WUmtsNFJ1cWI1TE1qRUxSVyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779733),('IZQGN890kZilPnvj9YYvzyhWjV47IdZppJkvRj4d',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMk1VZEZHZ0F1VHh1dUhleGlSRjZxNjVISXZmU2RBYkdGVUY5RjFzdSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787829533),('JAv12LOfOYyGlWDf40iKh10tP21LLptQjI00hStL',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHkyTFJIY05ZZWlTT2l6c2l1eTRnc0d1cWFDdmdVUHFGVTRvZGVENSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778716),('Jk1aIHo2ddjvotcwH7gQmJrGy0wjt6XNoh7WiqzY',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMHZYSjEzTmVBMmY4UW95ZFk2a2xPS1lEM0FwNFlIbmI2V01vN3RWYyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787836744),('jXkt6TaY6UBJILyrqI04bPzFaHTic529Nww5BJzm',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0EyQzE4OWRTbDA4WVVYS0t2QkZVQ3M5Wk5USWdZdHhYdmJyTzFsWCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779530),('jzkL2paTGQn1sF83tiDqYH5PAdnVI8Ggy7nPZBSR',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUQ2ek8wZE1rWUhxOHRkQWFZUktlMERsRGM1ZWFJR1JCZ2RsSEllRSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvaXNsYW1pYy10cmlvLWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787964419),('kcGIW004IPRtFgKKDEEWZL4v7u5i0Mc7OQ2Zzw8C',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYll5OUxIWm4zTjB4bHJhS1RvaEtKYlVvbkRUQ2tFZzVIZ2tnd1dNbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779066),('kGiaE749r6zRrmu09rNzpfLH6ryt4Anjdm3Betzf',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQkpTcGZGWnRvam15cGxmd0VYa2xxNGV6OUNBQko1REh0amZTWEY4NiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779055),('KhbEphiMMcf1AO3TzdTMkYt2VJ4Jllh4PINYYNTk',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoicnJ2ZFZoSFVHbzluVXlDZ3U3WHlvOUMxTWhUc1JNeE1rSDBkNGNJeSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6OTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YT91dG1fbWVkaXVtPW9yZ2FuaWMmdXRtX3NvdXJjZT1QaW50ZXJlc3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852028),('KM0Oev0FpSgWT8Vblyv28TqOUKLXHKTldVQoEI18',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiaWlzTkNySThHQlg3VWZzOEk3dm5vSGJ0UnprWnVFNjdmZm5wTTVYUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787829268),('kSOhtB6XcyKPcwfwEEbWPS2fK8ORv3uOvJ2x7UK7',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUnF4YVY2YVFCbWhoR05BQVVkNUxNVnlFa0RITEVRRDlnSnpKcjNOYSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787846436),('KtBrR3estXAcmX6lWBSsNVi4VKRrHcqzH44KRDUG',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiM1VVVGpRV1RsTmRWMFJQODJXM0VDQVZKS1pwSjF2dTBvQkMwUUliNSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787906038),('l3jqTIBPBid7h7WH6nymYtSahSZILv1zO53Wyqcq',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoid0c5UnNLZ0M4cWszZnpMNEE4RmlHTUxSc1JkbVNyWU1OdHJRRmxWRCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779627),('LnrWWEJTCERbgkekNia9eg4kXJkawELBTjN1Ssk1',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoib0RpWXdFZVAxcXdXV0dNdUF3cTZKSmpuRzBuN3JiM3FEMERLVXB0NiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778287),('lscv7RxwTbmGt7PtCASNLou0hCHmUzETOHDUklHV',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiM1dyUlRSVWxOSWVyTzdWVkVTZ3FFQkpORGZQT3I3djc1ZjdzNFNLWCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787852019),('Ltavx9kFv7CB6W0apCQoUZeUJg8irGUgL10ViG0r',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 16; SM-S948B Build/BP4A.251205.006; ) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/151.0.7922.199 Mobile Safari/537.36 WA4A/2.26.33.74','YTozOntzOjY6Il90b2tlbiI7czo0MDoiOXJXRmxvSjhxUGlRaURUNEtVNjNXaVVYREFpRGxleVdGa1hnZVR1dSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777816),('lwyfZqPkIiEi5Kq6KGTh1nmPWWfIbGnQU3Gv7EWG',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSFdoOUMzaEdoenhpbFY2cmd4dEhPWTE0VkowSWtLS3JiTlV3TVZzSyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779555),('M6fkCjVyzmSyhwlEeDhxfYOzv9kyWupEOvtxzeFu',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMEtlVjlGYUl4dDd5SGNUUVJlMHVUUFlGb0tGaVd4aUV5eVNYZHM2biI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778101),('mkI7kKV3LaPxJHFS8jDAN6zgEu2CerUtJU8g07ER',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMWRHQVRTbzFTeHJZWGp3b05RM1RLNm1JV0VlQ3VXbXJZdUdudGtEaCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787883124),('MzhiQ4dcLpIEFWAaCNzDqEuQVtt7Z2WJ1W1BkOeF',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWDU3a3NQR2FBNHo1NTNvMG1xdVNjNkVvbGVTdXh6VURJZkw0clBNbCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vZmFjZWJvb2svcHJvZHVjdHMueG1sIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787812727),('nBhbwN5by5dBvm4NU0IIFNijslv04lJAjU2worPt',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzhQT25VME54WkNXc1JVYU1lMnhraGdBMlVlTEFSek5tMlhQMFE1diI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788017706),('NCk7Ag5W6kZJVYTZkuXMEqmXuHeTnpUmuutQ8ImZ',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWnpONk84cExHT1gzNGY1eXlZQjI0b1F2enFGQWRzNkFsakV6NldBOSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779033),('Nh2RLaB2hNXPt4DDhXPCBbdzN11RiAtgrVUaOI9Q',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRjVLVFRIZEVuRGNCRDhiWjIyVUVlMWhNWXBhejVQd0ZYNFE0V2I1biI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787965719),('nhw2srZW53TSYlRUBAe7syPUOS7m8UPLGvOAUhPf',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYndQWlk3TEpUbmNzUDRWYkRndURDNTQzdlU0TzNWN1B2M3NhOXlsTyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779046),('nsKaIOB0h6Skso4e5LYAjoMhlYqi9SNJjo2D5tBE',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZE9tS0dEb0o3andIZTFSMXM3TVpOenBITnRrVFdvUnhnUmU3MnNyUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vZmFjZWJvb2svcHJvZHVjdHMueG1sIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787985463),('nYxAlJSyZSojxUO91ivIGwSBBSd1fnPiTorhp8jh',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoidTNvVG9mUVZKOWEzSGdjWmI1MUlrMm4zakw0NWdZdG1EMzhmRktFcCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778206),('o1qgvzH0wMfCUJf1hJC2TiV05EsBXss2uRDzDri1',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTGh6UmtZM2o3TXFJMlhhWnhrMTIxT1dlVExVTEtvMm1UTzhvQ25veCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787852049),('oAOhoYvjfT0XF5acM3qro3lIaW3MWpqeKrmItoe3',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSUUzdnFaUU5vT3ZBN3BjZVBMQ1U5RHBubXdpazNaWjZyRGcySW9kRCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777800),('p7y4XYMzuaTDtnVQaJcClP0vFN2JaMaLPPmbkmG9',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoielJSckhLQ3VOc1lxMHBZMlZmOUQwVDhYaUVwcnhhd2RPZkhrRmJZUyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvZm91ci1xdWxzLWhhcm1vbnktZGlnaXRhIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787888775),('PB763prSbhwQpoeSIfWZnmhHGqBJBVPX7nv4AKwj',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVE5bUtTa0VZYnhOM2NPeW1mQjh5NVpBWG5GQ0lJbVZ5MFBLMjRvcCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778939),('pIs64AcsSCLhBwVNfULLAd5a7TLTd7or1yUG7qnt',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiT0VPcnR1N3lBUzQ5Z1hFc244bFRvSzdLVW1YYWxFSnQ4UllSNVppTSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777975),('SBRUf8tp58ZpvWcMajWR3jvHDNaCaQkC4UkWk9Z7',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 11; CPH1969 Build/RP1A.200720.011; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/151.0.7922.170 Mobile Safari/537.36 [FB_IAB/PAA;FBAV/567.0.0.56.104;]','YTozOntzOjY6Il90b2tlbiI7czo0MDoiemhYOGFUVTJKZGlYQTVsMk1md0I0b2lIQVNmWmZ3UzNRbTJ0R3FIUiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779070),('sFOBXp4aTwS6C1smiyh4HxcZcMb5sO0Bj265fq6X',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoibDliNVpWU3FicWlDVW8yTVVYMUx6UnBPandMMHFSQ3pFTmExemxhUCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779149),('SpEDrb9JReBZU7H1HUR3q1uqRwEcJwI7vnYR4uOR',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMzVuY3I2MlBvOHRBUkVuSnBqV0EzUmFkUXJsYzRra0o2V0M2cmJlMSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787820457),('SrjeJ3yWPfx5GJFCSJjaJ66W7WANz8Gx5j5aofgr',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiR285ckk0ekh0ZFM3TVdpQmpEaDduRVVJbE1yOE5ybjFZM2paMGdKcCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6OTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YT91dG1fbWVkaXVtPW9yZ2FuaWMmdXRtX3NvdXJjZT1QaW50ZXJlc3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787852048),('sVtafKp0aeJKnzy0loyQEXsbTIj9XwQsgJLMGgXI',NULL,'172.18.0.1','Mozilla/5.0 (Linux; Android 11; CPH1969 Build/RP1A.200720.011; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/151.0.7922.170 Mobile Safari/537.36 [FB_IAB/PAA;FBAV/567.0.0.56.104;]','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYklSaGh0VVM2TnRVSGRPbHlqOEpHUklaVlVKRExjb2VhZGpEd1NsNSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778235),('UgCzQhoBhepQAXFGZn9GXDupTS7o3J8c5vDL7Fdx',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWmMxMzlWTlhadW9mbFFyWjJneEFCMGlwZU5DV2dHZkxSUHJtT1BWMSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787852018),('UH279WZyQ5iZKLN5jZ7vEaSx8c2fhgzfRUgW3E1G',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoidVNuVldoUHZGS0RnNUVkSU41V1hTOVpZMHREODFYNFhWeDRLM24zSSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvc3VucmlzZS1yaWRnZS1kaWdpdGEiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787937316),('UOn88mROvzYHrbzX8eEblxDScR2G4vsepx5cioE0',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiSDBWQndNbVNNbGhEZWY5QUhwTTVoOGY1MmFYNEpFT1pUTkpWamtTeiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778130),('UPKuv9GsSBoaeQdyJCBZIzKFyEeA9bb1787wkQeI',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTHAwa0dBWU9rZXdlMnNUeElITTNvQ0Job04xYWhYV3NiNnB6M1pEVCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778659),('uYwYTTlt9gtjK54fQfqfwG63ASighNYtvVJ70Ovw',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiNkJEeThvUnl5eWFhbGNKWFFjM2psdU9nZzllQUtIM0hNWmI2ZElacCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787889894),('v3yoeES20lrogQ6yRISq4ptLc4nIdselWSdKAnSv',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRnNXU2pkbVFRUVZLc24xaGREeHVyVDU3RFVPTzNxd2t3Qm5GQVdsUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787829274),('w6yHDiwFLOvdctdNr0aE71DErRP30cvUQdCCpHfG',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTDVLcnRyRGthaHMweTF3U0JMQk9lM2NzSkJXMjJyS3N4eTNIWllHUiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777798),('Wj9y5o1Vd543ozOZ8WwtuQmc97whX4Qj4NEIowPF',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVFdieFZTYVhVT1ozcm9PZHc5ZGJTdmtuMEF5eTdsMTBtU3kzTUJadSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788044807),('WwU3q8iyKZQDQ2dcNv0Pup0ECAiYXg3M2lfU5BRa',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiMlVxanVVT3pJbTVLalR6eVlUMVd2YUhESkxPTTdEMFRvQ2hrQW82MSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779649),('x8y9rBhXOcSxgWcVk8YIQAbIexpa8aLAoawtku08',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQTFJUzJFYzhwZ2Z5Nm9XT3hiVlNIcDMxejhOclpoRGRYd2xzUHRYaSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1787799310),('y2vKlqKzpqSuqBa8CR2mpIQAF2FtF9l4KLtfF7YC',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTmRHYk41U09KWFhDUjBpM0p3bE5uRkczZkpGYkl4ckUyTUJ0NXlFTyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDc6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvUmh5dGhtaWMtTW90aW9uIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1787863923),('ybwXBCexlYuoEySauTGqzetGGNzFEBPzOxoLgjpA',NULL,'172.18.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYmNNM0pxWndTUlhZa0xMdXBzZUxqcVdsZjJ6SDlGRU9uUnAwcVJCViI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1788090885),('YlbtNHwbW53z5IkvTNNE36p3xcwa8VpwxzGUbu44',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiclFkaTNUWlZuZDlVZjRRVlFldVRsNzZsdklzT2dkY1pYbW5IOUlmUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787778647),('yNHR0UZlRp6hzTKF1ewkyml3PA16VgTbqDsddXog',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUjJMTEZlTWZCenNQaXBIazVZNzV2eHYyc0V3Nms3ZTZvSVNuY1JleSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMva2FhYmEtc2FuY3R1YXJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788020476),('Z7D7iET6LeyNfFluvgnVy0irW9Uz43Q1Sm6f70jZ',NULL,'172.18.0.1','Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)','YTozOntzOjY6Il90b2tlbiI7czo0MDoicGdqU1lxdnAwR2t0Rk9SSlhqS1BGQjlLQ2hrMXdHcUMzVDlxQVR5eCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vcHJvZHVjdHMvdHJpYmFsLXN5bW1ldHJ5LWRpZ2l0YSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1788069514),('z82YATEyrsm9eoqWOzOleK8lDW0nOfFWPffdtOQN',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoibXFZdE1CY3g5clh0Z29VVWx2UGtYdERyUTk1TmlpYU9MSWM3eEViSiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787779686),('ZLwWVR1ghfPjF3xWsvezjXprKbcITqjUCd3uONUu',NULL,'172.18.0.1','facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZmpGOUlFNVJhU3RQa2NMenEzQnRnTzRVOEF1ajQyNmlUN0ZuSnJHZCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly9mbGZsLWRlc2lnbi5jb20vbWFpbi1jYXRlZ29yaWVzL3BoeXNpY2FsLXByb2R1Y3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1787777840);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
INSERT INTO `settings` VALUES (1,'egp_to_usd_rate','50.250989','2026-07-04 19:39:57','2026-08-30 04:14:31');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_companies`
--

DROP TABLE IF EXISTS `shipping_companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `region` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `governorate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cost` decimal(8,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_rates`
--

LOCK TABLES `shipping_rates` WRITE;
/*!40000 ALTER TABLE `shipping_rates` DISABLE KEYS */;
INSERT INTO `shipping_rates` VALUES (1,'Cairo, Giza & Outskirts','Cairo',87.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(2,'Cairo, Giza & Outskirts','Giza',87.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(3,'Cairo, Giza & Outskirts','Qalyubia',87.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(4,'Alexandria','Alexandria',94.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(5,'Delta','Sharqia',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(6,'Delta','Gharbia',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(7,'Delta','Menofia',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(8,'Delta','Kafr El Sheikh',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(9,'Delta','Beheira',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(10,'Delta','Dakahlia',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(11,'Delta','Damietta',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(12,'Canal','Ismailia',111.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(13,'Canal','Port Said',119.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(14,'Canal','Suez',119.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(15,'Upper Egypt 1','Beni Suef',128.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(16,'Upper Egypt 1','Fayoum',128.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(17,'Upper Egypt 1','Minya',128.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(18,'Upper Egypt 1','Assiut',128.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(19,'Upper Egypt 2','Sohag',144.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(20,'Upper Egypt 2','Qena',144.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(21,'Upper Egypt 2','Luxor',144.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(22,'Upper Egypt 2','Aswan',144.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(23,'Red Sea','Red Sea',196.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(24,'Remote Areas','New Valley',213.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(25,'Remote Areas','Matrouh',213.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(26,'Remote Areas','North Sinai',213.00,'2026-07-22 12:21:11','2026-07-22 12:21:11'),(27,'Remote Areas','South Sinai',213.00,'2026-07-22 12:21:11','2026-07-22 12:21:11');
/*!40000 ALTER TABLE `shipping_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_listings`
--

DROP TABLE IF EXISTS `store_listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_listings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `industor_id` bigint unsigned NOT NULL,
  `attachment_id` bigint unsigned DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
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
/*!40000 ALTER TABLE `store_listings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_days` int DEFAULT NULL,
  `ticket_limit` int NOT NULL DEFAULT '0',
  `can_publish_to_store` tinyint(1) NOT NULL DEFAULT '0',
  `discount_percent` decimal(5,2) DEFAULT NULL,
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
INSERT INTO `subscription_plans` VALUES (1,'Basic',500.00,'EGP',30,10,1,0.00,'2026-06-25 20:43:19','2026-08-14 14:17:34'),(2,'Premium',1000.00,'EGP',30,25,1,10.00,'2026-06-25 20:43:19','2026-08-14 14:17:55'),(3,'Enterprise',1500.00,'EGP',30,50,1,15.00,'2026-06-25 20:43:19','2026-08-14 14:18:10');
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_attachments`
--

DROP TABLE IF EXISTS `ticket_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_attachments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` int unsigned NOT NULL,
  `kind` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'delivery',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_attachments_uploaded_by_foreign` (`uploaded_by`),
  KEY `ticket_attachments_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_attachments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_attachments_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_attachments`
--

LOCK TABLES `ticket_attachments` WRITE;
/*!40000 ALTER TABLE `ticket_attachments` DISABLE KEYS */;
INSERT INTO `ticket_attachments` VALUES (40,42,30,'Coffee_shop_corner_with_art_202608071817.jpeg','tickets/42/V4ig7HulsinVPPbNFR0RHFtzZGzX9TOM6TyZ9CBU.jpg','image/jpeg',703040,'requirement','2026-08-14 20:08:01'),(41,42,30,'FDT0012.pdf','tickets/42/fzQZdYWpGKLUuHuWJwU22mhdgBk71QVqn8dJ7cCs.pdf','application/pdf',126544,'requirement','2026-08-14 20:08:01'),(42,42,10,'Kaaba Sanctuary.pdf','tickets/42/p34qmfzdFyYwFGOC2GERIO0oQirfAka1Oibl83eT.pdf','application/pdf',773761,'delivery','2026-08-14 20:15:46'),(43,43,30,'FDT0012.pdf','tickets/43/HX30hrrhchFQezdNffv6iaN6QqKkOXnQDMiQb2M9.pdf','application/pdf',126544,'requirement','2026-08-14 20:21:04'),(44,43,9,'Four Quls Harmony.pdf','tickets/43/YvZLUZHYnSHO3MF4P6bGmoC5sHagvR0zGI2gbtg4.pdf','application/pdf',936501,'delivery','2026-08-14 20:23:40');
/*!40000 ALTER TABLE `ticket_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_deadline_negotiations`
--

DROP TABLE IF EXISTS `ticket_deadline_negotiations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_deadline_negotiations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `round_number` int NOT NULL DEFAULT '1',
  `proposed_by` enum('industor','tester') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `proposed_deadline` timestamp NOT NULL,
  `proposed_price` decimal(12,2) DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_deadline_negotiations_created_by_foreign` (`created_by`),
  KEY `ticket_deadline_negotiations_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_deadline_negotiations_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_deadline_negotiations_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_deadline_negotiations`
--

LOCK TABLES `ticket_deadline_negotiations` WRITE;
/*!40000 ALTER TABLE `ticket_deadline_negotiations` DISABLE KEYS */;
INSERT INTO `ticket_deadline_negotiations` VALUES (36,42,0,'industor','2026-08-18 09:00:00',850.00,NULL,'pending',30,'2026-08-14 20:07:59'),(37,42,1,'tester','2026-08-18 21:00:00',1020.00,NULL,'rejected',7,'2026-08-14 20:09:20'),(38,42,2,'industor','2026-08-19 20:10:00',850.00,NULL,'accepted',30,'2026-08-14 20:10:47'),(39,43,0,'industor','2026-08-16 20:20:00',900.00,NULL,'accepted',30,'2026-08-14 20:21:03');
/*!40000 ALTER TABLE `ticket_deadline_negotiations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_modification_requests`
--

DROP TABLE IF EXISTS `ticket_modification_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_modification_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `designer_id` bigint unsigned NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `industor_response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `handled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_modification_requests_designer_id_foreign` (`designer_id`),
  KEY `ticket_modification_requests_ticket_id_status_index` (`ticket_id`,`status`),
  CONSTRAINT `ticket_modification_requests_designer_id_foreign` FOREIGN KEY (`designer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_modification_requests_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_modification_requests`
--

LOCK TABLES `ticket_modification_requests` WRITE;
/*!40000 ALTER TABLE `ticket_modification_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `ticket_modification_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_price_history`
--

DROP TABLE IF EXISTS `ticket_price_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_price_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `industor_price` decimal(12,2) DEFAULT NULL,
  `designer_price` decimal(12,2) DEFAULT NULL,
  `change_reason` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_price_history_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_price_history_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_price_history`
--

LOCK TABLES `ticket_price_history` WRITE;
/*!40000 ALTER TABLE `ticket_price_history` DISABLE KEYS */;
INSERT INTO `ticket_price_history` VALUES (26,42,850.00,850.00,595.00,'negotiation_agreed','2026-08-14 20:10:56'),(27,43,900.00,900.00,630.00,'negotiation_agreed','2026-08-14 20:21:23');
/*!40000 ALTER TABLE `ticket_price_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_status_history`
--

DROP TABLE IF EXISTS `ticket_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_status_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `from_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by` bigint unsigned NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_status_history_changed_by_foreign` (`changed_by`),
  KEY `ticket_status_history_ticket_id_index` (`ticket_id`),
  CONSTRAINT `ticket_status_history_changed_by_foreign` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_status_history_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=178 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_status_history`
--

LOCK TABLES `ticket_status_history` WRITE;
/*!40000 ALTER TABLE `ticket_status_history` DISABLE KEYS */;
INSERT INTO `ticket_status_history` VALUES (164,42,NULL,'pending_tester_review',30,'Ticket submitted for tester review with proposed deadline & price','2026-08-14 20:07:59'),(165,42,'pending_tester_review','waiting_industor_approval',7,NULL,'2026-08-14 20:09:20'),(166,42,'waiting_industor_approval','waiting_tester_review',30,NULL,'2026-08-14 20:10:47'),(167,42,'waiting_tester_review','pending_payment',7,NULL,'2026-08-14 20:10:56'),(168,42,'approved_by_tester','accepted',10,'Ticket accepted by designer','2026-08-14 20:15:36'),(169,42,'accepted','awaiting_qa',10,NULL,'2026-08-14 20:15:46'),(170,42,'accepted','awaiting_qa',10,'Deliverable uploaded; awaiting QA','2026-08-14 20:15:46'),(171,42,'awaiting_qa','completed',7,NULL,'2026-08-14 20:16:59'),(172,43,NULL,'pending_tester_review',30,'Single-purchase ticket submitted for tester review with proposed deadline & price','2026-08-14 20:21:03'),(173,43,'pending_tester_review','pending_payment',7,NULL,'2026-08-14 20:21:23'),(174,43,'approved_by_tester','accepted',9,'Ticket accepted by designer','2026-08-14 20:23:05'),(175,43,'accepted','awaiting_qa',9,NULL,'2026-08-14 20:23:40'),(176,43,'accepted','awaiting_qa',9,'Deliverable uploaded; awaiting QA','2026-08-14 20:23:40'),(177,43,'awaiting_qa','completed',7,NULL,'2026-08-14 20:24:06');
/*!40000 ALTER TABLE `ticket_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `industor_id` bigint unsigned NOT NULL,
  `subscription_id` bigint unsigned DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_order` int unsigned DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `industor_price` decimal(12,2) DEFAULT NULL,
  `designer_price` decimal(12,2) DEFAULT NULL,
  `price_updated_at` timestamp NULL DEFAULT NULL,
  `urgent_price_applied` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new',
  `tester_id` bigint unsigned DEFAULT NULL,
  `reviewed_by` bigint unsigned DEFAULT NULL,
  `designer_id` bigint unsigned DEFAULT NULL,
  `deadline` timestamp NULL DEFAULT NULL,
  `industor_expected_deadline` timestamp NULL DEFAULT NULL,
  `industor_expected_price` decimal(12,2) DEFAULT NULL,
  `tester_suggested_deadline` timestamp NULL DEFAULT NULL,
  `tester_suggested_price` decimal(12,2) DEFAULT NULL,
  `industor_counter_deadline` timestamp NULL DEFAULT NULL,
  `industor_counter_price` decimal(12,2) DEFAULT NULL,
  `final_deadline` timestamp NULL DEFAULT NULL,
  `final_price` decimal(12,2) DEFAULT NULL,
  `deadline_approved_by_industor` tinyint(1) NOT NULL DEFAULT '0',
  `current_negotiation_round` int NOT NULL DEFAULT '0',
  `negotiation_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting_tester_review',
  `deadline_negotiation_history` json DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT NULL,
  `qa_claimed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `review_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_published_to_store` tinyint(1) NOT NULL DEFAULT '0',
  `is_late` tinyint(1) NOT NULL DEFAULT '0',
  `penalty` decimal(10,2) DEFAULT NULL,
  `penalty_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `store_listing_id` bigint unsigned DEFAULT NULL,
  `is_single_purchase` tinyint(1) NOT NULL DEFAULT '0',
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
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES (42,30,27,'test1',NULL,'description',850.00,850.00,850.00,595.00,'2026-08-14 20:10:56',0,'completed',7,7,10,'2026-08-19 20:10:00','2026-08-18 09:00:00',850.00,NULL,NULL,'2026-08-19 20:10:00',850.00,'2026-08-19 20:10:00',850.00,0,2,'approved','[{\"reason\": null, \"status\": \"pending\", \"created_at\": \"2026-08-14T20:07:59+00:00\", \"created_by\": 30, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 850, \"proposed_deadline\": \"2026-08-18T09:00:00+00:00\"}, {\"reason\": null, \"status\": \"rejected\", \"created_at\": \"2026-08-14T20:09:20+00:00\", \"created_by\": 7, \"proposed_by\": \"tester\", \"round_number\": 1, \"proposed_price\": 1020, \"proposed_deadline\": \"2026-08-18T21:00:00+00:00\"}, {\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-08-14T20:10:47+00:00\", \"created_by\": 30, \"proposed_by\": \"industor\", \"round_number\": 2, \"proposed_price\": 850, \"proposed_deadline\": \"2026-08-19T20:10:00+00:00\"}]',NULL,NULL,NULL,'2026-08-14 20:15:35',NULL,'2026-08-14 20:15:46','2026-08-14 20:16:56','2026-08-14 20:16:59',NULL,NULL,0,0,NULL,NULL,NULL,0,'2026-08-14 20:07:59','2026-08-14 20:16:59'),(43,30,NULL,'test2',NULL,'test2',900.00,900.00,900.00,630.00,'2026-08-14 20:21:23',0,'completed',7,7,9,'2026-08-16 20:20:00','2026-08-16 20:20:00',900.00,NULL,NULL,NULL,NULL,'2026-08-16 20:20:00',900.00,0,0,'approved','[{\"reason\": null, \"status\": \"accepted\", \"created_at\": \"2026-08-14T20:21:03+00:00\", \"created_by\": 30, \"proposed_by\": \"industor\", \"round_number\": 0, \"proposed_price\": 900, \"proposed_deadline\": \"2026-08-16T20:20:00+00:00\"}]',NULL,NULL,NULL,'2026-08-14 20:23:05',NULL,'2026-08-14 20:23:40','2026-08-14 20:24:05','2026-08-14 20:24:06',NULL,NULL,0,0,NULL,NULL,NULL,1,'2026-08-14 20:21:03','2026-08-14 20:24:06');
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `traffic_sources`
--

DROP TABLE IF EXISTS `traffic_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `traffic_sources` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `source_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `plan_id` int unsigned NOT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `approval_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `paymob_transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tickets_remaining` int NOT NULL DEFAULT '0',
  `tickets_used` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_subscriptions_user_id_foreign` (`user_id`),
  KEY `user_subscriptions_plan_id_foreign` (`plan_id`),
  KEY `user_subscriptions_approved_by_foreign` (`approved_by`),
  KEY `user_subscriptions_approval_status_index` (`approval_status`),
  CONSTRAINT `user_subscriptions_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_subscriptions_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_subscriptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
INSERT INTO `user_subscriptions` VALUES (25,30,3,'2026-08-14 19:53:06','2026-09-13 19:53:06','active','active',NULL,'2026-08-14 19:59:53',NULL,'587616567',50,0),(26,30,3,'2026-08-14 19:58:06','2026-09-13 19:58:06','expired','active',NULL,NULL,NULL,'587620630',50,0),(27,30,3,'2026-08-14 19:58:37','2026-09-13 19:58:37','active','approved',1,'2026-08-14 20:01:54',NULL,'587622339',49,1);
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `google_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `two_factor_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expiry` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role_id` bigint unsigned DEFAULT NULL,
  `currency_preference` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EGP',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,NULL,NULL,NULL,'Admin','admin@flfl.com',NULL,'$2y$12$TrEP2FV4sOwfGDIXdF7eHuYpHc5WCSlLy0oH/LPgQckeWXpHiYN3W','01000000001',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-08-13 20:45:43',1,'EGP'),(2,NULL,NULL,NULL,'Regular User','user@flfl.com',NULL,'$2y$12$11FpdzEN1lLDmXAPSRjUzuBdAPY2R4dkycOp0iV7R0MALYFnhTd8u','01000000002',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-08-14 09:27:27',2,'EGP'),(3,NULL,NULL,NULL,'Tester','tester@flfl.com',NULL,'$2y$12$8vdzoNV9wBS.S5Ho0jY0i.4OYAoBvYv399ht6FL8u/2hVdymjViDO','01000000003',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:47','2026-06-25 20:31:47',3,'EGP'),(4,NULL,NULL,NULL,'Designer','designer@flfl.com',NULL,'$2y$12$Hm.e.W4PQvYjFoyqnvXC/O6BVM2nk8MteGTUepTvzukUTHQw0oH7y','01000000004',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:48','2026-08-14 19:14:36',4,'EGP'),(5,NULL,NULL,NULL,'Industor','industor@flfl.com',NULL,'$2y$12$bT0Hsq2eNE9pLOm2Ah358eBHMPWQsDFg1Y4KGdaQbFb43N.sCuOei','01000000005',0,0,NULL,NULL,NULL,1,NULL,'2026-06-25 20:31:48','2026-08-07 22:20:43',5,'EGP'),(6,NULL,NULL,NULL,'Tester One','tester1@flfl.com',NULL,'$2y$12$J2ONNaaNCPz3npyJ4jdiheaIuaceWyc25iuT64vCJzh76qDkI.fku','01095731382',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:30','2026-06-25 22:26:30',3,'EGP'),(7,NULL,NULL,NULL,'Tester Two','tester2@flfl.com',NULL,'$2y$12$7v08poTYP2vXriJQ3X0tX.Wl/86uoDL0xo6bU.89zUFBnJGalJOpK','01038509330',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:30','2026-06-25 22:26:30',3,'EGP'),(8,NULL,NULL,NULL,'Designer Ahmed','designer1@flfl.com',NULL,'$2y$12$BVK4mbTMHa7haVeqktawueirQNUBpbU2yNh6pWETWKAxK5rbbJ71O','01037489826',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(9,NULL,NULL,NULL,'Designer Sara','designer2@flfl.com',NULL,'$2y$12$p.c9rRNy6X7JyO3Y3y5mq.E2SEROHEG8vIjAq7f56ffr6ViP21KQG','01027285132',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(10,NULL,NULL,NULL,'Designer Omar','designer3@flfl.com',NULL,'$2y$12$y.DWgpYIi/ilSaJfp0qI.ucJLFOUqdmmJ7CH16IcSg/aYXX4Sw8MK','01045678773',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',4,'EGP'),(11,NULL,NULL,NULL,'Industor Khaled','industor1@flfl.com',NULL,'$2y$12$1f9cJN0reeL1/uMO3z.oWOVC2I1LrlS5JWTxNYlIBaHeGD67bpRca','01099519212',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',5,'EGP'),(12,NULL,NULL,NULL,'Industor Mona','industor2@flfl.com',NULL,'$2y$12$HsSCfLXAHSW1W9CZnJZNsOPvFUoahz6U4kFG5AcTDmjXXrq2mwnzm','01022838284',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:26:31','2026-06-25 22:26:31',5,'EGP'),(13,NULL,NULL,NULL,'Industor Ali','industor3@flfl.com',NULL,'$2y$12$XSSaePz1A7M8zP.Y26o.kOh3Bp4H6lqwUv.2hcJmtIpZHS1BoWkoe','01035146673',1,0,NULL,NULL,NULL,1,NULL,'2026-06-25 22:56:42','2026-06-25 22:56:42',5,'EGP'),(14,NULL,NULL,NULL,'yousef','yousef@gmail.com',NULL,'$2y$12$cMFhJPoPWbwKUBfA./Gfn.Fl1u50eh0bbzsPGOKL3KQyiFdfsxX3u',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-04 11:26:27','2026-08-08 10:19:01',5,'USD'),(15,'107844451118477508383','https://lh3.googleusercontent.com/a/ACg8ocJWdr6QzqB0oWpUj2HjRj6geHWj0nLHZthE0S7ogFMXURfT7bc=s96-c','google','Youssef. A Mohamed','youssef.a.mohamed51@gmail.com',NULL,'$2y$12$kV0wgXR.eKutLkfpuOTeEeS0xAgNGkEoojMMWXRP/7iUV8f5mVuKK',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-22 07:13:34','2026-08-07 21:50:01',2,'USD'),(16,'104113521888923465105','https://lh3.googleusercontent.com/a/ACg8ocK5CI36I2ziWLvKAoA1xQcnJ9OF-u8jNMUJzl_srsVqla-ej5A=s96-c','google','Youssef Abdo','y.abdo@it-gates.com',NULL,'$2y$12$1fCAOsOYPB3nEigSKFHrZuRvLryo2L2M3KYEUuzaJ2rO7AtAyVSqy',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-22 08:01:18','2026-08-30 12:04:38',1,'USD'),(17,'103699797635513942957','https://lh3.googleusercontent.com/a/ACg8ocLoWmvxumWYWBfJV_eDujGw8dv7qmhPFHl-fCz_LtifDUVNZ-s=s96-c','google','Youssef Abdou','yousefabdo2262@gmail.com',NULL,'$2y$12$SMikLczLOIpM3LNCFMMBP.B0JHKnxbMyjnk5xIQ6hDicrgwr.SA3O',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-26 21:29:30','2026-07-26 21:29:30',2,'EGP'),(18,'108319594562305879636',NULL,'google','hazem mansour','zoma.mansour2000@gmail.com',NULL,'$2y$12$hbj3qYXOjxeVTWQFSTJFzuIMD/56bVyMQlPuSI1/s.6ado2kcg./C',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-07-28 11:00:49','2026-07-28 11:00:49',2,'EGP'),(19,'110069704651648258004','https://lh3.googleusercontent.com/a/ACg8ocKaHbV9sRovaIYOq6ByFU066Fcaqzza5XYgW1SlvfWw_waSPCM=s96-c','google','Fares Safwat','safwatf783@gmail.com',NULL,'$2y$12$uKSXRY/pIbtOjBQAXncMnOLncxwuOTkfQbrHNxhlelZ6JuYqmrL1m',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-01 14:08:32','2026-08-05 21:17:28',2,'USD'),(20,'100387891982424554341','https://lh3.googleusercontent.com/a/ACg8ocIIP_HkMLYAZvYabdRHC1OatcKziNpO7a7Skzp-uyL6E3mJqj0=s96-c','google','Fares Safwat','safwatfa783@gmail.com',NULL,'$2y$12$OqURd.USgUCgf4tbxWYlfOTus8RBFqSRybCalIvjgHUNAKdBBdiJ6',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-05 21:15:27','2026-08-13 11:19:53',2,'USD'),(21,'102279552008198976752','https://lh3.googleusercontent.com/a/ACg8ocIhmBuxKHsthFRzVSwqW96ZzQj8QGj1i5y6LoXdVI7vi9GkRw=s96-c','google','Fares Safwat Sabra','fares.s.sabra@gmail.com',NULL,'$2y$12$zjT8wPLZ1OoD2UNO0oMJlOdtJP4t83c/Bwnuq1zgacpHP8yUS0w12',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-05 21:18:47','2026-08-05 21:22:29',2,'USD'),(22,'102173474175369435644','https://lh3.googleusercontent.com/a/ACg8ocJl6qcQWu8KCVRGGsR_HuSmv7OmSQKr5tZifYhDR3MwrpIweDY=s96-c','google','YOSEF Abdo','y01018025973@gmail.com',NULL,'$2y$12$K43Ru2JhAliRzSdSbCWeUO4X8tC5ohqc1EUjvOhrYnzkseS2wiQ.W',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-06 19:14:33','2026-08-06 19:16:14',2,'USD'),(23,NULL,NULL,NULL,'Rr Ss','ssr988629@gmail.com',NULL,'$2y$12$ym8GHcsUaFolRZISwMGm3.Vfb50Hn97ey9erb7OOUZUg1a4WcQ3NS',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-07 21:06:20','2026-08-07 21:06:20',2,'EGP'),(28,NULL,NULL,NULL,'Rr Ss','444@ee',NULL,'$2y$12$xviXPz67jKX9/vxEsqzb4ux9t9PRSy5.l2Df3CTudGe.EDjMf1j2.','01020975805',0,0,NULL,NULL,NULL,1,NULL,'2026-08-07 22:48:13','2026-08-07 22:50:27',5,'EGP'),(29,NULL,NULL,NULL,'Fares Safwat','safwatf73@gmail.com',NULL,'$2y$12$ApW8lT6wAdStL6Jtwju3WOBzzeKbA/GME.D3I2ss4wZX4dK2LXuKC',NULL,0,0,NULL,NULL,NULL,1,NULL,'2026-08-12 21:54:37','2026-08-12 21:54:47',2,'USD'),(30,NULL,NULL,NULL,'test@flfl-design.com','flfldesign.official@gmail.com',NULL,'$2y$12$EJ6V72h4.GdAN8538HNbMueYlIfLkiNGKyHxVI8ynggo8gVTQnW0K','01550095805',0,0,NULL,NULL,NULL,1,NULL,'2026-08-14 14:21:57','2026-08-14 18:49:26',5,'EGP');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_sessions`
--

DROP TABLE IF EXISTS `visitor_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitor_sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `session_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `traffic_source_id` int unsigned DEFAULT NULL,
  `device_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `converted` tinyint(1) NOT NULL DEFAULT '0',
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
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wishlist_user_id_product_id_unique` (`user_id`,`product_id`),
  KEY `wishlist_product_id_foreign` (`product_id`),
  CONSTRAINT `wishlist_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `wishlist_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
INSERT INTO `wishlist` VALUES (11,14,36),(13,16,70);
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-30 12:06:16
