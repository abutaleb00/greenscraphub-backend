-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:4306
-- Generation Time: Mar 01, 2026 at 04:26 PM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.0.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `greenscraphub`
--

-- --------------------------------------------------------

--
-- Table structure for table `agents`
--

CREATE TABLE `agents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `owner_user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `code` varchar(50) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address_line` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `commission_type` enum('percentage','flat') DEFAULT 'percentage',
  `commission_value` decimal(10,2) DEFAULT 0.00,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `agents`
--

INSERT INTO `agents` (`id`, `owner_user_id`, `name`, `code`, `email`, `phone`, `address_line`, `city`, `state`, `country`, `postal_code`, `commission_type`, `commission_value`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 5, 'Agent Two Recycling', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'percentage', '0.00', 1, '2025-12-08 13:55:52', '2025-12-08 13:55:52');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `total_points` int(11) DEFAULT 0,
  `default_address_id` bigint(20) UNSIGNED DEFAULT NULL,
  `referral_code` varchar(50) DEFAULT NULL,
  `referred_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `user_id`, `total_points`, `default_address_id`, `referral_code`, `referred_by`, `created_at`, `updated_at`) VALUES
(1, 7, 0, NULL, NULL, NULL, '2025-12-08 14:03:03', '2025-12-08 14:03:03'),
(3, 3, 0, NULL, NULL, NULL, '2025-12-08 17:53:34', '2025-12-08 17:53:34'),
(4, 8, 0, NULL, NULL, NULL, '2026-03-01 17:38:22', '2026-03-01 17:38:22');

-- --------------------------------------------------------

--
-- Table structure for table `customer_addresses`
--

CREATE TABLE `customer_addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(100) DEFAULT NULL,
  `address_line` varchar(255) NOT NULL,
  `area` varchar(150) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `state` varchar(150) DEFAULT NULL,
  `country` varchar(150) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `device_type` enum('android','ios','web') NOT NULL,
  `fcm_token` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `body` varchar(255) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `payout_requests`
--

CREATE TABLE `payout_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `user_type` enum('customer','rider','agent','admin') NOT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `fee_amount` decimal(10,2) DEFAULT 0.00,
  `method` enum('cash','bank','bkash','nagad','rocket','other') NOT NULL,
  `account_details` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected','paid') NOT NULL DEFAULT 'pending',
  `transaction_id` varchar(100) DEFAULT NULL,
  `admin_note` varchar(255) DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `requested_at` datetime NOT NULL DEFAULT current_timestamp(),
  `processed_at` datetime DEFAULT NULL,
  `processed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pickups`
--

CREATE TABLE `pickups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `booking_code` varchar(50) NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `customer_address_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pickup_address` text NOT NULL,
  `agent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rider_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('pending','assigned','rider_on_way','arrived','weighing','completed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status` enum('unpaid','paid','partially_paid','refunded') NOT NULL DEFAULT 'unpaid',
  `payment_method` enum('cash','wallet','bank','mobile_banking','mixed') DEFAULT NULL,
  `scheduled_date` date DEFAULT NULL,
  `scheduled_time_slot` varchar(50) DEFAULT NULL,
  `pickup_latitude` decimal(10,7) DEFAULT NULL,
  `pickup_longitude` decimal(10,7) DEFAULT NULL,
  `customer_note` varchar(255) DEFAULT NULL,
  `admin_note` varchar(255) DEFAULT NULL,
  `estimated_min_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `estimated_max_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `base_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `extra_charges` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_payable_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `wallet_credit_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cash_paid_to_customer` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rider_collected_cash` decimal(10,2) NOT NULL DEFAULT 0.00,
  `agent_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rider_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
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
  `cancelled_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_deleted` tinyint(4) DEFAULT 0,
  `pickup_type` enum('scheduled','instant') DEFAULT 'scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pickups`
--

INSERT INTO `pickups` (`id`, `booking_code`, `customer_id`, `customer_address_id`, `pickup_address`, `agent_id`, `rider_id`, `status`, `payment_status`, `payment_method`, `scheduled_date`, `scheduled_time_slot`, `pickup_latitude`, `pickup_longitude`, `customer_note`, `admin_note`, `estimated_min_amount`, `estimated_max_amount`, `base_amount`, `extra_charges`, `discount_amount`, `net_payable_amount`, `wallet_credit_amount`, `cash_paid_to_customer`, `rider_collected_cash`, `agent_commission_amount`, `rider_commission_amount`, `invoice_number`, `proof_image_before`, `proof_image_after`, `created_at`, `updated_at`, `assigned_at`, `rider_arrived_at`, `weighing_started_at`, `completed_at`, `cancelled_at`, `cancelled_by_user_id`, `is_deleted`, `pickup_type`) VALUES
(1, 'PK1765194814430', 3, NULL, '', 1, 1, 'pending', 'unpaid', NULL, '2025-01-15', '10:00 AM - 12:00 PM', '23.7805000', '90.2792000', 'call before coming', NULL, '250.00', '600.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', NULL, NULL, NULL, '2025-12-08 17:53:34', '2025-12-08 17:53:34', NULL, NULL, NULL, NULL, NULL, NULL, 0, 'scheduled'),
(2, 'PK1772365102421', 4, NULL, '', 1, 1, 'pending', 'unpaid', NULL, NULL, NULL, '23.8103000', '90.4125000', '', NULL, '1500.00', '3600.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', NULL, NULL, NULL, '2026-03-01 17:38:22', '2026-03-01 17:38:22', NULL, NULL, NULL, NULL, NULL, NULL, 0, 'scheduled');

-- --------------------------------------------------------

--
-- Table structure for table `pickup_area_stats`
--

CREATE TABLE `pickup_area_stats` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `area` varchar(150) NOT NULL,
  `city` varchar(150) DEFAULT NULL,
  `agent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `total_pickups` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `total_weight` decimal(12,3) NOT NULL DEFAULT 0.000,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `period_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pickup_items`
--

CREATE TABLE `pickup_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pickup_id` bigint(20) UNSIGNED NOT NULL,
  `scrap_item_id` bigint(20) UNSIGNED NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `estimated_weight` decimal(10,3) NOT NULL DEFAULT 0.000,
  `estimated_min_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `estimated_max_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `actual_weight` decimal(10,3) NOT NULL DEFAULT 0.000,
  `final_rate_per_unit` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `item_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pickup_items`
--

INSERT INTO `pickup_items` (`id`, `pickup_id`, `scrap_item_id`, `photo_url`, `estimated_weight`, `estimated_min_amount`, `estimated_max_amount`, `actual_weight`, `final_rate_per_unit`, `final_amount`, `created_at`, `updated_at`, `category_id`, `item_id`) VALUES
(1, 1, 1, '[]', '5.000', '250.00', '600.00', '0.000', '0.00', '0.00', '2025-12-08 17:53:34', '2025-12-08 17:53:34', NULL, NULL),
(2, 2, 2, '[\"uploads/raw/6a2f1555-8d11-4836-887a-17a12e46139e.jpeg\"]', '20.000', '1500.00', '3600.00', '0.000', '0.00', '0.00', '2026-03-01 17:38:22', '2026-03-01 17:38:22', NULL, NULL),
(3, 2, 1, '[\"uploads/raw/bcad8d98-09a9-4ad6-92e8-8b635e9ca9d3.jpeg\"]', '10.000', '1500.00', '3600.00', '0.000', '0.00', '0.00', '2026-03-01 17:38:22', '2026-03-01 17:38:22', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pickup_status_logs`
--

CREATE TABLE `pickup_status_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pickup_id` bigint(20) UNSIGNED NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `point_transactions`
--

CREATE TABLE `point_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `amount` int(11) NOT NULL,
  `type` enum('referral','milestone','redemption','bonus') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `riders`
--

CREATE TABLE `riders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `vehicle_type` varchar(50) DEFAULT NULL,
  `vehicle_number` varchar(50) DEFAULT NULL,
  `national_id` varchar(100) DEFAULT NULL,
  `emergency_contact` varchar(50) DEFAULT NULL,
  `rating_avg` decimal(3,2) DEFAULT 0.00,
  `total_completed` int(10) UNSIGNED DEFAULT 0,
  `is_online` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `riders`
--

INSERT INTO `riders` (`id`, `user_id`, `agent_id`, `vehicle_type`, `vehicle_number`, `national_id`, `emergency_contact`, `rating_avg`, `total_completed`, `is_online`, `is_verified`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 6, 1, 'Bike', 'DHA-1111', NULL, NULL, '0.00', 0, 0, 0, 1, '2025-12-08 14:01:39', '2025-12-08 14:01:39');

-- --------------------------------------------------------

--
-- Table structure for table `rider_locations`
--

CREATE TABLE `rider_locations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `rider_id` bigint(20) UNSIGNED NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`) VALUES
(1, 'admin', 'Platform administrator'),
(2, 'agent', 'Agent / Franchise owner'),
(3, 'rider', 'RagmanHeroes rider'),
(4, 'customer', 'End customer');

-- --------------------------------------------------------

--
-- Table structure for table `scrap_categories`
--

CREATE TABLE `scrap_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `display_order` int(10) UNSIGNED DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `scrap_categories`
--

INSERT INTO `scrap_categories` (`id`, `name`, `slug`, `description`, `icon`, `display_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Metals', 'metals', NULL, NULL, 1, 1, '2025-12-08 15:54:07', '2025-12-08 15:54:07'),
(2, 'Plastics', 'plastics', 'Simple product', '/uploads/category-icons/cat-1765187912747-135353973.png', 1, 1, '2025-12-08 15:58:32', '2025-12-08 15:58:32');

-- --------------------------------------------------------

--
-- Table structure for table `scrap_items`
--

CREATE TABLE `scrap_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `unit` varchar(50) NOT NULL DEFAULT 'kg',
  `min_price_per_unit` decimal(10,2) NOT NULL,
  `max_price_per_unit` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `scrap_items`
--

INSERT INTO `scrap_items` (`id`, `category_id`, `name`, `slug`, `image_url`, `description`, `unit`, `min_price_per_unit`, `max_price_per_unit`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Copper Wire', '', '/uploads/scrap-items/1765190972886-702882620.png', NULL, 'kg', '50.00', '120.00', 1, '2025-12-08 16:49:32', '2025-12-08 16:49:32'),
(2, 1, 'Tin Plastic', '', '/uploads/scrap-items/1772353710668-929981554.png', NULL, 'kg', '50.00', '120.00', 1, '2026-03-01 14:28:30', '2026-03-01 14:28:30');

-- --------------------------------------------------------

--
-- Table structure for table `scrap_price_history`
--

CREATE TABLE `scrap_price_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `scrap_item_id` bigint(20) UNSIGNED NOT NULL,
  `old_min_price` decimal(10,2) NOT NULL,
  `old_max_price` decimal(10,2) NOT NULL,
  `new_min_price` decimal(10,2) NOT NULL,
  `new_max_price` decimal(10,2) NOT NULL,
  `changed_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` tinyint(3) UNSIGNED NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `agent_id` int(11) DEFAULT NULL,
  `country_code` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role_id`, `full_name`, `email`, `phone`, `password_hash`, `agent_id`, `country_code`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(2, 1, 'Super Admin', 'admin@example.com', '01700000000', '$2a$10$MjPWUz91gj27yCTezxXQue.uOb/0iQ8e7Eo1RF4QazZ5CaUWvj5IK', NULL, NULL, 1, NULL, '2025-12-08 13:05:54', '2025-12-08 15:33:56'),
(3, 4, 'Test Customer', 'test@example.com', '01700000111', '$2a$10$MjPWUz91gj27yCTezxXQue.uOb/0iQ8e7Eo1RF4QazZ5CaUWvj5IK', NULL, NULL, 1, NULL, '2025-12-08 13:36:09', '2025-12-08 13:36:09'),
(4, 2, 'Agent One', 'agent1@example.com', '01700000222', '$2a$10$MjPWUz91gj27yCTezxXQue.uOb/0iQ8e7Eo1RF4QazZ5CaUWvj5IK', NULL, NULL, 1, NULL, '2025-12-08 13:48:56', '2025-12-08 13:54:03'),
(5, 2, 'Agent Two', 'agent2@example.com', '01700000333', '$2a$10$M9FJNtnlgT0MgKEGtw69tOmusN2BsDl9euNUAENLqcIClSjLN6/Bq', NULL, NULL, 1, NULL, '2025-12-08 13:55:52', '2025-12-08 13:55:52'),
(6, 3, 'Rider Admin Created', 'rideradmin@example.com', '01700000444', '$2a$10$Jrg/yHTYiuiEXLI6ZNEwdOlH6Puxm1MQ4VXtyodn7djQ/znugUm4q', NULL, NULL, 1, NULL, '2025-12-08 14:01:39', '2025-12-08 14:01:39'),
(7, 4, 'Backend Customer', 'backendcustomer@example.com', '0170000055555', '$2a$10$0KUOYymLUJ.I5dJWSOTpqeggTtCRJTzUqiG37NaP0SeKbdzO5MTU2', NULL, NULL, 1, NULL, '2025-12-08 14:03:03', '2025-12-08 14:03:03'),
(8, 4, 'Mohammad Abu Taleb', 'abutaleb142@gmail.com', '01925325050', '$2a$10$u0P8yOQLFYyMzim0BIMAcOq.KD1nlEMqbG3f7xzJNmsGbfK7zSEau', NULL, NULL, 1, NULL, '2026-03-01 17:28:59', '2026-03-01 17:28:59');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_accounts`
--

CREATE TABLE `wallet_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `user_type` enum('customer','rider','agent','admin') NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_withdrawn` decimal(15,2) DEFAULT 0.00,
  `currency` varchar(10) NOT NULL DEFAULT 'BDT',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('credit','debit') NOT NULL,
  `source` enum('pickup_wallet_credit','manual_adjustment','payout','refund','other') NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `balance_before` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `status` enum('pending','completed','failed') NOT NULL DEFAULT 'completed',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `fk_agents_owner` (`owner_user_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `referral_code` (`referral_code`),
  ADD KEY `fk_customers_user` (`user_id`),
  ADD KEY `fk_customers_default_address` (`default_address_id`);

--
-- Indexes for table `customer_addresses`
--
ALTER TABLE `customer_addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_customer_addresses_customer` (`customer_id`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_device_tokens_user` (`user_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_notifications_user` (`user_id`);

--
-- Indexes for table `payout_requests`
--
ALTER TABLE `payout_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_payout_requests_user` (`user_id`),
  ADD KEY `fk_payout_requests_wallet` (`wallet_id`),
  ADD KEY `fk_payout_requests_admin` (`processed_by`);

--
-- Indexes for table `pickups`
--
ALTER TABLE `pickups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_code` (`booking_code`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `fk_pickups_customer` (`customer_id`),
  ADD KEY `fk_pickups_customer_address` (`customer_address_id`),
  ADD KEY `fk_pickups_agent` (`agent_id`),
  ADD KEY `fk_pickups_rider` (`rider_id`),
  ADD KEY `fk_pickups_cancelled_by` (`cancelled_by_user_id`);

--
-- Indexes for table `pickup_area_stats`
--
ALTER TABLE `pickup_area_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_area_period_agent` (`area`,`period_date`,`agent_id`),
  ADD KEY `fk_pickup_area_stats_agent` (`agent_id`);

--
-- Indexes for table `pickup_items`
--
ALTER TABLE `pickup_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pickup_items_pickup` (`pickup_id`),
  ADD KEY `fk_pickup_items_scrap_item` (`scrap_item_id`);

--
-- Indexes for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pickup_status_logs_pickup` (`pickup_id`),
  ADD KEY `fk_pickup_status_logs_user` (`changed_by`);

--
-- Indexes for table `point_transactions`
--
ALTER TABLE `point_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_customer_id` (`customer_id`);

--
-- Indexes for table `riders`
--
ALTER TABLE `riders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_riders_user` (`user_id`),
  ADD KEY `fk_riders_agent` (`agent_id`);

--
-- Indexes for table `rider_locations`
--
ALTER TABLE `rider_locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_rider_locations_rider` (`rider_id`),
  ADD KEY `idx_rider_locations_latlng` (`latitude`,`longitude`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `scrap_categories`
--
ALTER TABLE `scrap_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `scrap_items`
--
ALTER TABLE `scrap_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_scrap_items_category` (`category_id`);

--
-- Indexes for table `scrap_price_history`
--
ALTER TABLE `scrap_price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_scrap_price_history_item` (`scrap_item_id`),
  ADD KEY `fk_scrap_price_history_user` (`changed_by_user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `fk_users_role` (`role_id`),
  ADD KEY `agent_id` (`agent_id`);

--
-- Indexes for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_wallet_user_currency` (`user_id`,`currency`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_wallet_transactions_wallet` (`wallet_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `agents`
--
ALTER TABLE `agents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `customer_addresses`
--
ALTER TABLE `customer_addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payout_requests`
--
ALTER TABLE `payout_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pickups`
--
ALTER TABLE `pickups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `pickup_area_stats`
--
ALTER TABLE `pickup_area_stats`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pickup_items`
--
ALTER TABLE `pickup_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `point_transactions`
--
ALTER TABLE `point_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `riders`
--
ALTER TABLE `riders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `rider_locations`
--
ALTER TABLE `rider_locations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `scrap_categories`
--
ALTER TABLE `scrap_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `scrap_items`
--
ALTER TABLE `scrap_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scrap_price_history`
--
ALTER TABLE `scrap_price_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `agents`
--
ALTER TABLE `agents`
  ADD CONSTRAINT `fk_agents_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `fk_customers_default_address` FOREIGN KEY (`default_address_id`) REFERENCES `customer_addresses` (`id`),
  ADD CONSTRAINT `fk_customers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `customer_addresses`
--
ALTER TABLE `customer_addresses`
  ADD CONSTRAINT `fk_customer_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Constraints for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD CONSTRAINT `fk_device_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `payout_requests`
--
ALTER TABLE `payout_requests`
  ADD CONSTRAINT `fk_payout_requests_admin` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_payout_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_payout_requests_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`);

--
-- Constraints for table `pickups`
--
ALTER TABLE `pickups`
  ADD CONSTRAINT `fk_pickups_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  ADD CONSTRAINT `fk_pickups_cancelled_by` FOREIGN KEY (`cancelled_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_pickups_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `fk_pickups_customer_address` FOREIGN KEY (`customer_address_id`) REFERENCES `customer_addresses` (`id`),
  ADD CONSTRAINT `fk_pickups_rider` FOREIGN KEY (`rider_id`) REFERENCES `riders` (`id`);

--
-- Constraints for table `pickup_area_stats`
--
ALTER TABLE `pickup_area_stats`
  ADD CONSTRAINT `fk_pickup_area_stats_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`);

--
-- Constraints for table `pickup_items`
--
ALTER TABLE `pickup_items`
  ADD CONSTRAINT `fk_pickup_items_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`),
  ADD CONSTRAINT `fk_pickup_items_scrap_item` FOREIGN KEY (`scrap_item_id`) REFERENCES `scrap_items` (`id`);

--
-- Constraints for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  ADD CONSTRAINT `fk_pickup_status_logs_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`),
  ADD CONSTRAINT `fk_pickup_status_logs_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `point_transactions`
--
ALTER TABLE `point_transactions`
  ADD CONSTRAINT `fk_customer_points` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `riders`
--
ALTER TABLE `riders`
  ADD CONSTRAINT `fk_riders_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  ADD CONSTRAINT `fk_riders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `rider_locations`
--
ALTER TABLE `rider_locations`
  ADD CONSTRAINT `fk_rider_locations_rider` FOREIGN KEY (`rider_id`) REFERENCES `riders` (`id`);

--
-- Constraints for table `scrap_items`
--
ALTER TABLE `scrap_items`
  ADD CONSTRAINT `fk_scrap_items_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`);

--
-- Constraints for table `scrap_price_history`
--
ALTER TABLE `scrap_price_history`
  ADD CONSTRAINT `fk_scrap_price_history_item` FOREIGN KEY (`scrap_item_id`) REFERENCES `scrap_items` (`id`),
  ADD CONSTRAINT `fk_scrap_price_history_user` FOREIGN KEY (`changed_by_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Constraints for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD CONSTRAINT `fk_wallet_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `fk_wallet_transactions_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
