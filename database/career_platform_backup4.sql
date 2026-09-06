/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: career_platform
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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `slug` varchar(160) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `uq_categories_name` (`name`),
  KEY `idx_categories_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(1,'Interview Prep 2','interview-prep-2','Mock interviews, feedback and drills',1,'2025-08-12 04:15:38'),
(2,'Web Development','web-development','HTML, CSS, JS, frameworks',1,'2025-08-16 15:11:39'),
(3,'Mobile Development','mobile-development','iOS, Android, cross-platform',1,'2025-08-16 15:11:39'),
(4,'Data Science','data-science','Analytics, Python, SQL, visualization',1,'2025-08-16 15:11:39'),
(5,'AI & Machine Learning','ai-ml','ML, DL, LLMs, MLOps',1,'2025-08-16 15:11:39'),
(6,'Cloud & DevOps','cloud-devops','AWS, Azure, GCP, CI/CD, containers',1,'2025-08-16 15:11:39'),
(7,'Cybersecurity','cybersecurity','Security, networks, ethical hacking',1,'2025-08-16 15:11:39'),
(8,'Programming Languages','programming-languages','JS/TS, Python, Java, C#, Go, Rust',1,'2025-08-16 15:11:39'),
(9,'Design & UX','design-ux','UI/UX, product design, Figma',1,'2025-08-16 15:11:39'),
(10,'Product Management','product-management','Roadmaps, discovery, delivery',1,'2025-08-16 15:11:39'),
(11,'Business & Entrepreneurship','business-entrepreneurship','Strategy, ops, startups',1,'2025-08-16 15:11:39'),
(12,'Marketing','marketing','Digital, content, SEO/SEM',1,'2025-08-16 15:11:39'),
(13,'Finance & Accounting','finance-accounting','FP&A, bookkeeping, investing',1,'2025-08-16 15:11:39'),
(14,'Career Development','career-development','Interviews, resumes, soft skills',1,'2025-08-16 15:11:39'),
(15,'Personal Productivity','personal-productivity','Time management, tools, habits',1,'2025-08-16 15:11:39');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_participants`
--

DROP TABLE IF EXISTS `chat_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_participants` (
  `chat_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT current_timestamp(),
  `typing` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`chat_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_cp_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_participants`
--

LOCK TABLES `chat_participants` WRITE;
/*!40000 ALTER TABLE `chat_participants` DISABLE KEYS */;
INSERT INTO `chat_participants` VALUES
(1,2,'2025-08-12 15:44:42',0),
(1,4,'2025-08-12 15:44:42',0),
(2,3,'2025-08-12 15:54:17',0),
(2,4,'2025-08-12 15:54:17',0);
/*!40000 ALTER TABLE `chat_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_group` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `fk_chats_created_by_users` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES
(1,0,NULL,NULL,4,'2025-08-12 15:44:42','2025-08-12 15:44:42'),
(2,0,NULL,NULL,4,'2025-08-12 15:54:17','2025-08-12 15:54:17');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_categories`
--

DROP TABLE IF EXISTS `course_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_course_category` (`course_id`,`category_id`),
  KEY `idx_cc_course` (`course_id`),
  KEY `idx_cc_category` (`category_id`),
  CONSTRAINT `fk_cc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cc_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_categories`
--

LOCK TABLES `course_categories` WRITE;
/*!40000 ALTER TABLE `course_categories` DISABLE KEYS */;
INSERT INTO `course_categories` VALUES
(3,5,14,'2025-08-16 21:45:44');
/*!40000 ALTER TABLE `course_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_category_map`
--

DROP TABLE IF EXISTS `course_category_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_category_map` (
  `course_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`course_id`,`category_id`),
  KEY `idx_ccm_category` (`category_id`),
  CONSTRAINT `fk_ccm_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ccm_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_category_map`
--

LOCK TABLES `course_category_map` WRITE;
/*!40000 ALTER TABLE `course_category_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_category_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_enrollments`
--

DROP TABLE IF EXISTS `course_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `enrolled_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_enroll_course_created` (`course_id`,`enrolled_at`),
  CONSTRAINT `course_enrollments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_enrollments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_enrollments`
--

LOCK TABLES `course_enrollments` WRITE;
/*!40000 ALTER TABLE `course_enrollments` DISABLE KEYS */;
INSERT INTO `course_enrollments` VALUES
(2,5,1,'2025-08-16 18:49:42'),
(3,5,1,'2025-08-16 18:49:46');
/*!40000 ALTER TABLE `course_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_features`
--

DROP TABLE IF EXISTS `course_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `feature_type` enum('text','image','pdf') NOT NULL,
  `feature_value` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `course_features_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_features`
--

LOCK TABLES `course_features` WRITE;
/*!40000 ALTER TABLE `course_features` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_files`
--

DROP TABLE IF EXISTS `course_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_path` text DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_files`
--

LOCK TABLES `course_files` WRITE;
/*!40000 ALTER TABLE `course_files` DISABLE KEYS */;
INSERT INTO `course_files` VALUES
(1,1,'32-HCL-Technologies-Denmark-Apps_0 (1).pdf','application/pdf','uploads\\course_materials\\1753465705488-32-HCL-Technologies-Denmark-Apps_0 (1).pdf','2025-07-25 17:48:25'),
(2,1,'32-HCL-Technologies-Denmark-Apps_0 (1).pdf','application/pdf','uploads\\course_materials\\1754504043452-32-HCL-Technologies-Denmark-Apps_0 (1).pdf','2025-08-06 18:14:03'),
(3,3,'Sales Invoice - 1010.pdf','application/pdf','uploads/course_materials/1755332683112-Sales Invoice - 1010.pdf','2025-08-16 08:24:43'),
(4,5,'Maysha MalihaÂ Mou ( Borrower).pdf','application/pdf','/uploads/courses/materials/1755347566826-maysha-maliha-mou-borrower.pdf','2025-08-16 12:32:46'),
(5,5,'Invoice-LMCAZGIW-0001.pdf','application/pdf','/uploads/courses/materials/1755358147449-invoice-lmcazgiw-0001.pdf','2025-08-16 15:29:07'),
(6,5,'Invoice-LMCAZGIW-0001.pdf','application/pdf','/uploads/courses/materials/1755359167008-invoice-lmcazgiw-0001.pdf','2025-08-16 15:46:07');
/*!40000 ALTER TABLE `course_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_lessons`
--

DROP TABLE IF EXISTS `course_lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_lessons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `is_free` tinyint(1) NOT NULL DEFAULT 0,
  `order_no` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`,`order_no`),
  CONSTRAINT `course_lessons_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_lessons`
--

LOCK TABLES `course_lessons` WRITE;
/*!40000 ALTER TABLE `course_lessons` DISABLE KEYS */;
INSERT INTO `course_lessons` VALUES
(1,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 12:13:11','2025-08-16 12:13:11'),
(2,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,2,'2025-08-16 12:13:11','2025-08-16 12:13:11'),
(3,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:28:57','2025-08-16 15:28:57'),
(4,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,2,'2025-08-16 15:28:57','2025-08-16 15:28:57'),
(5,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(6,5,'Introduction','Welcome to the course!','',1,2,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(7,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',1,3,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(8,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,4,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(9,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(10,5,'Introduction','Welcome to the course!','',1,2,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(11,5,'Introduction','Welcome to the course!','',1,3,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(12,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,4,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(13,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,5,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(14,5,'Introduction','Welcome to the course!','',1,6,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(15,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',1,7,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(16,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,8,'2025-08-16 15:45:55','2025-08-16 15:45:55');
/*!40000 ALTER TABLE `course_lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_materials`
--

DROP TABLE IF EXISTS `course_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_materials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `lesson_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `lesson_id` (`lesson_id`),
  CONSTRAINT `course_materials_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_materials_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `course_lessons` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_materials`
--

LOCK TABLES `course_materials` WRITE;
/*!40000 ALTER TABLE `course_materials` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_orders`
--

DROP TABLE IF EXISTS `course_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'usd',
  `provider` enum('stripe','paypal') NOT NULL DEFAULT 'stripe',
  `status` enum('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  `provider_session_id` varchar(191) DEFAULT NULL,
  `provider_payment_id` varchar(191) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `provider_payment_intent_id` varchar(255) DEFAULT NULL,
  `provider_charge_id` varchar(255) DEFAULT NULL,
  `provider_invoice_id` varchar(255) DEFAULT NULL,
  `payment_method_id` varchar(255) DEFAULT NULL,
  `receipt_url` text DEFAULT NULL,
  `hosted_invoice_url` text DEFAULT NULL,
  `invoice_pdf_url` text DEFAULT NULL,
  `card_brand` varchar(32) DEFAULT NULL,
  `card_last4` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_course` (`user_id`,`course_id`),
  KEY `course_id` (`course_id`),
  KEY `idx_course_orders_provider_session` (`provider_session_id`),
  CONSTRAINT `course_orders_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_orders`
--

LOCK TABLES `course_orders` WRITE;
/*!40000 ALTER TABLE `course_orders` DISABLE KEYS */;
INSERT INTO `course_orders` VALUES
(1,5,1,20.00,'usd','stripe','paid','cs_test_a1e7JPHw57Xh1eu8AtGDwjmjyQh13wrVypWTqs4uJSEt49KaHQUaQZX8ME',NULL,'2025-08-16 16:33:10','2025-08-16 18:49:43','pi_3RwpAf3RqEMUJuhk0olhjg8r','ch_3RwpAf3RqEMUJuhk0qL72Jpw',NULL,'pm_1RwpAe3RqEMUJuhkKbw2Kgvn','https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKMelg8UGMgafYtUBTsM6LBYsKXon2CVykaVSAjCDiGipegx4eynm30SqyTnIZOPRW11RMOCrG_5lrKrI',NULL,NULL,'visa','4242');
/*!40000 ALTER TABLE `course_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_progress`
--

DROP TABLE IF EXISTS `course_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_progress` (`user_id`,`course_id`,`lesson_id`),
  KEY `course_id` (`course_id`),
  KEY `lesson_id` (`lesson_id`),
  CONSTRAINT `course_progress_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_progress_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `course_lessons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_progress`
--

LOCK TABLES `course_progress` WRITE;
/*!40000 ALTER TABLE `course_progress` DISABLE KEYS */;
INSERT INTO `course_progress` VALUES
(1,5,1,1,1,'2025-08-16 19:21:42'),
(2,5,5,1,1,'2025-08-16 19:21:26'),
(3,5,9,1,1,'2025-08-16 19:12:47'),
(4,5,6,1,1,'2025-08-16 19:12:43'),
(5,5,10,1,1,'2025-08-16 19:12:42'),
(6,5,7,1,1,'2025-08-16 19:12:40'),
(7,5,16,1,1,'2025-08-16 19:12:29'),
(8,5,15,1,1,'2025-08-16 19:12:30'),
(9,5,14,1,1,'2025-08-16 19:12:32'),
(10,5,13,1,1,'2025-08-16 19:12:33'),
(11,5,12,1,1,'2025-08-16 19:12:36'),
(12,5,8,1,1,'2025-08-16 19:12:37'),
(13,5,11,1,1,'2025-08-16 19:12:39'),
(17,5,2,1,1,'2025-08-16 19:12:45'),
(20,5,3,1,1,'2025-08-16 19:12:49');
/*!40000 ALTER TABLE `course_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_reviews`
--

DROP TABLE IF EXISTS `course_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` between 0 and 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_reviews_course_created` (`course_id`,`created_at`),
  CONSTRAINT `course_reviews_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_reviews`
--

LOCK TABLES `course_reviews` WRITE;
/*!40000 ALTER TABLE `course_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `meet_link` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT 0.00,
  `status` enum('upcoming','ongoing','completed') NOT NULL DEFAULT 'upcoming',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `course_image` varchar(255) DEFAULT NULL,
  `image_url` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `creator_role` int(11) DEFAULT 2,
  `expert_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `level` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `language` varchar(64) DEFAULT 'English',
  `currency` varchar(16) DEFAULT 'usd',
  `estimated_hours` varchar(32) DEFAULT NULL,
  `visibility` enum('public','unlisted','private') DEFAULT 'public',
  `trailer_url` varchar(255) DEFAULT NULL,
  `publish_state` enum('draft','published','archived') DEFAULT 'draft',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_courses_slug` (`slug`),
  KEY `created_by` (`created_by`),
  KEY `idx_courses_active_created` (`is_active`,`created_at`),
  KEY `idx_courses_status_created` (`status`,`created_at`),
  KEY `idx_courses_expert_created` (`expert_id`,`created_at`),
  KEY `idx_courses_price` (`price`),
  KEY `idx_courses_created` (`created_at`),
  FULLTEXT KEY `ft_courses_title_desc` (`title`,`description`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES
(4,'Professional React Bootcamp','professional-react-bootcamp','<p>Learn React with projects.</p>',NULL,NULL,NULL,NULL,49.00,'upcoming',1,'/uploads/courses/thumbnails/1755345927822-2025-08-15_151724.png',NULL,3,2,3,'2025-08-16 12:05:27',NULL,NULL,NULL,'beginner','English','usd',NULL,'public',NULL,'published'),
(5,'Hello 2','hello','<p>Hi</p><p>Hellow</p>','1899-11-27','1899-11-27','','',20.00,'upcoming',1,'/uploads/courses/thumbnails/1755346349217-2025-08-15_193438.png',NULL,3,2,3,'2025-08-16 12:12:29','2025-08-16 21:46:12',NULL,'hiii','beginner','English','usd','9','public','www/youtube.com','published');
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_education`
--

DROP TABLE IF EXISTS `expert_education`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_education` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `graduation_year` year(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `expert_education_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_education`
--

LOCK TABLES `expert_education` WRITE;
/*!40000 ALTER TABLE `expert_education` DISABLE KEYS */;
INSERT INTO `expert_education` VALUES
(1,3,'MBA','XYZ University',2018);
/*!40000 ALTER TABLE `expert_education` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_experiences`
--

DROP TABLE IF EXISTS `expert_experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_experiences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `expert_experiences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_experiences`
--

LOCK TABLES `expert_experiences` WRITE;
/*!40000 ALTER TABLE `expert_experiences` DISABLE KEYS */;
INSERT INTO `expert_experiences` VALUES
(1,3,'Coach','ABC','2020-01-01','2022-12-31','2025-08-05 17:05:27');
/*!40000 ALTER TABLE `expert_experiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_languages`
--

DROP TABLE IF EXISTS `expert_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `language` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `expert_id` (`expert_id`),
  CONSTRAINT `expert_languages_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_languages`
--

LOCK TABLES `expert_languages` WRITE;
/*!40000 ALTER TABLE `expert_languages` DISABLE KEYS */;
INSERT INTO `expert_languages` VALUES
(16,5,'EnglishHindi'),
(17,3,'English'),
(18,3,'French');
/*!40000 ALTER TABLE `expert_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_profiles`
--

DROP TABLE IF EXISTS `expert_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `headline` text DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `languages` varchar(255) DEFAULT NULL,
  `graduated` tinyint(1) DEFAULT 0,
  `stripe_account_id` varchar(255) DEFAULT NULL,
  `public_url_slug` varchar(100) DEFAULT NULL,
  `total_sessions_completed` int(11) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `public_url_slug` (`public_url_slug`),
  CONSTRAINT `expert_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_profiles`
--

LOCK TABLES `expert_profiles` WRITE;
/*!40000 ALTER TABLE `expert_profiles` DISABLE KEYS */;
INSERT INTO `expert_profiles` VALUES
(1,3,'Full-Stack Developer','<p>Uploads <strong>photo first</strong>, then PUTs the JSON payload.</p><p>Keeps <strong>location</strong> in its own textarea so it’s easy to view/edit.</p><p>Prevents accidental nulls by falling back to the GET snapshot for any unset field.</p>',NULL,0,NULL,NULL,0,0),
(6,5,'Senior Web Developer','<p>You don’t need to touch your APIs. If you want the “Course” count to be precise, return total_services_offered (or a similar field) in /experts; the card already reads several possible names.</p>',NULL,0,NULL,NULL,0,0),
(7,4,NULL,NULL,NULL,0,NULL,NULL,0,0);
/*!40000 ALTER TABLE `expert_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_reviews`
--

DROP TABLE IF EXISTS `expert_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` between 1 and 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_review` (`service_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `expert_reviews_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `expert_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_reviews`
--

LOCK TABLES `expert_reviews` WRITE;
/*!40000 ALTER TABLE `expert_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_service_categories`
--

DROP TABLE IF EXISTS `expert_service_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_service_categories` (
  `service_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`service_id`,`category_id`),
  KEY `idx_esc_category` (`category_id`),
  CONSTRAINT `fk_esc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_esc_service` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_service_categories`
--

LOCK TABLES `expert_service_categories` WRITE;
/*!40000 ALTER TABLE `expert_service_categories` DISABLE KEYS */;
INSERT INTO `expert_service_categories` VALUES
(1,1),
(3,1),
(4,1);
/*!40000 ALTER TABLE `expert_service_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_services`
--

DROP TABLE IF EXISTS `expert_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `image` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_consultation` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_services`
--

LOCK TABLES `expert_services` WRITE;
/*!40000 ALTER TABLE `expert_services` DISABLE KEYS */;
INSERT INTO `expert_services` VALUES
(1,3,'Resume Coaching','Expert help on resume',19.99,'/uploads/service_images/image-1754423016143-225351101.jpg','2025-08-05 19:21:28','2025-08-05 19:43:36',0),
(2,3,'Resume Coaching','Expert help on resume',49.99,'/uploads/service_images/image-1754569451107-952051340.jpg','2025-08-07 12:24:11','2025-08-07 12:24:11',0),
(3,3,'Interview Session Expert','<p class=\"ql-align-justify\">Customer service executives are the backbone of companies, who often communicate with their customers. These specialists help businesses establish and maintain strong relationships with their customers and clients. Knowing more about this domain will help you decide whether you want to pursue this career.</p><p class=\"ql-align-justify\"><br></p><h2>Who is a Customer Service Executive?</h2><p class=\"ql-align-justify\">A customer service executive is a professional who is responsible for communicating the reasons and methods related to service expectations within an organization. These professionals are assigned several duties, including answering phone calls, responding to customer questions, and resolving customer issues. They are typically responsible for front-line responsibilities that have a direct impact on a company\'s customer experience. They may also supervise a team of customer care professionals and train them on how to handle consumer complaints.</p><p class=\"ql-align-justify\">On the other hand, some customer service jobs are suitable for freshers, which range across a broad spectrum of categories, including call centers, technology, hospitality, education, and finance.</p><h2>10 Most Asked Customer Service Interview Questions</h2><ol><li>What is Customer Service?</li><li><a href=\"https://www.simplilearn.com/how-to-introduce-yourself-in-a-job-interview-article\" rel=\"noopener noreferrer\" target=\"_blank\">Tell me about yourself.</a></li><li>How do you prioritize your work?</li><li>How do you handle difficult customers?</li><li>How would previous colleagues describe you?</li><li>What are your greatest strengths?</li><li>How do you cope under pressure?</li><li>What are the top 20 customer service skills?</li><li>&nbsp;What are your career goals?</li><li>How do you keep yourself motivated?</li></ol>',29.00,'/uploads/service_images/image-1755266091630-124515018.png','2025-08-15 13:27:36','2025-08-15 13:54:51',0),
(4,3,'hh','<p>fdhdfh</p>',30.00,'/uploads/service_images/image-1755344110910-837517836.png','2025-08-16 11:35:10','2025-08-16 11:35:10',0);
/*!40000 ALTER TABLE `expert_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_skills`
--

DROP TABLE IF EXISTS `expert_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_skill_per_expert` (`expert_id`,`skill_id`),
  KEY `skill_id` (`skill_id`),
  CONSTRAINT `expert_skills_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`),
  CONSTRAINT `expert_skills_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_skills`
--

LOCK TABLES `expert_skills` WRITE;
/*!40000 ALTER TABLE `expert_skills` DISABLE KEYS */;
INSERT INTO `expert_skills` VALUES
(25,3,4),
(26,3,5),
(23,5,4),
(24,5,5);
/*!40000 ALTER TABLE `expert_skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_time_slots`
--

DROP TABLE IF EXISTS `expert_time_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `is_booked` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_expert_slot` (`expert_id`,`start_time`),
  KEY `idx_expert_time` (`expert_id`,`start_time`),
  CONSTRAINT `expert_time_slots_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=171 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_time_slots`
--

LOCK TABLES `expert_time_slots` WRITE;
/*!40000 ALTER TABLE `expert_time_slots` DISABLE KEYS */;
INSERT INTO `expert_time_slots` VALUES
(1,3,'2025-08-15 10:00:00','2025-08-15 11:00:00',0,'2025-08-09 21:20:55'),
(2,3,'2025-08-11 09:00:00','2025-08-11 10:00:00',0,'2025-08-10 07:02:01'),
(3,3,'2025-08-11 10:00:00','2025-08-11 11:00:00',0,'2025-08-10 07:02:01'),
(4,3,'2025-08-11 11:00:00','2025-08-11 12:00:00',0,'2025-08-10 07:02:01'),
(5,3,'2025-08-11 12:00:00','2025-08-11 13:00:00',0,'2025-08-10 07:02:01'),
(6,3,'2025-08-18 09:00:00','2025-08-18 10:00:00',1,'2025-08-10 07:02:01'),
(7,3,'2025-08-18 10:00:00','2025-08-18 11:00:00',1,'2025-08-10 07:02:01'),
(8,3,'2025-08-18 11:00:00','2025-08-18 12:00:00',1,'2025-08-10 07:02:01'),
(9,3,'2025-08-18 12:00:00','2025-08-18 13:00:00',0,'2025-08-10 07:02:01'),
(10,3,'2025-08-25 09:00:00','2025-08-25 10:00:00',0,'2025-08-10 07:02:01'),
(11,3,'2025-08-25 10:00:00','2025-08-25 11:00:00',0,'2025-08-10 07:02:01'),
(12,3,'2025-08-25 11:00:00','2025-08-25 12:00:00',0,'2025-08-10 07:02:01'),
(13,3,'2025-08-25 12:00:00','2025-08-25 13:00:00',0,'2025-08-10 07:02:01'),
(14,3,'2025-08-11 15:00:00','2025-08-11 16:00:00',0,'2025-08-10 07:02:01'),
(15,3,'2025-08-11 16:00:00','2025-08-11 17:00:00',0,'2025-08-10 07:02:01'),
(16,3,'2025-08-11 17:00:00','2025-08-11 18:00:00',0,'2025-08-10 07:02:01'),
(17,3,'2025-08-18 15:00:00','2025-08-18 16:00:00',0,'2025-08-10 07:02:01'),
(18,3,'2025-08-18 16:00:00','2025-08-18 17:00:00',0,'2025-08-10 07:02:01'),
(19,3,'2025-08-18 17:00:00','2025-08-18 18:00:00',0,'2025-08-10 07:02:01'),
(20,3,'2025-08-25 15:00:00','2025-08-25 16:00:00',0,'2025-08-10 07:02:01'),
(21,3,'2025-08-25 16:00:00','2025-08-25 17:00:00',0,'2025-08-10 07:02:01'),
(22,3,'2025-08-25 17:00:00','2025-08-25 18:00:00',0,'2025-08-10 07:02:01'),
(23,3,'2025-08-13 10:00:00','2025-08-13 11:00:00',0,'2025-08-10 07:02:01'),
(24,3,'2025-08-13 11:00:00','2025-08-13 12:00:00',0,'2025-08-10 07:02:01'),
(25,3,'2025-08-20 10:00:00','2025-08-20 11:00:00',0,'2025-08-10 07:02:01'),
(26,3,'2025-08-20 11:00:00','2025-08-20 12:00:00',0,'2025-08-10 07:02:01'),
(27,3,'2025-08-27 10:00:00','2025-08-27 11:00:00',0,'2025-08-10 07:02:01'),
(28,3,'2025-08-27 11:00:00','2025-08-27 12:00:00',0,'2025-08-10 07:02:01'),
(29,3,'2025-08-15 09:00:00','2025-08-15 10:00:00',0,'2025-08-10 07:02:01'),
(30,3,'2025-08-15 11:00:00','2025-08-15 12:00:00',1,'2025-08-10 07:02:01'),
(31,3,'2025-08-15 12:00:00','2025-08-15 13:00:00',0,'2025-08-10 07:02:01'),
(32,3,'2025-08-15 13:00:00','2025-08-15 14:00:00',1,'2025-08-10 07:02:01'),
(33,3,'2025-08-15 14:00:00','2025-08-15 15:00:00',1,'2025-08-10 07:02:01'),
(34,3,'2025-08-15 15:00:00','2025-08-15 16:00:00',0,'2025-08-10 07:02:01'),
(35,3,'2025-08-15 16:00:00','2025-08-15 17:00:00',0,'2025-08-10 07:02:01'),
(36,3,'2025-08-22 09:00:00','2025-08-22 10:00:00',0,'2025-08-10 07:02:01'),
(37,3,'2025-08-22 10:00:00','2025-08-22 11:00:00',0,'2025-08-10 07:02:01'),
(38,3,'2025-08-22 11:00:00','2025-08-22 12:00:00',0,'2025-08-10 07:02:01'),
(39,3,'2025-08-22 12:00:00','2025-08-22 13:00:00',0,'2025-08-10 07:02:01'),
(40,3,'2025-08-22 13:00:00','2025-08-22 14:00:00',0,'2025-08-10 07:02:01'),
(41,3,'2025-08-22 14:00:00','2025-08-22 15:00:00',0,'2025-08-10 07:02:01'),
(42,3,'2025-08-22 15:00:00','2025-08-22 16:00:00',0,'2025-08-10 07:02:01'),
(43,3,'2025-08-22 16:00:00','2025-08-22 17:00:00',0,'2025-08-10 07:02:01'),
(44,3,'2025-08-29 09:00:00','2025-08-29 10:00:00',0,'2025-08-10 07:02:01'),
(45,3,'2025-08-29 10:00:00','2025-08-29 11:00:00',0,'2025-08-10 07:02:01'),
(46,3,'2025-08-29 11:00:00','2025-08-29 12:00:00',0,'2025-08-10 07:02:01'),
(47,3,'2025-08-29 12:00:00','2025-08-29 13:00:00',0,'2025-08-10 07:02:01'),
(48,3,'2025-08-29 13:00:00','2025-08-29 14:00:00',0,'2025-08-10 07:02:01'),
(49,3,'2025-08-29 14:00:00','2025-08-29 15:00:00',0,'2025-08-10 07:02:01'),
(50,3,'2025-08-29 15:00:00','2025-08-29 16:00:00',0,'2025-08-10 07:02:01'),
(51,3,'2025-08-29 16:00:00','2025-08-29 17:00:00',0,'2025-08-10 07:02:01'),
(105,3,'2025-09-01 09:00:00','2025-09-01 10:00:00',0,'2025-08-15 09:30:42'),
(106,3,'2025-09-01 10:00:00','2025-09-01 11:00:00',0,'2025-08-15 09:30:42'),
(107,3,'2025-09-01 11:00:00','2025-09-01 12:00:00',0,'2025-08-15 09:30:42'),
(108,3,'2025-09-01 12:00:00','2025-09-01 13:00:00',0,'2025-08-15 09:30:42'),
(109,3,'2025-09-08 09:00:00','2025-09-08 10:00:00',0,'2025-08-15 09:30:42'),
(110,3,'2025-09-08 10:00:00','2025-09-08 11:00:00',0,'2025-08-15 09:30:42'),
(111,3,'2025-09-08 11:00:00','2025-09-08 12:00:00',0,'2025-08-15 09:30:42'),
(112,3,'2025-09-08 12:00:00','2025-09-08 13:00:00',0,'2025-08-15 09:30:42'),
(113,3,'2025-09-15 09:00:00','2025-09-15 10:00:00',0,'2025-08-15 09:30:42'),
(114,3,'2025-09-15 10:00:00','2025-09-15 11:00:00',0,'2025-08-15 09:30:42'),
(115,3,'2025-09-15 11:00:00','2025-09-15 12:00:00',0,'2025-08-15 09:30:42'),
(116,3,'2025-09-15 12:00:00','2025-09-15 13:00:00',0,'2025-08-15 09:30:42'),
(117,3,'2025-09-22 09:00:00','2025-09-22 10:00:00',0,'2025-08-15 09:30:42'),
(118,3,'2025-09-22 10:00:00','2025-09-22 11:00:00',0,'2025-08-15 09:30:42'),
(119,3,'2025-09-22 11:00:00','2025-09-22 12:00:00',0,'2025-08-15 09:30:42'),
(120,3,'2025-09-22 12:00:00','2025-09-22 13:00:00',0,'2025-08-15 09:30:42'),
(121,3,'2025-09-29 09:00:00','2025-09-29 10:00:00',0,'2025-08-15 09:30:42'),
(122,3,'2025-09-29 10:00:00','2025-09-29 11:00:00',0,'2025-08-15 09:30:42'),
(123,3,'2025-09-29 11:00:00','2025-09-29 12:00:00',0,'2025-08-15 09:30:42'),
(124,3,'2025-09-29 12:00:00','2025-09-29 13:00:00',0,'2025-08-15 09:30:42'),
(125,3,'2025-09-01 17:00:00','2025-09-01 18:00:00',0,'2025-08-15 09:30:42'),
(126,3,'2025-09-08 17:00:00','2025-09-08 18:00:00',0,'2025-08-15 09:30:42'),
(127,3,'2025-09-15 17:00:00','2025-09-15 18:00:00',0,'2025-08-15 09:30:42'),
(128,3,'2025-09-22 17:00:00','2025-09-22 18:00:00',0,'2025-08-15 09:30:42'),
(129,3,'2025-09-29 17:00:00','2025-09-29 18:00:00',0,'2025-08-15 09:30:42'),
(130,3,'2025-09-03 10:00:00','2025-09-03 11:00:00',0,'2025-08-15 09:30:42'),
(131,3,'2025-09-03 11:00:00','2025-09-03 12:00:00',0,'2025-08-15 09:30:42'),
(132,3,'2025-09-10 10:00:00','2025-09-10 11:00:00',0,'2025-08-15 09:30:42'),
(133,3,'2025-09-10 11:00:00','2025-09-10 12:00:00',0,'2025-08-15 09:30:42'),
(134,3,'2025-09-17 10:00:00','2025-09-17 11:00:00',0,'2025-08-15 09:30:42'),
(135,3,'2025-09-17 11:00:00','2025-09-17 12:00:00',0,'2025-08-15 09:30:42'),
(136,3,'2025-09-24 10:00:00','2025-09-24 11:00:00',0,'2025-08-15 09:30:42'),
(137,3,'2025-09-24 11:00:00','2025-09-24 12:00:00',0,'2025-08-15 09:30:42'),
(138,3,'2025-09-05 09:00:00','2025-09-05 10:00:00',0,'2025-08-15 09:30:42'),
(139,3,'2025-09-05 10:00:00','2025-09-05 11:00:00',0,'2025-08-15 09:30:42'),
(140,3,'2025-09-05 11:00:00','2025-09-05 12:00:00',0,'2025-08-15 09:30:42'),
(141,3,'2025-09-05 12:00:00','2025-09-05 13:00:00',0,'2025-08-15 09:30:42'),
(142,3,'2025-09-05 13:00:00','2025-09-05 14:00:00',0,'2025-08-15 09:30:42'),
(143,3,'2025-09-05 14:00:00','2025-09-05 15:00:00',0,'2025-08-15 09:30:42'),
(144,3,'2025-09-05 15:00:00','2025-09-05 16:00:00',0,'2025-08-15 09:30:42'),
(145,3,'2025-09-05 16:00:00','2025-09-05 17:00:00',0,'2025-08-15 09:30:42'),
(146,3,'2025-09-12 09:00:00','2025-09-12 10:00:00',0,'2025-08-15 09:30:42'),
(147,3,'2025-09-12 10:00:00','2025-09-12 11:00:00',0,'2025-08-15 09:30:42'),
(148,3,'2025-09-12 11:00:00','2025-09-12 12:00:00',0,'2025-08-15 09:30:42'),
(149,3,'2025-09-12 12:00:00','2025-09-12 13:00:00',0,'2025-08-15 09:30:42'),
(150,3,'2025-09-12 13:00:00','2025-09-12 14:00:00',0,'2025-08-15 09:30:42'),
(151,3,'2025-09-12 14:00:00','2025-09-12 15:00:00',0,'2025-08-15 09:30:42'),
(152,3,'2025-09-12 15:00:00','2025-09-12 16:00:00',0,'2025-08-15 09:30:42'),
(153,3,'2025-09-12 16:00:00','2025-09-12 17:00:00',0,'2025-08-15 09:30:42'),
(154,3,'2025-09-19 09:00:00','2025-09-19 10:00:00',0,'2025-08-15 09:30:42'),
(155,3,'2025-09-19 10:00:00','2025-09-19 11:00:00',0,'2025-08-15 09:30:42'),
(156,3,'2025-09-19 11:00:00','2025-09-19 12:00:00',0,'2025-08-15 09:30:42'),
(157,3,'2025-09-19 12:00:00','2025-09-19 13:00:00',0,'2025-08-15 09:30:42'),
(158,3,'2025-09-19 13:00:00','2025-09-19 14:00:00',0,'2025-08-15 09:30:42'),
(159,3,'2025-09-19 14:00:00','2025-09-19 15:00:00',0,'2025-08-15 09:30:42'),
(160,3,'2025-09-19 15:00:00','2025-09-19 16:00:00',0,'2025-08-15 09:30:42'),
(161,3,'2025-09-19 16:00:00','2025-09-19 17:00:00',0,'2025-08-15 09:30:42'),
(162,3,'2025-09-26 09:00:00','2025-09-26 10:00:00',0,'2025-08-15 09:30:42'),
(163,3,'2025-09-26 10:00:00','2025-09-26 11:00:00',0,'2025-08-15 09:30:42'),
(164,3,'2025-09-26 11:00:00','2025-09-26 12:00:00',0,'2025-08-15 09:30:42'),
(165,3,'2025-09-26 12:00:00','2025-09-26 13:00:00',0,'2025-08-15 09:30:42'),
(166,3,'2025-09-26 13:00:00','2025-09-26 14:00:00',0,'2025-08-15 09:30:42'),
(167,3,'2025-09-26 14:00:00','2025-09-26 15:00:00',0,'2025-08-15 09:30:42'),
(168,3,'2025-09-26 15:00:00','2025-09-26 16:00:00',0,'2025-08-15 09:30:42'),
(169,3,'2025-09-26 16:00:00','2025-09-26 17:00:00',0,'2025-08-15 09:30:42'),
(170,3,'2025-08-30 03:00:00','2025-08-30 04:00:00',0,'2025-08-15 10:12:54');
/*!40000 ALTER TABLE `expert_time_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_weekly_availability`
--

DROP TABLE IF EXISTS `expert_weekly_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_weekly_availability` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `day_of_week` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 30,
  `buffer_minutes` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_expert_dow_window` (`expert_id`,`day_of_week`,`start_time`,`end_time`),
  CONSTRAINT `expert_weekly_availability_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_weekly_availability`
--

LOCK TABLES `expert_weekly_availability` WRITE;
/*!40000 ALTER TABLE `expert_weekly_availability` DISABLE KEYS */;
INSERT INTO `expert_weekly_availability` VALUES
(1,3,'Saturday','14:00:00','16:30:00',30,10,'2025-08-08 19:29:17'),
(2,3,'Saturday','10:00:00','14:00:00',30,0,'2025-08-08 20:50:48');
/*!40000 ALTER TABLE `expert_weekly_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_weekly_templates`
--

DROP TABLE IF EXISTS `expert_weekly_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_weekly_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `day_of_week` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_expert_dow` (`expert_id`,`day_of_week`),
  CONSTRAINT `expert_weekly_templates_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_weekly_templates`
--

LOCK TABLES `expert_weekly_templates` WRITE;
/*!40000 ALTER TABLE `expert_weekly_templates` DISABLE KEYS */;
INSERT INTO `expert_weekly_templates` VALUES
(1,3,'Monday','09:00:00','13:00:00','2025-08-10 07:01:33'),
(2,3,'Monday','17:00:00','18:00:00','2025-08-10 07:01:33'),
(3,3,'Wednesday','10:00:00','12:00:00','2025-08-10 07:01:33'),
(4,3,'Friday','09:00:00','17:00:00','2025-08-10 07:01:33');
/*!40000 ALTER TABLE `expert_weekly_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `general_profiles`
--

DROP TABLE IF EXISTS `general_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `general_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `interests` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `general_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `general_profiles`
--

LOCK TABLES `general_profiles` WRITE;
/*!40000 ALTER TABLE `general_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `general_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industries`
--

LOCK TABLES `industries` WRITE;
/*!40000 ALTER TABLE `industries` DISABLE KEYS */;
INSERT INTO `industries` VALUES
(2,'Business'),
(1,'Updated Industry');
/*!40000 ALTER TABLE `industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_participants`
--

DROP TABLE IF EXISTS `meeting_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('host','participant') DEFAULT 'participant',
  `status` enum('invited','accepted','declined','left') DEFAULT 'accepted',
  `reminder_sent` tinyint(1) DEFAULT 0,
  `joined_at` datetime DEFAULT NULL,
  `left_at` datetime DEFAULT NULL,
  `invited_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_meeting_user` (`meeting_id`,`user_id`),
  UNIQUE KEY `uniq_meeting_user` (`meeting_id`,`user_id`),
  KEY `idx_mp_meeting` (`meeting_id`),
  KEY `idx_mp_user` (`user_id`),
  KEY `idx_meeting` (`meeting_id`),
  CONSTRAINT `meeting_participants_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meeting_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_participants`
--

LOCK TABLES `meeting_participants` WRITE;
/*!40000 ALTER TABLE `meeting_participants` DISABLE KEYS */;
INSERT INTO `meeting_participants` VALUES
(1,6,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-15 17:50:00'),
(2,6,4,'participant','accepted',0,NULL,NULL,NULL,'2025-08-15 17:50:00'),
(3,7,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-16 06:52:01'),
(4,7,4,'participant','accepted',0,NULL,NULL,NULL,'2025-08-16 06:52:01');
/*!40000 ALTER TABLE `meeting_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meetings`
--

DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `expert_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `slot_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `provider` enum('livekit','zoom','meet') DEFAULT 'livekit',
  `room_name` varchar(128) NOT NULL,
  `join_url_user` varchar(255) DEFAULT NULL,
  `join_url_expert` varchar(255) DEFAULT NULL,
  `status` enum('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `meeting_type` enum('one-on-one','group') NOT NULL DEFAULT 'one-on-one',
  `video_tool` enum('jitsi','webrtc','livekit') NOT NULL DEFAULT 'livekit',
  `meet_type` enum('audio','video') NOT NULL DEFAULT 'video',
  `timezone` varchar(100) NOT NULL DEFAULT 'UTC',
  `live_room_name` varchar(255) DEFAULT NULL,
  `is_live` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_sent` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_order` (`order_id`),
  KEY `slot_id` (`slot_id`),
  KEY `idx_meeting_expert_time` (`expert_id`,`start_time`),
  KEY `idx_meetings_created_by` (`created_by`),
  CONSTRAINT `fk_meetings_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `meetings_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `service_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meetings_ibfk_2` FOREIGN KEY (`slot_id`) REFERENCES `expert_time_slots` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetings`
--

LOCK TABLES `meetings` WRITE;
/*!40000 ALTER TABLE `meetings` DISABLE KEYS */;
INSERT INTO `meetings` VALUES
(3,1,3,3,6,'2025-08-18 09:00:00','2025-08-18 10:00:00',NULL,'livekit','room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=user','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=expert','','2025-08-10 07:47:52','one-on-one','livekit','video','UTC',NULL,0,0),
(4,3,3,3,7,'2025-08-18 10:00:00','2025-08-18 11:00:00',NULL,'livekit','room_6b304630-692a-49a5-8cec-e5d96e9835f5','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=user','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=expert','','2025-08-10 07:50:26','one-on-one','livekit','video','UTC',NULL,0,0),
(5,5,3,4,8,'2025-08-18 11:00:00','2025-08-18 12:00:00',NULL,'livekit','room_56dbff05-1a15-416c-9577-ad04d2851035','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=user','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=expert','','2025-08-11 19:21:19','one-on-one','livekit','video','UTC',NULL,0,0),
(6,6,3,4,30,'2025-08-15 11:00:00','2025-08-15 12:00:00',NULL,'livekit','room_915e28fc-6b01-4470-b983-0ea9f59d54ab','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=user','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=expert','upcoming','2025-08-14 19:44:30','one-on-one','livekit','video','UTC',NULL,0,0),
(7,36,3,4,32,'2025-08-15 13:00:00','2025-08-15 14:00:00',NULL,'livekit','room_79c13df8-f57a-44ed-96d3-fe860a2e0e55','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=user','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=expert','upcoming','2025-08-16 06:52:01','one-on-one','livekit','video','UTC',NULL,0,0),
(8,39,3,3,33,'2025-08-15 14:00:00','2025-08-15 15:00:00',NULL,'livekit','room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=user','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=expert','upcoming','2025-08-16 07:40:16','one-on-one','livekit','video','UTC',NULL,0,0);
/*!40000 ALTER TABLE `meetings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_reads`
--

DROP TABLE IF EXISTS `message_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_reads` (
  `message_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`message_id`,`user_id`),
  KEY `fk_mread_user` (`user_id`),
  CONSTRAINT `fk_mread_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mread_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_reads`
--

LOCK TABLES `message_reads` WRITE;
/*!40000 ALTER TABLE `message_reads` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `content` text DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `file_url` text DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `edited_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_chat_created` (`chat_id`,`created_at`),
  KEY `idx_sender` (`sender_id`),
  CONSTRAINT `fk_messages_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES
(1,1,4,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-12 09:51:36'),
(2,1,4,'how are yuo?',NULL,NULL,0,0,NULL,NULL,'2025-08-12 09:51:47'),
(3,1,4,'where are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-12 10:35:41'),
(4,1,4,'tui koi',NULL,NULL,0,0,NULL,NULL,'2025-08-12 10:39:02');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `path` varchar(255) DEFAULT NULL,
  `icon` varchar(64) DEFAULT NULL,
  `order_num` int(11) NOT NULL DEFAULT 999,
  `is_menu` tinyint(1) NOT NULL DEFAULT 1,
  `parent_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_pages_path` (`path`),
  KEY `idx_pages_parent` (`parent_id`),
  CONSTRAINT `fk_pages_parent` FOREIGN KEY (`parent_id`) REFERENCES `pages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES
(1,'Dashboard','/dashboard','layout-dashboard',1,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(2,'Expert Dashboard','/expert/dashboard','layout-dashboard',2,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 20:14:52'),
(3,'Resume Review','/resume','file-check',3,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(4,'Courses & Events','/course-events','monitor-play',4,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:29:46'),
(5,'Service Hub','/services','briefcase',5,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(6,'Find an Expert','/find-an-expert','graduation-cap',6,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:33:09'),
(7,'My Network','/my-network','earth',7,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:34:20'),
(8,'Messages','/messages','messages-square',8,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:35:54'),
(9,'Coaching Session','/meetings','calendar-days',9,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:37:32'),
(10,'Job Board','/jobs','list',10,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(11,'Payments','/payments','credit-card',11,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(12,'Settings','/settings','settings',12,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(16,'Admin Setting','/admin-setting','calendar-cog',16,1,NULL,1,'2025-08-13 19:40:46','2025-08-13 20:49:31'),
(17,'Page List','/menu-page-list','layout-panel-top',1,1,16,1,'2025-08-13 19:44:02','2025-08-13 20:47:41'),
(18,'Role List','/user-role-list','globe-lock',2,1,16,1,'2025-08-13 19:45:14','2025-08-13 20:47:12'),
(19,'Role Permission','/role-page-access','shield-alert',2,1,16,1,'2025-08-13 19:46:08','2025-08-13 20:48:13'),
(20,'Category List','/category-list','clipboard-list',6,1,16,1,'2025-08-13 20:44:05','2025-08-13 20:44:05'),
(21,'My Availability','/my-availability','timer-reset',999,1,6,1,'2025-08-15 06:34:08','2025-08-15 06:34:08'),
(22,'Create Services','/services/create','package-plus',999,1,5,1,'2025-08-15 13:17:22','2025-08-15 13:17:22'),
(23,'My Services','/my-services','shopping-cart',1,1,5,1,'2025-08-15 13:19:45','2025-08-15 13:22:21'),
(24,'All Experts','/find-an-expert','book-open-text',1,1,6,1,'2025-08-15 15:04:15','2025-08-15 15:04:15'),
(25,'All Services','/services','gift',1,1,5,1,'2025-08-15 16:37:45','2025-08-15 16:37:45'),
(26,'All Courses & Events','/course-events','calendar-sync',1,1,4,1,'2025-08-16 06:51:35','2025-08-16 06:51:35'),
(27,'Create New Course','/course-events/create','diamond-plus',3,1,4,1,'2025-08-16 07:15:04','2025-08-16 07:15:04'),
(28,'My Courses','/my-courses','school',2,1,4,1,'2025-08-16 07:15:58','2025-08-16 07:15:58');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_prt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES
(1,3,'0991a70f7bab68a19f284834d7cb94525979f29becb22c472ec474035dd7593b','2025-08-10 15:54:30',0,NULL,'2025-08-10 08:54:30');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_webhook_events`
--

DROP TABLE IF EXISTS `payment_webhook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_webhook_events` (
  `id` varchar(191) NOT NULL,
  `provider` enum('stripe') NOT NULL,
  `received_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_webhook_events`
--

LOCK TABLES `payment_webhook_events` WRITE;
/*!40000 ALTER TABLE `payment_webhook_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_webhook_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_page_permissions`
--

DROP TABLE IF EXISTS `role_page_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_page_permissions` (
  `role_id` int(11) NOT NULL,
  `page_id` int(11) NOT NULL,
  `can_view` tinyint(1) NOT NULL DEFAULT 0,
  `can_create` tinyint(1) NOT NULL DEFAULT 0,
  `can_update` tinyint(1) NOT NULL DEFAULT 0,
  `can_delete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`role_id`,`page_id`),
  KEY `fk_rpp_page` (`page_id`),
  CONSTRAINT `fk_rpp_page` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rpp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_page_permissions`
--

LOCK TABLES `role_page_permissions` WRITE;
/*!40000 ALTER TABLE `role_page_permissions` DISABLE KEYS */;
INSERT INTO `role_page_permissions` VALUES
(1,1,1,1,0,0),
(1,4,1,1,0,0),
(1,5,1,1,0,0),
(1,6,1,1,0,0),
(1,7,1,0,0,0),
(1,8,1,1,1,1),
(1,9,1,1,1,1),
(1,11,1,0,1,0),
(1,12,1,1,1,1),
(1,16,1,1,1,1),
(1,17,1,1,1,1),
(1,18,1,1,1,1),
(1,19,1,1,1,1),
(1,20,1,1,1,1),
(1,21,1,1,1,1),
(1,22,1,1,1,1),
(1,23,1,1,1,1),
(1,24,1,1,1,1),
(1,25,1,1,1,1),
(1,26,1,1,0,0),
(1,27,1,1,0,0),
(1,28,1,1,0,0),
(2,2,1,0,0,0),
(2,4,1,1,1,1),
(2,5,1,1,1,1),
(2,6,1,1,1,1),
(2,7,1,1,1,1),
(2,8,1,1,1,1),
(2,9,1,1,1,1),
(2,11,1,1,1,1),
(2,12,1,1,1,1),
(2,21,1,1,1,1),
(2,22,1,1,1,1),
(2,23,1,1,1,1),
(2,24,1,1,1,1),
(2,25,1,1,1,1),
(2,26,1,1,0,0),
(2,27,1,1,1,1),
(2,28,1,1,1,1),
(5,1,1,0,0,0),
(5,4,1,0,0,0),
(5,5,1,0,0,0),
(5,6,1,0,0,0),
(5,7,1,0,0,0),
(5,8,1,0,0,0),
(5,9,1,0,0,0),
(5,11,1,0,0,0),
(5,12,1,0,0,0);
/*!40000 ALTER TABLE `role_page_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(60) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES
(1,'Administrator','admin','2025-08-13 08:37:05','2025-08-13 08:39:13'),
(2,'Expert','expert','2025-08-13 08:37:05','2025-08-13 08:38:20'),
(4,'Reviewer','reviewer','2025-08-13 08:37:55','2025-08-13 08:37:55'),
(5,'User','user','2025-08-13 08:37:55','2025-08-13 08:37:55');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_orders`
--

DROP TABLE IF EXISTS `service_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `expert_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `status` enum('pending','paid','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `payment_ref` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `slot_id` int(11) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Failed') DEFAULT 'Pending',
  `meeting_id` int(11) DEFAULT NULL,
  `stripe_payment_intent_id` varchar(255) DEFAULT NULL,
  `stripe_charge_id` varchar(255) DEFAULT NULL,
  `stripe_invoice_id` varchar(255) DEFAULT NULL,
  `payment_method_id` varchar(255) DEFAULT NULL,
  `receipt_url` text DEFAULT NULL,
  `hosted_invoice_url` text DEFAULT NULL,
  `invoice_pdf_url` text DEFAULT NULL,
  `card_brand` varchar(50) DEFAULT NULL,
  `card_last4` varchar(10) DEFAULT NULL,
  `is_pending` tinyint(1) GENERATED ALWAYS AS (`status` = 'pending') STORED,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_expert` (`expert_id`),
  KEY `idx_status_created` (`status`,`created_at`),
  KEY `idx_service_orders_slot` (`slot_id`),
  KEY `idx_service_orders_payment_status` (`payment_status`),
  KEY `idx_service_orders_meeting_id` (`meeting_id`),
  KEY `idx_pending_lookup` (`user_id`,`expert_id`,`service_id`,`slot_id`,`status`),
  CONSTRAINT `service_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_orders_ibfk_2` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_orders`
--

LOCK TABLES `service_orders` WRITE;
/*!40000 ALTER TABLE `service_orders` DISABLE KEYS */;
INSERT INTO `service_orders` VALUES
(1,3,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-09 19:46:16','2025-08-15 05:44:16',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(2,3,3,1,19.99,'USD','cancelled','Please prepare documents before meeting',NULL,'2025-08-09 21:00:15','2025-08-15 05:44:16',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(3,3,3,1,19.99,'USD','pending','Please review my resume before call',NULL,'2025-08-10 07:49:06','2025-08-12 07:39:13',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(4,4,3,1,19.99,'USD','pending','Please review my resume before call',NULL,'2025-08-11 15:28:11','2025-08-11 15:28:11',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(5,4,3,1,19.99,'USD','paid','Please review my resume before call','manual-OK-123','2025-08-11 19:18:52','2025-08-11 19:21:19',8,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(6,4,3,2,49.99,'USD','paid',NULL,'cs_test_b1LoAVIvITXyG6V25dVzM3umMBp52sogmnb03z0E4rTFOmR37d2FDXPbjU','2025-08-14 19:43:49','2025-08-14 19:44:31',30,'Paid',6,'pi_3Rw74X3RqEMUJuhk0anuzhlI','ch_3Rw74X3RqEMUJuhk01SLvTEy','in_1Rw74Z3RqEMUJuhkQLBAVt8v','pm_1Rw74W3RqEMUJuhkJyT3K4ug','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJ_5-MQGMgZICvWPGLU6LBYcH4C7KtuUlx8ao70PpsJsm_cqARnHUbhflXr_0R88izE56N_v7j_DoWpX?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH/pdf?s=ap','visa','4242',0),
(7,4,3,2,49.99,'USD','cancelled',NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(8,4,3,2,49.99,'USD','cancelled',NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(9,4,3,2,49.99,'USD','cancelled',NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(10,4,3,2,49.99,'USD','cancelled',NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(11,4,3,2,49.99,'USD','pending',NULL,NULL,'2025-08-14 20:58:04','2025-08-14 20:58:04',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(12,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(13,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(14,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(15,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(16,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:11:04','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(17,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(18,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(19,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(20,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(21,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:14:16','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(22,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(23,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(24,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:15:18','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(25,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(26,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(27,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:16:24','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(28,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(29,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(30,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:17:28','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(31,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:18:07','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(32,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:20:22','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(33,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:20:47','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(34,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:22:37','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(35,4,3,1,19.99,'USD','cancelled',NULL,NULL,'2025-08-15 05:22:56','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(36,4,3,1,19.99,'USD','paid',NULL,'cs_test_b1BjCsbtM1eKde8bGgWzwjnzaVuTdIUNIvtrHsqb1ixFs7fmwClld3JFm2','2025-08-15 05:23:11','2025-08-16 06:52:01',32,'Paid',7,'pi_3Rwdxw3RqEMUJuhk16iUcsFO','ch_3Rwdxw3RqEMUJuhk1skTjrTj','in_1Rwdxy3RqEMUJuhk8wFdoR26','pm_1Rw8v33RqEMUJuhkSAN3rnay','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJHVgMUGMgY-mXdTyFg6LBbUju_CRnKhkFVpdmSmtfDftvzB_cnmcOmRND5HAKuaeESvVH3AJyJutevz?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9/pdf?s=ap','visa','4242',0),
(37,4,3,1,19.99,'USD','pending',NULL,NULL,'2025-08-15 05:53:23','2025-08-15 05:53:23',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(38,3,3,1,19.99,'USD','pending',NULL,NULL,'2025-08-15 10:41:09','2025-08-15 10:41:09',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(39,3,3,1,19.99,'USD','paid',NULL,'cs_test_b1IfjVcKdWYKloyjDwmFJhkMU8PodwgYd5Z4xPVHctH1i39lbT587v0Z2p','2025-08-15 10:49:46','2025-08-16 07:40:17',33,'Paid',8,'pi_3Rweii3RqEMUJuhk1h6lUhVW','py_3Rweii3RqEMUJuhk10AMjbFM','in_1Rwein3RqEMUJuhkZXfYXxju','pm_1Rweih3RqEMUJuhk6S8OpnPk','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKOHrgMUGMgYxprV3KCk6LBazZnimaArZJKcifiFYOWNGZzGCPFniVCKGn0dilPIHGQc1U0JlMlBoo8Ah?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu/pdf?s=ap',NULL,NULL,0);
/*!40000 ALTER TABLE `service_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_reviews`
--

DROP TABLE IF EXISTS `service_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_review` (`service_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `service_reviews_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`),
  CONSTRAINT `service_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_reviews`
--

LOCK TABLES `service_reviews` WRITE;
/*!40000 ALTER TABLE `service_reviews` DISABLE KEYS */;
INSERT INTO `service_reviews` VALUES
(1,1,3,4,'Very helpful session!','2025-08-05 19:44:44');
/*!40000 ALTER TABLE `service_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES
(3,'AI Strategy'),
(4,'NodeJS'),
(1,'Python'),
(5,'ReactJs'),
(2,'TensorFlow');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_connections`
--

DROP TABLE IF EXISTS `user_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `connected_user_id` int(11) NOT NULL,
  `status` enum('pending','connected','rejected') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_connection` (`user_id`,`connected_user_id`),
  KEY `connected_user_id` (`connected_user_id`),
  CONSTRAINT `user_connections_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_connections_ibfk_2` FOREIGN KEY (`connected_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_connections`
--

LOCK TABLES `user_connections` WRITE;
/*!40000 ALTER TABLE `user_connections` DISABLE KEYS */;
INSERT INTO `user_connections` VALUES
(3,3,4,'pending','2025-08-08 20:15:45','2025-08-08 20:15:45'),
(4,3,1,'pending','2025-08-08 21:16:24','2025-08-08 21:16:24'),
(5,3,3,'pending','2025-08-15 19:48:51','2025-08-15 19:48:51'),
(6,3,5,'pending','2025-08-15 19:49:32','2025-08-15 19:49:32'),
(7,4,5,'pending','2025-08-16 04:38:18','2025-08-16 04:38:18'),
(8,4,3,'pending','2025-08-16 04:38:19','2025-08-16 04:38:19');
/*!40000 ALTER TABLE `user_connections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_industries`
--

DROP TABLE IF EXISTS `user_industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `industry_id` (`industry_id`),
  CONSTRAINT `user_industries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_industries_ibfk_2` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_industries`
--

LOCK TABLES `user_industries` WRITE;
/*!40000 ALTER TABLE `user_industries` DISABLE KEYS */;
INSERT INTO `user_industries` VALUES
(1,1,1),
(2,2,1),
(29,3,2);
/*!40000 ALTER TABLE `user_industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES
(1,1),
(1,2),
(3,2),
(4,1);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `profile_photo` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `location` varchar(255) DEFAULT NULL,
  `timezone` varchar(100) DEFAULT NULL,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
  `stripe_default_payment_method` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'abutaleb142@gmail.com','$2a$10$PAJBvQi/P/XLdFJWwEvO8OqOMlYPT6E8yuGDlY5vbDuWM1P3L4smu',NULL,2,NULL,NULL,NULL,NULL,'active','2025-08-05 07:05:07','2025-08-08 15:16:10','Mohammad Abu','Taleb',0,NULL,NULL,NULL,NULL),
(2,'mustafizur142@gmail.com','$2a$10$xgiljheLPBWwAzwCVQ/ECudaISBdwvG9kSmATC8IpqlPEazNJRkPO',NULL,1,NULL,NULL,NULL,NULL,'active','2025-08-05 07:07:41','2025-08-05 07:07:41','Mustafizur','Rahman',0,NULL,NULL,NULL,NULL),
(3,'imranhossen1119999@gmail.com','$2a$10$gHsVq1qLWS65hjd6D7ufDOTMka4bzln7vrcdUJZmkfF.Sxq94LEUG','2025-08-10 14:52:23',2,'/uploads/profile_photos/1755276406736-Rashed Islam.jpg','Jessore','Jessore','Bangladesh','active','2025-08-05 07:14:34','2025-08-16 06:17:01','Imran','Hossen',1,'Jessore mani Road','Asia/Dhaka','cus_Ss5IuKQ2Wybk0m',NULL),
(4,'admin@example.com','$2a$10$BNkZhxIFJ3qRC5pHbOdTKe8w5G7Fm/oE6NrVnuWad/NpjSuG0BA6K',NULL,1,'/uploads/profile_photos/1755318940977-munsi.jpg',NULL,NULL,NULL,'active','2025-08-05 07:20:47','2025-08-16 04:35:41',NULL,NULL,1,'',NULL,'cus_Srql9qnzJPpwCc','pm_1Rw8v33RqEMUJuhkSAN3rnay'),
(5,'admin2@example.com','$2a$10$GwSLMgsCmCen/9Gqw5mIM.OLgHB7xjx4abIH0QwDqn0Pp.w7k2ntC',NULL,2,'/uploads/profile_photos/1755289622403-apon.jpg','San Frincisco','CA','United States','active','2025-08-06 09:32:28','2025-08-15 20:29:49','Mr Alex','Joe',0,'San Frincisco, CA','Pacific/Midway',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `vw_chat_last_message`
--

DROP TABLE IF EXISTS `vw_chat_last_message`;
/*!50001 DROP VIEW IF EXISTS `vw_chat_last_message`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_chat_last_message` AS SELECT
 1 AS `chat_id`,
  1 AS `last_message_id`,
  1 AS `sender_id`,
  1 AS `content`,
  1 AS `file_url`,
  1 AS `attachment`,
  1 AS `last_message_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_user_chat_unread`
--

DROP TABLE IF EXISTS `vw_user_chat_unread`;
/*!50001 DROP VIEW IF EXISTS `vw_user_chat_unread`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_user_chat_unread` AS SELECT
 1 AS `user_id`,
  1 AS `chat_id`,
  1 AS `unread_count` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_chat_last_message`
--

/*!50001 DROP VIEW IF EXISTS `vw_chat_last_message`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_chat_last_message` AS select `m`.`chat_id` AS `chat_id`,`m`.`id` AS `last_message_id`,`m`.`sender_id` AS `sender_id`,`m`.`content` AS `content`,`m`.`file_url` AS `file_url`,`m`.`attachment` AS `attachment`,`m`.`created_at` AS `last_message_at` from (`messages` `m` join (select `messages`.`chat_id` AS `chat_id`,max(`messages`.`created_at`) AS `max_created` from `messages` group by `messages`.`chat_id`) `t` on(`t`.`chat_id` = `m`.`chat_id` and `t`.`max_created` = `m`.`created_at`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_user_chat_unread`
--

/*!50001 DROP VIEW IF EXISTS `vw_user_chat_unread`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_user_chat_unread` AS select `cp`.`user_id` AS `user_id`,`m`.`chat_id` AS `chat_id`,count(0) AS `unread_count` from ((`chat_participants` `cp` join `messages` `m` on(`m`.`chat_id` = `cp`.`chat_id` and `m`.`sender_id` <> `cp`.`user_id`)) left join `message_reads` `mr` on(`mr`.`message_id` = `m`.`id` and `mr`.`user_id` = `cp`.`user_id`)) where `mr`.`message_id` is null group by `cp`.`user_id`,`m`.`chat_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-16 19:25:30
