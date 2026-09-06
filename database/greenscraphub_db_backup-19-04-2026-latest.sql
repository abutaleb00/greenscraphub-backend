/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: greenscraphub_db
-- ------------------------------------------------------
-- Server version	10.11.13-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
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
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) DEFAULT NULL,
  `platform` varchar(50) DEFAULT NULL,
  `browser` varchar(100) DEFAULT NULL,
  `os` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `metadata` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES
(1,2,'LOGIN','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','{\"status\":\"success\"}','2026-04-18 09:13:04'),
(2,23,'LOGIN','WEB','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{\"status\":\"success\"}','2026-04-18 11:43:28'),
(3,23,'CREATE_PICKUP','WEB','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{\"booking_code\":\"GS-108-1335\",\"pickup_id\":25,\"estimated_value\":\"320.00\"}','2026-04-18 11:45:01'),
(4,2,'LOGOUT','WEB','Chrome Mobile 147.0.0','Android 0.0.0','Generic Smartphone 0.0.0','127.0.0.1','{}','2026-04-18 11:49:20'),
(5,23,'LOGIN','ANDROID_APP','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{\"status\":\"success\"}','2026-04-19 05:26:26'),
(6,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 16 and all related pickup_items\"','2026-04-19 08:37:38'),
(7,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 17 and all related pickup_items\"','2026-04-19 08:37:41'),
(8,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 25 and all related pickup_items\"','2026-04-19 08:37:51'),
(9,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 23 and all related pickup_items\"','2026-04-19 08:37:54'),
(10,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 22 and all related pickup_items\"','2026-04-19 08:37:58'),
(11,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 21 and all related pickup_items\"','2026-04-19 08:38:01'),
(12,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 20 and all related pickup_items\"','2026-04-19 08:38:04'),
(13,2,'ADMIN_HARD_DELETE','WEB','Chrome 147.0.0','Windows 10.0.0','Other 0.0.0','127.0.0.1','\"Deleted Pickup ID: 19 and all related pickup_items\"','2026-04-19 08:38:07'),
(14,23,'LOGOUT','ANDROID_APP','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{}','2026-04-19 08:42:20'),
(15,23,'LOGIN','ANDROID_APP','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{\"status\":\"success\"}','2026-04-19 08:42:43'),
(16,23,'LOGOUT','ANDROID_APP','okhttp 4.9.2','Other 0.0.0','Other 0.0.0','127.0.0.1','{}','2026-04-19 08:45:10');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `label` varchar(50) DEFAULT 'Home',
  `address_line` varchar(255) NOT NULL,
  `landmark` varchar(255) DEFAULT NULL,
  `house_no` varchar(50) DEFAULT NULL,
  `road_no` varchar(50) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `division_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `upazila_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `division_id` (`division_id`),
  KEY `district_id` (`district_id`),
  KEY `idx_address_upazila` (`upazila_id`),
  KEY `idx_address_user` (`user_id`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  CONSTRAINT `addresses_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  CONSTRAINT `addresses_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`),
  CONSTRAINT `fk_user_address` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES
(6,17,'Business Hub','Hose 2, Mujguni Bashik',NULL,NULL,NULL,23.81030000,90.41250000,1,'2026-03-05 10:57:25','2026-03-05 10:57:25',NULL,NULL,NULL),
(7,18,'Business Hub','Notun rastar Mor, Khalishpur',NULL,NULL,NULL,23.81754445,90.41422026,1,'2026-03-05 10:59:15','2026-03-05 10:59:15',NULL,NULL,NULL),
(8,24,'Home','Professorpara',NULL,NULL,NULL,22.84655683,89.54179390,1,'2026-03-05 13:33:15','2026-03-05 13:39:27',3,4,108),
(9,23,'Home','Model Schrrol Road',NULL,NULL,NULL,22.84560000,89.54030000,1,'2026-03-05 13:36:34','2026-04-15 08:01:48',3,4,108),
(10,23,'Office','Newmarket Road, Shop 2',NULL,NULL,NULL,23.81030000,90.41250000,0,'2026-04-15 05:33:42','2026-04-15 08:01:27',3,1,93),
(11,29,'Home','Dhaka',NULL,NULL,NULL,22.84560000,89.54030000,0,'2026-04-17 19:13:02','2026-04-17 19:13:02',NULL,NULL,NULL),
(12,2,'Home','Bastuhara',NULL,NULL,NULL,23.81030000,90.41250000,0,'2026-04-18 11:48:51','2026-04-18 11:48:51',3,1,95);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_audit_logs`
--

DROP TABLE IF EXISTS `admin_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` bigint(20) unsigned NOT NULL,
  `action` varchar(100) DEFAULT NULL,
  `target_id` bigint(20) unsigned DEFAULT NULL,
  `old_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_value`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_audit_logs`
--

LOCK TABLES `admin_audit_logs` WRITE;
/*!40000 ALTER TABLE `admin_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_coverage`
--

DROP TABLE IF EXISTS `agent_coverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_coverage` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) unsigned NOT NULL,
  `upazila_id` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_agent_area` (`agent_id`,`upazila_id`),
  KEY `upazila_id` (`upazila_id`),
  CONSTRAINT `agent_coverage_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `agent_coverage_ibfk_2` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_coverage`
--

LOCK TABLES `agent_coverage` WRITE;
/*!40000 ALTER TABLE `agent_coverage` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_coverage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `owner_user_id` bigint(20) unsigned NOT NULL,
  `business_name` varchar(255) DEFAULT NULL,
  `company_name_en` varchar(150) NOT NULL,
  `company_name_bn` varchar(150) NOT NULL,
  `code` varchar(50) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `nid_number` varchar(20) DEFAULT NULL,
  `trade_license` varchar(50) DEFAULT NULL,
  `address_line` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `base_division_id` int(11) DEFAULT NULL,
  `base_district_id` int(11) DEFAULT NULL,
  `commission_type` enum('percentage','fixed') DEFAULT 'percentage',
  `commission_value` decimal(10,2) DEFAULT 0.00,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `default_rider_mode` enum('commission','salary') DEFAULT 'salary',
  `platform_fee_percent` decimal(5,2) DEFAULT 5.00,
  `hub_commission_type` enum('percentage','fixed') DEFAULT 'percentage',
  `hub_commission_value` decimal(10,2) DEFAULT 10.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `fk_agents_owner` (`owner_user_id`),
  KEY `base_division_id` (`base_division_id`),
  KEY `base_district_id` (`base_district_id`),
  CONSTRAINT `agents_ibfk_1` FOREIGN KEY (`base_division_id`) REFERENCES `divisions` (`id`),
  CONSTRAINT `agents_ibfk_2` FOREIGN KEY (`base_district_id`) REFERENCES `districts` (`id`),
  CONSTRAINT `fk_agents_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
INSERT INTO `agents` VALUES
(3,17,'SS Traders','','','AG-1JSSZ','agent1@example.com','01700000222',NULL,NULL,'Hose 2, Mujguni Bashik',23.81030000,90.41250000,NULL,NULL,'percentage',0.00,1,'salary',5.00,'percentage',10.00,'2026-03-05 16:57:25','2026-03-05 16:57:25'),
(4,18,'Three Brother','','','AG-WY7YA','agent2@example.com','01700000333',NULL,NULL,'Notun rastar Mor, Khalishpur',23.81754445,90.41422026,NULL,NULL,'percentage',0.00,1,'salary',5.00,'percentage',10.00,'2026-03-05 16:59:15','2026-03-05 16:59:15');
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_inquiries`
--

DROP TABLE IF EXISTS `contact_inquiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_inquiries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `inquiry_type` varchar(100) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('pending','read','replied') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_inquiries`
--

LOCK TABLES `contact_inquiries` WRITE;
/*!40000 ALTER TABLE `contact_inquiries` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_inquiries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corporate_leads`
--

DROP TABLE IF EXISTS `corporate_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `corporate_leads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('unread','read','contacted','resolved') DEFAULT 'unread',
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corporate_leads`
--

LOCK TABLES `corporate_leads` WRITE;
/*!40000 ALTER TABLE `corporate_leads` DISABLE KEYS */;
/*!40000 ALTER TABLE `corporate_leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `preferred_language` enum('en','bn') DEFAULT 'en',
  `total_points` int(11) DEFAULT 0,
  `total_pickups_completed` int(10) unsigned DEFAULT 0,
  `default_address_id` bigint(20) unsigned DEFAULT NULL,
  `referral_code` varchar(50) DEFAULT NULL,
  `referred_by` bigint(20) unsigned DEFAULT NULL,
  `status` enum('active','suspended','blacklisted') DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `referral_code` (`referral_code`),
  KEY `fk_customer_default_address` (`default_address_id`),
  KEY `idx_customer_referral` (`referral_code`),
  KEY `idx_customer_user` (`user_id`),
  CONSTRAINT `fk_customer_default_address` FOREIGN KEY (`default_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_customers_default_address` FOREIGN KEY (`default_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_customers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
(6,23,'en',20,0,9,'GSR3HFB',NULL,'active','2026-03-05 17:04:34','2026-04-15 08:01:27'),
(7,24,'en',20,0,NULL,'GSPDH3K',NULL,'active','2026-03-05 17:05:32','2026-03-05 17:05:32'),
(9,29,'en',20,0,NULL,'GSQQ5P9',NULL,'active','2026-04-17 19:12:01','2026-04-17 19:12:01');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_tokens`
--

DROP TABLE IF EXISTS `device_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `device_type` enum('android','ios','web') NOT NULL,
  `fcm_token` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_device_tokens_user` (`user_id`),
  CONSTRAINT `fk_device_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_tokens`
--

LOCK TABLES `device_tokens` WRITE;
/*!40000 ALTER TABLE `device_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `districts`
--

DROP TABLE IF EXISTS `districts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `districts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `division_id` int(11) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `division_id` (`division_id`),
  CONSTRAINT `districts_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `districts`
--

LOCK TABLES `districts` WRITE;
/*!40000 ALTER TABLE `districts` DISABLE KEYS */;
INSERT INTO `districts` VALUES
(1,3,'Khulna','খুলনা',1),
(2,3,'Bagerhat','বাগেরহাট',1),
(3,3,'Chuadanga','চুয়াডাঙ্গা',1),
(4,3,'Jashore','যশোর',1),
(5,3,'Jhenaidah','ঝিনাইদহ',1),
(6,3,'Kushtia','কুষ্টিয়া',1),
(7,3,'Magura','মাগুরা',1),
(8,3,'Meherpur','মেহেরপুর',1),
(9,3,'Narail','নড়াইল',1),
(10,3,'Satkhira','সাতক্ষীরা',1);
/*!40000 ALTER TABLE `districts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `divisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `status` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `divisions`
--

LOCK TABLES `divisions` WRITE;
/*!40000 ALTER TABLE `divisions` DISABLE KEYS */;
INSERT INTO `divisions` VALUES
(3,'Khulna','খুলনা',1);
/*!40000 ALTER TABLE `divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_ledger`
--

DROP TABLE IF EXISTS `financial_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_ledger` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source_type` varchar(50) DEFAULT 'pickup',
  `source_id` int(11) DEFAULT NULL,
  `pickup_id` bigint(20) unsigned DEFAULT NULL,
  `wallet_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `total_volume` decimal(15,2) DEFAULT 0.00,
  `debit` decimal(12,2) DEFAULT 0.00,
  `credit` decimal(12,2) DEFAULT 0.00,
  `balance_snapshot` decimal(12,2) NOT NULL,
  `entry_type` enum('commission','payout','adjustment','platform_fee') NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `admin_commission` decimal(15,2) DEFAULT 0.00,
  `agent_commission` decimal(15,2) DEFAULT 0.00,
  `rider_commission` decimal(15,2) DEFAULT 0.00,
  `net_payout` decimal(15,2) DEFAULT 0.00,
  `payment_method` varchar(20) DEFAULT 'cash',
  PRIMARY KEY (`id`),
  KEY `wallet_id` (`wallet_id`),
  KEY `transaction_id` (`transaction_id`),
  CONSTRAINT `financial_ledger_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`),
  CONSTRAINT `financial_ledger_ibfk_2` FOREIGN KEY (`transaction_id`) REFERENCES `wallet_transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_ledger`
--

LOCK TABLES `financial_ledger` WRITE;
/*!40000 ALTER TABLE `financial_ledger` DISABLE KEYS */;
INSERT INTO `financial_ledger` VALUES
(10,'cash_settlement',5,NULL,8,3,0.00,0.00,2350.00,0.00,'','Hub Vault Intake: Full Settlement','2026-03-05 18:08:13',0.00,0.00,0.00,0.00,'cash');
/*!40000 ALTER TABLE `financial_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hub_inventory`
--

DROP TABLE IF EXISTS `hub_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hub_inventory` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) unsigned NOT NULL,
  `category_id` bigint(20) unsigned NOT NULL,
  `current_weight` decimal(15,2) DEFAULT 0.00,
  `last_updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_category` (`agent_id`,`category_id`),
  KEY `fk_hub_inv_category` (`category_id`),
  CONSTRAINT `fk_hub_inv_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hub_inv_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hub_inventory`
--

LOCK TABLES `hub_inventory` WRITE;
/*!40000 ALTER TABLE `hub_inventory` DISABLE KEYS */;
INSERT INTO `hub_inventory` VALUES
(3,4,1,2.00,'2026-03-05 18:08:13'),
(4,4,2,1.00,'2026-03-05 18:18:31'),
(5,4,4,1.00,'2026-03-05 18:08:13');
/*!40000 ALTER TABLE `hub_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hub_release_items`
--

DROP TABLE IF EXISTS `hub_release_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hub_release_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `release_id` bigint(20) unsigned NOT NULL,
  `category_id` bigint(20) unsigned NOT NULL,
  `weight_released` decimal(15,2) NOT NULL,
  `sale_price_per_kg` decimal(15,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ritems_release` (`release_id`),
  KEY `fk_ritems_category` (`category_id`),
  CONSTRAINT `fk_ritems_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ritems_release` FOREIGN KEY (`release_id`) REFERENCES `hub_releases` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hub_release_items`
--

LOCK TABLES `hub_release_items` WRITE;
/*!40000 ALTER TABLE `hub_release_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `hub_release_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hub_releases`
--

DROP TABLE IF EXISTS `hub_releases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hub_releases` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) unsigned NOT NULL,
  `total_revenue` decimal(15,2) NOT NULL,
  `status` enum('pending','sold','cancelled') DEFAULT 'sold',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_release_agent_id` (`agent_id`),
  CONSTRAINT `fk_release_agent_id` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hub_releases`
--

LOCK TABLES `hub_releases` WRITE;
/*!40000 ALTER TABLE `hub_releases` DISABLE KEYS */;
INSERT INTO `hub_releases` VALUES
(1,4,106.00,'sold','2026-03-05 18:18:31');
/*!40000 ALTER TABLE `hub_releases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_price_overrides`
--

DROP TABLE IF EXISTS `item_price_overrides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_price_overrides` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_id` bigint(20) unsigned NOT NULL,
  `division_id` bigint(20) unsigned DEFAULT NULL,
  `district_id` bigint(20) unsigned DEFAULT NULL,
  `upazila_id` bigint(20) unsigned DEFAULT NULL,
  `min_rate` decimal(10,2) NOT NULL,
  `max_rate` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_regional_lookup` (`item_id`,`upazila_id`,`district_id`,`division_id`),
  CONSTRAINT `fk_override_to_item` FOREIGN KEY (`item_id`) REFERENCES `scrap_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_price_overrides`
--

LOCK TABLES `item_price_overrides` WRITE;
/*!40000 ALTER TABLE `item_price_overrides` DISABLE KEYS */;
INSERT INTO `item_price_overrides` VALUES
(8,9,3,1,95,46.00,50.00,1,'2026-03-22 15:22:31','2026-03-22 15:22:31'),
(9,9,3,4,108,48.00,57.00,1,'2026-03-22 15:23:19','2026-03-22 15:23:19');
/*!40000 ALTER TABLE `item_price_overrides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title_key` varchar(100) NOT NULL,
  `body_key` varchar(255) NOT NULL,
  `body_placeholders` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`body_placeholders`)),
  `notification_type` enum('info','alert','success','warning') DEFAULT 'info',
  `click_action` varchar(255) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_notifications_user_read` (`user_id`,`is_read`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_requests`
--

DROP TABLE IF EXISTS `payout_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `user_type` enum('agent','rider') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `fee_amount` decimal(10,2) DEFAULT 0.00,
  `net_amount` decimal(12,2) GENERATED ALWAYS AS (`amount` - `fee_amount`) VIRTUAL,
  `payment_method` enum('bkash','nagad','rocket','bank_transfer') NOT NULL,
  `account_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`account_details`)),
  `status` enum('pending','processing','completed','rejected','cancelled') DEFAULT 'pending',
  `transaction_id` varchar(100) DEFAULT NULL,
  `admin_note` text DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  `processed_by` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `processed_by` (`processed_by`),
  KEY `idx_payout_pending` (`status`,`requested_at`),
  CONSTRAINT `payout_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `payout_requests_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_requests`
--

LOCK TABLES `payout_requests` WRITE;
/*!40000 ALTER TABLE `payout_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `payout_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup_area_stats`
--

DROP TABLE IF EXISTS `pickup_area_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_area_stats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `area` varchar(150) NOT NULL,
  `city` varchar(150) DEFAULT NULL,
  `agent_id` bigint(20) unsigned DEFAULT NULL,
  `total_pickups` int(10) unsigned NOT NULL DEFAULT 0,
  `total_weight` decimal(12,3) NOT NULL DEFAULT 0.000,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `period_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_area_period_agent` (`area`,`period_date`,`agent_id`),
  KEY `fk_pickup_area_stats_agent` (`agent_id`),
  CONSTRAINT `fk_pickup_area_stats_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup_area_stats`
--

LOCK TABLES `pickup_area_stats` WRITE;
/*!40000 ALTER TABLE `pickup_area_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `pickup_area_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup_items`
--

DROP TABLE IF EXISTS `pickup_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pickup_id` bigint(20) unsigned NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `item_note` text DEFAULT NULL,
  `estimated_weight` decimal(10,3) NOT NULL DEFAULT 0.000,
  `actual_weight` decimal(10,2) DEFAULT 0.00,
  `final_rate_per_unit` decimal(10,2) DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `item_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pickup_items_pickup` (`pickup_id`),
  CONSTRAINT `fk_pickup_items_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup_items`
--

LOCK TABLES `pickup_items` WRITE;
/*!40000 ALTER TABLE `pickup_items` DISABLE KEYS */;
INSERT INTO `pickup_items` VALUES
(1,1,'[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]',NULL,2.000,2.00,800.00,1600.00,'2026-03-05 20:25:45','2026-03-05 22:45:39',1,5),
(2,1,'[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]',NULL,3.000,3.00,50.00,150.00,'2026-03-05 20:25:45','2026-03-05 22:45:39',2,9),
(3,1,'[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]',NULL,1.000,1.00,600.00,600.00,'2026-03-05 20:25:45','2026-03-05 22:45:39',4,11),
(4,2,'[\"/uploads/pickups/photos-1772733513656-12662644.png\"]',NULL,4.000,1.00,2334.00,2334.00,'2026-03-05 23:58:33','2026-03-09 16:35:51',5,6),
(5,3,'[\"/uploads/pickups/item_photos[0]-1772866791706-880120334.jpg\"]',NULL,13.000,13.00,10.00,130.00,'2026-03-07 12:59:51','2026-03-07 14:18:56',7,8),
(11,7,'[\"/uploads/pickups/item_photos_0-1773072622743-292100054.jpg\"]',NULL,15.000,15.00,10.00,150.00,'2026-03-09 16:10:22','2026-03-09 16:37:38',7,8),
(12,8,'[\"/uploads/pickups/photos-1773425443796-646870816.png\"]',NULL,1.000,1.00,10.00,10.00,'2026-03-13 18:10:43','2026-03-14 14:33:13',7,8),
(13,9,'[\"/uploads/pickups/photos-1773503565719-336669195.jpg\"]',NULL,12.000,12.00,120.00,1440.00,'2026-03-14 15:52:45','2026-03-14 16:02:06',7,8),
(14,9,NULL,NULL,0.000,1.00,900.00,900.00,'2026-03-14 16:02:06','2026-03-14 16:02:06',NULL,11),
(15,10,'[\"/uploads/pickups/photos-1773599939387-74135093.png\"]',NULL,12.000,12.00,10.00,120.00,'2026-03-15 18:38:59','2026-04-15 03:40:22',7,8),
(16,11,'[]',NULL,1.000,1.00,10.00,10.00,'2026-03-15 19:05:27','2026-04-15 03:29:35',7,8),
(17,11,'[]',NULL,1.000,1.00,600.00,600.00,'2026-03-15 19:05:27','2026-04-15 03:29:35',4,11),
(18,12,'[]',NULL,45.000,43.00,550.00,23650.00,'2026-03-15 19:14:39','2026-03-22 15:08:46',4,11),
(19,12,NULL,NULL,0.000,600.00,1.00,600.00,'2026-03-22 15:08:46','2026-03-22 15:08:46',NULL,6),
(20,13,'[\"/uploads/pickups/photos-1774550430093-323011035.jpg\"]',NULL,1.000,2.00,110.00,220.00,'2026-03-26 18:40:30','2026-03-26 18:58:44',5,6),
(21,13,NULL,NULL,0.000,10.00,50.00,500.00,'2026-03-26 18:58:44','2026-03-26 18:58:44',NULL,11),
(22,14,'[\"/uploads/pickups/photos-1776170519459-985750907.png\"]',NULL,1.000,1.00,300.00,300.00,'2026-04-14 12:41:59','2026-04-15 03:56:03',5,10),
(23,14,'[\"/uploads/pickups/photos-1776170519459-985750907.png\"]',NULL,2.000,2.00,120.00,240.00,'2026-04-14 12:41:59','2026-04-15 03:56:03',5,6),
(24,15,'[\"/uploads/pickups/item_photos_0-1776211821796-189763878.jpg\",\"/uploads/pickups/item_photos_0-1776211821807-178505153.jpg\"]',NULL,3.000,3.00,600.00,1800.00,'2026-04-15 00:10:21','2026-04-15 19:26:44',4,11),
(25,15,'[\"/uploads/pickups/item_photos_1-1776211821812-328263436.jpg\"]',NULL,1.000,1.00,50.00,50.00,'2026-04-15 00:10:21','2026-04-15 19:26:44',2,9),
(29,18,'[\"/uploads/pickups/item_photos_0-1776280411583-467894315.jpg\"]',NULL,6.000,7.00,12.00,84.00,'2026-04-15 19:13:31','2026-04-15 19:30:37',3,4),
(30,18,'[]',NULL,10.000,9.00,11.00,99.00,'2026-04-15 19:13:31','2026-04-15 19:30:37',3,13),
(31,18,NULL,NULL,0.000,2.00,25.00,50.00,'2026-04-15 19:30:37','2026-04-15 19:30:37',NULL,12),
(42,24,'[]',NULL,1.000,0.00,300.00,300.00,'2026-04-17 19:13:17','2026-04-17 19:13:17',5,10);
/*!40000 ALTER TABLE `pickup_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup_status_logs`
--

DROP TABLE IF EXISTS `pickup_status_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_status_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pickup_id` bigint(20) unsigned NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` bigint(20) unsigned DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_pickup_status_logs_pickup` (`pickup_id`),
  KEY `fk_pickup_status_logs_user` (`changed_by`),
  CONSTRAINT `fk_pickup_status_logs_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`),
  CONSTRAINT `fk_pickup_status_logs_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup_status_logs`
--

LOCK TABLES `pickup_status_logs` WRITE;
/*!40000 ALTER TABLE `pickup_status_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `pickup_status_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup_timeline`
--

DROP TABLE IF EXISTS `pickup_timeline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_timeline` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pickup_id` bigint(20) unsigned NOT NULL,
  `status` varchar(50) NOT NULL,
  `note` text DEFAULT NULL,
  `changed_by` bigint(20) unsigned NOT NULL,
  `lat_at_time` decimal(10,8) DEFAULT NULL,
  `lng_at_time` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pickup_id` (`pickup_id`),
  CONSTRAINT `pickup_timeline_ibfk_1` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup_timeline`
--

LOCK TABLES `pickup_timeline` WRITE;
/*!40000 ALTER TABLE `pickup_timeline` DISABLE KEYS */;
INSERT INTO `pickup_timeline` VALUES
(9,1,'pending','Shipment request created by customer',0,NULL,NULL,'2026-03-05 14:25:45'),
(10,1,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-05 15:23:41'),
(11,1,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-05 16:26:22'),
(12,1,'completed','Finalized. Settlement: ৳2350 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-05 16:45:39'),
(13,2,'pending','Shipment request created by customer',0,NULL,NULL,'2026-03-05 17:58:33'),
(14,1,'completed','Handover confirmed by Agent. Items moved to Hub Inventory.',18,NULL,NULL,'2026-03-05 18:08:13'),
(15,3,'pending','Shipment request created by customer',0,NULL,NULL,'2026-03-07 06:59:51'),
(16,2,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-07 07:41:27'),
(17,2,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-03-07 07:42:20'),
(18,2,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-07 07:43:11'),
(19,3,'accepted','Dispatched to Rider: Rider 4',17,NULL,NULL,'2026-03-07 07:44:22'),
(20,3,'rider_on_way','Rider marked status as: rider on way',22,NULL,NULL,'2026-03-07 07:44:54'),
(21,3,'arrived','Rider marked status as: arrived',22,NULL,NULL,'2026-03-07 07:45:06'),
(22,3,'completed','Finalized. Settlement: ৳130 via CASH. Mode: commission.',22,NULL,NULL,'2026-03-07 08:18:56'),
(23,7,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-09 16:10:22'),
(24,7,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-09 16:25:06'),
(25,7,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-03-09 16:26:43'),
(26,7,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-09 16:26:53'),
(27,2,'completed','Finalized. Settlement: ৳2334 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-09 16:35:51'),
(28,7,'completed','Finalized. Settlement: ৳150 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-09 16:37:38'),
(29,8,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-13 18:10:43'),
(30,8,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-13 18:12:42'),
(31,8,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-03-14 11:16:00'),
(32,8,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-14 11:22:51'),
(33,8,'completed','Finalized. Settlement: ৳10 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-14 14:33:13'),
(34,9,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-14 15:52:45'),
(35,9,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-14 15:53:34'),
(36,9,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-03-14 15:54:06'),
(37,9,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-14 15:54:23'),
(38,9,'weighing','Rider marked status as: weighing',19,NULL,NULL,'2026-03-14 15:54:55'),
(39,9,'completed','Finalized. Settlement: ৳2340 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-14 16:02:06'),
(40,10,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-15 18:38:59'),
(41,11,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-15 19:05:27'),
(42,12,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-15 19:14:39'),
(43,12,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-22 15:05:15'),
(44,11,'accepted','Dispatched to Rider: Rider 1',18,NULL,NULL,'2026-03-22 15:05:26'),
(45,12,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-03-22 15:06:24'),
(46,12,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-03-22 15:07:13'),
(47,12,'weighing','Rider marked status as: weighing',19,NULL,NULL,'2026-03-22 15:08:35'),
(48,12,'completed','Finalized. Settlement: ৳24250 via CASH. Mode: salary.',19,NULL,NULL,'2026-03-22 15:08:46'),
(49,10,'accepted','Dispatched to Rider: Rider 2',18,NULL,NULL,'2026-03-22 15:15:38'),
(50,13,'pending','Shipment request created by customer',23,NULL,NULL,'2026-03-26 18:40:30'),
(51,13,'accepted','Dispatched to Rider: Rider 3 pro',17,NULL,NULL,'2026-03-26 18:53:40'),
(52,13,'rider_on_way','Rider marked status as: rider on way',21,NULL,NULL,'2026-03-26 18:56:07'),
(53,13,'arrived','Rider marked status as: arrived',21,NULL,NULL,'2026-03-26 18:57:03'),
(54,13,'completed','Finalized. Settlement: ৳720 via CASH. Mode: salary.',21,NULL,NULL,'2026-03-26 18:58:44'),
(55,14,'pending','Shipment request created by customer',23,NULL,NULL,'2026-04-14 12:41:59'),
(56,15,'pending','Shipment request created by customer',23,NULL,NULL,'2026-04-15 00:10:21'),
(57,15,'accepted','Dispatched to Rider: Rider 3 pro',17,NULL,NULL,'2026-04-15 01:34:10'),
(58,14,'accepted','Dispatched to Rider: Rider 3 pro',17,NULL,NULL,'2026-04-15 03:08:15'),
(59,11,'rider_on_way','Rider marked status as: rider on way',19,NULL,NULL,'2026-04-15 03:13:08'),
(60,11,'arrived','Rider marked status as: arrived',19,NULL,NULL,'2026-04-15 03:16:42'),
(61,11,'completed','Finalized. Settlement: ৳610 via CASH. Mode: salary.',19,NULL,NULL,'2026-04-15 03:29:35'),
(62,10,'rider_on_way','Rider marked status as: rider on way',20,NULL,NULL,'2026-04-15 03:36:37'),
(63,10,'arrived','Rider marked status as: arrived',20,NULL,NULL,'2026-04-15 03:37:04'),
(64,10,'completed','Finalized. Settlement: ৳120 via CASH. Mode: salary.',20,NULL,NULL,'2026-04-15 03:40:22'),
(65,14,'rider_on_way','Rider marked status as: rider on way',21,NULL,NULL,'2026-04-15 03:45:39'),
(66,14,'arrived','Rider marked status as: arrived',21,NULL,NULL,'2026-04-15 03:51:25'),
(67,14,'completed','Finalized. ৳540 via CASH.',21,NULL,NULL,'2026-04-15 03:56:03'),
(68,14,'completed','Finalized. ৳540 via CASH.',21,NULL,NULL,'2026-04-15 03:56:41'),
(69,14,'completed','Finalized. ৳540 via CASH.',21,NULL,NULL,'2026-04-15 04:00:39'),
(70,14,'completed','Finalized. ৳540 via CASH.',21,NULL,NULL,'2026-04-15 04:01:04'),
(71,14,'completed','Finalized. ৳540 via CASH.',21,NULL,NULL,'2026-04-15 04:04:30'),
(72,15,'rider_on_way','Rider marked status as: rider on way',21,NULL,NULL,'2026-04-15 04:05:18'),
(75,18,'pending','Shipment request created by customer',23,NULL,NULL,'2026-04-15 19:13:31'),
(76,18,'accepted','Dispatched to Rider: Rider 3 pro',17,NULL,NULL,'2026-04-15 19:17:41'),
(77,15,'arrived','Rider marked status as: arrived',21,NULL,NULL,'2026-04-15 19:19:32'),
(78,15,'weighing','Rider marked status as: weighing',21,NULL,NULL,'2026-04-15 19:26:23'),
(79,15,'completed','Finalized. ৳1850 via CASH.',21,NULL,NULL,'2026-04-15 19:26:44'),
(80,18,'rider_on_way','Rider marked status as: rider on way',21,NULL,NULL,'2026-04-15 19:29:22'),
(81,18,'arrived','Rider marked status as: arrived',21,NULL,NULL,'2026-04-15 19:29:26'),
(82,18,'weighing','Rider marked status as: weighing',21,NULL,NULL,'2026-04-15 19:30:12'),
(83,18,'completed','Finalized. ৳233 via CASH.',21,NULL,NULL,'2026-04-15 19:30:37'),
(89,24,'pending','Shipment request created by customer',29,NULL,NULL,'2026-04-17 19:13:17');
/*!40000 ALTER TABLE `pickup_timeline` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickups`
--

DROP TABLE IF EXISTS `pickups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `booking_code` varchar(50) NOT NULL,
  `customer_id` bigint(20) unsigned NOT NULL,
  `customer_address_id` bigint(20) unsigned DEFAULT NULL,
  `agent_id` bigint(20) unsigned DEFAULT NULL,
  `rider_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('pending','assigned','accepted','rider_on_way','arrived','weighing','completed','cancelled') DEFAULT 'pending',
  `payment_status` enum('unpaid','paid','partially_paid','refunded') NOT NULL DEFAULT 'unpaid',
  `payment_method` enum('cash','wallet','bank','mobile_banking','mixed') DEFAULT NULL,
  `payment_mode_snapshot` enum('commission','salary') DEFAULT NULL,
  `scheduled_date` date DEFAULT NULL,
  `scheduled_time_slot` varchar(50) DEFAULT NULL,
  `customer_note` varchar(255) DEFAULT NULL,
  `admin_note` varchar(255) DEFAULT NULL,
  `base_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_payable_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `admin_commission_amount` decimal(10,2) DEFAULT 0.00,
  `wallet_credit_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cash_paid_to_customer` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rider_collected_cash` decimal(10,2) NOT NULL DEFAULT 0.00,
  `is_settled_to_hub` tinyint(1) DEFAULT 0,
  `agent_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rider_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `platform_fee_amount` decimal(10,2) DEFAULT 0.00,
  `invoice_number` varchar(50) DEFAULT NULL,
  `proof_image_before` varchar(255) DEFAULT NULL,
  `proof_image_after` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `assigned_at` datetime DEFAULT NULL,
  `rider_arrived_at` datetime DEFAULT NULL,
  `weighing_started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by_user_id` bigint(20) unsigned DEFAULT NULL,
  `is_deleted` tinyint(4) DEFAULT 0,
  `pickup_type` enum('scheduled','instant') DEFAULT 'scheduled',
  `division_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `upazila_id` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_code` (`booking_code`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `fk_pickups_customer` (`customer_id`),
  KEY `fk_pickups_agent` (`agent_id`),
  KEY `fk_pickups_cancelled_by` (`cancelled_by_user_id`),
  KEY `fk_pickups_address` (`customer_address_id`),
  KEY `division_id` (`division_id`),
  KEY `district_id` (`district_id`),
  KEY `idx_pickup_routing` (`upazila_id`,`status`),
  KEY `idx_pickup_status_geo` (`status`,`upazila_id`),
  KEY `idx_pickup_settlement` (`rider_id`,`status`,`is_settled_to_hub`),
  CONSTRAINT `fk_pickups_address` FOREIGN KEY (`customer_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_pickups_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  CONSTRAINT `fk_pickups_cancelled_by` FOREIGN KEY (`cancelled_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_pickups_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_pickups_rider` FOREIGN KEY (`rider_id`) REFERENCES `riders` (`id`),
  CONSTRAINT `pickups_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  CONSTRAINT `pickups_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  CONSTRAINT `pickups_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickups`
--

LOCK TABLES `pickups` WRITE;
/*!40000 ALTER TABLE `pickups` DISABLE KEYS */;
INSERT INTO `pickups` VALUES
(1,'GS-96-5631',6,9,4,5,'completed','paid',NULL,'salary','2026-03-06','10:00 AM - 12:00 PM',NULL,NULL,2350.00,2350.00,0.00,0.00,0.00,2350.00,1,235.00,0.00,117.50,NULL,NULL,NULL,'2026-03-05 20:25:45','2026-03-06 00:08:13','2026-03-05 21:23:41','2026-03-05 22:26:22',NULL,'2026-03-05 22:45:39',NULL,NULL,0,'scheduled',3,1,96,0),
(2,'GS-96-3671',6,9,4,5,'completed','paid',NULL,'salary','2026-03-20','10:00 AM - 12:00 PM',NULL,NULL,480.00,2334.00,0.00,0.00,0.00,2334.00,0,233.40,0.00,116.70,NULL,NULL,NULL,'2026-03-05 23:58:33','2026-03-09 16:35:51','2026-03-07 13:41:27','2026-03-07 13:43:11',NULL,'2026-03-09 16:35:51',NULL,NULL,0,'scheduled',3,1,96,0),
(3,'GS-96-1889',6,9,3,8,'completed','paid',NULL,'commission','2026-03-07','10:00 AM - 06:00 PM','',NULL,130.00,130.00,0.00,0.00,0.00,130.00,0,13.00,2.60,6.50,NULL,NULL,NULL,'2026-03-07 12:59:51','2026-03-07 14:18:56','2026-03-07 13:44:22','2026-03-07 13:45:06',NULL,'2026-03-07 14:18:56',NULL,NULL,0,'scheduled',3,1,96,0),
(7,'GS-96-2750',6,9,4,5,'completed','paid',NULL,'salary','2026-03-09','10:00 AM - 06:00 PM','',NULL,150.00,150.00,0.00,0.00,0.00,150.00,0,15.00,0.00,7.50,NULL,NULL,NULL,'2026-03-09 16:10:22','2026-03-09 16:37:38','2026-03-09 16:25:06','2026-03-09 16:26:53',NULL,'2026-03-09 16:37:38',NULL,NULL,0,'scheduled',3,1,96,0),
(8,'GS-96-3802',6,9,4,5,'completed','paid',NULL,'salary','2026-03-15','10:00 AM - 12:00 PM',NULL,NULL,10.00,10.00,0.00,0.00,0.00,10.00,0,1.00,0.00,0.50,NULL,NULL,NULL,'2026-03-13 18:10:43','2026-03-14 14:33:13','2026-03-13 18:12:42','2026-03-14 11:22:51',NULL,'2026-03-14 14:33:13',NULL,NULL,0,'scheduled',3,1,96,0),
(9,'GS-96-5726',6,9,4,5,'completed','paid',NULL,'salary','2026-03-15','10:00 AM - 12:00 PM',NULL,NULL,120.00,2340.00,0.00,0.00,0.00,2340.00,0,234.00,0.00,117.00,NULL,NULL,NULL,'2026-03-14 15:52:45','2026-03-14 16:02:06','2026-03-14 15:53:34','2026-03-14 15:54:23','2026-03-14 15:54:55','2026-03-14 16:02:06',NULL,NULL,0,'scheduled',3,1,96,0),
(10,'GS-96-9399',6,9,4,6,'completed','paid',NULL,'salary','2026-03-18','12:00 PM - 02:00 PM',NULL,NULL,120.00,120.00,0.00,0.00,0.00,120.00,0,12.00,0.00,6.00,NULL,NULL,NULL,'2026-03-15 18:38:59','2026-04-15 03:40:22','2026-03-22 15:15:38','2026-04-15 03:37:04',NULL,'2026-04-15 03:40:22',NULL,NULL,0,'scheduled',3,1,96,0),
(11,'GS-96-7465',6,9,4,5,'completed','paid',NULL,'salary','2026-03-17','10:00 AM - 12:00 PM',NULL,NULL,610.00,610.00,0.00,0.00,0.00,610.00,0,61.00,0.00,30.50,NULL,NULL,NULL,'2026-03-15 19:05:27','2026-04-15 03:29:35','2026-03-22 15:05:26','2026-04-15 03:16:42',NULL,'2026-04-15 03:29:35',NULL,NULL,0,'scheduled',3,1,96,0),
(12,'GS-96-9371',6,9,4,5,'completed','paid',NULL,'salary','2026-03-17','10:00 AM - 12:00 PM',NULL,NULL,27000.00,24250.00,0.00,0.00,0.00,24250.00,0,2425.00,0.00,1212.50,NULL,NULL,NULL,'2026-03-15 19:14:39','2026-03-22 15:08:46','2026-03-22 15:05:15','2026-03-22 15:07:13','2026-03-22 15:08:35','2026-03-22 15:08:46',NULL,NULL,0,'scheduled',3,1,96,0),
(13,'GS-96-0102',6,9,3,7,'completed','paid',NULL,'salary','2026-03-27','12:00 PM - 02:00 PM',NULL,NULL,120.00,720.00,0.00,0.00,0.00,720.00,0,72.00,0.00,36.00,NULL,NULL,NULL,'2026-03-26 18:40:30','2026-03-26 18:58:44','2026-03-26 18:53:40','2026-03-26 18:57:03',NULL,'2026-03-26 18:58:44',NULL,NULL,0,'scheduled',3,1,96,0),
(14,'GS-96-9474',6,9,3,7,'completed','paid',NULL,'salary','2026-04-15','12:00 PM - 02:00 PM',NULL,NULL,540.00,540.00,0.00,0.00,0.00,540.00,0,54.00,0.00,27.00,NULL,NULL,NULL,'2026-04-14 12:41:59','2026-04-15 04:04:30','2026-04-15 03:08:15','2026-04-15 03:51:25',NULL,'2026-04-15 04:04:30',NULL,NULL,0,'scheduled',3,1,96,0),
(15,'GS-96-1833',6,9,3,7,'completed','paid',NULL,'salary','2026-04-15','02:00 PM - 04:00 PM','Call me before come',NULL,1848.00,1850.00,0.00,0.00,0.00,1850.00,0,185.00,0.00,92.50,NULL,NULL,NULL,'2026-04-15 00:10:21','2026-04-15 19:26:44','2026-04-15 01:34:10','2026-04-15 19:19:32','2026-04-15 19:26:23','2026-04-15 19:26:44',NULL,NULL,0,'scheduled',3,1,96,0),
(18,'GS-108-1593',6,9,3,7,'completed','paid',NULL,'salary','2026-04-16','12:00 PM - 02:00 PM','Please come quickly',NULL,180.00,233.00,0.00,0.00,0.00,233.00,0,23.30,0.00,11.65,NULL,NULL,NULL,'2026-04-15 19:13:31','2026-04-15 19:30:37','2026-04-15 19:17:41','2026-04-15 19:29:26','2026-04-15 19:30:12','2026-04-15 19:30:37',NULL,NULL,0,'scheduled',3,4,108,0),
(24,'GS-0-7931',9,11,NULL,NULL,'pending','unpaid',NULL,NULL,'2026-04-24','02:00 PM - 04:00 PM',NULL,NULL,300.00,0.00,0.00,0.00,0.00,0.00,0,0.00,0.00,0.00,NULL,NULL,NULL,'2026-04-17 19:13:17','2026-04-17 19:13:17',NULL,NULL,NULL,NULL,NULL,NULL,0,'scheduled',NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `pickups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_earnings`
--

DROP TABLE IF EXISTS `platform_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_earnings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pickup_id` bigint(20) unsigned NOT NULL,
  `gross_revenue` decimal(12,2) DEFAULT NULL,
  `customer_payout` decimal(12,2) DEFAULT NULL,
  `rider_commission` decimal(10,2) DEFAULT NULL,
  `agent_commission` decimal(10,2) DEFAULT NULL,
  `net_profit` decimal(12,2) GENERATED ALWAYS AS (`gross_revenue` - `customer_payout` - `rider_commission` - `agent_commission`) VIRTUAL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_earnings`
--

LOCK TABLES `platform_earnings` WRITE;
/*!40000 ALTER TABLE `platform_earnings` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform_earnings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_transactions`
--

DROP TABLE IF EXISTS `point_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) unsigned NOT NULL,
  `amount` int(11) NOT NULL,
  `type` enum('referral','milestone','redemption','bonus') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_points` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_transactions`
--

LOCK TABLES `point_transactions` WRITE;
/*!40000 ALTER TABLE `point_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `point_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rider_locations`
--

DROP TABLE IF EXISTS `rider_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `rider_locations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rider_id` bigint(20) unsigned NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_rider_locations_rider` (`rider_id`),
  KEY `idx_rider_locations_latlng` (`latitude`,`longitude`),
  CONSTRAINT `fk_rider_locations_rider` FOREIGN KEY (`rider_id`) REFERENCES `riders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rider_locations`
--

LOCK TABLES `rider_locations` WRITE;
/*!40000 ALTER TABLE `rider_locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `rider_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `riders`
--

DROP TABLE IF EXISTS `riders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `riders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `preferred_language` enum('en','bn') DEFAULT 'bn',
  `agent_id` bigint(20) unsigned NOT NULL,
  `vehicle_type` enum('bicycle','van','motorcycle','truck') NOT NULL,
  `vehicle_number` varchar(50) DEFAULT NULL,
  `national_id` varchar(100) DEFAULT NULL,
  `emergency_contact` varchar(50) DEFAULT NULL,
  `rating_avg` decimal(3,2) DEFAULT 0.00,
  `total_completed` int(10) unsigned DEFAULT 0,
  `is_online` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `profile_status` enum('pending','verified','suspended','rejected') DEFAULT 'pending',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `current_latitude` decimal(10,8) DEFAULT NULL,
  `current_longitude` decimal(11,8) DEFAULT NULL,
  `status` enum('offline','available','on_pickup','busy') DEFAULT 'offline',
  `division_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `upazila_id` int(11) DEFAULT NULL,
  `base_upazila_id` int(11) NOT NULL,
  `payment_mode` enum('commission','salary','default') DEFAULT 'default' COMMENT 'commission: per task, salary: monthly fixed, default: follow hub setting',
  PRIMARY KEY (`id`),
  KEY `fk_riders_user` (`user_id`),
  KEY `division_id` (`division_id`),
  KEY `district_id` (`district_id`),
  KEY `fk_rider_upazila` (`upazila_id`),
  KEY `idx_rider_dispatch` (`agent_id`,`upazila_id`,`status`),
  CONSTRAINT `fk_rider_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rider_upazila` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`),
  CONSTRAINT `fk_riders_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  CONSTRAINT `fk_riders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `riders_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  CONSTRAINT `riders_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  CONSTRAINT `riders_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `riders`
--

LOCK TABLES `riders` WRITE;
/*!40000 ALTER TABLE `riders` DISABLE KEYS */;
INSERT INTO `riders` VALUES
(5,19,'bn',4,'bicycle','Dhaka-203436',NULL,NULL,0.00,0,1,0,'pending',1,'2026-03-05 17:00:36','2026-03-22 15:10:19',NULL,NULL,'offline',NULL,NULL,NULL,0,'default'),
(6,20,'bn',4,'van','Dhaka-203435',NULL,NULL,0.00,0,0,0,'pending',1,'2026-03-05 17:01:21','2026-04-19 07:13:27',NULL,NULL,'offline',NULL,NULL,NULL,0,'salary'),
(7,21,'bn',3,'motorcycle','Dhaka-203456',NULL,NULL,0.00,0,1,0,'pending',1,'2026-03-05 17:02:20','2026-04-15 19:28:14',NULL,NULL,'offline',NULL,NULL,NULL,0,'salary'),
(8,22,'bn',3,'van','Khulna-3045',NULL,NULL,0.00,0,0,0,'pending',1,'2026-03-05 17:03:09','2026-03-05 19:52:33',NULL,NULL,'offline',NULL,NULL,NULL,0,'commission');
/*!40000 ALTER TABLE `riders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES
(1,'admin','Platform administrator'),
(2,'agent','Agent / Franchise owner'),
(3,'rider','RagmanHeroes rider'),
(4,'customer','End customer');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scrap_categories`
--

DROP TABLE IF EXISTS `scrap_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scrap_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) NOT NULL,
  `slug` varchar(150) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `display_order` int(10) unsigned DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_category_display` (`display_order`,`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scrap_categories`
--

LOCK TABLES `scrap_categories` WRITE;
/*!40000 ALTER TABLE `scrap_categories` DISABLE KEYS */;
INSERT INTO `scrap_categories` VALUES
(1,'Metals','ধাতু','metals','Scrap Metal: Sell Steel, Aluminum, Copper & Iron','/uploads/category-icons/cat-1772467362887-897006764.png',0,1,'2025-12-08 15:54:07','2026-03-07 00:16:32'),
(2,'Plastics','প্লাস্টিক','plastics','Plastic Scrap Sell Platform – Mixed Plastics, Acrylic, Nylon, EVA','/uploads/category-icons/cat-1772467323291-213023767.png',1,1,'2025-12-08 15:58:32','2026-03-07 00:16:45'),
(3,'Papers','কাগজপত্র','papers','Sell Scrap Paper: OCC, Newsprint, Mixed Paper, and More','/uploads/category-icons/cat-1772467408911-593373092.png',2,1,'2026-03-02 22:03:28','2026-03-07 00:16:57'),
(4,'Machinery','যন্ত্রপাতি','machinery','Machinery Sell: Used & Second-Hand Machinery','/uploads/category-icons/cat-1772467465559-948913515.png',3,1,'2026-03-02 22:04:25','2026-03-07 00:17:11'),
(5,'Electronics','ইলেকট্রনিক্স','electronics','Electronics Sell: Laptop, Computers, Mobiles, Fan, Fridges & more','/uploads/category-icons/cat-1772467571778-257101315.png',4,1,'2026-03-02 22:06:11','2026-03-07 00:17:25'),
(6,'Appliances','গ্যাজেট','appliances','Sell old, broken, or unused appliances like refrigerators, washing machines, dryers, ac & more','/uploads/category-icons/cat-1772789850229-338850523.png',5,1,'2026-03-02 22:07:52','2026-03-07 00:18:39'),
(7,'Others','অন্যান্য','others','Selling recyclable scrap is a sustainable way to clear clutter, reduce landfill waste, and generate income','/uploads/category-icons/cat-1772467734924-895347405.png',6,1,'2026-03-02 22:08:54','2026-03-03 13:22:33');
/*!40000 ALTER TABLE `scrap_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scrap_items`
--

DROP TABLE IF EXISTS `scrap_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scrap_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint(20) unsigned NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `unit` varchar(50) NOT NULL DEFAULT 'kg',
  `current_min_rate` decimal(10,2) NOT NULL,
  `current_max_rate` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_scrap_item_category` (`category_id`,`is_active`),
  CONSTRAINT `fk_scrap_items_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scrap_items`
--

LOCK TABLES `scrap_items` WRITE;
/*!40000 ALTER TABLE `scrap_items` DISABLE KEYS */;
INSERT INTO `scrap_items` VALUES
(4,3,'Newspapers','সংবাদপত্র','newspapers','/uploads/scrap-items/item-1772470023425-246776345.png','Price depends on newspaper quality','kg',20.00,22.00,1,'2026-03-02 22:40:27','2026-04-18 18:36:59'),
(5,1,'Copper','তামা','copper','/uploads/scrap-items/item-1772470085165-999138325.png','Price depends on the quality and condition','kg',1500.00,1600.00,1,'2026-03-02 22:48:05','2026-04-18 18:35:51'),
(6,5,'Computer / CPU','কম্পিউটার / সিপিইউ','computer--cpu','/uploads/scrap-items/item-1772470135116-747221887.png','Price depends on the quality and condition of the products.','kg',120.00,150.00,0,'2026-03-02 22:48:55','2026-04-17 14:49:45'),
(8,7,'Other house Hold','অন্যান্য গৃহস্থালী আসবাবপত্র','other-house-hold','/uploads/scrap-items/item-1772470264783-960194181.png','Price depends on the quality and condition of the products.','kg',10.00,1000.00,1,'2026-03-02 22:51:04','2026-03-06 22:15:14'),
(9,2,'Mix PLastic','প্লাস্টিক','mix-plastic','/uploads/scrap-items/item-1772470297972-729893632.png','Price depends on the quality and condition of the products.','kg',28.00,30.00,1,'2026-03-02 22:51:37','2026-04-18 18:37:31'),
(10,5,'Ceiling Fan','সিলিং ফ্যান','ceiling-fan','/uploads/scrap-items/item-1772470354417-756695218.png','Price depends on the quality and condition of the products.','piece',500.00,600.00,1,'2026-03-02 22:52:34','2026-04-18 18:30:10'),
(11,4,'Air Conditioner','এয়ার কন্ডিশনার','air-conditioner','/uploads/scrap-items/item-1772470434945-820633490.png','Price depends on the quality and condition of the products.','piece',600.00,900.00,0,'2026-03-02 22:53:54','2026-04-18 18:33:52'),
(12,3,'OFFICE PAPER (A3A4)','অফিস পেপার (A3A4)','office-paper-a3a4','/uploads/scrap-items/item-1776247853164-488481188.jpg','','kg',25.00,28.00,1,'2026-04-15 10:10:53','2026-04-18 18:37:10'),
(13,3,'COPIES/BOOKS','কপি/বই','copiesbooks','/uploads/scrap-items/item-1776248004751-89059430.jpg','Final price may vary based on the product inspection at the time of collection','kg',18.00,20.00,1,'2026-04-15 10:13:24','2026-04-18 18:36:42'),
(14,3,'CARDBOARD','কার্ডবোর্ড','cardboard','/uploads/scrap-items/item-1776248649519-656235266.jpg','Final price may vary based on the product inspection at the time of collection','kg',11.00,15.00,1,'2026-04-15 10:24:09','2026-04-18 18:36:25'),
(15,1,'IRON','লোহা','iron','/uploads/scrap-items/item-1776248910475-630858379.jpg','Final price may vary based on the product inspection at the time of collection','kg',40.00,45.00,1,'2026-04-15 10:28:30','2026-04-18 18:36:03'),
(16,1,'STEEL','স্টীল','steel','/uploads/scrap-items/item-1776249095617-897100241.jpg','Final price may vary based on the product inspection at the time of collection','kg',40.00,45.00,1,'2026-04-15 10:31:35','2026-04-16 18:46:05'),
(17,1,'ALUMINIUM','অ্যালুমিনিয়াম','aluminium','/uploads/scrap-items/item-1776249227027-418077989.jpg','Final price may vary based on the product inspection at the time of collection','kg',270.00,280.00,1,'2026-04-15 10:33:47','2026-04-18 18:35:36'),
(18,6,'SPLIT AC 1 TON (COPPER COIL)','স্প্লিট এসি ১ টন (কপার কয়েল)','split-ac-1-ton-copper-coil','/uploads/scrap-items/item-1776249468856-772121266.jpg','Final price may vary based on the product inspection at the time of collection','piece',4000.00,4500.00,1,'2026-04-15 10:37:48','2026-04-18 18:27:36'),
(19,6,'SPLIT AC 1.5 TON (COPPER COIL)','স্প্লিট এসি ১.৫ টন (কপার কয়েল)','split-ac-15-ton-copper-coil','/uploads/scrap-items/item-1776249641949-750556816.jpg','Final price may vary based on the product inspection at the time of collection','piece',5500.00,6000.00,1,'2026-04-15 10:40:41','2026-04-18 18:27:53'),
(20,6,'SPLIT AC 2 TON (COPPER COIL)','স্প্লিট এসি ২ টন (কপার কয়েল)','split-ac-2-ton-copper-coil','/uploads/scrap-items/item-1776249782652-324800817.jpg','Final price may vary based on the product inspection at the time of collection','piece',7000.00,8000.00,1,'2026-04-15 10:43:02','2026-04-18 18:28:09'),
(21,6,'WINDOW AC 1 TON (COPPER COIL)','উইন্ডো এসি ১ টন (কপার কয়েল)','window-ac-1-ton-copper-coil','/uploads/scrap-items/item-1776249983927-369114016.jpg','Final price may vary based on the product inspection at the time of collection','piece',5000.00,5500.00,1,'2026-04-15 10:46:23','2026-04-18 18:29:21'),
(22,6,'WINDOW AC 1.5 TON (COPPER COIL)','উইন্ডো এসি ১.৫ টন (কপার কয়েল)','window-ac-15-ton-copper-coil','/uploads/scrap-items/item-1776250254088-814482221.jpg','Final price may vary based on the product inspection at the time of collection','piece',6000.00,6500.00,1,'2026-04-15 10:50:54','2026-04-18 18:29:34'),
(23,6,'WINDOW AC 2 TON (COPPER COIL)','উইন্ডো এসি ২ টন (কপার কয়েল)','window-ac-2-ton-copper-coil','/uploads/scrap-items/item-1776250504795-13319194.jpg','Final price may vary based on the product inspection at the time of collection','piece',7500.00,8500.00,1,'2026-04-15 10:55:04','2026-04-18 18:29:47'),
(24,6,'FRONT LOAD FULLY AUTOMATIC WASHING MACHINE','ফ্রন্ট লোড সম্পূর্ণ স্বয়ংক্রিয় ওয়াশিং মেশিন','front-load-fully-automatic-washing-machine','/uploads/scrap-items/item-1776250738356-714364023.jpg','Final price may vary based on the product inspection at the time of collection','piece',600.00,700.00,1,'2026-04-15 10:58:58','2026-04-18 18:25:21'),
(25,6,'TOP LOAD FULLY AUTOMATIC WASHING MACHINE','টপ লোড সম্পূর্ণ স্বয়ংক্রিয় ওয়াশিং মেশিন','top-load-fully-automatic-washing-machine','/uploads/scrap-items/item-1776251001004-675528990.jpg','Final price may vary based on the product inspection at the time of collection','kg',40.00,45.00,1,'2026-04-15 11:03:21','2026-04-18 18:28:54'),
(26,6,'SEMI AUTOMATIC WASHING MACHINE (DOUBLE DRUM)','সেমি অটোমেটিক ওয়াশিং মেশিন (ডাবল ড্রাম)','semi-automatic-washing-machine-double-drum','/uploads/scrap-items/item-1776251155659-548438939.jpg','Final price may vary based on the product inspection at the time of collection','piece',700.00,800.00,1,'2026-04-15 11:05:55','2026-04-18 18:26:41'),
(27,6,'GEYSER','গিজার','geyser','/uploads/scrap-items/item-1776251644648-9203401.jpg','Final price may vary based on the product inspection at the time of collection','kg',40.00,45.00,1,'2026-04-15 11:14:04','2026-04-18 18:25:47'),
(28,6,'SINGLE DOOR FRIDGE','এক দরজার ফ্রিজ','single-door-fridge','/uploads/scrap-items/item-1776364583223-872115588.jpg','Final price may vary based on the product inspection at the time of collection','piece',1800.00,2000.00,1,'2026-04-16 18:10:49','2026-04-18 18:27:13'),
(29,6,'DOUBLE DOOR FRIDGE','ডাবল ডোর ফ্রিজ','double-door-fridge','/uploads/scrap-items/item-1776364595712-846197315.jpg','Final price may vary based on the product inspection at the time of collection','piece',2000.00,2500.00,1,'2026-04-16 18:20:51','2026-04-18 18:24:59'),
(30,6,'IRON COOLER','লোহার কুলার','iron-cooler','/uploads/scrap-items/item-1776365263218-469190839.png','Final price may vary based on the product inspection at the time of collection','kg',40.00,45.00,1,'2026-04-16 18:47:43','2026-04-18 18:26:04'),
(31,2,'PLASTIC COOLER','প্লাস্টিক কুলার','plastic-cooler','/uploads/scrap-items/item-1776366635124-172996914.jpg','Final price may vary based on the product inspection at the time of collection','kg',25.00,30.00,1,'2026-04-16 18:49:13','2026-04-18 18:37:45'),
(32,2,'HEAVY E-WASTE (CONTENT: METAL > PLASTIC)','ভারী ই-বর্জ্য (উপাদান: ধাতু > প্লাস্টিক)','heavy-e-waste-content-metal-plastic','/uploads/scrap-items/item-1776365489696-2255363.png',NULL,'kg',30.00,35.00,1,'2026-04-16 18:51:29','2026-04-16 18:51:29'),
(33,2,'LIGHT E-WASTE (CONTENT: PLASTIC > METAL)','হালকা ই-বর্জ্য (উপাদান: প্লাস্টিক > ধাতু)','light-e-waste-content-plastic--metal','/uploads/scrap-items/item-1776365617997-979315711.png','','kg',28.00,30.00,1,'2026-04-16 18:53:38','2026-04-18 18:38:01'),
(34,5,'PRINTER/SCANNER/FAX MACHINE','প্রিন্টার/স্ক্যানার/ফ্যাক্স মেশিন','printerscannerfax-machine','/uploads/scrap-items/item-1776366193886-459781210.jpg','','piece',100.00,120.00,1,'2026-04-16 18:54:40','2026-04-16 19:03:13'),
(35,4,'MOTORS (COPPER WIRING)','মোটর (তামার তার)','motors-copper-wiring','/uploads/scrap-items/item-1776366292632-628798463.jpg','','piece',1500.00,2500.00,1,'2026-04-16 18:56:04','2026-04-18 18:35:00'),
(36,5,'MICROWAVE','মাইক্রোওয়েভ','microwave','/uploads/scrap-items/item-1776435693429-571863074.jpg','','piece',500.00,600.00,1,'2026-04-17 14:21:33','2026-04-18 18:33:20'),
(37,5,'CRT TV','সিআরটি টিভি','crt-tv','/uploads/scrap-items/item-1776436108305-325466377.jpg','','piece',150.00,200.00,1,'2026-04-17 14:28:28','2026-04-18 18:31:19'),
(38,5,'UPS','ইউপিএস','ups','/uploads/scrap-items/item-1776436239414-254912175.jpg',NULL,'piece',300.00,350.00,1,'2026-04-17 14:30:39','2026-04-17 14:30:39'),
(39,5,'INVERTER/STABILIZER (COPPER COIL)','ইনভার্টার/স্ট্যাবিলাইজার (তামার কয়েল)','inverterstabilizer-copper-coil','/uploads/scrap-items/item-1776436461721-788399734.jpg','','kg',60.00,70.00,1,'2026-04-17 14:34:21','2026-04-18 18:31:47'),
(40,4,'BATTERY(USED WITH INVERTERS)','ব্যাটারি (ইনভার্টারের সাথে ব্যবহৃত)','batteryused-with-inverters','/uploads/scrap-items/item-1776436599227-812061614.jpg','','kg',165.00,170.00,1,'2026-04-17 14:36:39','2026-04-18 18:34:33'),
(41,6,'MOBILE -TABLET (TAB)','মোবাইল - ট্যাবলেট (ট্যাব)','mobile-tablet-tab','/uploads/scrap-items/item-1776436748505-357070003.jpg','Final price may vary based on the product inspection at the time of collection','piece',30.00,300.00,1,'2026-04-17 14:39:08','2026-04-17 14:39:08'),
(42,5,'LAPTOP (ON)','ল্যাপটপ (চালু)','laptop-on','/uploads/scrap-items/item-1776436861767-600903174.jpg','','piece',1500.00,2000.00,1,'2026-04-17 14:41:01','2026-04-18 18:32:15'),
(43,5,'LAPTOP (OFF)','ল্যাপটপ (বন্ধ)','laptop-off','/uploads/scrap-items/item-1776436950980-484795461.jpg','','piece',300.00,700.00,1,'2026-04-17 14:42:30','2026-04-18 18:32:02'),
(44,5,'CRT MONITOR','সিআরটি মনিটর','crt-monitor','/uploads/scrap-items/item-1776437056730-281875610.jpg','','kg',500.00,600.00,1,'2026-04-17 14:44:16','2026-04-18 18:31:03'),
(45,5,'LCD MONITOR','এলসিডি মনিটর','lcd-monitor','/uploads/scrap-items/item-1776437233520-87720574.jpg',NULL,'kg',30.00,40.00,1,'2026-04-17 14:47:13','2026-04-17 14:47:13'),
(46,5,'COMPUTER CPU','কম্পিউটার সিপিইউ','computer-cpu','/uploads/scrap-items/item-1776437339930-370219250.jpg','','kg',40.00,45.00,1,'2026-04-17 14:48:59','2026-04-18 18:30:43'),
(47,5,'LED/SMART TV (OFF)','এলইডি/স্মার্ট টিভি (বন্ধ)','led-smart-tv-off','/uploads/scrap-items/item-1776437587780-505833796.jpg',NULL,'piece',100.00,300.00,1,'2026-04-17 14:53:07','2026-04-17 14:53:07'),
(48,5,'LED/SMART TV (ON)','এলইডি/স্মার্ট টিভি (চালু)','led-smart-tv-on','/uploads/scrap-items/item-1776437631466-99045366.jpg',NULL,'piece',1000.00,5000.00,1,'2026-04-17 14:53:51','2026-04-17 14:53:51'),
(49,4,'WATER DISPENSER','জল বিতরণকারী','water-dispenser','/uploads/scrap-items/item-1776437776466-8681071.jpg',NULL,'piece',400.00,700.00,1,'2026-04-17 14:56:16','2026-04-17 14:56:16'),
(50,4,'WATER FILTER','পানি ফিল্টার','water-filter','/uploads/scrap-items/item-1776437931436-686278078.jpg',NULL,'piece',50.00,500.00,1,'2026-04-17 14:58:51','2026-04-17 14:58:51'),
(51,1,'Tin','টিন','tin','/uploads/scrap-items/item-1776537636493-361548621.jpg',NULL,'kg',28.00,30.00,1,'2026-04-18 18:40:36','2026-04-18 18:40:36'),
(52,1,'Brass','পিতল','brass','/uploads/scrap-items/item-1776537852395-724489190.jpg',NULL,'kg',700.00,750.00,1,'2026-04-18 18:44:12','2026-04-18 18:44:12');
/*!40000 ALTER TABLE `scrap_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scrap_price_history`
--

DROP TABLE IF EXISTS `scrap_price_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scrap_price_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `scrap_item_id` bigint(20) unsigned NOT NULL,
  `old_min_price` decimal(10,2) NOT NULL,
  `old_max_price` decimal(10,2) NOT NULL,
  `new_min_price` decimal(10,2) NOT NULL,
  `new_max_price` decimal(10,2) NOT NULL,
  `changed_by_user_id` bigint(20) unsigned NOT NULL,
  `change_reason` varchar(255) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_price_history_item` (`scrap_item_id`),
  KEY `fk_price_history_admin` (`changed_by_user_id`),
  CONSTRAINT `fk_price_history_admin` FOREIGN KEY (`changed_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_price_history_item` FOREIGN KEY (`scrap_item_id`) REFERENCES `scrap_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scrap_price_history`
--

LOCK TABLES `scrap_price_history` WRITE;
/*!40000 ALTER TABLE `scrap_price_history` DISABLE KEYS */;
INSERT INTO `scrap_price_history` VALUES
(5,9,0.00,0.00,46.00,50.00,2,'Regional Price Adjustment','2026-03-22 15:22:31'),
(6,9,0.00,0.00,48.00,57.00,2,'Regional Price Adjustment','2026-03-22 15:23:19'),
(7,4,20.00,30.00,10.00,15.00,2,'Administrative Price Update','2026-04-15 10:06:48'),
(8,10,300.00,500.00,300.00,400.00,2,'Administrative Price Update','2026-04-16 18:39:29'),
(9,29,900.00,1199.00,2000.00,2500.00,2,'Administrative Price Update','2026-04-18 18:24:59'),
(10,24,1200.00,1500.00,600.00,700.00,2,'Administrative Price Update','2026-04-18 18:25:21'),
(11,27,35.00,40.00,40.00,45.00,2,'Administrative Price Update','2026-04-18 18:25:47'),
(12,30,25.00,30.00,40.00,45.00,2,'Administrative Price Update','2026-04-18 18:26:04'),
(13,26,700.00,900.00,700.00,800.00,2,'Administrative Price Update','2026-04-18 18:26:41'),
(14,28,800.00,900.00,1800.00,2000.00,2,'Administrative Price Update','2026-04-18 18:27:13'),
(15,18,3000.00,3500.00,4000.00,4500.00,2,'Administrative Price Update','2026-04-18 18:27:36'),
(16,19,3200.00,3700.00,5500.00,6000.00,2,'Administrative Price Update','2026-04-18 18:27:53'),
(17,20,3500.00,4000.00,7000.00,8000.00,2,'Administrative Price Update','2026-04-18 18:28:09'),
(18,25,1000.00,1200.00,40.00,45.00,2,'Administrative Price Update','2026-04-18 18:28:54'),
(19,21,3000.00,3200.00,5000.00,5500.00,2,'Administrative Price Update','2026-04-18 18:29:21'),
(20,22,3800.00,4500.00,6000.00,6500.00,2,'Administrative Price Update','2026-04-18 18:29:34'),
(21,23,4500.00,5000.00,7500.00,8500.00,2,'Administrative Price Update','2026-04-18 18:29:47'),
(22,10,300.00,400.00,500.00,600.00,2,'Administrative Price Update','2026-04-18 18:30:10'),
(23,46,300.00,1000.00,40.00,45.00,2,'Administrative Price Update','2026-04-18 18:30:43'),
(24,44,20.00,25.00,500.00,600.00,2,'Administrative Price Update','2026-04-18 18:31:03'),
(25,37,300.00,400.00,150.00,200.00,2,'Administrative Price Update','2026-04-18 18:31:19'),
(26,43,200.00,700.00,300.00,700.00,2,'Administrative Price Update','2026-04-18 18:32:02'),
(27,42,500.00,2000.00,1500.00,2000.00,2,'Administrative Price Update','2026-04-18 18:32:15'),
(28,36,250.00,500.00,500.00,600.00,2,'Administrative Price Update','2026-04-18 18:33:20'),
(29,40,70.00,80.00,165.00,170.00,2,'Administrative Price Update','2026-04-18 18:34:33'),
(30,35,60.00,80.00,1500.00,2500.00,2,'Administrative Price Update','2026-04-18 18:35:00'),
(31,17,160.00,170.00,270.00,280.00,2,'Administrative Price Update','2026-04-18 18:35:36'),
(32,5,800.00,900.00,1500.00,1600.00,2,'Administrative Price Update','2026-04-18 18:35:51'),
(33,15,30.00,35.00,40.00,45.00,2,'Administrative Price Update','2026-04-18 18:36:03'),
(34,14,13.00,22.00,11.00,15.00,2,'Administrative Price Update','2026-04-18 18:36:25'),
(35,13,12.00,20.00,18.00,20.00,2,'Administrative Price Update','2026-04-18 18:36:42'),
(36,4,10.00,15.00,20.00,22.00,2,'Administrative Price Update','2026-04-18 18:36:59'),
(37,12,15.00,25.00,25.00,28.00,2,'Administrative Price Update','2026-04-18 18:37:10'),
(38,9,50.00,65.00,28.00,30.00,2,'Administrative Price Update','2026-04-18 18:37:31'),
(39,31,10.00,15.00,25.00,30.00,2,'Administrative Price Update','2026-04-18 18:37:45'),
(40,33,10.00,12.00,28.00,30.00,2,'Administrative Price Update','2026-04-18 18:38:01');
/*!40000 ALTER TABLE `scrap_price_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settlements`
--

DROP TABLE IF EXISTS `settlements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settlements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) unsigned NOT NULL,
  `settlement_date` date NOT NULL,
  `total_cash_collected` decimal(12,2) DEFAULT NULL,
  `total_commissions_earned` decimal(12,2) DEFAULT NULL,
  `net_amount_to_admin` decimal(12,2) DEFAULT NULL,
  `status` enum('pending','verified','disputed') DEFAULT 'pending',
  `verified_by_admin_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `settlements_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settlements`
--

LOCK TABLES `settlements` WRITE;
/*!40000 ALTER TABLE `settlements` DISABLE KEYS */;
/*!40000 ALTER TABLE `settlements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES
('min_withdrawal_amount','200','2026-04-17 05:05:28');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unified_inquiries`
--

DROP TABLE IF EXISTS `unified_inquiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `unified_inquiries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('general','corporate') NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `inquiry_category` varchar(100) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('unread','read','contacted','resolved') DEFAULT 'unread',
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unified_inquiries`
--

LOCK TABLES `unified_inquiries` WRITE;
/*!40000 ALTER TABLE `unified_inquiries` DISABLE KEYS */;
INSERT INTO `unified_inquiries` VALUES
(1,'general','Mohammad Abu Taleb','abutaleb142@gmail.com','+8801674075335',NULL,'Enterprise Solution','Please give me a quation','unread',NULL,'2026-04-16 12:54:20','2026-04-16 12:54:20');
/*!40000 ALTER TABLE `unified_inquiries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upazilas`
--

DROP TABLE IF EXISTS `upazilas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `upazilas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `district_id` int(11) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `district_id` (`district_id`),
  CONSTRAINT `upazilas_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upazilas`
--

LOCK TABLES `upazilas` WRITE;
/*!40000 ALTER TABLE `upazilas` DISABLE KEYS */;
INSERT INTO `upazilas` VALUES
(93,1,'Khulna Sadar','খুলনা সদর',1),
(94,1,'Sonadanga','সোনাডাঙ্গা',1),
(95,1,'Khalishpur','খালিশপুর',1),
(96,1,'Daulatpur','দৌলতপুর',1),
(97,1,'Khan Jahan Ali','খান জাহান আলী',1),
(98,1,'Dighalia','দিঘলিয়া',1),
(99,1,'Dumuria','ডুমুরিয়া',1),
(100,1,'Phultala','ফুলতলা',1),
(101,1,'Rupsha','রূপসা',1),
(102,1,'Terokhada','তেরখাদা',1),
(103,1,'Batiaghata','বটিয়াঘাটা',1),
(104,1,'Dacope','দাকোপ',1),
(105,1,'Paikgachha','পাইকগাছা',1),
(106,1,'Koyra','কয়রা',1),
(107,4,'Jashore Sadar','যশোর সদর',1),
(108,4,'Abhaynagar','অভয়নগর',1),
(109,4,'Bagherpara','বাঘেরপাড়া',1),
(110,4,'Chaugachha','চৌগাছা',1),
(111,4,'Jhikargachha','ঝিকরগাছা',1),
(112,4,'Keshabpur','কেশবপুর',1),
(113,4,'Manirampur','মণিরামপুর',1),
(114,4,'Sharsha','শার্শা',1),
(115,10,'Satkhira Sadar','সাতক্ষীরা সদর',1),
(116,10,'Assasuni','আশাশুনি',1),
(117,10,'Debhata','দেবহাটা',1),
(118,10,'Kalaroa','কলারোয়া',1),
(119,10,'Kaliganj','কালিগঞ্জ',1),
(120,10,'Shyamnagar','শ্যামনগর',1),
(121,10,'Tala','তালা',1);
/*!40000 ALTER TABLE `upazilas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` tinyint(3) unsigned NOT NULL,
  `fcm_token` text DEFAULT NULL,
  `preferred_language` enum('en','bn') DEFAULT 'bn',
  `full_name` varchar(150) NOT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `agent_id` bigint(20) unsigned DEFAULT NULL,
  `country_code` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`),
  KEY `agent_id` (`agent_id`),
  KEY `fk_user_role` (`role_id`),
  CONSTRAINT `fk_user_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(2,1,NULL,'bn','Super Admin',NULL,'admin@example.com','01700000000','$2a$10$MjPWUz91gj27yCTezxXQue.uOb/0iQ8e7Eo1RF4QazZ5CaUWvj5IK','2026-03-04 10:28:48','2026-03-02 18:00:00',NULL,'bd',1,NULL,'2025-12-08 13:05:54','2026-03-05 16:29:27'),
(17,2,NULL,'bn','Agent 1',NULL,'agent1@example.com','01700000222','$2a$10$LRgMT3rMpZwsCBF3fP7nyeW6m7ac28XdjGN3QLy4I2h4ESyCdfIMS',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 16:57:25','2026-03-05 16:57:25'),
(18,2,NULL,'bn','Agent 2',NULL,'agent2@example.com','01700000333','$2a$10$8DW.7ciYjppB1UQ0m0eKAOFVTk7.0PJ4I3/dSy.X8z34pfJwu4AIu',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 16:59:15','2026-03-05 16:59:15'),
(19,3,NULL,'bn','Rider 1',NULL,'mustafizur142@gmail.com','01700000444','$2a$10$6G8vDtrV3xcxs5JZXDes6.mvmyuZ3cBdBgdrlLp9RB6vQu6TPjiRe',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:00:36','2026-03-14 10:29:16'),
(20,3,NULL,'bn','Saiful Islam',NULL,'rider2@example.com','01700000555','$2a$10$mUC2CYlIT6jS8ipYTyuC9ey/r8wW43pNXcq5Pp6yafPurjUayHsoO',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:01:21','2026-04-19 07:13:27'),
(21,3,NULL,'bn','Rider 3 pro',NULL,'rider3@example.com','01700000666','$2a$10$IiR64pYy4Fb9fRU4TPt2GeLI5T.p8YZcvUdFFKDkoKtQqE0uHflrO',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:02:20','2026-03-05 19:40:36'),
(22,3,NULL,'bn','Rider 4',NULL,'rider4@example.com','01700000777','$2a$10$FG./0BPa1BEn56GQII5CE.451/DvZaFuP9XrN1ffPZg0mcHag19qW',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:03:09','2026-03-05 19:52:33'),
(23,4,'ExponentPushToken[6Mlp1QEypYPBFNOrG_uboM]','bn','Customer One','/uploads/profiles/profile-1776234032033-610843090.jpeg','abutaleb142@gmail.com','01700000888','$2a$10$YdsSX0EW.tFtDYk1VTJHU.S4OTi629D5RaPRDtwkUMHJYUfF6AJfu',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:04:34','2026-04-19 08:42:44'),
(24,4,NULL,'bn','Customer 2',NULL,'customer2@example.com','01700000999','$2a$10$pMISbLcll6xbAfgPYRRe6u5xCmQBkM4Hsv/WFYMnTSnBIwHz7Txxe',NULL,NULL,NULL,NULL,1,NULL,'2026-03-05 17:05:32','2026-03-05 19:39:27'),
(29,4,NULL,'bn','Md. Hassan Bin Emrul Kayesh',NULL,'kayesh.sbl@gmail.com','01725451613','$2a$10$UOc1B1wrZlF6L/UAMyosduFC12yReKGOjzMdb7RCGljFOVeEPjz56',NULL,NULL,NULL,NULL,1,NULL,'2026-04-17 19:12:01','2026-04-17 19:12:01');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_accounts`
--

DROP TABLE IF EXISTS `wallet_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `pending_balance` decimal(12,2) DEFAULT 0.00,
  `total_withdrawn` decimal(12,2) DEFAULT 0.00,
  `last_transaction_at` timestamp NULL DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'BDT',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_wallet` (`user_id`),
  UNIQUE KEY `uq_wallet_user_currency` (`user_id`,`currency`),
  CONSTRAINT `fk_wallet_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_accounts`
--

LOCK TABLES `wallet_accounts` WRITE;
/*!40000 ALTER TABLE `wallet_accounts` DISABLE KEYS */;
INSERT INTO `wallet_accounts` VALUES
(7,17,347.30,0.00,0.00,NULL,'BDT',1,'2026-03-05 16:57:25','2026-04-15 19:30:37'),
(8,18,3216.40,0.00,0.00,NULL,'BDT',1,'2026-03-05 16:59:15','2026-04-15 03:40:22'),
(9,19,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:00:36','2026-03-05 17:00:36'),
(10,20,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:01:21','2026-03-05 17:01:21'),
(11,21,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:02:20','2026-03-05 17:02:20'),
(12,22,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:03:09','2026-03-05 17:03:09'),
(13,23,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:04:34','2026-03-05 17:04:34'),
(14,24,0.00,0.00,0.00,NULL,'BDT',1,'2026-03-05 17:05:32','2026-03-05 17:05:32'),
(16,29,0.00,0.00,0.00,NULL,'BDT',1,'2026-04-17 19:12:01','2026-04-17 19:12:01');
/*!40000 ALTER TABLE `wallet_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_transactions`
--

DROP TABLE IF EXISTS `wallet_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `wallet_id` bigint(20) unsigned NOT NULL,
  `type` enum('credit','debit') NOT NULL,
  `source` enum('pickup_commission','referral_bonus','payout_withdrawal','adjustment','refund','pickup_payment','cash_collection') NOT NULL,
  `reference_type` enum('pickup','payout_request','user') NOT NULL,
  `reference_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `balance_before` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `description_en` varchar(255) DEFAULT NULL,
  `description_bn` varchar(255) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'completed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_transaction_history` (`wallet_id`,`created_at`),
  CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_transactions`
--

LOCK TABLES `wallet_transactions` WRITE;
/*!40000 ALTER TABLE `wallet_transactions` DISABLE KEYS */;
INSERT INTO `wallet_transactions` VALUES
(1,8,'debit','','pickup',1,2350.00,0.00,0.00,'Cash collection recorded for GS-96-5631',NULL,NULL,'completed','2026-03-05 16:45:39'),
(2,8,'credit','pickup_commission','pickup',1,235.00,0.00,235.00,'Hub Commission: GS-96-5631',NULL,NULL,'completed','2026-03-05 16:45:39'),
(3,8,'credit','','',5,2350.00,0.00,0.00,'Physical cash handover from Rider ID: 5. Note: Full Settlement',NULL,NULL,'completed','2026-03-05 18:08:13'),
(4,7,'debit','','pickup',3,130.00,0.00,0.00,'Cash collection recorded for GS-96-1889',NULL,NULL,'completed','2026-03-07 08:18:56'),
(5,7,'credit','pickup_commission','pickup',3,13.00,0.00,13.00,'Hub Commission: GS-96-1889',NULL,NULL,'completed','2026-03-07 08:18:56'),
(6,8,'debit','cash_collection','pickup',2,2334.00,0.00,0.00,'Cash collection recorded for GS-96-3671',NULL,NULL,'completed','2026-03-09 16:35:51'),
(7,8,'credit','pickup_commission','pickup',2,233.40,235.00,468.40,'Hub Commission: GS-96-3671',NULL,NULL,'completed','2026-03-09 16:35:51'),
(8,8,'debit','cash_collection','pickup',7,150.00,0.00,0.00,'Cash collection recorded for GS-96-2750',NULL,NULL,'completed','2026-03-09 16:37:38'),
(9,8,'credit','pickup_commission','pickup',7,15.00,468.40,483.40,'Hub Commission: GS-96-2750',NULL,NULL,'completed','2026-03-09 16:37:38'),
(10,8,'debit','cash_collection','pickup',8,10.00,0.00,0.00,'Cash collection recorded for GS-96-3802',NULL,NULL,'completed','2026-03-14 14:33:13'),
(11,8,'credit','pickup_commission','pickup',8,1.00,483.40,484.40,'Hub Commission: GS-96-3802',NULL,NULL,'completed','2026-03-14 14:33:13'),
(12,8,'debit','cash_collection','pickup',9,2340.00,0.00,0.00,'Cash collection recorded for GS-96-5726',NULL,NULL,'completed','2026-03-14 16:02:06'),
(13,8,'credit','pickup_commission','pickup',9,234.00,484.40,718.40,'Hub Commission: GS-96-5726',NULL,NULL,'completed','2026-03-14 16:02:06'),
(14,8,'debit','cash_collection','pickup',12,24250.00,0.00,0.00,'Cash collection recorded for GS-96-9371',NULL,NULL,'completed','2026-03-22 15:08:46'),
(15,8,'credit','pickup_commission','pickup',12,2425.00,718.40,3143.40,'Hub Commission: GS-96-9371',NULL,NULL,'completed','2026-03-22 15:08:46'),
(16,7,'debit','cash_collection','pickup',13,720.00,0.00,0.00,'Cash collection recorded for GS-96-0102',NULL,NULL,'completed','2026-03-26 18:58:44'),
(17,7,'credit','pickup_commission','pickup',13,72.00,13.00,85.00,'Hub Commission: GS-96-0102',NULL,NULL,'completed','2026-03-26 18:58:44'),
(18,8,'debit','cash_collection','pickup',11,610.00,0.00,0.00,'Cash collection recorded for GS-96-7465',NULL,NULL,'completed','2026-04-15 03:29:35'),
(19,8,'credit','pickup_commission','pickup',11,61.00,3143.40,3204.40,'Hub Commission: GS-96-7465',NULL,NULL,'completed','2026-04-15 03:29:35'),
(20,8,'debit','cash_collection','pickup',10,120.00,0.00,0.00,'Cash collection recorded for GS-96-9399',NULL,NULL,'completed','2026-04-15 03:40:22'),
(21,8,'credit','pickup_commission','pickup',10,12.00,3204.40,3216.40,'Hub Commission: GS-96-9399',NULL,NULL,'completed','2026-04-15 03:40:22'),
(22,7,'credit','pickup_commission','pickup',14,54.00,85.00,139.00,'Hub Commission: GS-96-9474',NULL,NULL,'completed','2026-04-15 03:56:03'),
(23,7,'credit','pickup_commission','pickup',15,185.00,139.00,324.00,'Hub Commission: GS-96-1833',NULL,NULL,'completed','2026-04-15 19:26:44'),
(24,7,'credit','pickup_commission','pickup',18,23.30,324.00,347.30,'Hub Commission: GS-108-1593',NULL,NULL,'completed','2026-04-15 19:30:37');
/*!40000 ALTER TABLE `wallet_transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19  8:49:05
