-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:4306
-- Generation Time: Mar 07, 2026 at 05:38 PM
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
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
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
  `upazila_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `addresses`
--

INSERT INTO `addresses` (`id`, `user_id`, `label`, `address_line`, `landmark`, `house_no`, `road_no`, `latitude`, `longitude`, `is_default`, `created_at`, `updated_at`, `division_id`, `district_id`, `upazila_id`) VALUES
(6, 17, 'Business Hub', 'Hose 2, Mujguni Bashik', NULL, NULL, NULL, '23.81030000', '90.41250000', 1, '2026-03-05 10:57:25', '2026-03-05 10:57:25', NULL, NULL, NULL),
(7, 18, 'Business Hub', 'Notun rastar Mor, Khalishpur', NULL, NULL, NULL, '23.81754445', '90.41422026', 1, '2026-03-05 10:59:15', '2026-03-05 10:59:15', NULL, NULL, NULL),
(8, 24, 'Home', 'Professorpara', NULL, NULL, NULL, '22.84655683', '89.54179390', 1, '2026-03-05 13:33:15', '2026-03-05 13:39:27', 3, 4, 108),
(9, 23, 'Home', 'Model Schrrol Road', NULL, NULL, NULL, '22.84560000', '89.54030000', 1, '2026-03-05 13:36:34', '2026-03-05 13:36:34', 3, 1, 96);

-- --------------------------------------------------------

--
-- Table structure for table `admin_audit_logs`
--

CREATE TABLE `admin_audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` bigint(20) UNSIGNED NOT NULL,
  `action` varchar(100) DEFAULT NULL,
  `target_id` bigint(20) UNSIGNED DEFAULT NULL,
  `old_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_value`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `agents`
--

CREATE TABLE `agents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `owner_user_id` bigint(20) UNSIGNED NOT NULL,
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
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `agents`
--

INSERT INTO `agents` (`id`, `owner_user_id`, `business_name`, `company_name_en`, `company_name_bn`, `code`, `email`, `phone`, `nid_number`, `trade_license`, `address_line`, `latitude`, `longitude`, `base_division_id`, `base_district_id`, `commission_type`, `commission_value`, `is_active`, `default_rider_mode`, `platform_fee_percent`, `hub_commission_type`, `hub_commission_value`, `created_at`, `updated_at`) VALUES
(3, 17, 'SS Traders', '', '', 'AG-1JSSZ', 'agent1@example.com', '01700000222', NULL, NULL, 'Hose 2, Mujguni Bashik', '23.81030000', '90.41250000', NULL, NULL, 'percentage', '0.00', 1, 'salary', '5.00', 'percentage', '10.00', '2026-03-05 16:57:25', '2026-03-05 16:57:25'),
(4, 18, 'Three Brother', '', '', 'AG-WY7YA', 'agent2@example.com', '01700000333', NULL, NULL, 'Notun rastar Mor, Khalishpur', '23.81754445', '90.41422026', NULL, NULL, 'percentage', '0.00', 1, 'salary', '5.00', 'percentage', '10.00', '2026-03-05 16:59:15', '2026-03-05 16:59:15');

-- --------------------------------------------------------

--
-- Table structure for table `agent_coverage`
--

CREATE TABLE `agent_coverage` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `upazila_id` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `preferred_language` enum('en','bn') DEFAULT 'en',
  `total_points` int(11) DEFAULT 0,
  `total_pickups_completed` int(10) UNSIGNED DEFAULT 0,
  `default_address_id` bigint(20) UNSIGNED DEFAULT NULL,
  `referral_code` varchar(50) DEFAULT NULL,
  `referred_by` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('active','suspended','blacklisted') DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `user_id`, `preferred_language`, `total_points`, `total_pickups_completed`, `default_address_id`, `referral_code`, `referred_by`, `status`, `created_at`, `updated_at`) VALUES
(6, 23, 'en', 20, 0, NULL, 'GSR3HFB', NULL, 'active', '2026-03-05 17:04:34', '2026-03-05 17:04:34'),
(7, 24, 'en', 20, 0, NULL, 'GSPDH3K', NULL, 'active', '2026-03-05 17:05:32', '2026-03-05 17:05:32');

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
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `id` int(11) NOT NULL,
  `division_id` int(11) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `division_id`, `name_en`, `name_bn`, `is_active`) VALUES
(1, 3, 'Khulna', 'খুলনা', 1),
(2, 3, 'Bagerhat', 'বাগেরহাট', 1),
(3, 3, 'Chuadanga', 'চুয়াডাঙ্গা', 1),
(4, 3, 'Jashore', 'যশোর', 1),
(5, 3, 'Jhenaidah', 'ঝিনাইদহ', 1),
(6, 3, 'Kushtia', 'কুষ্টিয়া', 1),
(7, 3, 'Magura', 'মাগুরা', 1),
(8, 3, 'Meherpur', 'মেহেরপুর', 1),
(9, 3, 'Narail', 'নড়াইল', 1),
(10, 3, 'Satkhira', 'সাতক্ষীরা', 1);

-- --------------------------------------------------------

--
-- Table structure for table `divisions`
--

CREATE TABLE `divisions` (
  `id` int(11) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `status` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `divisions`
--

INSERT INTO `divisions` (`id`, `name_en`, `name_bn`, `status`) VALUES
(3, 'Khulna', 'খুলনা', 1);

-- --------------------------------------------------------

--
-- Table structure for table `financial_ledger`
--

CREATE TABLE `financial_ledger` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `source_type` varchar(50) DEFAULT 'pickup',
  `source_id` int(11) DEFAULT NULL,
  `pickup_id` bigint(20) UNSIGNED DEFAULT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `transaction_id` bigint(20) UNSIGNED NOT NULL,
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
  `payment_method` varchar(20) DEFAULT 'cash'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `financial_ledger`
--

INSERT INTO `financial_ledger` (`id`, `source_type`, `source_id`, `pickup_id`, `wallet_id`, `transaction_id`, `total_volume`, `debit`, `credit`, `balance_snapshot`, `entry_type`, `description`, `created_at`, `admin_commission`, `agent_commission`, `rider_commission`, `net_payout`, `payment_method`) VALUES
(10, 'cash_settlement', 5, NULL, 8, 3, '0.00', '0.00', '2350.00', '0.00', '', 'Hub Vault Intake: Full Settlement', '2026-03-05 18:08:13', '0.00', '0.00', '0.00', '0.00', 'cash');

-- --------------------------------------------------------

--
-- Table structure for table `hub_inventory`
--

CREATE TABLE `hub_inventory` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `current_weight` decimal(15,2) DEFAULT 0.00,
  `last_updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `hub_inventory`
--

INSERT INTO `hub_inventory` (`id`, `agent_id`, `category_id`, `current_weight`, `last_updated_at`) VALUES
(3, 4, 1, '2.00', '2026-03-05 18:08:13'),
(4, 4, 2, '1.00', '2026-03-05 18:18:31'),
(5, 4, 4, '1.00', '2026-03-05 18:08:13');

-- --------------------------------------------------------

--
-- Table structure for table `hub_releases`
--

CREATE TABLE `hub_releases` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `total_revenue` decimal(15,2) NOT NULL,
  `status` enum('pending','sold','cancelled') DEFAULT 'sold',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `hub_releases`
--

INSERT INTO `hub_releases` (`id`, `agent_id`, `total_revenue`, `status`, `created_at`) VALUES
(1, 4, '106.00', 'sold', '2026-03-05 18:18:31');

-- --------------------------------------------------------

--
-- Table structure for table `hub_release_items`
--

CREATE TABLE `hub_release_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `release_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `weight_released` decimal(15,2) NOT NULL,
  `sale_price_per_kg` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `item_price_overrides`
--

CREATE TABLE `item_price_overrides` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `division_id` bigint(20) UNSIGNED DEFAULT NULL,
  `district_id` bigint(20) UNSIGNED DEFAULT NULL,
  `upazila_id` bigint(20) UNSIGNED DEFAULT NULL,
  `min_rate` decimal(10,2) NOT NULL,
  `max_rate` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `item_price_overrides`
--

INSERT INTO `item_price_overrides` (`id`, `item_id`, `division_id`, `district_id`, `upazila_id`, `min_rate`, `max_rate`, `is_active`, `created_at`, `updated_at`) VALUES
(7, 7, 3, 1, NULL, '450.00', '550.00', 1, '2026-03-07 00:26:10', '2026-03-07 00:26:10');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title_key` varchar(100) NOT NULL,
  `body_key` varchar(255) NOT NULL,
  `body_placeholders` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`body_placeholders`)),
  `notification_type` enum('info','alert','success','warning') DEFAULT 'info',
  `click_action` varchar(255) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `payout_requests`
--

CREATE TABLE `payout_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
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
  `agent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rider_id` bigint(20) UNSIGNED DEFAULT NULL,
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
  `cancelled_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_deleted` tinyint(4) DEFAULT 0,
  `pickup_type` enum('scheduled','instant') DEFAULT 'scheduled',
  `division_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `upazila_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pickups`
--

INSERT INTO `pickups` (`id`, `booking_code`, `customer_id`, `customer_address_id`, `agent_id`, `rider_id`, `status`, `payment_status`, `payment_method`, `payment_mode_snapshot`, `scheduled_date`, `scheduled_time_slot`, `customer_note`, `admin_note`, `base_amount`, `net_payable_amount`, `admin_commission_amount`, `wallet_credit_amount`, `cash_paid_to_customer`, `rider_collected_cash`, `is_settled_to_hub`, `agent_commission_amount`, `rider_commission_amount`, `platform_fee_amount`, `invoice_number`, `proof_image_before`, `proof_image_after`, `created_at`, `updated_at`, `assigned_at`, `rider_arrived_at`, `weighing_started_at`, `completed_at`, `cancelled_at`, `cancelled_by_user_id`, `is_deleted`, `pickup_type`, `division_id`, `district_id`, `upazila_id`) VALUES
(1, 'GS-96-5631', 6, 9, 4, 5, 'completed', 'paid', NULL, 'salary', '2026-03-06', '10:00 AM - 12:00 PM', NULL, NULL, '2350.00', '2350.00', '0.00', '0.00', '0.00', '2350.00', 1, '235.00', '0.00', '117.50', NULL, NULL, NULL, '2026-03-05 20:25:45', '2026-03-06 00:08:13', '2026-03-05 21:23:41', '2026-03-05 22:26:22', NULL, '2026-03-05 22:45:39', NULL, NULL, 0, 'scheduled', 3, 1, 96),
(2, 'GS-96-3671', 6, 9, 4, 5, 'arrived', 'unpaid', NULL, NULL, '2026-03-20', '10:00 AM - 12:00 PM', NULL, NULL, '480.00', '0.00', '0.00', '0.00', '0.00', '0.00', 0, '0.00', '0.00', '0.00', NULL, NULL, NULL, '2026-03-05 23:58:33', '2026-03-07 13:43:11', '2026-03-07 13:41:27', '2026-03-07 13:43:11', NULL, NULL, NULL, NULL, 0, 'scheduled', 3, 1, 96),
(3, 'GS-96-1889', 6, 9, 3, 8, 'completed', 'paid', NULL, 'commission', '2026-03-07', '10:00 AM - 06:00 PM', '', NULL, '130.00', '130.00', '0.00', '0.00', '0.00', '130.00', 0, '13.00', '2.60', '6.50', NULL, NULL, NULL, '2026-03-07 12:59:51', '2026-03-07 14:18:56', '2026-03-07 13:44:22', '2026-03-07 13:45:06', NULL, '2026-03-07 14:18:56', NULL, NULL, 0, 'scheduled', 3, 1, 96);

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
  `photo_url` varchar(255) DEFAULT NULL,
  `item_note` text DEFAULT NULL,
  `estimated_weight` decimal(10,3) NOT NULL DEFAULT 0.000,
  `actual_weight` decimal(10,2) DEFAULT 0.00,
  `final_rate_per_unit` decimal(10,2) DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `item_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pickup_items`
--

INSERT INTO `pickup_items` (`id`, `pickup_id`, `photo_url`, `item_note`, `estimated_weight`, `actual_weight`, `final_rate_per_unit`, `final_amount`, `created_at`, `updated_at`, `category_id`, `item_id`) VALUES
(1, 1, '[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]', NULL, '2.000', '2.00', '800.00', '1600.00', '2026-03-05 20:25:45', '2026-03-05 22:45:39', 1, 5),
(2, 1, '[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]', NULL, '3.000', '3.00', '50.00', '150.00', '2026-03-05 20:25:45', '2026-03-05 22:45:39', 2, 9),
(3, 1, '[\"/uploads/pickups/photos-1772720745619-417431482.png\",\"/uploads/pickups/photos-1772720745624-276214854.png\",\"/uploads/pickups/photos-1772720745625-92893509.png\",\"/uploads/pickups/photos-1772720745626-391953612.png\"]', NULL, '1.000', '1.00', '600.00', '600.00', '2026-03-05 20:25:45', '2026-03-05 22:45:39', 4, 11),
(4, 2, '[\"/uploads/pickups/photos-1772733513656-12662644.png\"]', NULL, '4.000', '0.00', '120.00', '480.00', '2026-03-05 23:58:33', '2026-03-05 23:58:33', 5, 6),
(5, 3, '[\"/uploads/pickups/item_photos[0]-1772866791706-880120334.jpg\"]', NULL, '13.000', '13.00', '10.00', '130.00', '2026-03-07 12:59:51', '2026-03-07 14:18:56', 7, 8);

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
-- Table structure for table `pickup_timeline`
--

CREATE TABLE `pickup_timeline` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pickup_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(50) NOT NULL,
  `note` text DEFAULT NULL,
  `changed_by` bigint(20) UNSIGNED NOT NULL,
  `lat_at_time` decimal(10,8) DEFAULT NULL,
  `lng_at_time` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pickup_timeline`
--

INSERT INTO `pickup_timeline` (`id`, `pickup_id`, `status`, `note`, `changed_by`, `lat_at_time`, `lng_at_time`, `created_at`) VALUES
(9, 1, 'pending', 'Shipment request created by customer', 0, NULL, NULL, '2026-03-05 14:25:45'),
(10, 1, 'accepted', 'Dispatched to Rider: Rider 1', 18, NULL, NULL, '2026-03-05 15:23:41'),
(11, 1, 'arrived', 'Rider marked status as: arrived', 19, NULL, NULL, '2026-03-05 16:26:22'),
(12, 1, 'completed', 'Finalized. Settlement: ৳2350 via CASH. Mode: salary.', 19, NULL, NULL, '2026-03-05 16:45:39'),
(13, 2, 'pending', 'Shipment request created by customer', 0, NULL, NULL, '2026-03-05 17:58:33'),
(14, 1, 'completed', 'Handover confirmed by Agent. Items moved to Hub Inventory.', 18, NULL, NULL, '2026-03-05 18:08:13'),
(15, 3, 'pending', 'Shipment request created by customer', 0, NULL, NULL, '2026-03-07 06:59:51'),
(16, 2, 'accepted', 'Dispatched to Rider: Rider 1', 18, NULL, NULL, '2026-03-07 07:41:27'),
(17, 2, 'rider_on_way', 'Rider marked status as: rider on way', 19, NULL, NULL, '2026-03-07 07:42:20'),
(18, 2, 'arrived', 'Rider marked status as: arrived', 19, NULL, NULL, '2026-03-07 07:43:11'),
(19, 3, 'accepted', 'Dispatched to Rider: Rider 4', 17, NULL, NULL, '2026-03-07 07:44:22'),
(20, 3, 'rider_on_way', 'Rider marked status as: rider on way', 22, NULL, NULL, '2026-03-07 07:44:54'),
(21, 3, 'arrived', 'Rider marked status as: arrived', 22, NULL, NULL, '2026-03-07 07:45:06'),
(22, 3, 'completed', 'Finalized. Settlement: ৳130 via CASH. Mode: commission.', 22, NULL, NULL, '2026-03-07 08:18:56');

-- --------------------------------------------------------

--
-- Table structure for table `platform_earnings`
--

CREATE TABLE `platform_earnings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pickup_id` bigint(20) UNSIGNED NOT NULL,
  `gross_revenue` decimal(12,2) DEFAULT NULL,
  `customer_payout` decimal(12,2) DEFAULT NULL,
  `rider_commission` decimal(10,2) DEFAULT NULL,
  `agent_commission` decimal(10,2) DEFAULT NULL,
  `net_profit` decimal(12,2) GENERATED ALWAYS AS (`gross_revenue` - `customer_payout` - `rider_commission` - `agent_commission`) VIRTUAL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
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
  `preferred_language` enum('en','bn') DEFAULT 'bn',
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `vehicle_type` enum('bicycle','van','motorcycle','truck') NOT NULL,
  `vehicle_number` varchar(50) DEFAULT NULL,
  `national_id` varchar(100) DEFAULT NULL,
  `emergency_contact` varchar(50) DEFAULT NULL,
  `rating_avg` decimal(3,2) DEFAULT 0.00,
  `total_completed` int(10) UNSIGNED DEFAULT 0,
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
  `payment_mode` enum('commission','salary','default') DEFAULT 'default' COMMENT 'commission: per task, salary: monthly fixed, default: follow hub setting'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `riders`
--

INSERT INTO `riders` (`id`, `user_id`, `preferred_language`, `agent_id`, `vehicle_type`, `vehicle_number`, `national_id`, `emergency_contact`, `rating_avg`, `total_completed`, `is_online`, `is_verified`, `profile_status`, `is_active`, `created_at`, `updated_at`, `current_latitude`, `current_longitude`, `status`, `division_id`, `district_id`, `upazila_id`, `base_upazila_id`, `payment_mode`) VALUES
(5, 19, 'bn', 4, 'bicycle', 'Dhaka-203435', NULL, NULL, '0.00', 0, 0, 0, 'pending', 1, '2026-03-05 17:00:36', '2026-03-05 17:00:36', NULL, NULL, 'offline', NULL, NULL, NULL, 0, 'default'),
(6, 20, 'bn', 4, 'bicycle', 'Dhaka-203435', NULL, NULL, '0.00', 0, 0, 0, 'pending', 1, '2026-03-05 17:01:21', '2026-03-05 17:01:21', NULL, NULL, 'offline', NULL, NULL, NULL, 0, 'salary'),
(7, 21, 'bn', 3, 'motorcycle', 'Dhaka-203456', NULL, NULL, '0.00', 0, 0, 0, 'pending', 1, '2026-03-05 17:02:20', '2026-03-05 17:02:20', NULL, NULL, 'offline', NULL, NULL, NULL, 0, 'salary'),
(8, 22, 'bn', 3, 'van', 'Khulna-3045', NULL, NULL, '0.00', 0, 0, 0, 'pending', 1, '2026-03-05 17:03:09', '2026-03-05 19:52:33', NULL, NULL, 'offline', NULL, NULL, NULL, 0, 'commission');

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
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) NOT NULL,
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

INSERT INTO `scrap_categories` (`id`, `name_en`, `name_bn`, `slug`, `description`, `icon`, `display_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Metals', 'ধাতু', 'metals', 'Scrap Metal: Sell Steel, Aluminum, Copper & Iron', '/uploads/category-icons/cat-1772467362887-897006764.png', 0, 1, '2025-12-08 15:54:07', '2026-03-07 00:16:32'),
(2, 'Plastics', 'প্লাস্টিক', 'plastics', 'Plastic Scrap Sell Platform – Mixed Plastics, Acrylic, Nylon, EVA', '/uploads/category-icons/cat-1772467323291-213023767.png', 1, 1, '2025-12-08 15:58:32', '2026-03-07 00:16:45'),
(3, 'Papers', 'কাগজপত্র', 'papers', 'Sell Scrap Paper: OCC, Newsprint, Mixed Paper, and More', '/uploads/category-icons/cat-1772467408911-593373092.png', 2, 1, '2026-03-02 22:03:28', '2026-03-07 00:16:57'),
(4, 'Machinery', 'যন্ত্রপাতি', 'machinery', 'Machinery Sell: Used & Second-Hand Machinery', '/uploads/category-icons/cat-1772467465559-948913515.png', 3, 1, '2026-03-02 22:04:25', '2026-03-07 00:17:11'),
(5, 'Electronics', 'ইলেকট্রনিক্স', 'electronics', 'Electronics Sell: Laptop, Computers, Mobiles, Fan, Fridges & more', '/uploads/category-icons/cat-1772467571778-257101315.png', 4, 1, '2026-03-02 22:06:11', '2026-03-07 00:17:25'),
(6, 'Appliances', 'গ্যাজেট', 'appliances', 'Sell old, broken, or unused appliances like refrigerators, washing machines, dryers, ac & more', '/uploads/category-icons/cat-1772789850229-338850523.png', 5, 1, '2026-03-02 22:07:52', '2026-03-07 00:18:39'),
(7, 'Others', 'অন্যান্য', 'others', 'Selling recyclable scrap is a sustainable way to clear clutter, reduce landfill waste, and generate income', '/uploads/category-icons/cat-1772467734924-895347405.png', 6, 1, '2026-03-02 22:08:54', '2026-03-03 13:22:33');

-- --------------------------------------------------------

--
-- Table structure for table `scrap_items`
--

CREATE TABLE `scrap_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
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
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `scrap_items`
--

INSERT INTO `scrap_items` (`id`, `category_id`, `name_en`, `name_bn`, `slug`, `image_url`, `description`, `unit`, `current_min_rate`, `current_max_rate`, `is_active`, `created_at`, `updated_at`) VALUES
(4, 3, 'Newspapers', 'সংবাদপত্র', 'newspapers', '/uploads/scrap-items/item-1772470023425-246776345.png', 'Price depends on newspaper quality', 'kg', '20.00', '30.00', 1, '2026-03-02 22:40:27', '2026-03-06 22:15:23'),
(5, 1, 'Copper', 'তামা', 'copper', '/uploads/scrap-items/item-1772470085165-999138325.png', 'Price depends on the quality and condition', 'kg', '800.00', '900.00', 1, '2026-03-02 22:48:05', '2026-03-06 22:14:00'),
(6, 5, 'Computer / CPU', 'কম্পিউটার / সিপিইউ', 'computer--cpu', '/uploads/scrap-items/item-1772470135116-747221887.png', 'Price depends on the quality and condition of the products.', 'kg', '120.00', '150.00', 1, '2026-03-02 22:48:55', '2026-03-06 22:13:39'),
(7, 6, 'Washing Machine', 'ওয়াশিং মেশিন', 'washing-machine', '/uploads/scrap-items/item-1772470205632-872173265.png', 'Price depends on the quality and condition of the products.', 'piece', '500.00', '700.00', 1, '2026-03-02 22:50:05', '2026-03-07 00:22:07'),
(8, 7, 'Other house Hold', 'অন্যান্য গৃহস্থালী আসবাবপত্র', 'other-house-hold', '/uploads/scrap-items/item-1772470264783-960194181.png', 'Price depends on the quality and condition of the products.', 'kg', '10.00', '1000.00', 1, '2026-03-02 22:51:04', '2026-03-06 22:15:14'),
(9, 2, 'Mix PLastic', 'প্লাস্টিক', 'mix-plastic', '/uploads/scrap-items/item-1772470297972-729893632.png', 'Price depends on the quality and condition of the products.', 'kg', '50.00', '65.00', 1, '2026-03-02 22:51:37', '2026-03-06 22:16:00'),
(10, 5, 'Ceiling Fan', 'সিলিং ফ্যান', 'ceiling-fan', '/uploads/scrap-items/item-1772470354417-756695218.png', 'Price depends on the quality and condition of the products.', 'kg', '300.00', '500.00', 1, '2026-03-02 22:52:34', '2026-03-06 22:13:27'),
(11, 4, 'Air Conditioner', 'এয়ার কন্ডিশনার', 'air-conditioner', '/uploads/scrap-items/item-1772470434945-820633490.png', 'Price depends on the quality and condition of the products.', 'piece', '600.00', '900.00', 1, '2026-03-02 22:53:54', '2026-03-06 22:13:50');

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
  `changed_by_user_id` bigint(20) UNSIGNED NOT NULL,
  `change_reason` varchar(255) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `scrap_price_history`
--

INSERT INTO `scrap_price_history` (`id`, `scrap_item_id`, `old_min_price`, `old_max_price`, `new_min_price`, `new_max_price`, `changed_by_user_id`, `change_reason`, `changed_at`) VALUES
(3, 7, '600.00', '800.00', '500.00', '700.00', 2, 'Administrative Price Update', '2026-03-06 18:22:07'),
(4, 7, '0.00', '0.00', '450.00', '550.00', 2, 'Regional Price Adjustment', '2026-03-06 18:26:10');

-- --------------------------------------------------------

--
-- Table structure for table `settlements`
--

CREATE TABLE `settlements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `settlement_date` date NOT NULL,
  `total_cash_collected` decimal(12,2) DEFAULT NULL,
  `total_commissions_earned` decimal(12,2) DEFAULT NULL,
  `net_amount_to_admin` decimal(12,2) DEFAULT NULL,
  `status` enum('pending','verified','disputed') DEFAULT 'pending',
  `verified_by_admin_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `upazilas`
--

CREATE TABLE `upazilas` (
  `id` int(11) NOT NULL,
  `district_id` int(11) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_bn` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `upazilas`
--

INSERT INTO `upazilas` (`id`, `district_id`, `name_en`, `name_bn`, `is_active`) VALUES
(93, 1, 'Khulna Sadar', 'খুলনা সদর', 1),
(94, 1, 'Sonadanga', 'সোনাডাঙ্গা', 1),
(95, 1, 'Khalishpur', 'খালিশপুর', 1),
(96, 1, 'Daulatpur', 'দৌলতপুর', 1),
(97, 1, 'Khan Jahan Ali', 'খান জাহান আলী', 1),
(98, 1, 'Dighalia', 'দিঘলিয়া', 1),
(99, 1, 'Dumuria', 'ডুমুরিয়া', 1),
(100, 1, 'Phultala', 'ফুলতলা', 1),
(101, 1, 'Rupsha', 'রূপসা', 1),
(102, 1, 'Terokhada', 'তেরখাদা', 1),
(103, 1, 'Batiaghata', 'বটিয়াঘাটা', 1),
(104, 1, 'Dacope', 'দাকোপ', 1),
(105, 1, 'Paikgachha', 'পাইকগাছা', 1),
(106, 1, 'Koyra', 'কয়রা', 1),
(107, 4, 'Jashore Sadar', 'যশোর সদর', 1),
(108, 4, 'Abhaynagar', 'অভয়নগর', 1),
(109, 4, 'Bagherpara', 'বাঘেরপাড়া', 1),
(110, 4, 'Chaugachha', 'চৌগাছা', 1),
(111, 4, 'Jhikargachha', 'ঝিকরগাছা', 1),
(112, 4, 'Keshabpur', 'কেশবপুর', 1),
(113, 4, 'Manirampur', 'মণিরামপুর', 1),
(114, 4, 'Sharsha', 'শার্শা', 1),
(115, 10, 'Satkhira Sadar', 'সাতক্ষীরা সদর', 1),
(116, 10, 'Assasuni', 'আশাশুনি', 1),
(117, 10, 'Debhata', 'দেবহাটা', 1),
(118, 10, 'Kalaroa', 'কলারোয়া', 1),
(119, 10, 'Kaliganj', 'কালিগঞ্জ', 1),
(120, 10, 'Shyamnagar', 'শ্যামনগর', 1),
(121, 10, 'Tala', 'তালা', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` tinyint(3) UNSIGNED NOT NULL,
  `preferred_language` enum('en','bn') DEFAULT 'bn',
  `full_name` varchar(150) NOT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `agent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `country_code` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role_id`, `preferred_language`, `full_name`, `profile_image`, `email`, `phone`, `password_hash`, `email_verified_at`, `phone_verified_at`, `agent_id`, `country_code`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(2, 1, 'bn', 'Super Admin', NULL, 'admin@example.com', '01700000000', '$2a$10$MjPWUz91gj27yCTezxXQue.uOb/0iQ8e7Eo1RF4QazZ5CaUWvj5IK', '2026-03-04 10:28:48', '2026-03-02 18:00:00', NULL, 'bd', 1, NULL, '2025-12-08 13:05:54', '2026-03-05 16:29:27'),
(17, 2, 'bn', 'Agent 1', NULL, 'agent1@example.com', '01700000222', '$2a$10$LRgMT3rMpZwsCBF3fP7nyeW6m7ac28XdjGN3QLy4I2h4ESyCdfIMS', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 16:57:25', '2026-03-05 16:57:25'),
(18, 2, 'bn', 'Agent 2', NULL, 'agent2@example.com', '01700000333', '$2a$10$8DW.7ciYjppB1UQ0m0eKAOFVTk7.0PJ4I3/dSy.X8z34pfJwu4AIu', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 16:59:15', '2026-03-05 16:59:15'),
(19, 3, 'bn', 'Rider 1', NULL, 'rider1@example.com', '01700000444', '$2a$10$6G8vDtrV3xcxs5JZXDes6.mvmyuZ3cBdBgdrlLp9RB6vQu6TPjiRe', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:00:36', '2026-03-05 17:00:36'),
(20, 3, 'bn', 'Rider 2', NULL, 'rider2@example.com', '01700000555', '$2a$10$mUC2CYlIT6jS8ipYTyuC9ey/r8wW43pNXcq5Pp6yafPurjUayHsoO', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:01:21', '2026-03-05 17:01:21'),
(21, 3, 'bn', 'Rider 3 pro', NULL, 'rider3@example.com', '01700000666', '$2a$10$IiR64pYy4Fb9fRU4TPt2GeLI5T.p8YZcvUdFFKDkoKtQqE0uHflrO', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:02:20', '2026-03-05 19:40:36'),
(22, 3, 'bn', 'Rider 4', NULL, 'rider4@example.com', '01700000777', '$2a$10$FG./0BPa1BEn56GQII5CE.451/DvZaFuP9XrN1ffPZg0mcHag19qW', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:03:09', '2026-03-05 19:52:33'),
(23, 4, 'bn', 'Customer 1', NULL, 'customer1@example.com', '01700000888', '$2a$10$YdsSX0EW.tFtDYk1VTJHU.S4OTi629D5RaPRDtwkUMHJYUfF6AJfu', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:04:34', '2026-03-05 19:36:34'),
(24, 4, 'bn', 'Customer 2', NULL, 'customer2@example.com', '01700000999', '$2a$10$pMISbLcll6xbAfgPYRRe6u5xCmQBkM4Hsv/WFYMnTSnBIwHz7Txxe', NULL, NULL, NULL, NULL, 1, NULL, '2026-03-05 17:05:32', '2026-03-05 19:39:27');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_accounts`
--

CREATE TABLE `wallet_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `pending_balance` decimal(12,2) DEFAULT 0.00,
  `total_withdrawn` decimal(12,2) DEFAULT 0.00,
  `last_transaction_at` timestamp NULL DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'BDT',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `wallet_accounts`
--

INSERT INTO `wallet_accounts` (`id`, `user_id`, `balance`, `pending_balance`, `total_withdrawn`, `last_transaction_at`, `currency`, `is_active`, `created_at`, `updated_at`) VALUES
(7, 17, '13.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 16:57:25', '2026-03-07 14:18:56'),
(8, 18, '235.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 16:59:15', '2026-03-05 22:45:39'),
(9, 19, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:00:36', '2026-03-05 17:00:36'),
(10, 20, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:01:21', '2026-03-05 17:01:21'),
(11, 21, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:02:20', '2026-03-05 17:02:20'),
(12, 22, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:03:09', '2026-03-05 17:03:09'),
(13, 23, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:04:34', '2026-03-05 17:04:34'),
(14, 24, '0.00', '0.00', '0.00', NULL, 'BDT', 1, '2026-03-05 17:05:32', '2026-03-05 17:05:32');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('credit','debit') NOT NULL,
  `source` enum('pickup_commission','referral_bonus','payout_withdrawal','adjustment','refund') NOT NULL,
  `reference_type` enum('pickup','payout_request','user') NOT NULL,
  `reference_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `balance_before` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `description_en` varchar(255) DEFAULT NULL,
  `description_bn` varchar(255) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'completed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `wallet_transactions`
--

INSERT INTO `wallet_transactions` (`id`, `wallet_id`, `type`, `source`, `reference_type`, `reference_id`, `amount`, `balance_before`, `balance_after`, `description_en`, `description_bn`, `metadata`, `status`, `created_at`) VALUES
(1, 8, 'debit', '', 'pickup', 1, '2350.00', '0.00', '0.00', 'Cash collection recorded for GS-96-5631', NULL, NULL, 'completed', '2026-03-05 16:45:39'),
(2, 8, 'credit', 'pickup_commission', 'pickup', 1, '235.00', '0.00', '235.00', 'Hub Commission: GS-96-5631', NULL, NULL, 'completed', '2026-03-05 16:45:39'),
(3, 8, 'credit', '', '', 5, '2350.00', '0.00', '0.00', 'Physical cash handover from Rider ID: 5. Note: Full Settlement', NULL, NULL, 'completed', '2026-03-05 18:08:13'),
(4, 7, 'debit', '', 'pickup', 3, '130.00', '0.00', '0.00', 'Cash collection recorded for GS-96-1889', NULL, NULL, 'completed', '2026-03-07 08:18:56'),
(5, 7, 'credit', 'pickup_commission', 'pickup', 3, '13.00', '0.00', '13.00', 'Hub Commission: GS-96-1889', NULL, NULL, 'completed', '2026-03-07 08:18:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `division_id` (`division_id`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `idx_address_upazila` (`upazila_id`),
  ADD KEY `idx_address_user` (`user_id`);

--
-- Indexes for table `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `fk_agents_owner` (`owner_user_id`),
  ADD KEY `base_division_id` (`base_division_id`),
  ADD KEY `base_district_id` (`base_district_id`);

--
-- Indexes for table `agent_coverage`
--
ALTER TABLE `agent_coverage`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_agent_area` (`agent_id`,`upazila_id`),
  ADD KEY `upazila_id` (`upazila_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `referral_code` (`referral_code`),
  ADD KEY `fk_customer_default_address` (`default_address_id`),
  ADD KEY `idx_customer_referral` (`referral_code`),
  ADD KEY `idx_customer_user` (`user_id`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_device_tokens_user` (`user_id`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `division_id` (`division_id`);

--
-- Indexes for table `divisions`
--
ALTER TABLE `divisions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name_en`);

--
-- Indexes for table `financial_ledger`
--
ALTER TABLE `financial_ledger`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallet_id` (`wallet_id`),
  ADD KEY `transaction_id` (`transaction_id`);

--
-- Indexes for table `hub_inventory`
--
ALTER TABLE `hub_inventory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `agent_category` (`agent_id`,`category_id`),
  ADD KEY `fk_hub_inv_category` (`category_id`);

--
-- Indexes for table `hub_releases`
--
ALTER TABLE `hub_releases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_release_agent_id` (`agent_id`);

--
-- Indexes for table `hub_release_items`
--
ALTER TABLE `hub_release_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ritems_release` (`release_id`),
  ADD KEY `fk_ritems_category` (`category_id`);

--
-- Indexes for table `item_price_overrides`
--
ALTER TABLE `item_price_overrides`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_regional_lookup` (`item_id`,`upazila_id`,`district_id`,`division_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`);

--
-- Indexes for table `payout_requests`
--
ALTER TABLE `payout_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_payout_pending` (`status`,`requested_at`);

--
-- Indexes for table `pickups`
--
ALTER TABLE `pickups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_code` (`booking_code`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `fk_pickups_customer` (`customer_id`),
  ADD KEY `fk_pickups_agent` (`agent_id`),
  ADD KEY `fk_pickups_cancelled_by` (`cancelled_by_user_id`),
  ADD KEY `fk_pickups_address` (`customer_address_id`),
  ADD KEY `division_id` (`division_id`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `idx_pickup_routing` (`upazila_id`,`status`),
  ADD KEY `idx_pickup_status_geo` (`status`,`upazila_id`),
  ADD KEY `idx_pickup_settlement` (`rider_id`,`status`,`is_settled_to_hub`);

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
  ADD KEY `fk_pickup_items_pickup` (`pickup_id`);

--
-- Indexes for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pickup_status_logs_pickup` (`pickup_id`),
  ADD KEY `fk_pickup_status_logs_user` (`changed_by`);

--
-- Indexes for table `pickup_timeline`
--
ALTER TABLE `pickup_timeline`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pickup_id` (`pickup_id`);

--
-- Indexes for table `platform_earnings`
--
ALTER TABLE `platform_earnings`
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `division_id` (`division_id`),
  ADD KEY `district_id` (`district_id`),
  ADD KEY `fk_rider_upazila` (`upazila_id`),
  ADD KEY `idx_rider_dispatch` (`agent_id`,`upazila_id`,`status`);

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
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category_display` (`display_order`,`is_active`);

--
-- Indexes for table `scrap_items`
--
ALTER TABLE `scrap_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_scrap_item_category` (`category_id`,`is_active`);

--
-- Indexes for table `scrap_price_history`
--
ALTER TABLE `scrap_price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_price_history_item` (`scrap_item_id`),
  ADD KEY `fk_price_history_admin` (`changed_by_user_id`);

--
-- Indexes for table `settlements`
--
ALTER TABLE `settlements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agent_id` (`agent_id`);

--
-- Indexes for table `upazilas`
--
ALTER TABLE `upazilas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `district_id` (`district_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `agent_id` (`agent_id`),
  ADD KEY `fk_user_role` (`role_id`);

--
-- Indexes for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_wallet` (`user_id`),
  ADD UNIQUE KEY `uq_wallet_user_currency` (`user_id`,`currency`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_transaction_history` (`wallet_id`,`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `agents`
--
ALTER TABLE `agents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `agent_coverage`
--
ALTER TABLE `agent_coverage`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `divisions`
--
ALTER TABLE `divisions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `financial_ledger`
--
ALTER TABLE `financial_ledger`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `hub_inventory`
--
ALTER TABLE `hub_inventory`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `hub_releases`
--
ALTER TABLE `hub_releases`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `hub_release_items`
--
ALTER TABLE `hub_release_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `item_price_overrides`
--
ALTER TABLE `item_price_overrides`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pickup_area_stats`
--
ALTER TABLE `pickup_area_stats`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pickup_items`
--
ALTER TABLE `pickup_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pickup_timeline`
--
ALTER TABLE `pickup_timeline`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `platform_earnings`
--
ALTER TABLE `platform_earnings`
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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `scrap_items`
--
ALTER TABLE `scrap_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scrap_price_history`
--
ALTER TABLE `scrap_price_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `settlements`
--
ALTER TABLE `settlements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `upazilas`
--
ALTER TABLE `upazilas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  ADD CONSTRAINT `addresses_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  ADD CONSTRAINT `addresses_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`),
  ADD CONSTRAINT `fk_user_address` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `agents`
--
ALTER TABLE `agents`
  ADD CONSTRAINT `agents_ibfk_1` FOREIGN KEY (`base_division_id`) REFERENCES `divisions` (`id`),
  ADD CONSTRAINT `agents_ibfk_2` FOREIGN KEY (`base_district_id`) REFERENCES `districts` (`id`),
  ADD CONSTRAINT `fk_agents_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `agent_coverage`
--
ALTER TABLE `agent_coverage`
  ADD CONSTRAINT `agent_coverage_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `agent_coverage_ibfk_2` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `fk_customer_default_address` FOREIGN KEY (`default_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_customers_default_address` FOREIGN KEY (`default_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_customers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD CONSTRAINT `fk_device_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `districts_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`);

--
-- Constraints for table `financial_ledger`
--
ALTER TABLE `financial_ledger`
  ADD CONSTRAINT `financial_ledger_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`),
  ADD CONSTRAINT `financial_ledger_ibfk_2` FOREIGN KEY (`transaction_id`) REFERENCES `wallet_transactions` (`id`);

--
-- Constraints for table `hub_inventory`
--
ALTER TABLE `hub_inventory`
  ADD CONSTRAINT `fk_hub_inv_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hub_inv_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hub_releases`
--
ALTER TABLE `hub_releases`
  ADD CONSTRAINT `fk_release_agent_id` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hub_release_items`
--
ALTER TABLE `hub_release_items`
  ADD CONSTRAINT `fk_ritems_category` FOREIGN KEY (`category_id`) REFERENCES `scrap_categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ritems_release` FOREIGN KEY (`release_id`) REFERENCES `hub_releases` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `item_price_overrides`
--
ALTER TABLE `item_price_overrides`
  ADD CONSTRAINT `fk_override_to_item` FOREIGN KEY (`item_id`) REFERENCES `scrap_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payout_requests`
--
ALTER TABLE `payout_requests`
  ADD CONSTRAINT `payout_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `payout_requests_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pickups`
--
ALTER TABLE `pickups`
  ADD CONSTRAINT `fk_pickups_address` FOREIGN KEY (`customer_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pickups_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  ADD CONSTRAINT `fk_pickups_cancelled_by` FOREIGN KEY (`cancelled_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_pickups_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `fk_pickups_rider` FOREIGN KEY (`rider_id`) REFERENCES `riders` (`id`),
  ADD CONSTRAINT `pickups_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  ADD CONSTRAINT `pickups_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  ADD CONSTRAINT `pickups_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`);

--
-- Constraints for table `pickup_area_stats`
--
ALTER TABLE `pickup_area_stats`
  ADD CONSTRAINT `fk_pickup_area_stats_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`);

--
-- Constraints for table `pickup_items`
--
ALTER TABLE `pickup_items`
  ADD CONSTRAINT `fk_pickup_items_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`);

--
-- Constraints for table `pickup_status_logs`
--
ALTER TABLE `pickup_status_logs`
  ADD CONSTRAINT `fk_pickup_status_logs_pickup` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`),
  ADD CONSTRAINT `fk_pickup_status_logs_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pickup_timeline`
--
ALTER TABLE `pickup_timeline`
  ADD CONSTRAINT `pickup_timeline_ibfk_1` FOREIGN KEY (`pickup_id`) REFERENCES `pickups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `point_transactions`
--
ALTER TABLE `point_transactions`
  ADD CONSTRAINT `fk_customer_points` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `riders`
--
ALTER TABLE `riders`
  ADD CONSTRAINT `fk_rider_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rider_upazila` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`),
  ADD CONSTRAINT `fk_riders_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  ADD CONSTRAINT `fk_riders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `riders_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`),
  ADD CONSTRAINT `riders_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  ADD CONSTRAINT `riders_ibfk_3` FOREIGN KEY (`upazila_id`) REFERENCES `upazilas` (`id`);

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
  ADD CONSTRAINT `fk_price_history_admin` FOREIGN KEY (`changed_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_price_history_item` FOREIGN KEY (`scrap_item_id`) REFERENCES `scrap_items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `settlements`
--
ALTER TABLE `settlements`
  ADD CONSTRAINT `settlements_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`);

--
-- Constraints for table `upazilas`
--
ALTER TABLE `upazilas`
  ADD CONSTRAINT `upazilas_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_agent` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Constraints for table `wallet_accounts`
--
ALTER TABLE `wallet_accounts`
  ADD CONSTRAINT `fk_wallet_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_accounts` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
