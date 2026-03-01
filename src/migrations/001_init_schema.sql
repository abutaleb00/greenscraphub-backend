-- GreenScrapHub schema (agents, riders under agents, price ranges, extras/discounts)

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(150) NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','customer','agent','rider') NOT NULL DEFAULT 'customer',
  agent_id INT UNSIGNED NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_phone (phone),
  UNIQUE KEY uq_users_email (email),
  INDEX idx_users_role (role),
  INDEX idx_users_agent_id (agent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS agents (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  company_name VARCHAR(150) NULL,
  area_coverage TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_agents_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS riders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  agent_id INT UNSIGNED NOT NULL,
  vehicle_type VARCHAR(50) NULL,
  vehicle_number VARCHAR(50) NULL,
  rating_avg DECIMAL(3,2) DEFAULT 0.00,
  total_completed INT UNSIGNED DEFAULT 0,
  is_online TINYINT(1) DEFAULT 0,
  last_lat DECIMAL(10,7) NULL,
  last_lng DECIMAL(10,7) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_riders_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_riders_agent FOREIGN KEY (agent_id) REFERENCES agents(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  default_address_id INT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_customers_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customer_addresses (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  label VARCHAR(50) NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255) NULL,
  area VARCHAR(100) NULL,
  city VARCHAR(100) NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  is_default TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_custaddr_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Scrap categories and items

CREATE TABLE IF NOT EXISTS scrap_categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(120) NOT NULL,
  description TEXT NULL,
  icon_url VARCHAR(255) NULL,
  sort_order INT DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_scrap_categories_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS scrap_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'kg',
  image_url VARCHAR(255) NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_scrap_items_category FOREIGN KEY (category_id) REFERENCES scrap_categories(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Price ranges per item (min/max price per kg, used for estimation)
CREATE TABLE IF NOT EXISTS scrap_item_price_ranges (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scrap_item_id INT UNSIGNED NOT NULL,
  min_qty_kg DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  max_qty_kg DECIMAL(10,2) NULL,
  min_price_per_kg DECIMAL(10,2) NOT NULL,
  max_price_per_kg DECIMAL(10,2) NOT NULL,
  effective_from DATETIME NULL,
  effective_to DATETIME NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_price_item FOREIGN KEY (scrap_item_id) REFERENCES scrap_items(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pickup orders

CREATE TABLE IF NOT EXISTS pickup_orders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_code VARCHAR(30) NOT NULL,
  customer_id INT UNSIGNED NOT NULL,
  agent_id INT UNSIGNED NULL,
  rider_id INT UNSIGNED NULL,
  status ENUM('pending','assigned','accepted','reached','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending',
  scheduled_at DATETIME NULL,
  time_slot_from TIME NULL,
  time_slot_to TIME NULL,
  customer_address_id INT UNSIGNED NULL,
  address_snapshot TEXT NULL,
  estimated_min_amount DECIMAL(12,2) DEFAULT 0.00,
  estimated_max_amount DECIMAL(12,2) DEFAULT 0.00,
  final_amount DECIMAL(12,2) DEFAULT 0.00,
  extra_charges_amount DECIMAL(12,2) DEFAULT 0.00,
  discount_amount DECIMAL(12,2) DEFAULT 0.00,
  payment_method ENUM('cash','wallet','bkash','nagad','rocket','bank') DEFAULT 'cash',
  payment_status ENUM('pending','paid','failed','refunded') DEFAULT 'pending',
  wallet_credit_amount DECIMAL(12,2) DEFAULT 0.00,
  rider_cash_collected DECIMAL(12,2) DEFAULT 0.00,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_po_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_po_agent FOREIGN KEY (agent_id) REFERENCES agents(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_po_rider FOREIGN KEY (rider_id) REFERENCES riders(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_po_address FOREIGN KEY (customer_address_id) REFERENCES customer_addresses(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pickup_order_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pickup_order_id INT UNSIGNED NOT NULL,
  scrap_item_id INT UNSIGNED NOT NULL,
  estimated_weight_kg DECIMAL(10,2) DEFAULT 0.00,
  estimated_min_price_per_kg DECIMAL(10,2) DEFAULT 0.00,
  estimated_max_price_per_kg DECIMAL(10,2) DEFAULT 0.00,
  final_weight_kg DECIMAL(10,2) DEFAULT 0.00,
  final_price_per_kg DECIMAL(10,2) DEFAULT 0.00,
  extra_charge DECIMAL(10,2) DEFAULT 0.00,
  discount DECIMAL(10,2) DEFAULT 0.00,
  estimated_min_total DECIMAL(12,2) DEFAULT 0.00,
  estimated_max_total DECIMAL(12,2) DEFAULT 0.00,
  final_total DECIMAL(12,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_poi_order FOREIGN KEY (pickup_order_id) REFERENCES pickup_orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_poi_item FOREIGN KEY (scrap_item_id) REFERENCES scrap_items(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customer wallet & payouts

CREATE TABLE IF NOT EXISTS customer_wallet_transactions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  pickup_order_id INT UNSIGNED NULL,
  type ENUM('credit','debit') NOT NULL,
  source ENUM('scrap_sale','withdrawal','adjustment') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  balance_after DECIMAL(12,2) NOT NULL,
  status ENUM('pending','completed','failed') NOT NULL DEFAULT 'completed',
  meta JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_wallet_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_wallet_order FOREIGN KEY (pickup_order_id) REFERENCES pickup_orders(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payout_requests (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  method ENUM('bkash','nagad','rocket','bank','cash') NOT NULL,
  account_details JSON NOT NULL,
  status ENUM('pending','approved','paid','rejected') NOT NULL DEFAULT 'pending',
  processed_by_admin_id INT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_payout_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_payout_admin FOREIGN KEY (processed_by_admin_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Simple admin seed (default admin user) - optional, adjust password hash manually if needed.
