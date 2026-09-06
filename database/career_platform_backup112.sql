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
-- Table structure for table `auth_revoked_tokens`
--

DROP TABLE IF EXISTS `auth_revoked_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_revoked_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `token_hash` char(64) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `expires_at` (`expires_at`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_revoked_tokens`
--

LOCK TABLES `auth_revoked_tokens` WRITE;
/*!40000 ALTER TABLE `auth_revoked_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_revoked_tokens` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(15,'Personal Productivity','personal-productivity','Time management, tools, habits',1,'2025-08-16 15:11:39'),
(16,'New Category 2','new-category-2','This is for demo',1,'2025-08-17 14:11:40');
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
  UNIQUE KEY `uq_chat_user` (`chat_id`,`user_id`),
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
(2,4,'2025-08-12 15:54:17',0),
(3,1,'2025-08-18 00:33:24',0),
(3,3,'2025-08-18 00:33:24',0),
(4,3,'2025-08-20 08:37:46',0),
(4,5,'2025-08-20 08:37:46',0),
(5,1,'2025-08-31 09:59:46',0),
(5,2,'2025-08-31 09:59:46',0),
(6,2,'2025-08-31 11:59:02',0),
(6,6,'2025-08-31 11:59:02',0),
(7,3,'2025-08-31 13:29:47',0),
(7,6,'2025-08-31 13:29:47',0);
/*!40000 ALTER TABLE `chat_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_reads`
--

DROP TABLE IF EXISTS `chat_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_reads` (
  `chat_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `last_read_message_id` bigint(20) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`chat_id`,`user_id`),
  KEY `idx_read_last` (`chat_id`,`last_read_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_reads`
--

LOCK TABLES `chat_reads` WRITE;
/*!40000 ALTER TABLE `chat_reads` DISABLE KEYS */;
INSERT INTO `chat_reads` VALUES
(1,2,28,'2025-09-07 12:54:53'),
(1,4,40,'2025-08-30 06:14:29'),
(2,3,35,'2025-08-20 13:24:23'),
(2,4,37,'2025-08-30 06:14:33'),
(3,1,23,'2025-08-20 10:11:27'),
(3,3,17,'2025-08-17 18:42:42');
/*!40000 ALTER TABLE `chat_reads` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES
(1,0,NULL,NULL,4,'2025-08-12 15:44:42','2025-08-12 15:44:42'),
(2,0,NULL,NULL,4,'2025-08-12 15:54:17','2025-08-12 15:54:17'),
(3,0,NULL,NULL,1,'2025-08-18 00:33:24','2025-08-18 00:33:24'),
(4,0,NULL,NULL,3,'2025-08-20 08:37:46','2025-08-20 08:37:46'),
(5,0,NULL,NULL,2,'2025-08-31 09:59:46','2025-08-31 09:59:46'),
(6,0,NULL,NULL,2,'2025-08-31 11:59:02','2025-08-31 11:59:02'),
(7,0,NULL,NULL,6,'2025-08-31 13:29:47','2025-08-31 13:29:47');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_assignment_versions`
--

DROP TABLE IF EXISTS `coaching_assignment_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_assignment_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `text` longtext DEFAULT NULL,
  `links_json` text DEFAULT NULL,
  `files_json` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_assignment_seq` (`assignment_id`,`seq`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `fk_cav_user` (`submitted_by`),
  CONSTRAINT `fk_cav_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `coaching_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cav_user` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_assignment_versions`
--

LOCK TABLES `coaching_assignment_versions` WRITE;
/*!40000 ALTER TABLE `coaching_assignment_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_assignment_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_assignments`
--

DROP TABLE IF EXISTS `coaching_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `step_seq` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `instructions` text DEFAULT NULL,
  `due_at` datetime DEFAULT NULL,
  `status` enum('open','submitted','reviewed','overdue') DEFAULT 'open',
  PRIMARY KEY (`id`),
  KEY `idx_ca_enrollment_status_due` (`enrollment_id`,`status`,`due_at`),
  CONSTRAINT `coaching_assignments_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `coaching_enrollments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_assignments`
--

LOCK TABLES `coaching_assignments` WRITE;
/*!40000 ALTER TABLE `coaching_assignments` DISABLE KEYS */;
INSERT INTO `coaching_assignments` VALUES
(1,1,1,'Intake & Goals','Define goals & baseline','2025-08-20 00:00:00','reviewed'),
(2,1,3,'Self-paced','','2025-09-03 00:00:00','open');
/*!40000 ALTER TABLE `coaching_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_bookings`
--

DROP TABLE IF EXISTS `coaching_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `step_seq` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `status` enum('scheduled','completed','no_show','rescheduled') DEFAULT 'scheduled',
  PRIMARY KEY (`id`),
  KEY `idx_cb_enrollment_step` (`enrollment_id`,`step_seq`),
  CONSTRAINT `coaching_bookings_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `coaching_enrollments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_bookings`
--

LOCK TABLES `coaching_bookings` WRITE;
/*!40000 ALTER TABLE `coaching_bookings` DISABLE KEYS */;
INSERT INTO `coaching_bookings` VALUES
(1,1,2,0,'scheduled'),
(2,1,4,0,'scheduled');
/*!40000 ALTER TABLE `coaching_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_enrollments`
--

DROP TABLE IF EXISTS `coaching_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `coach_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `status` enum('active','paused','completed','cancelled') DEFAULT 'active',
  `next_step_seq` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_coach_enroll_order` (`order_id`),
  CONSTRAINT `fk_coach_enroll_order` FOREIGN KEY (`order_id`) REFERENCES `coaching_orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_enrollments`
--

LOCK TABLES `coaching_enrollments` WRITE;
/*!40000 ALTER TABLE `coaching_enrollments` DISABLE KEYS */;
INSERT INTO `coaching_enrollments` VALUES
(1,5,3,1,'2025-08-22','active',1,'2025-08-22 15:46:43',NULL);
/*!40000 ALTER TABLE `coaching_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_orders`
--

DROP TABLE IF EXISTS `coaching_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_ref` varchar(128) DEFAULT NULL,
  `stripe_payment_intent_id` varchar(64) DEFAULT NULL,
  `provider_payment_intent_id` varchar(64) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `template_id` (`template_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_orders`
--

LOCK TABLES `coaching_orders` WRITE;
/*!40000 ALTER TABLE `coaching_orders` DISABLE KEYS */;
INSERT INTO `coaching_orders` VALUES
(1,3,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-22 17:43:23','2025-08-22 17:43:23'),
(2,3,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-22 17:43:23','2025-08-22 17:43:23'),
(3,3,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:10:01','2025-08-23 14:10:01'),
(4,3,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:10:01','2025-08-23 14:10:01'),
(5,3,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:29:03','2025-08-23 14:29:03'),
(6,2,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-24 08:55:52','2025-08-24 08:55:52'),
(7,2,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-24 08:55:52','2025-08-24 08:55:52'),
(8,2,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-24 09:49:05','2025-08-24 09:49:05'),
(9,2,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-24 09:49:05','2025-08-24 09:49:05'),
(10,6,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-28 05:20:07','2025-08-28 05:20:07'),
(11,6,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-28 05:20:07','2025-08-28 05:20:07'),
(12,2,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-28 08:22:22','2025-08-28 08:22:22'),
(13,2,5,130.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-28 10:34:39','2025-08-28 10:34:39'),
(14,6,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-30 05:52:09','2025-08-30 05:52:09'),
(15,2,6,80.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-30 11:32:16','2025-08-30 11:32:16'),
(16,2,6,80.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-30 11:32:16','2025-08-30 11:32:16'),
(17,5,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:32:45','2025-08-31 05:32:45'),
(18,5,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:32:45','2025-08-31 05:32:45'),
(19,5,6,80.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:36:43','2025-08-31 05:36:43'),
(20,5,5,130.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:36:50','2025-08-31 05:36:50'),
(21,5,5,130.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:36:50','2025-08-31 05:36:50'),
(22,5,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:36:56','2025-08-31 05:36:56'),
(23,5,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:37:00','2025-08-31 05:37:00'),
(24,5,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:37:04','2025-08-31 05:37:04'),
(25,2,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:38:11','2025-08-31 05:38:11'),
(26,2,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:38:11','2025-08-31 05:38:11'),
(27,6,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:42:33','2025-08-31 05:42:33'),
(28,6,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 05:42:33','2025-08-31 05:42:33'),
(29,3,6,80.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 06:53:13','2025-08-31 06:53:13'),
(30,3,6,80.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 06:53:13','2025-08-31 06:53:13'),
(31,3,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 06:54:55','2025-08-31 06:54:55'),
(32,3,7,170.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-31 06:54:55','2025-08-31 06:54:55'),
(33,6,10,0.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-06 17:00:54','2025-09-06 17:00:54');
/*!40000 ALTER TABLE `coaching_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_slots`
--

DROP TABLE IF EXISTS `coaching_program_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `expert_id` int(11) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `capacity` int(11) NOT NULL DEFAULT 1,
  `seats_taken` int(11) NOT NULL DEFAULT 0,
  `status` enum('open','hidden','cancelled') NOT NULL DEFAULT 'open',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_template_time` (`template_id`,`start_time`),
  CONSTRAINT `fk_cps_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_slots`
--

LOCK TABLES `coaching_program_slots` WRITE;
/*!40000 ALTER TABLE `coaching_program_slots` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_program_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_steps`
--

DROP TABLE IF EXISTS `coaching_program_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `step_type` enum('live','self_paced') NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `due_offset_days` int(11) DEFAULT NULL,
  `required_submission` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `coaching_program_steps_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_steps`
--

LOCK TABLES `coaching_program_steps` WRITE;
/*!40000 ALTER TABLE `coaching_program_steps` DISABLE KEYS */;
INSERT INTO `coaching_program_steps` VALUES
(1,1,1,'self_paced','Intake & Goals','Define goals & baseline',2,1),
(2,1,2,'live','Session 1: Kickoff','Review goals',NULL,NULL),
(3,1,3,'self_paced','Self-paced','',2,1),
(4,1,4,'live','Session 2','',NULL,NULL);
/*!40000 ALTER TABLE `coaching_program_steps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_templates`
--

DROP TABLE IF EXISTS `coaching_program_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coach_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_months` enum('3','6','9','12') NOT NULL,
  `cadence_weeks` tinyint(4) NOT NULL DEFAULT 2,
  `total_live_sessions` tinyint(4) NOT NULL,
  `summary` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `slug` varchar(190) DEFAULT NULL,
  `images_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images_json`)),
  `description` longtext DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `cover_image` varchar(512) DEFAULT NULL,
  `image` varchar(512) DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_templates`
--

LOCK TABLES `coaching_program_templates` WRITE;
/*!40000 ALTER TABLE `coaching_program_templates` DISABLE KEYS */;
INSERT INTO `coaching_program_templates` VALUES
(1,2,'Career Acceleration',499.00,'3',2,12,'Bi-weekly live sessions with self-paced work.',1,'2025-08-22 15:45:30',NULL,NULL,NULL,'USD',NULL,NULL,NULL,'2025-08-23 02:56:35'),
(2,3,'This is long course',20.00,'9',2,6,'This is long course',1,'2025-08-22 20:52:06','this-is-long-course','[]','<p>This is the sample data</p>','USD','/uploads/coaching/1755930164873_2025-08-21_210359.png','/uploads/coaching/1755930164873_2025-08-21_210359.png',NULL,'2025-08-23 12:49:40'),
(3,3,'This is long course',20.00,'',2,6,'This is long course',1,'2025-08-22 21:02:05','this-is-long-course-1','[]','<p>This is the sample data for the coaching program.</p>','USD','/uploads/coaching/1755932077934_2025-08-19_160347.png','/uploads/coaching/1755932077934_2025-08-19_160347.png',NULL,'2025-08-23 20:53:24'),
(4,3,'Test 2',15.00,'9',2,6,'',1,'2025-08-22 21:04:10','test-2','[]','','USD','/uploads/coaching/1756637944817_images.jpeg','/uploads/coaching/1756637944817_images.jpeg',NULL,'2025-08-31 10:59:04'),
(5,6,'Frontend Mastery Coaching Program',130.00,'3',2,6,'Frontend Mastery',1,'2025-08-28 10:32:29','frontend-mastery-coaching-program','[]','<p>A practical and hands-on coaching program designed for aspiring and junior developers who want to master HTML, CSS, JavaScript, and React. The program focuses on real-world projects, responsive design, problem-solving, and building confidence to work on professional web development tasks. Perfect for anyone who wants to quickly upgrade their frontend skills and land freelance or full-time opportunities.</p>','USD','/uploads/coaching/1756377149947_FrontendLead-4.png','/uploads/coaching/1756377149947_FrontendLead-4.png',6,'2025-08-28 10:33:25'),
(6,6,'Build Skills, Mindset, and Success',80.00,'6',2,8,'Success',0,'2025-08-30 05:57:04','build-skills-mindset-and-success','[]','<p>Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;</p>','USD','/uploads/coaching/1756533424730_99aa6219-3206-4ea5-8d1b-08dcf982fd29.png','/uploads/coaching/1756533424730_99aa6219-3206-4ea5-8d1b-08dcf982fd29.png',6,'2025-09-06 17:19:03'),
(7,5,'Full Stack Developer',170.00,'3',2,8,'Developer',1,'2025-08-30 13:19:52','full-stack-developer','[]','<p>Become a complete web developer by mastering both front-end and back-end technologies. In this course, you’ll learn how to design responsive user interfaces, build dynamic applications, and manage powerful databases. From HTML, CSS, and JavaScript to frameworks like React, Node.js, and Express, you’ll gain hands-on experience through real-world projects. By the end of the program, you’ll have the skills to build, deploy, and maintain full-stack applications—ready to launch your career as a professional Full-Stack Developer.Become a complete web developer by mastering both front-end and back-end technologies. In this course, you’ll learn how to design responsive user interfaces, build dynamic applications, and manage powerful databases. From HTML, CSS, and JavaScript to frameworks like React, Node.js, and Express, you’ll gain hands-on experience through real-world projects. By the end of the program, you’ll have the skills to build, deploy, and maintain full-stack applications—ready to launch your career as a professional Full-Stack Developer.Become a complete web developer by mastering both front-end and back-end technologies. In this course, you’ll learn how to design responsive user interfaces, build dynamic applications, and manage powerful databases. From HTML, CSS, and JavaScript to frameworks like React, Node.js, and Express, you’ll gain hands-on experience through real-world projects. By the end of the program, you’ll have the skills to build, deploy, and maintain full-stack applications—ready to launch your career as a professional Full-Stack Developer.</p>','USD','/uploads/coaching/1756559992155_0_cl7fc6pt1MHjIF4K.png','/uploads/coaching/1756559992155_0_cl7fc6pt1MHjIF4K.png',5,'2025-08-30 13:19:52'),
(8,6,'Norman',0.00,'3',2,6,'',0,'2025-09-04 17:41:16','norman','[]','','USD','/uploads/coaching/1757007676808_ChatGPT_Image_Sep_4__2025__10_59_29_AM.png','/uploads/coaching/1757007676808_ChatGPT_Image_Sep_4__2025__10_59_29_AM.png',6,'2025-09-06 17:19:10'),
(9,6,'New Startup Founder\'s Advisory Program',0.00,'3',2,6,'',0,'2025-09-04 17:52:56','new-startup-founder-s-advisory-program','[]','','USD','/uploads/coaching/1757008376918_Norman_s_New_Startup_Founder_s_Advisory_Program.png','/uploads/coaching/1757008376918_Norman_s_New_Startup_Founder_s_Advisory_Program.png',6,'2025-09-06 17:19:20'),
(10,6,'New Startup Ventures Results-Driven Advisory Program',600.00,'9',2,3,'Let\'s work together to scale your startup venture.',1,'2025-09-04 18:03:51','new-startup-founder-s-advisory-program-1','[]','<h2><strong>New Startup Founder\'s Advisory Program</strong></h2><p><br></p><p><strong>Turn your startup idea into a real business with expert guidance.</strong></p><p><br></p><p>Are you serious about building a startup company? This program gives you direct access to Norman Musengimana — a seasoned founder and advisor who has personally worked with and guided over 300 successful startup founders from the first spark of an idea to scalable growth.</p><ol><li><strong>A refined pitch &amp; startup story.</strong></li><li><strong>Real customer validation insights.</strong></li><li><strong>A tested go-to-market plan.</strong></li><li><strong>Documented early traction.</strong></li><li><strong>A 90-day growth roadmap.</strong></li><li><strong>&amp; A Solid tailored funding strategy</strong></li></ol><p><br></p><p>Norman brings hands-on experience across <strong>multiple industries</strong>, combining practical know-how with proven frameworks. You’ll gain:</p><ul><li><strong>Clarity on your idea</strong> – sharpen your concept and define a winning business model.</li><li><strong>Confidence in execution</strong> – learn step-by-step how to validate, launch, and grow.</li><li><strong>Connections and perspective</strong> – insights from working with founders across tech, services, consumer, and impact-driven ventures.</li></ul><p><br></p><p>This isn’t theory — it’s real-world startup coaching from someone who has been in your shoes and helped hundreds succeed.</p><p><br></p><p>If you’re ready to move beyond dreaming and start building, this program is for you.</p>','USD','/uploads/coaching/1757180020421_Coaching_program_-_Norman_Prosfata_Inc..jpeg','/uploads/coaching/1757180020421_Coaching_program_-_Norman_Prosfata_Inc..jpeg',6,'2025-09-06 17:36:37'),
(11,6,'New Startup Venture Advisory Program',0.00,'3',1,3,'Let us work together to turn your startup into a scalable business venture through proven strategies, aces to resources and candid quality advice.',0,'2025-09-06 17:21:55','norman-1','[]','<p>Are you serious about building a startup company? This program gives you direct access to Norman Musengimana — a seasoned founder and advisor who has personally worked with and guided over 300 successful startup founders from the first spark of an idea to scalable growth.</p><ol><li><strong>A refined pitch &amp; startup story.</strong></li><li><strong>Real customer validation insights.</strong></li><li><strong>A tested go-to-market plan.</strong></li><li><strong>Documented early traction.</strong></li><li><strong>A 90-day growth roadmap.</strong></li><li><strong>&amp; A Solid tailored funding strategy</strong></li></ol><p><br></p><p>Norman brings hands-on experience across&nbsp;<strong>multiple industries</strong>, combining practical know-how with proven frameworks. You’ll gain:</p><ul><li><strong>Clarity on your idea</strong>&nbsp;– sharpen your concept and define a winning business model.</li><li><strong>Confidence in execution</strong>&nbsp;– learn step-by-step how to validate, launch, and grow.</li><li><strong>Connections and perspective</strong>&nbsp;– insights from working with founders across tech, services, consumer, and impact-driven ventures.</li></ul><p><br></p><p>This isn’t theory — it’s real-world startup coaching from someone who has been in your shoes and helped hundreds succeed.</p><p><br></p><p>If you’re ready to move beyond dreaming and start building, this program is for you.</p>','USD','/uploads/coaching/1757179315970_Coaching_program_-_Norman_Prosfata_Inc..jpeg','/uploads/coaching/1757179315970_Coaching_program_-_Norman_Prosfata_Inc..jpeg',6,'2025-09-06 17:33:29');
/*!40000 ALTER TABLE `coaching_program_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_reminder_logs`
--

DROP TABLE IF EXISTS `coaching_reminder_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_reminder_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reminder_type` varchar(40) NOT NULL,
  `ref_id` varchar(100) NOT NULL,
  `recipient_email` varchar(190) NOT NULL,
  `sent_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_crl_type_ref` (`reminder_type`,`ref_id`),
  KEY `idx_crl_recipient` (`recipient_email`,`sent_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_reminder_logs`
--

LOCK TABLES `coaching_reminder_logs` WRITE;
/*!40000 ALTER TABLE `coaching_reminder_logs` DISABLE KEYS */;
INSERT INTO `coaching_reminder_logs` VALUES
(1,'DIGEST_48H','COACH','imranhossen1119999@gmail.com','2025-09-03 07:15:05');
/*!40000 ALTER TABLE `coaching_reminder_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_sessions`
--

DROP TABLE IF EXISTS `coaching_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `enrollment_id` bigint(20) unsigned NOT NULL,
  `seq` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `kind` enum('assignment','session') NOT NULL DEFAULT 'session',
  `duration_minutes` int(11) DEFAULT NULL,
  `meeting_required` tinyint(1) NOT NULL DEFAULT 1,
  `scheduled_start` datetime DEFAULT NULL,
  `scheduled_end` datetime DEFAULT NULL,
  `meeting_id` varchar(64) DEFAULT NULL,
  `status` enum('unscheduled','scheduled','completed','cancelled','missed') NOT NULL DEFAULT 'unscheduled',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_enrollment_seq` (`enrollment_id`,`seq`),
  KEY `idx_enrollment` (`enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_sessions`
--

LOCK TABLES `coaching_sessions` WRITE;
/*!40000 ALTER TABLE `coaching_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_slot_holds`
--

DROP TABLE IF EXISTS `coaching_slot_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_slot_holds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `template_id` bigint(20) unsigned NOT NULL,
  `expert_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_hold` (`expert_id`,`start_time`,`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_slot_holds`
--

LOCK TABLES `coaching_slot_holds` WRITE;
/*!40000 ALTER TABLE `coaching_slot_holds` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_slot_holds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_submissions`
--

DROP TABLE IF EXISTS `coaching_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_submissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint(20) unsigned NOT NULL,
  `client_id` int(11) NOT NULL,
  `submitted_at` datetime NOT NULL,
  `files_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`files_json`)),
  `notes` text DEFAULT NULL,
  `status` enum('submitted','needs_changes','approved') DEFAULT 'submitted',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_submissions`
--

LOCK TABLES `coaching_submissions` WRITE;
/*!40000 ALTER TABLE `coaching_submissions` DISABLE KEYS */;
INSERT INTO `coaching_submissions` VALUES
(1,1,5,'2025-08-22 21:49:04','[]','hello','approved',3,'2025-08-22 21:49:44','Looks good.');
/*!40000 ALTER TABLE `coaching_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_categories`
--

DROP TABLE IF EXISTS `coaching_template_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_template_cat` (`template_id`,`category_id`),
  KEY `idx_template` (`template_id`),
  KEY `idx_category` (`category_id`),
  CONSTRAINT `fk_ctc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ctc_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_categories`
--

LOCK TABLES `coaching_template_categories` WRITE;
/*!40000 ALTER TABLE `coaching_template_categories` DISABLE KEYS */;
INSERT INTO `coaching_template_categories` VALUES
(11,2,5,'2025-08-23 06:49:40'),
(12,2,11,'2025-08-23 06:49:40'),
(21,3,5,'2025-08-23 14:50:58'),
(22,3,11,'2025-08-23 14:50:58'),
(23,5,2,'2025-08-28 10:32:29'),
(24,6,4,'2025-08-30 05:57:04'),
(25,6,6,'2025-08-30 05:57:04'),
(26,6,11,'2025-08-30 05:57:04'),
(27,6,5,'2025-08-30 05:57:04'),
(28,6,13,'2025-08-30 05:57:04'),
(29,6,12,'2025-08-30 05:57:04'),
(30,6,15,'2025-08-30 05:57:04'),
(31,6,10,'2025-08-30 05:57:04'),
(32,7,2,'2025-08-30 13:19:52'),
(33,7,3,'2025-08-30 13:19:52'),
(34,7,9,'2025-08-30 13:19:52'),
(35,7,5,'2025-08-30 13:19:52'),
(36,4,5,'2025-08-31 10:59:04'),
(37,4,11,'2025-08-31 10:59:04'),
(44,11,11,'2025-09-06 17:32:10'),
(57,10,11,'2025-09-06 17:36:37'),
(58,10,15,'2025-09-06 17:36:37'),
(59,10,10,'2025-09-06 17:36:37');
/*!40000 ALTER TABLE `coaching_template_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_images`
--

DROP TABLE IF EXISTS `coaching_template_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `image_url` varchar(1024) NOT NULL,
  `sort_order` int(11) DEFAULT 1,
  `is_cover` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `coaching_template_images_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_images`
--

LOCK TABLES `coaching_template_images` WRITE;
/*!40000 ALTER TABLE `coaching_template_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_template_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_steps`
--

DROP TABLE IF EXISTS `coaching_template_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `kind` enum('assignment','session') NOT NULL DEFAULT 'assignment',
  `duration_weeks` int(11) DEFAULT NULL,
  `meeting_required` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_template_seq` (`template_id`,`seq`),
  CONSTRAINT `fk_cts_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_steps`
--

LOCK TABLES `coaching_template_steps` WRITE;
/*!40000 ALTER TABLE `coaching_template_steps` DISABLE KEYS */;
INSERT INTO `coaching_template_steps` VALUES
(9,2,1,'Introduction',NULL,'assignment',1,0,'2025-08-23 12:49:40','2025-08-23 12:49:40'),
(10,2,2,'Live Session',NULL,'session',1,1,'2025-08-23 12:49:40','2025-08-23 12:49:40'),
(19,3,1,'Assigment',NULL,'assignment',1,0,'2025-08-23 20:50:58','2025-08-23 20:50:58'),
(20,3,2,'Live Session',NULL,'session',1,1,'2025-08-23 20:50:58','2025-08-23 20:50:58'),
(21,6,1,'Success','<p>Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;Our coaching program is designed to guide you with personalized strategies, practical tools, and ongoing support. Whether for personal growth or professional development, we help you reach your full potential with clarity and purpose.&nbsp;</p>','session',2,1,'2025-08-30 05:57:05','2025-08-30 05:57:05'),
(22,4,1,'1',NULL,'assignment',1,0,'2025-08-31 10:59:05','2025-08-31 10:59:05'),
(23,4,2,'2',NULL,'session',1,0,'2025-08-31 10:59:05','2025-08-31 10:59:05'),
(36,11,1,'Before Session 1: Startup Snapshot & Current Challenge','<ol><li><strong>Homework:</strong> Share your <strong>pitch deck draft, mission, vision, team composition, milestones achieved so far, and your biggest current challenge.</strong></li><li><strong>Goal:</strong> Give Norman a clear picture of where you stand and what outcome you want from the first session.</li></ol><p><br></p>','assignment',2,0,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(37,11,2,'Live Session 1: Diagnose & Prioritize','<ol><li><strong>Activity:</strong> Walk through your startup story, pitch deck, and milestones together.</li><li><strong>Value:</strong> Get a <strong>diagnosis of your biggest bottleneck</strong> (e.g., market fit, product clarity, fundraising prep).</li><li><strong>Outcome:</strong> Leave with a <strong>focused priority list</strong> for the next 30 days and a refined problem statement.</li></ol><p><br></p>','session',4,1,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(38,11,3,'Before Session 2: Customer & Market Validation','<ol><li><strong>Homework:</strong> Run a <strong>short customer discovery or validation exercise</strong> (surveys, 5–10 interviews, or feedback loops).</li><li><strong>Goal:</strong> Gather real-world insights about your target customers and refine your <strong>value proposition</strong>.</li></ol><p><br></p>','assignment',6,0,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(39,11,4,'Live Session 2: Build Your Growth Engine','<ol><li><strong>Activity:</strong> Use customer insights to refine your <strong>business model, pricing, and go-to-market approach.</strong></li><li><strong>Value:</strong> Learn how to design <strong>repeatable ways to attract and keep customers.</strong></li><li><strong>Outcome:</strong> Leave with a <strong>draft go-to-market plan</strong> and clear metrics to test over the next 30 days.</li></ol><p><br></p>','session',8,1,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(40,11,5,'Before Session 3: Show Traction & Next Moves','<ol><li><strong>Homework:</strong> Document your <strong>progress from experiments, partnerships, or early traction</strong> (signups, pilots, letters of intent, or test results).</li><li><strong>Goal:</strong> Show evidence of momentum and prepare to discuss <strong>fundraising readiness or scaling options.</strong></li></ol><p><br></p>','assignment',10,0,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(41,11,6,'Last Live Session 3: Scale & Secure Your Next 90 Days','<ol><li><strong>Activity:</strong> Review your traction and refine your <strong>scaling strategy, team needs, and investor/partner pitch.</strong></li><li><strong>Value:</strong> Get <strong>tailored advice</strong> on how to convert early wins into sustainable growth including a solid funding strategy.</li><li><strong>Outcome:</strong> Leave with a <strong>90-day action roadmap</strong>, plus a sharpened story for pitching to investors, accelerators, or key partners.</li></ol><p><br></p>','assignment',12,1,'2025-09-06 17:32:10','2025-09-06 17:32:10'),
(66,10,1,'Homework 1 (Before Session 1): Startup Snapshot & Current Challenge','<ol><li><strong>Homework:</strong> Share your <strong>pitch deck draft, mission, vision, team composition, milestones achieved so far, and your biggest current challenge.</strong></li><li><strong>Goal:</strong> Give Norman a clear picture of where you stand and what outcome you want from the first session.</li></ol>','assignment',2,0,'2025-09-06 17:36:37','2025-09-06 17:36:37'),
(67,10,2,'Live Session 1: Diagnose & Prioritize','<ol><li><strong>Activity:</strong> Walk through your startup story, pitch deck, and milestones together.</li><li><strong>Value:</strong> Get a <strong>diagnosis of your biggest bottleneck</strong> (e.g., market fit, product clarity, fundraising prep).</li><li><strong>Outcome:</strong> Leave with a <strong>focused priority list</strong> for the next 30 days and a refined problem statement.</li></ol>','session',4,1,'2025-09-06 17:36:37','2025-09-06 17:36:37'),
(68,10,3,'Homework 2 (Before Session 2): Customer & Market Validation','<ol><li><strong>Homework:</strong> Run a <strong>short customer discovery or validation exercise</strong> (surveys, 5–10 interviews, or feedback loops).</li><li><strong>Goal:</strong> Gather real-world insights about your target customers and refine your <strong>value proposition</strong>.</li></ol>','assignment',6,0,'2025-09-06 17:36:37','2025-09-06 17:36:37'),
(69,10,4,'Live Session 2: Build Your Growth Engine','<ol><li><strong>Activity:</strong> Use customer insights to refine your <strong>business model, pricing, and go-to-market approach.</strong></li><li><strong>Value:</strong> Learn how to design <strong>repeatable ways to attract and keep customers.</strong></li><li><strong>Outcome:</strong> Leave with a <strong>draft go-to-market plan</strong> and clear metrics to test over the next 30 days.</li></ol>','session',8,1,'2025-09-06 17:36:37','2025-09-06 17:36:37'),
(70,10,5,'Homework 3 (Before Session 3): Show Traction & Next Moves','<ol><li><strong>Homework:</strong> Document your <strong>progress from experiments, partnerships, or early traction</strong> (signups, pilots, letters of intent, or test results).</li><li><strong>Goal:</strong> Show evidence of momentum and prepare to discuss <strong>fundraising readiness or scaling options.</strong></li></ol>','assignment',10,0,'2025-09-06 17:36:37','2025-09-06 17:36:37'),
(71,10,6,'Last Live Session 3: Scale & Secure Your Next 90 Days','<ol><li><strong>Activity:</strong> Review your traction and refine your <strong>scaling strategy, team needs, and investor/partner pitch.</strong></li><li><strong>Value:</strong> Get <strong>tailored advice</strong> on how to convert early wins into sustainable growth including a solid funding strategy.</li><li><strong>Outcome:</strong> Leave with a <strong>90-day action roadmap</strong>, plus a sharpened story for pitching to investors, accelerators, or key partners.</li></ol>','session',12,1,'2025-09-06 17:36:37','2025-09-06 17:36:37');
/*!40000 ALTER TABLE `coaching_template_steps` ENABLE KEYS */;
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
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_enroll_course_created` (`course_id`,`enrolled_at`),
  CONSTRAINT `course_enrollments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_enrollments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_enrollments`
--

LOCK TABLES `course_enrollments` WRITE;
/*!40000 ALTER TABLE `course_enrollments` DISABLE KEYS */;
INSERT INTO `course_enrollments` VALUES
(2,5,1,'2025-08-16 18:49:42',NULL),
(3,5,1,'2025-08-16 18:49:46',NULL),
(4,19,2,'2025-08-26 14:02:10','2025-08-31 10:00:07'),
(5,18,3,'2025-08-30 12:11:10',NULL),
(6,18,3,'2025-08-30 12:11:21',NULL),
(7,19,4,'2025-08-30 22:08:58','2025-08-30 22:09:25'),
(8,19,3,'2025-08-31 06:52:09',NULL),
(9,18,3,'2025-08-31 06:58:17',NULL),
(10,19,3,'2025-08-31 06:58:27',NULL),
(11,19,3,'2025-08-31 07:03:14',NULL),
(12,18,2,'2025-08-31 09:33:03',NULL),
(13,18,3,'2025-08-31 10:36:02',NULL),
(14,19,3,'2025-08-31 11:34:36',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(6,5,'Invoice-LMCAZGIW-0001.pdf','application/pdf','/uploads/courses/materials/1755359167008-invoice-lmcazgiw-0001.pdf','2025-08-16 15:46:07'),
(7,14,'Invoice-NHR24TMQ-0001 (1).pdf','application/pdf','/uploads/courses/materials/1755443380731-invoice-nhr24tmq-0001-1.pdf','2025-08-17 15:09:40'),
(8,14,'Receipt-2168-1384.pdf','application/pdf','/uploads/courses/materials/1755443380783-receipt-2168-1384.pdf','2025-08-17 15:09:40'),
(9,17,'Herbsion_Seo_Report.zip','application/x-zip-compressed','/uploads/courses/materials/1756214967388-herbsion_seo_report.zip','2025-08-26 13:29:27'),
(10,20,'IMG-20250720-WA0351.jpg','image/jpeg','/uploads/courses/materials/1756532378438-img-20250720-wa0351.jpg','2025-08-30 05:39:38'),
(11,21,'IMG-20250720-WA0351.jpg','image/jpeg','/uploads/courses/materials/1756564656199-img-20250720-wa0351.jpg','2025-08-30 14:37:36'),
(12,18,'IMG-20250720-WA0351.jpg','image/jpeg','/uploads/courses/materials/1756636553372-img-20250720-wa0351.jpg','2025-08-31 10:35:53'),
(13,20,'munsi.jpg','image/jpeg','/uploads/courses/materials/1756646229839-munsi.jpg','2025-08-31 13:17:09'),
(14,17,'munsi.jpg','image/jpeg','/uploads/courses/materials/1756646334036-munsi.jpg','2025-08-31 13:18:54'),
(15,22,'munsi.jpg','image/jpeg','/uploads/courses/materials/1756646677541-munsi.jpg','2025-08-31 13:24:37');
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
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(16,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,8,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(17,14,'Introduction','Welcome to the course!','https://www.youtube.com/watch?v=hZEm3gQ7jwI',1,1,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(18,14,'New Lesson 2','This thsi isdfgfdh gjshfk','',0,2,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(19,14,'New Lesson','This thsi isdfgfdh gjshfk','',0,3,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(20,17,'Introduction','Welcome to the course!','',1,1,'2025-08-26 13:24:25','2025-08-26 13:24:25'),
(21,18,'Introduction','Welcome to the course!','',1,1,'2025-08-26 13:57:37','2025-08-26 13:57:37'),
(22,18,'Introduction','Welcome to the course!','',1,1,'2025-08-26 13:58:17','2025-08-26 13:58:17'),
(23,19,'Introduction','Welcome to the course!','',1,1,'2025-08-26 13:59:52','2025-08-26 13:59:52'),
(24,20,'Introduction','Welcome to the course!','',1,1,'2025-08-30 05:38:44','2025-08-30 05:38:44'),
(25,20,'Your Learning Journey','','https://www.youtube.com/',0,2,'2025-08-30 05:38:45','2025-08-30 05:38:45'),
(26,21,'Introduction','Welcome to the course!','',1,1,'2025-08-30 14:37:09','2025-08-30 14:37:09'),
(27,21,'Skills Development','This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.','https://www.youtube.com/watch?v=ezpObgmGMAs&list=PL1pf33qWCkmgQhpHoKOw08ILdh8FRDHhv',0,2,'2025-08-30 14:37:09','2025-08-30 14:37:09'),
(28,18,'Introduction','Welcome to the course!','',1,1,'2025-08-31 10:35:19','2025-08-31 10:35:19'),
(29,18,'Introduction','Welcome to the course!','https://www.youtube.com/',0,2,'2025-08-31 10:35:19','2025-08-31 10:35:19'),
(30,20,'Introduction','Welcome to the course!','',1,1,'2025-08-31 13:16:50','2025-08-31 13:16:50'),
(31,20,'Your Learning Journey','','https://www.youtube.com/',0,2,'2025-08-31 13:16:50','2025-08-31 13:16:50'),
(32,17,'Introduction','Welcome to the course!','',1,1,'2025-08-31 13:18:43','2025-08-31 13:18:43'),
(33,17,'Full Stack Web Development','','https://www.youtube.com/watch?v=8KaJRw-rfn8&list=PLEiEAq2VkUULCC3eEATL4zzuapTjmo1Z_',0,2,'2025-08-31 13:18:44','2025-08-31 13:18:44'),
(34,22,'Introduction','Welcome to the course!','',1,1,'2025-08-31 13:24:23','2025-08-31 13:24:23'),
(35,22,'Backend Development with Node.js','','https://www.youtube.com/watch?v=YLpCPo0FDtE&list=PL9ooVrP1hQOGTHk2auXsk3cyqRBbbsQ6l',0,2,'2025-08-31 13:24:23','2025-08-31 13:24:23');
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
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled_reason` varchar(255) DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_orders`
--

LOCK TABLES `course_orders` WRITE;
/*!40000 ALTER TABLE `course_orders` DISABLE KEYS */;
INSERT INTO `course_orders` VALUES
(1,5,1,20.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1c8615v1AvHRfG1Qz60ObOoCcPRKPlxKPGFPnAGaTSgo6cZOZyrINspkY',NULL,'2025-08-16 16:33:10','2025-08-19 12:21:16','pi_3RwpAf3RqEMUJuhk0olhjg8r','ch_3RwpAf3RqEMUJuhk0qL72Jpw',NULL,'pm_1RwpAe3RqEMUJuhkKbw2Kgvn','https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKMelg8UGMgafYtUBTsM6LBYsKXon2CVykaVSAjCDiGipegx4eynm30SqyTnIZOPRW11RMOCrG_5lrKrI',NULL,NULL,'visa','4242'),
(5,17,2,190.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-26 13:30:53','2025-08-31 09:59:22','pi_3S0NUx3RqEMUJuhk0wAgZGwg',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(11,19,2,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-08-26 14:02:10','2025-08-26 14:02:10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(18,4,2,49.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1H2IhryBptUuiWV5YaJAsJkyWAMd52PNvoh6FDDIC7xSy6df8WCOcU6Z5',NULL,'2025-08-28 08:10:22','2025-08-30 05:26:26','pi_3S1hIz3RqEMUJuhk0uBEoFwn',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(22,5,6,20.00,'usd','stripe','pending',NULL,NULL,NULL,'cs_test_a1BZ3uxFTnrJtJQFpOfSTYUtXpWmw3rLxjty8c0txYpjRgi1ZTlG7L4G9U',NULL,'2025-08-30 05:28:12','2025-08-31 13:47:07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(34,20,4,70.00,'usd','stripe','pending',NULL,NULL,NULL,'cs_test_a1ZVxPGtu0Y9reXkgLJKg0H97UAkInmjJic5nja1ZwQGXxK3qJNiDQc3NT',NULL,'2025-08-30 06:10:51','2025-08-30 06:15:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(36,18,3,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-08-30 12:11:10','2025-08-31 10:36:02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(38,19,4,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-08-30 22:08:58','2025-08-30 22:08:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(39,19,3,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-08-31 06:52:09','2025-08-31 11:34:36',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(40,21,3,170.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-31 06:52:43','2025-08-31 07:04:43',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(42,20,3,70.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-31 06:53:27','2025-08-31 06:54:41',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(68,21,2,170.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-31 09:32:49','2025-08-31 10:15:17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(70,18,2,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-08-31 09:33:03','2025-08-31 09:33:03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(82,20,2,70.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-31 11:51:12','2025-08-31 11:54:14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(86,22,4,180.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-31 13:53:55','2025-08-31 13:53:55',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_progress`
--

LOCK TABLES `course_progress` WRITE;
/*!40000 ALTER TABLE `course_progress` DISABLE KEYS */;
INSERT INTO `course_progress` VALUES
(1,5,1,1,1,'2025-08-16 20:03:02'),
(2,5,5,1,1,'2025-08-16 20:03:08'),
(3,5,9,1,1,'2025-08-16 20:03:11'),
(4,5,6,1,0,NULL),
(5,5,10,1,0,NULL),
(6,5,7,1,0,NULL),
(7,5,16,1,1,'2025-08-16 20:03:34'),
(8,5,15,1,1,'2025-08-16 20:03:33'),
(9,5,14,1,1,'2025-08-16 20:03:31'),
(10,5,13,1,1,'2025-08-16 20:03:30'),
(11,5,12,1,1,'2025-08-16 20:03:28'),
(12,5,8,1,1,'2025-08-16 20:03:26'),
(13,5,11,1,1,'2025-08-16 20:14:33'),
(17,5,2,1,1,'2025-08-17 14:54:31'),
(20,5,3,1,1,'2025-08-16 20:03:06'),
(55,5,4,1,1,'2025-08-17 14:54:32'),
(101,19,23,2,1,'2025-08-30 05:26:39'),
(104,19,23,4,1,'2025-08-30 22:09:22');
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
  `rating` tinyint(3) unsigned NOT NULL,
  `comment` text DEFAULT NULL,
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_course_user` (`course_id`,`user_id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_reviews_course_created` (`course_id`,`created_at`),
  CONSTRAINT `course_reviews_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_reviews`
--

LOCK TABLES `course_reviews` WRITE;
/*!40000 ALTER TABLE `course_reviews` DISABLE KEYS */;
INSERT INTO `course_reviews` VALUES
(1,5,1,5,'good',NULL,'2025-08-16 19:43:24'),
(2,19,2,5,'Thanks',NULL,'2025-08-28 11:27:52'),
(3,18,2,5,'Thanks Norman',NULL,'2025-08-31 10:00:34');
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES
(4,'Professional React Bootcamp','professional-react-bootcamp','<p>Learn React with projects.</p>',NULL,NULL,NULL,NULL,49.00,'upcoming',1,'/uploads/courses/thumbnails/1755345927822-2025-08-15_151724.png',NULL,3,2,3,'2025-08-16 12:05:27',NULL,NULL,NULL,'beginner','English','usd',NULL,'public',NULL,'published'),
(5,'Hello 2','hello','<p>Hi</p><p>Hellow</p>','1899-11-27','1899-11-27','','',20.00,'upcoming',1,'/uploads/courses/thumbnails/1755346349217-2025-08-15_193438.png',NULL,3,2,3,'2025-08-16 12:12:29','2025-08-16 21:46:12',NULL,'hiii','beginner','English','usd','9','public','www/youtube.com','published'),
(14,'Hellow','hellow','<p>Hi</p>','0000-00-00','0000-00-00','','',20.00,'upcoming',1,'/uploads/courses/thumbnails/1755443226730-bg.jpg',NULL,1,2,1,'2025-08-17 15:07:06','2025-08-17 21:09:47',NULL,'fd','beginner','English','usd','8','public','','published'),
(15,'Digital Marketing Masterclass','digital-marketing-masterclass','<p>In this course, you will learn how to build and optimize websites, run digital marketing campaigns, and apply real-world strategies to grow your business.</p>','2025-08-20','2025-08-21','60','https://prosfata.com/experts',90.00,'upcoming',0,'/uploads/courses/thumbnails/1755703407189-191113-happyyoungemployee-stock.jpg',NULL,3,2,3,'2025-08-20 15:23:27',NULL,NULL,'Digital Marketing','beginner','Spanish','usd','2 hours','public','https://prosfata.com/experts','draft'),
(16,'Web Development Beginner to Advanced','web-development-beginner-to-advanced','<p>In this course, you will learn how to build and optimize websites, run digital marketing campaigns, and apply real-world strategies to grow your business.</p>','2025-08-20','2025-08-21','60 mins','https://prosfata.com/experts',0.00,'upcoming',0,'/uploads/courses/thumbnails/1755703858969-online-courses.jpg',NULL,3,2,3,'2025-08-20 15:30:58',NULL,NULL,'Beginner to Advanced','beginner','English','usd','1 hour','public','https://prosfata.com/experts','draft'),
(17,'Full Stack Web Development','full-stack-web-development-with-react-node-js','<p>Lorem Ipsum&nbsp;is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p>','2025-08-27','2025-08-28','60','',190.00,'upcoming',1,'/uploads/courses/thumbnails/1756213426010-2022_08_microsoftteams-image-13-2-1.jpg',NULL,6,2,6,'2025-08-26 13:03:46','2025-08-31 13:18:57',NULL,'React ','beginner','Spanish','usd','3','public','','published'),
(18,'Mobile Application ','mobile-application','<p>course</p>','2025-08-28','2025-08-26','800','',0.00,'upcoming',1,'/uploads/courses/thumbnails/1756216037872-1756023062843-png_image.png',NULL,3,2,3,'2025-08-26 13:47:17','2025-08-31 10:35:56',NULL,'','beginner','English','usd','6','public','','published'),
(19,'Wordpress Development ','wordpress-development','<p>wordpress</p>','2025-08-30','2025-10-30','400','',0.00,'upcoming',1,'/uploads/courses/thumbnails/1756216789104-think-of-a-website-like-an-ice-block_-visual-selection.png',NULL,3,2,3,'2025-08-26 13:59:49','2025-08-26 13:59:56',NULL,'','beginner','English','usd','600','public','','published'),
(20,'Your Learning Journey','your-learning-journey','<p>All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.All your courses are organized here in one place. Learn at your own pace, build new skills, and take steady steps toward your goals. Each course is designed to be simple, practical, and effective—so you can keep growing anytime, anywhere.</p>','2025-08-30','2025-08-31','120','',70.00,'upcoming',1,'/uploads/courses/thumbnails/1756532281500-istockphoto-1257522431-612x612.jpg',NULL,6,2,6,'2025-08-30 05:38:01','2025-08-31 13:17:12',NULL,'Journey','advanced','Spanish','usd','2 Hours','public','','published'),
(21,'Professional Skills Development – Learn, Apply & Grow','professional-skills-development-learn-apply-grow','<p>This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.This course is designed to help you build essential skills with clear explanations, practical examples, and hands-on projects. Whether you are a beginner or looking to upgrade your knowledge, you’ll gain the confidence to apply what you learn in real-world situations and take your career or personal growth to the next level.</p>','2025-08-31','2025-09-01','120','',170.00,'upcoming',1,'/uploads/courses/thumbnails/1756564570653-professional-development-3.jpg',NULL,5,2,5,'2025-08-30 14:36:10','2025-08-30 14:37:41',NULL,'Development ','beginner','English','usd','2','public','','published'),
(22,'Backend Development with Node.js','backend-development-with-node-js','<p>Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.Design and build robust APIs using Node.js, Express, and JWT authentication. Learn database modeling, error handling, and deployment so your services scale securely.</p>','2025-09-02','2025-10-09','120','',180.00,'upcoming',1,'/uploads/courses/thumbnails/1756646635495-when_to_consider_using_node_js_0d84032172.jpg',NULL,6,2,6,'2025-08-31 13:23:55','2025-08-31 13:24:49',NULL,'Node.js','advanced','English','usd','2 Hour','public','','published');
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
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_languages`
--

LOCK TABLES `expert_languages` WRITE;
/*!40000 ALTER TABLE `expert_languages` DISABLE KEYS */;
INSERT INTO `expert_languages` VALUES
(16,5,'EnglishHindi'),
(22,1,'English'),
(23,6,'English'),
(28,3,'English'),
(29,3,'French');
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
  `public_profile_url` varchar(255) DEFAULT NULL,
  `total_sessions_completed` int(11) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `public_url_slug` (`public_url_slug`),
  UNIQUE KEY `idx_expert_profiles_slug` (`public_url_slug`),
  KEY `idx_expert_profiles_public_profile_url` (`public_profile_url`),
  CONSTRAINT `expert_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_profiles`
--

LOCK TABLES `expert_profiles` WRITE;
/*!40000 ALTER TABLE `expert_profiles` DISABLE KEYS */;
INSERT INTO `expert_profiles` VALUES
(1,3,'Full-Stack Developer','<p>Become a complete web developer by mastering both front-end and back-end technologies. In this course, you’ll learn how to design responsive user interfaces, build dynamic applications, and manage powerful databases. From HTML, CSS, and JavaScript to frameworks like React, Node.js, and Express, you’ll gain hands-on experience through real-world projects. By the end of the program, you’ll have the skills to build, deploy, and maintain full-stack applications—ready to launch your career as a professional Full-Stack Developer.</p>','English',0,NULL,NULL,'https://prosfata.space/expert/imran-hossen',0,0),
(6,5,'Senior Web Developer','<p>You don’t need to touch your APIs. If you want the “Course” count to be precise, return total_services_offered (or a similar field) in /experts; the card already reads several possible names.</p>',NULL,0,NULL,NULL,'https://prosfata.space/expert/mr-alex-joe',0,0),
(7,4,NULL,NULL,NULL,0,NULL,NULL,NULL,0,0),
(8,1,'','',NULL,0,NULL,NULL,'https://prosfata.space/expert/mohammad-abu-taleb',0,0),
(42,6,'Business Development Manager','<p>With over 18 years of experience in innovation and entrepreneurship, I am passionate about impact change, and economic development, as well as helping start-ups and entrepreneurs turn their ideas and concepts into sustainable businesses. As a Business Development Manager at Kingston Economic Development Corporation, I facilitate the growth and success of the local start-up ecosystem by collaborating with partners, providing resources, and guiding founders.</p><p><br></p><p>I have a unique background that combines academic excellence, international exposure, and social impact. I hold two Master\'s degrees in Leading Innovation and Change and Management of Innovation and Entrepreneurship, as well as professional certifications in Performance Technology and GrowthWheel. I have volunteered and traveled to over 20 countries, working on social innovation and entrepreneurship projects. I also have a diverse skill set that includes new business development, strategic thinking, and presentation skills. I value respect, kindness, and lifelong learning, and I enjoy connecting with people, discovering new technologies, and exploring the world of patents and ideas.</p>',NULL,0,NULL,'norman-musengimana','https://prosfata.space/expert/expert/norman-musengimana',0,0),
(51,2,'','',NULL,0,NULL,NULL,NULL,0,0);
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
(4,1),
(5,1),
(5,5),
(5,7),
(5,13),
(5,14),
(6,2),
(6,3),
(6,5),
(6,9),
(7,11),
(8,2),
(8,3),
(8,8),
(8,9),
(8,14);
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
  PRIMARY KEY (`id`),
  KEY `idx_es_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(4,3,'hh','<p>fdhdfh</p>',30.00,'/uploads/service_images/image-1755344110910-837517836.png','2025-08-16 11:35:10','2025-08-16 11:35:10',0),
(5,3,'Interview Session','<p>1 to 1 interview preparation</p>',10.00,'/uploads/service_images/image-1755441846854-913300727.jpg','2025-08-17 14:44:06','2025-08-17 14:44:06',0),
(6,3,'Web Application','<p>Web Application</p>',450.00,'/uploads/service_images/image-1755688325793-725001791.png','2025-08-20 11:12:05','2025-08-20 11:14:29',0),
(7,6,'Solutions That Empower You','<p>Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.Discover a range of services designed to make your journey easier and more effective. From personalized support to practical solutions, each service is built to help you achieve results faster, with quality and reliability you can trust.</p>',150.00,'/uploads/service_images/image-1756532639217-860613376.jpeg','2025-08-30 05:43:01','2025-08-30 05:43:59',0),
(8,6,'Frontend Development with React','<p>Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.Learn to create fast, accessible, and responsive interfaces using React, modern JavaScript, and Tailwind CSS. You’ll build components, manage state, and ship a polished single-page app.</p>',130.00,'/uploads/service_images/image-1756646885451-538500322.webp','2025-08-31 13:28:05','2025-08-31 13:28:05',0);
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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_skills`
--

LOCK TABLES `expert_skills` WRITE;
/*!40000 ALTER TABLE `expert_skills` DISABLE KEYS */;
INSERT INTO `expert_skills` VALUES
(31,1,4),
(32,1,6),
(40,3,4),
(41,3,5),
(23,5,4),
(24,5,5),
(33,6,7),
(34,6,8),
(35,6,9);
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
  UNIQUE KEY `uq_expert_start_end` (`expert_id`,`start_time`,`end_time`),
  KEY `idx_expert_time` (`expert_id`,`start_time`),
  CONSTRAINT `expert_time_slots_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(25,3,'2025-08-20 10:00:00','2025-08-20 11:00:00',1,'2025-08-10 07:02:01'),
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
(170,3,'2025-08-30 03:00:00','2025-08-30 04:00:00',0,'2025-08-15 10:12:54'),
(171,1,'2025-08-24 11:00:00','2025-08-24 12:00:00',0,'2025-08-17 14:32:12'),
(172,1,'2025-08-31 11:00:00','2025-08-31 12:00:00',0,'2025-08-17 14:32:12'),
(173,1,'2025-08-18 14:00:00','2025-08-18 15:00:00',0,'2025-08-17 14:32:12'),
(174,1,'2025-08-25 14:00:00','2025-08-25 15:00:00',0,'2025-08-17 14:32:12'),
(175,1,'2025-08-17 18:00:00','2025-08-17 19:00:00',0,'2025-08-17 14:32:49'),
(176,1,'2025-08-24 18:00:00','2025-08-24 19:00:00',0,'2025-08-17 14:32:49'),
(177,1,'2025-08-31 18:00:00','2025-08-31 19:00:00',0,'2025-08-17 14:32:49'),
(182,1,'2025-09-07 11:00:00','2025-09-07 12:00:00',0,'2025-08-17 14:33:11'),
(183,1,'2025-09-14 11:00:00','2025-09-14 12:00:00',0,'2025-08-17 14:33:11'),
(184,1,'2025-09-21 11:00:00','2025-09-21 12:00:00',0,'2025-08-17 14:33:11'),
(185,1,'2025-09-28 11:00:00','2025-09-28 12:00:00',0,'2025-08-17 14:33:11'),
(186,1,'2025-09-01 14:00:00','2025-09-01 15:00:00',0,'2025-08-17 14:33:11'),
(187,1,'2025-09-08 14:00:00','2025-09-08 15:00:00',0,'2025-08-17 14:33:11'),
(188,1,'2025-09-15 14:00:00','2025-09-15 15:00:00',0,'2025-08-17 14:33:11'),
(189,1,'2025-09-22 14:00:00','2025-09-22 15:00:00',0,'2025-08-17 14:33:11'),
(190,1,'2025-09-29 14:00:00','2025-09-29 15:00:00',0,'2025-08-17 14:33:11'),
(191,1,'2025-09-07 18:00:00','2025-09-07 19:00:00',0,'2025-08-17 14:33:11'),
(192,1,'2025-09-14 18:00:00','2025-09-14 19:00:00',0,'2025-08-17 14:33:11'),
(193,1,'2025-09-21 18:00:00','2025-09-21 19:00:00',0,'2025-08-17 14:33:11'),
(194,1,'2025-09-28 18:00:00','2025-09-28 19:00:00',0,'2025-08-17 14:33:11'),
(195,6,'2025-08-30 11:04:00','2025-08-30 12:04:00',0,'2025-08-30 06:02:20'),
(196,6,'2025-12-07 12:04:00','2025-12-07 13:04:00',0,'2025-08-30 06:03:40'),
(197,3,'2025-09-02 06:02:00','2025-09-02 08:04:00',0,'2025-08-31 10:39:02'),
(198,3,'2025-09-03 06:02:00','2025-09-03 08:04:00',0,'2025-08-31 10:39:25'),
(199,6,'2025-09-04 17:00:00','2025-09-04 17:58:00',0,'2025-08-31 13:40:46');
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
  UNIQUE KEY `uq_template_hour` (`expert_id`,`day_of_week`,`start_time`,`end_time`),
  KEY `idx_expert_dow` (`expert_id`,`day_of_week`),
  CONSTRAINT `expert_weekly_templates_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(4,3,'Friday','09:00:00','17:00:00','2025-08-10 07:01:33'),
(5,1,'Sunday','11:00:00','12:00:00','2025-08-17 14:31:17'),
(6,1,'Monday','14:00:00','15:00:00','2025-08-17 14:31:41'),
(7,1,'Sunday','18:00:00','19:00:00','2025-08-17 14:32:47'),
(8,6,'Wednesday','10:00:00','11:00:00','2025-08-30 05:44:55'),
(9,6,'Saturday','11:04:00','12:04:00','2025-08-30 05:45:15'),
(10,6,'Wednesday','07:00:00','08:00:00','2025-08-30 05:45:45'),
(11,3,'Monday','14:03:00','15:03:00','2025-08-31 10:39:54'),
(12,6,'Monday','15:00:00','16:00:00','2025-08-31 13:38:14'),
(13,6,'Monday','16:00:00','17:00:00','2025-08-31 13:39:05'),
(14,6,'Monday','17:00:00','18:00:00','2025-08-31 13:39:05');
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
-- Table structure for table `meeting_attendance_sessions`
--

DROP TABLE IF EXISTS `meeting_attendance_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_attendance_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) DEFAULT NULL,
  `room_name` varchar(191) NOT NULL,
  `participant_sid` varchar(191) NOT NULL,
  `identity` varchar(191) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `joined_at` datetime NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `left_at` datetime DEFAULT NULL,
  `duration_seconds` int(10) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_room_sid` (`room_name`,`participant_sid`),
  KEY `idx_meeting_room` (`meeting_id`,`room_name`),
  KEY `idx_user` (`user_id`),
  KEY `idx_user_joined` (`user_id`,`joined_at`),
  KEY `idx_meeting_joined` (`meeting_id`,`joined_at`),
  KEY `idx_room_sid` (`room_name`,`participant_sid`),
  KEY `idx_att_meeting_user` (`meeting_id`,`user_id`),
  KEY `idx_att_user_joined` (`user_id`,`joined_at`),
  CONSTRAINT `fk_att_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_att_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_attendance_sessions`
--

LOCK TABLES `meeting_attendance_sessions` WRITE;
/*!40000 ALTER TABLE `meeting_attendance_sessions` DISABLE KEYS */;
INSERT INTO `meeting_attendance_sessions` VALUES
(1,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_icWLWoohnwML','3',3,'expert','2025-08-18 12:17:28',NULL,NULL,NULL,'2025-08-18 12:17:28','2025-08-18 12:17:28'),
(2,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_uqL5KsGRzftE','3',3,'expert','2025-08-18 12:17:54',NULL,'2025-08-18 12:18:22',28,'2025-08-18 12:17:54','2025-08-18 12:18:22'),
(3,3,'room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc','PA_YSAUAEBJhQAz','3',3,'expert','2025-08-18 12:18:39',NULL,NULL,NULL,'2025-08-18 12:18:39','2025-08-18 12:18:39'),
(4,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_UwzDYxSiexcF','3',3,'expert','2025-08-20 13:11:44','2025-08-20 13:11:44','2025-08-20 13:11:44',0,'2025-08-20 13:11:44','2025-08-20 13:14:00'),
(5,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_sZu4hEb3cbNw','3',3,'expert','2025-08-20 13:12:39','2025-08-20 13:12:39','2025-08-20 13:12:39',0,'2025-08-20 13:12:39','2025-08-20 13:15:00'),
(6,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_fLjfUdyDPU9B','3',3,'expert','2025-08-20 13:21:53','2025-08-20 13:21:53','2025-08-20 13:21:53',0,'2025-08-20 13:21:53','2025-08-20 13:24:00'),
(7,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_UWFMEtRQxhM5','4',4,'client','2025-08-30 07:14:14','2025-08-30 11:29:45','2025-08-30 11:29:45',15331,'2025-08-30 07:14:14','2025-08-30 11:32:00');
/*!40000 ALTER TABLE `meeting_attendance_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_messages`
--

DROP TABLE IF EXISTS `meeting_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` bigint(20) unsigned NOT NULL,
  `room_name` varchar(191) NOT NULL,
  `sender_user_id` bigint(20) unsigned DEFAULT NULL,
  `sender_identity` varchar(191) NOT NULL,
  `text` text NOT NULL,
  `msg_ts` bigint(20) unsigned NOT NULL,
  `text_hash` char(64) NOT NULL,
  `raw` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_meeting_chat` (`meeting_id`,`room_name`,`msg_ts`,`sender_identity`,`text_hash`),
  KEY `idx_meeting_created` (`meeting_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_messages`
--

LOCK TABLES `meeting_messages` WRITE;
/*!40000 ALTER TABLE `meeting_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_messages` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
(4,7,4,'participant','accepted',0,NULL,NULL,NULL,'2025-08-16 06:52:01'),
(7,9,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-19 14:29:59'),
(8,9,5,'participant','accepted',0,NULL,NULL,NULL,'2025-08-19 14:29:59');
/*!40000 ALTER TABLE `meeting_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_reminders`
--

DROP TABLE IF EXISTS `meeting_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_reminders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `kind` varchar(32) NOT NULL,
  `status` varchar(16) NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `error_text` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_mr_meeting_kind` (`meeting_id`,`kind`),
  KEY `idx_mr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_reminders`
--

LOCK TABLES `meeting_reminders` WRITE;
/*!40000 ALTER TABLE `meeting_reminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_reminders` ENABLE KEYS */;
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
  `status` enum('upcoming','ongoing','completed','cancelled','expired') NOT NULL DEFAULT 'upcoming',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `meeting_type` enum('one-on-one','group') NOT NULL DEFAULT 'one-on-one',
  `video_tool` enum('jitsi','webrtc','livekit') NOT NULL DEFAULT 'livekit',
  `meet_type` enum('audio','video') NOT NULL DEFAULT 'video',
  `timezone` varchar(100) NOT NULL DEFAULT 'UTC',
  `live_room_name` varchar(255) DEFAULT NULL,
  `is_live` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_sent` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_30_sent` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_order` (`order_id`),
  KEY `slot_id` (`slot_id`),
  KEY `idx_meeting_expert_time` (`expert_id`,`start_time`),
  KEY `idx_meetings_created_by` (`created_by`),
  KEY `idx_meeting_start` (`start_time`),
  KEY `idx_meetings_times` (`start_time`,`end_time`,`status`),
  KEY `idx_meetings_status_start` (`status`,`start_time`),
  CONSTRAINT `fk_meetings_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `meetings_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `service_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meetings_ibfk_2` FOREIGN KEY (`slot_id`) REFERENCES `expert_time_slots` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetings`
--

LOCK TABLES `meetings` WRITE;
/*!40000 ALTER TABLE `meetings` DISABLE KEYS */;
INSERT INTO `meetings` VALUES
(3,1,3,3,6,'2025-08-18 09:00:00','2025-08-18 10:00:00',NULL,'livekit','room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=user','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=expert','completed',NULL,NULL,'2025-08-10 07:47:52','one-on-one','livekit','video','UTC',NULL,0,0,0),
(4,3,3,3,7,'2025-08-18 10:00:00','2025-08-18 11:00:00',NULL,'livekit','room_6b304630-692a-49a5-8cec-e5d96e9835f5','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=user','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=expert','expired',NULL,NULL,'2025-08-10 07:50:26','one-on-one','livekit','video','UTC',NULL,0,0,0),
(5,5,3,4,8,'2025-08-18 11:00:00','2025-08-18 12:00:00',NULL,'livekit','room_56dbff05-1a15-416c-9577-ad04d2851035','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=user','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=expert','',NULL,NULL,'2025-08-11 19:21:19','one-on-one','livekit','video','UTC',NULL,0,0,0),
(6,6,3,4,30,'2025-08-15 11:00:00','2025-08-15 12:00:00',NULL,'livekit','room_915e28fc-6b01-4470-b983-0ea9f59d54ab','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=user','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=expert','completed',NULL,NULL,'2025-08-14 19:44:30','one-on-one','livekit','video','UTC',NULL,0,0,0),
(7,36,3,4,32,'2025-08-15 13:00:00','2025-08-15 14:00:00',NULL,'livekit','room_79c13df8-f57a-44ed-96d3-fe860a2e0e55','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=user','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=expert','',NULL,NULL,'2025-08-16 06:52:01','one-on-one','livekit','video','UTC',NULL,0,0,0),
(8,39,3,3,33,'2025-08-15 14:00:00','2025-08-15 15:00:00',NULL,'livekit','room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=user','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=expert','',NULL,NULL,'2025-08-16 07:40:16','one-on-one','livekit','video','UTC',NULL,0,0,0),
(9,41,3,5,25,'2025-08-20 10:00:00','2025-08-20 11:00:00',NULL,'livekit','room_5e4b73d9-5c8e-40b4-8629-e799524dc106','/meet/join/room_5e4b73d9-5c8e-40b4-8629-e799524dc106?as=user','/meet/join/room_5e4b73d9-5c8e-40b4-8629-e799524dc106?as=expert','completed',NULL,NULL,'2025-08-19 14:29:59','one-on-one','livekit','video','UTC',NULL,0,0,0);
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
INSERT INTO `message_reads` VALUES
(1,2,'2025-08-28 08:23:26'),
(1,4,'2025-08-30 06:14:29'),
(2,2,'2025-08-28 08:23:26'),
(2,4,'2025-08-30 06:14:29'),
(3,2,'2025-08-28 08:23:26'),
(3,4,'2025-08-30 06:14:29'),
(4,2,'2025-08-28 08:23:26'),
(4,4,'2025-08-30 06:14:29'),
(5,3,'2025-08-17 19:13:16'),
(5,4,'2025-08-17 19:13:42'),
(6,2,'2025-08-28 08:23:26'),
(6,4,'2025-08-30 06:14:29'),
(7,2,'2025-08-28 08:23:26'),
(7,4,'2025-08-30 06:14:29'),
(8,2,'2025-08-28 08:23:26'),
(8,4,'2025-08-30 06:14:29'),
(9,3,'2025-08-17 19:14:05'),
(9,4,'2025-08-17 19:13:42'),
(10,3,'2025-08-17 19:14:05'),
(10,4,'2025-08-17 21:13:03'),
(11,3,'2025-08-20 06:16:51'),
(11,4,'2025-08-17 21:13:03'),
(12,3,'2025-08-20 06:16:51'),
(12,4,'2025-08-17 22:21:48'),
(13,1,'2025-08-18 00:34:50'),
(13,3,'2025-08-18 00:34:43'),
(14,1,'2025-08-18 00:34:50'),
(14,3,'2025-08-18 00:42:42'),
(15,1,'2025-08-18 00:42:16'),
(15,3,'2025-08-18 00:42:42'),
(16,1,'2025-08-18 00:42:23'),
(16,3,'2025-08-18 00:42:42'),
(17,1,'2025-08-18 00:42:54'),
(17,3,'2025-08-18 00:42:42'),
(18,1,'2025-08-18 00:42:54'),
(19,3,'2025-08-20 06:16:51'),
(19,4,'2025-08-20 06:16:45'),
(20,1,'2025-08-18 00:51:38'),
(21,1,'2025-08-18 01:00:39'),
(22,1,'2025-08-18 01:05:26'),
(23,1,'2025-08-20 10:11:27'),
(24,3,'2025-08-20 06:16:51'),
(24,4,'2025-08-20 06:16:45'),
(25,3,'2025-08-20 06:16:51'),
(25,4,'2025-08-20 06:16:45'),
(26,3,'2025-08-20 06:16:51'),
(26,4,'2025-08-20 13:24:13'),
(27,3,'2025-08-20 13:24:23'),
(27,4,'2025-08-20 13:24:13'),
(28,2,'2025-08-28 08:23:26'),
(28,4,'2025-08-30 06:14:29'),
(29,3,'2025-08-20 13:24:23'),
(29,4,'2025-08-20 13:24:13'),
(30,3,'2025-08-20 13:24:23'),
(30,4,'2025-08-20 13:24:13'),
(31,3,'2025-08-20 13:24:23'),
(31,4,'2025-08-20 13:24:13'),
(35,3,'2025-08-20 13:24:23'),
(35,4,'2025-08-20 13:24:56'),
(36,4,'2025-08-20 13:24:56'),
(37,4,'2025-08-20 13:29:14'),
(38,4,'2025-08-30 06:14:29'),
(39,4,'2025-08-30 06:14:29'),
(40,4,'2025-08-30 06:14:29');
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
  KEY `idx_messages_chat_created` (`chat_id`,`created_at`),
  KEY `idx_messages_sender_created` (`sender_id`,`created_at`),
  KEY `idx_msg_chat_id_id` (`chat_id`,`id`),
  KEY `idx_msg_sender_created` (`sender_id`,`created_at`),
  CONSTRAINT `fk_messages_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
(4,1,4,'tui koi',NULL,NULL,0,0,NULL,NULL,'2025-08-12 10:39:02'),
(5,2,4,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 11:39:23'),
(6,1,4,'hgf',NULL,NULL,0,0,NULL,NULL,'2025-08-17 11:59:52'),
(7,1,4,'dsgdg',NULL,NULL,0,0,NULL,NULL,'2025-08-17 12:08:32'),
(8,1,4,'how are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 12:21:33'),
(9,2,3,'how are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 13:13:24'),
(10,2,4,'I\'m fine',NULL,NULL,0,0,NULL,NULL,'2025-08-17 13:14:05'),
(11,2,3,'Hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 15:13:03'),
(12,2,3,'helodsgsfd',NULL,NULL,0,0,NULL,NULL,'2025-08-17 15:13:15'),
(13,3,1,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:34:07'),
(14,3,3,'How ae you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:34:50'),
(15,3,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:16'),
(16,3,3,'How are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:23'),
(17,3,1,'file',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:42'),
(18,3,3,'hhh',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:54'),
(19,2,3,'hhi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:43:31'),
(20,3,3,'okay',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:51:38'),
(21,3,3,NULL,NULL,'http://localhost:5000/uploads/chat/130c4306cecd275d5d891dbf2c42425c.png',0,0,NULL,NULL,'2025-08-17 18:57:40'),
(22,3,3,'See the attachment',NULL,'http://localhost:5000/uploads/chat/113485e437eedfdc19935256f19b6558.pdf',0,0,NULL,NULL,'2025-08-17 19:05:26'),
(23,3,3,'Please knock me when available ',NULL,NULL,0,0,NULL,NULL,'2025-08-18 06:14:50'),
(24,2,3,'Hey',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:13:23'),
(25,2,3,'are you there?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:13:31'),
(26,2,4,'yes',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:16:50'),
(27,2,3,'what are you doing now?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:53:11'),
(28,1,4,'Hello from Insomnia',NULL,NULL,0,0,NULL,NULL,'2025-08-20 08:42:54'),
(29,2,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:07:59'),
(30,2,3,'munsi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:08:06'),
(31,2,3,'how are you',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:08:19'),
(32,4,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:22:42'),
(33,4,3,NULL,NULL,'http://api.prosfata.space/uploads/chat/4d4fb65f074194381b8fe10a8ef89b94.png',0,0,NULL,NULL,'2025-08-20 13:23:02'),
(34,4,3,'Are are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:23:17'),
(35,2,4,'hey',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:24:16'),
(36,2,3,'ab ku kkhk ',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:24:56'),
(37,2,3,NULL,NULL,'http://api.prosfata.space/uploads/chat/982ac7165f31f43a2da7e4223c929cb1.png',0,0,NULL,NULL,'2025-08-20 13:29:14'),
(38,1,2,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-28 08:23:30'),
(39,1,2,'hi Abu',NULL,NULL,0,0,NULL,NULL,'2025-08-30 05:25:03'),
(40,1,2,'thanks your response',NULL,NULL,0,0,NULL,NULL,'2025-08-30 05:25:17'),
(41,1,2,'hello',NULL,NULL,0,0,NULL,NULL,'2025-08-31 09:44:08'),
(42,5,2,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-31 09:59:56'),
(43,5,2,'hello',NULL,NULL,0,0,NULL,NULL,'2025-08-31 11:59:49'),
(44,5,2,'thank you for your great response',NULL,NULL,0,0,NULL,NULL,'2025-08-31 12:00:07'),
(45,7,6,'hi imran',NULL,NULL,0,0,NULL,NULL,'2025-08-31 13:41:14'),
(46,6,6,'hi mustafizur',NULL,NULL,0,0,NULL,NULL,'2025-08-31 13:41:31'),
(47,6,6,'how are you',NULL,NULL,0,0,NULL,NULL,'2025-08-31 13:41:40'),
(48,6,6,NULL,NULL,'http://api.prosfata.space/uploads/chat/2c605590013c217f45e4d9b91869db5e.png',0,0,NULL,NULL,'2025-08-31 13:41:49'),
(49,6,6,NULL,NULL,'http://api.prosfata.space/uploads/chat/56c2dff319518627d52d675b1b5a67ac.jpg',0,0,NULL,NULL,'2025-08-31 13:42:06'),
(50,7,6,NULL,NULL,'http://api.prosfata.space/uploads/chat/74abdb3920596527600f370333c432ea.jpg',0,0,NULL,NULL,'2025-08-31 13:42:39'),
(51,7,6,NULL,NULL,'http://api.prosfata.space/uploads/chat/220000d85b65c986bed157ca9e39f7ed.jpg',0,0,NULL,NULL,'2025-08-31 13:42:50'),
(52,7,6,NULL,NULL,'http://api.prosfata.space/uploads/chat/63b14c52578c5d089b4a871b7afeb263.jpg',0,0,NULL,NULL,'2025-08-31 13:42:59'),
(53,1,2,'sure',NULL,NULL,0,0,NULL,NULL,'2025-09-07 12:54:56');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_settings`
--

DROP TABLE IF EXISTS `notification_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_settings` (
  `user_id` int(11) NOT NULL,
  `push_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `email_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `message_mentions` tinyint(1) NOT NULL DEFAULT 1,
  `meeting_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `course_payments` tinyint(1) NOT NULL DEFAULT 1,
  `service_suggestions` tinyint(1) NOT NULL DEFAULT 0,
  `promotions` tinyint(1) NOT NULL DEFAULT 0,
  `service_updates` tinyint(1) NOT NULL DEFAULT 1,
  `subscription_renewals` tinyint(1) NOT NULL DEFAULT 1,
  `feedback_requests` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_ns_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_settings`
--

LOCK TABLES `notification_settings` WRITE;
/*!40000 ALTER TABLE `notification_settings` DISABLE KEYS */;
INSERT INTO `notification_settings` VALUES
(1,1,1,1,1,1,0,0,1,1,1,'2025-08-20 18:53:52','2025-08-20 18:53:52'),
(2,1,1,1,1,1,0,0,1,1,1,'2025-08-28 08:24:09','2025-08-31 13:48:40'),
(3,1,1,1,1,1,0,0,1,1,1,'2025-08-30 12:10:10','2025-08-30 12:10:10'),
(4,1,1,1,1,1,0,1,1,1,1,'2025-08-20 19:02:35','2025-08-20 19:37:48'),
(6,1,1,1,1,1,0,0,1,1,1,'2025-08-28 05:21:24','2025-08-28 05:21:24');
/*!40000 ALTER TABLE `notification_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  PRIMARY KEY (`id`),
  KEY `idx_notif_user_created` (`user_id`,`created_at`),
  KEY `idx_notif_user_unread` (`user_id`,`is_read`),
  CONSTRAINT `fk_n_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES
(1,1,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',0,NULL,'2025-08-20 18:53:52',NULL),
(2,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-08-20 19:42:01','2025-08-20 19:02:35',NULL),
(3,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-08-31 13:52:51','2025-08-20 19:42:28',NULL),
(4,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-08-30 06:11:04','2025-08-20 19:42:44',NULL);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(28,'My Courses','/my-courses','school',2,1,4,1,'2025-08-16 07:15:58','2025-08-16 07:15:58'),
(29,'My Courses','/learning','book-open-check',3,1,30,1,'2025-08-17 05:08:25','2025-08-19 08:53:29'),
(30,'My Accounts','/','baggage-claim',9,1,NULL,1,'2025-08-19 08:52:24','2025-08-19 13:38:17'),
(31,'My Meeting History','/meetings/history/my','calendar-days',3,1,30,1,'2025-08-19 08:55:31','2025-08-19 13:39:51'),
(32,'Services Meeting History','/meetings/history/expert','calendar-clock',6,1,30,1,'2025-08-19 13:41:27','2025-08-19 13:41:27'),
(33,'Experts Meeting History','/meetings/history/admin','calendar-search',7,1,30,1,'2025-08-19 13:42:09','2025-08-19 13:42:09'),
(34,'Coaching','/coaching/catalog','book-open-check',8,1,NULL,1,'2025-08-23 14:05:45','2025-08-23 20:39:52'),
(35,'All Coaching Programs','/coaching/catalog','notebook-text',1,1,34,1,'2025-08-23 14:07:02','2025-08-23 20:41:51'),
(36,'My Programs','/coaching/my-programs','list-ordered',2,1,34,1,'2025-08-23 14:08:51','2025-08-23 20:42:34'),
(37,'Create Program','/coaching/programs/new','plus-circle',3,1,34,1,'2025-08-23 20:43:29','2025-08-23 20:43:29'),
(38,'My Availability','/my-availability','calendar-clock',4,1,34,1,'2025-08-23 20:44:56','2025-08-23 20:44:56'),
(39,'Reviews (Assignments)','/coaching/review','clipboard-list',5,1,34,1,'2025-08-23 20:45:59','2025-08-23 20:45:59'),
(40,'Meetings (Expert)','/meetings/history/expert','clock',6,1,34,1,'2025-08-23 20:46:52','2025-08-23 20:46:52'),
(41,'Browse Programs','/coaching/catalog','notebook-text',7,1,34,1,'2025-08-23 20:48:35','2025-08-23 20:48:35'),
(42,'My Enrollments','/coaching/enrollments','user-round',8,1,34,1,'2025-08-23 20:49:25','2025-08-23 20:49:25'),
(43,'Schedule Sessions','/coaching/schedule','calendar-range',9,1,34,1,'2025-08-23 20:50:16','2025-08-23 20:50:16'),
(44,'Roadmap & Assignments','/coaching/assignments','list-ordered',10,1,34,1,'2025-08-23 20:51:33','2025-08-23 20:51:33'),
(45,'My Meetings','/meetings/history/my','clock',11,1,34,1,'2025-08-23 20:52:36','2025-08-23 20:52:36'),
(46,'User Management','/admin/users','user-round-cog',3,1,16,1,'2025-08-24 07:50:39','2025-08-24 07:50:39');
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
  UNIQUE KEY `uq_prt_token` (`token_hash`),
  KEY `user_id` (`user_id`),
  KEY `idx_prt_expires` (`expires_at`),
  CONSTRAINT `fk_prt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES
(1,3,'0991a70f7bab68a19f284834d7cb94525979f29becb22c472ec474035dd7593b','2025-08-10 15:54:30',0,NULL,'2025-08-10 08:54:30'),
(2,6,'e086f1659441902a16c967c6305a6e23a8a6d94cf06a53860c79d3a991d4cfc4','2025-09-06 23:50:48',1,'2025-09-06 22:52:38','2025-09-06 22:50:48');
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
(1,28,1,1,0,0),
(1,29,1,1,1,1),
(1,30,1,1,1,1),
(1,31,1,1,1,1),
(1,33,1,1,1,1),
(1,46,1,1,1,1),
(2,1,1,0,0,0),
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
(2,28,1,1,1,1),
(2,29,1,1,1,1),
(2,30,1,1,1,0),
(2,31,1,1,1,1),
(2,32,1,1,1,1),
(2,34,1,1,1,1),
(2,35,1,1,1,1),
(2,36,1,1,1,1),
(2,37,1,1,1,1),
(2,38,1,1,1,1),
(2,39,1,1,1,1),
(2,40,1,1,1,1),
(5,1,1,0,0,0),
(5,4,1,0,0,0),
(5,5,1,0,0,0),
(5,6,1,0,0,0),
(5,7,1,0,0,0),
(5,8,1,0,0,0),
(5,9,1,0,0,0),
(5,11,1,0,0,0),
(5,12,1,0,0,0),
(5,29,1,0,0,0),
(5,30,1,1,1,1),
(5,31,1,0,0,0),
(5,34,1,1,1,1),
(5,41,1,1,1,1),
(5,42,1,1,1,1),
(5,43,1,1,1,1),
(5,44,1,1,1,1),
(5,45,1,1,1,1);
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
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled_reason` varchar(255) DEFAULT NULL,
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
  KEY `idx_so_meeting` (`meeting_id`,`created_at`),
  CONSTRAINT `service_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_orders_ibfk_2` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_orders`
--

LOCK TABLES `service_orders` WRITE;
/*!40000 ALTER TABLE `service_orders` DISABLE KEYS */;
INSERT INTO `service_orders` VALUES
(1,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-09 19:46:16','2025-08-19 13:03:15',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(2,3,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,'Please prepare documents before meeting',NULL,'2025-08-09 21:00:15','2025-08-15 05:44:16',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(3,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,'Please review my resume before call',NULL,'2025-08-10 07:49:06','2025-08-12 07:39:13',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(4,4,3,1,19.99,'USD','pending',NULL,NULL,NULL,'Please review my resume before call',NULL,'2025-08-11 15:28:11','2025-08-11 15:28:11',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(5,4,3,1,19.99,'USD','paid',NULL,NULL,NULL,'Please review my resume before call','manual-OK-123','2025-08-11 19:18:52','2025-08-11 19:21:19',8,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(6,4,3,2,49.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1LoAVIvITXyG6V25dVzM3umMBp52sogmnb03z0E4rTFOmR37d2FDXPbjU','2025-08-14 19:43:49','2025-08-14 19:44:31',30,'Paid',6,'pi_3Rw74X3RqEMUJuhk0anuzhlI','ch_3Rw74X3RqEMUJuhk01SLvTEy','in_1Rw74Z3RqEMUJuhkQLBAVt8v','pm_1Rw74W3RqEMUJuhkJyT3K4ug','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJ_5-MQGMgZICvWPGLU6LBYcH4C7KtuUlx8ao70PpsJsm_cqARnHUbhflXr_0R88izE56N_v7j_DoWpX?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH/pdf?s=ap','visa','4242',0),
(7,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(8,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(9,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(10,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(11,4,3,2,49.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:58:04','2025-08-14 20:58:04',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(12,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(13,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(14,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(15,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(16,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:04','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(17,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(18,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(19,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(20,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(21,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:16','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(22,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(23,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(24,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:18','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(25,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(26,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(27,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:24','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(28,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(29,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(30,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:17:28','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(31,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:18:07','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(32,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:20:22','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(33,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:20:47','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(34,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:22:37','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(35,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:22:56','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(36,4,3,1,19.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1BjCsbtM1eKde8bGgWzwjnzaVuTdIUNIvtrHsqb1ixFs7fmwClld3JFm2','2025-08-15 05:23:11','2025-08-16 06:52:01',32,'Paid',7,'pi_3Rwdxw3RqEMUJuhk16iUcsFO','ch_3Rwdxw3RqEMUJuhk1skTjrTj','in_1Rwdxy3RqEMUJuhk8wFdoR26','pm_1Rw8v33RqEMUJuhkSAN3rnay','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJHVgMUGMgY-mXdTyFg6LBbUju_CRnKhkFVpdmSmtfDftvzB_cnmcOmRND5HAKuaeESvVH3AJyJutevz?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9/pdf?s=ap','visa','4242',0),
(37,4,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:53:23','2025-08-15 05:53:23',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(38,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-15 10:41:09','2025-08-15 10:41:09',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(39,3,3,1,19.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1IfjVcKdWYKloyjDwmFJhkMU8PodwgYd5Z4xPVHctH1i39lbT587v0Z2p','2025-08-15 10:49:46','2025-08-16 07:40:17',33,'Paid',8,'pi_3Rweii3RqEMUJuhk1h6lUhVW','py_3Rweii3RqEMUJuhk10AMjbFM','in_1Rwein3RqEMUJuhkZXfYXxju','pm_1Rweih3RqEMUJuhk6S8OpnPk','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKOHrgMUGMgYxprV3KCk6LBazZnimaArZJKcifiFYOWNGZzGCPFniVCKGn0dilPIHGQc1U0JlMlBoo8Ah?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu/pdf?s=ap',NULL,NULL,0),
(40,1,3,2,49.99,'USD','cancelled','2025-08-19 18:00:29',NULL,NULL,NULL,NULL,'2025-08-17 14:14:40','2025-08-19 12:00:29',25,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(41,5,3,5,10.00,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1Shqp1eXsYWmqIH6jUbiivRrpfREcPwCkSKG67w7HXmJY98oe8qDHNxiS','2025-08-19 14:29:27','2025-08-19 14:29:59',25,'Paid',9,'pi_3RxqXu3RqEMUJuhk1oDIHDsE','ch_3RxqXu3RqEMUJuhk1yg0Bymq','in_1RxqXx3RqEMUJuhkiSq8kAJZ','pm_1RxqXt3RqEMUJuhkFNGx2BXH','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKOeUksUGMgY0JGwVynQ6LBaZ0A4_dS77YzavX7_UKXW4vEC4EEWWnm6FKQ7zwrH_1yPnnHWQovX-SHdQ?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TdGRwZXUxSEx3SUJhN3I4MEdic05uQm1maDVuQmRaLDE0NjE1NDU5OQ0200IubaNjyA?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TdGRwZXUxSEx3SUJhN3I4MEdic05uQm1maDVuQmRaLDE0NjE1NDU5OQ0200IubaNjyA/pdf?s=ap','visa','4242',0),
(42,1,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 06:07:25','2025-08-20 06:07:25',36,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(43,1,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 06:07:25','2025-08-20 06:07:25',36,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(44,3,3,6,450.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 11:22:24','2025-08-20 11:22:24',37,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(45,3,3,6,450.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 11:22:24','2025-08-20 11:22:24',37,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES
(3,'AI Strategy'),
(7,'bussiness'),
(8,'Career Development Coaching'),
(9,'Contact for pricing'),
(4,'NodeJS'),
(1,'Python'),
(5,'ReactJs'),
(6,'RwactJS'),
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
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
(8,4,3,'pending','2025-08-16 04:38:19','2025-08-16 04:38:19'),
(9,4,1,'pending','2025-08-20 06:17:07','2025-08-20 06:17:07'),
(10,1,5,'pending','2025-08-20 10:11:15','2025-08-20 10:11:15'),
(11,1,3,'pending','2025-08-20 10:11:16','2025-08-20 10:11:16'),
(12,6,5,'pending','2025-08-20 13:52:12','2025-08-20 13:52:12'),
(13,6,3,'pending','2025-08-20 13:52:13','2025-08-20 13:52:13'),
(14,6,1,'pending','2025-08-20 13:52:15','2025-08-20 13:52:15'),
(16,2,5,'pending','2025-08-31 09:34:24','2025-08-31 09:34:24'),
(17,2,3,'pending','2025-08-31 09:34:26','2025-08-31 09:34:26'),
(18,2,1,'pending','2025-08-31 09:34:27','2025-08-31 09:34:27'),
(19,3,6,'pending','2025-08-31 10:37:05','2025-08-31 10:37:05'),
(21,2,6,'pending','2025-08-31 11:58:49','2025-08-31 11:58:49'),
(22,4,6,'pending','2025-09-04 13:58:12','2025-09-04 13:58:12');
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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_industries`
--

LOCK TABLES `user_industries` WRITE;
/*!40000 ALTER TABLE `user_industries` DISABLE KEYS */;
INSERT INTO `user_industries` VALUES
(32,1,1),
(36,6,2),
(37,6,1),
(40,3,2),
(41,2,1);
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
  `phone_number` varchar(32) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
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
  `public_slug` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uniq_users_public_slug` (`public_slug`),
  UNIQUE KEY `uq_users_public_slug` (`public_slug`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'abutaleb142@gmail.com',NULL,NULL,'$2a$10$RXiuogRf0xrA8eXRgDZblektWOnKCuL3r1kJIINLYa0CGCdo8Ymeu','2025-08-20 10:13:13',2,1,'/uploads/profile_photos/1755444112126-david-kazi.jpg','','','','active','2025-08-05 07:05:07','2025-08-20 10:13:13','Mohammad Abu','Taleb',0,'','','cus_Sst8O2EL92yt2P','pm_1Rx7N83RqEMUJuhkQY14JnBc','mohammad-abu-taleb'),
(2,'mustafizur142@gmail.com','019287543434','1991-07-15','$2a$10$ytBh93tBsRM6TrGiXNvxrusnXfUvQ/NpTSeFErcDLXjYTgGgYG/Rq',NULL,5,1,'/uploads/profile_photos/1756021977140-Ahmed.jpg','Dhaka','Dhaka','Bangladesh','active','2025-08-05 07:07:41','2025-08-31 10:03:50','Mustafizur','Rahman',0,'Jessore Road','Asia/Dhaka','cus_SvRQWVuL5yfBEp',NULL,NULL),
(3,'imranhossen1119999@gmail.com','+8801644812250',NULL,'$2a$10$gHsVq1qLWS65hjd6D7ufDOTMka4bzln7vrcdUJZmkfF.Sxq94LEUG','2025-08-10 14:52:23',2,1,'/uploads/profile_photos/1756555799817-munsi.jpg','Jessore','Jessore','Bangladesh','active','2025-08-05 07:14:34','2025-08-30 12:24:52','Imran','Hossen',1,'Jessore mani Road','Asia/Dhaka','cus_Ss5IuKQ2Wybk0m',NULL,'imran-hossen'),
(4,'admin@example.com','',NULL,'$2a$10$BNkZhxIFJ3qRC5pHbOdTKe8w5G7Fm/oE6NrVnuWad/NpjSuG0BA6K',NULL,1,1,'/uploads/profile_photos/1756539801452-abu_taleb_ceo.png','Dhaka 2','Dhaka','Bangladesh','active','2025-08-05 07:20:47','2025-08-30 07:43:22','MOHAMMAD','TALEB',1,'Dhaka, Dhaka','Asia/Dhaka','cus_Srql9qnzJPpwCc','pm_1Rw8v33RqEMUJuhkSAN3rnay',NULL),
(5,'admin2@example.com',NULL,NULL,'$2a$10$GwSLMgsCmCen/9Gqw5mIM.OLgHB7xjx4abIH0QwDqn0Pp.w7k2ntC',NULL,2,1,'/uploads/profile_photos/1755289622403-apon.jpg','San Frincisco','CA','United States','active','2025-08-06 09:32:28','2025-08-19 14:29:32','Mr Alex','Joe',0,'San Frincisco, CA','Pacific/Midway','cus_StdplrRRlszAZY',NULL,'mr-alex-joe'),
(6,'norman@prosfata.com','+1 (613) 770-4810','2022-11-16','$2a$10$WxcjssPkhGMkCE4kX5oSWegl2tIvDWNfTemf4gygwhVSYjOk1MrO6','2025-09-06 22:52:38',2,1,'/uploads/profile_photos/1755697808535-norman.png','Ontario','Kingston','Canada','active','2025-08-20 13:49:12','2025-09-06 22:52:38','Norman','Musengimana',0,'Kingston, Ontario, Canada','Canada/Atlantic',NULL,NULL,'norman-musengimana');
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

-- Dump completed on 2025-09-07 13:00:11
