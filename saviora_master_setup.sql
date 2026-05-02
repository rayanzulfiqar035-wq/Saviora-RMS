-- ============================================================
-- SAVIORA RESTAURANT MANAGEMENT SYSTEM — MASTER SETUP SCRIPT
-- ============================================================
-- This script creates the database, schema, and initial data.
-- Rebranded: Saviora RMS
-- ============================================================

CREATE DATABASE IF NOT EXISTS Restaurant_db;
USE Restaurant_db;

-- ==========================================
-- 1. REFERENCE TABLES (Parents)
-- ==========================================

CREATE TABLE IF NOT EXISTS Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ROLE (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    permissions_description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS REWARD_TIER (
    tier_id INT PRIMARY KEY AUTO_INCREMENT,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    min_points_required INT NOT NULL,
    discount_per_point DECIMAL(5,2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS INGREDIENT_CATALOG (
    ingredient_id INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100) UNIQUE NOT NULL,
    measurement_unit VARCHAR(20) NOT NULL,
    global_min_threshold DECIMAL(10,2) NOT NULL,
    substitution_category VARCHAR(50),
    add_on_price DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS SUPPLIER (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS CAMPAIGN (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_name VARCHAR(100) NOT NULL,
    point_multiplier DECIMAL(3,2) NOT NULL,
    end_date DATE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS MENU_ITEM (
    menu_item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) UNIQUE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    rating INT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5)
) ENGINE=InnoDB;

-- ==========================================
-- 2. ENTITY TABLES
-- ==========================================

CREATE TABLE IF NOT EXISTS STAFF (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    role_id INT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS CUSTOMER (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    tier_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    total_points INT DEFAULT 0,
    FOREIGN KEY (tier_id) REFERENCES REWARD_TIER(tier_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS DINING_TABLE (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    table_number INT NOT NULL,
    seating_capacity INT NOT NULL,
    table_state VARCHAR(20) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS FURNITURE (
    furniture_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ENGINE=InnoDB;

-- ==========================================
-- 3. JUNCTION & TRANSACTION TABLES
-- ==========================================

CREATE TABLE IF NOT EXISTS BRANCH_INVENTORY (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT UNIQUE NOT NULL,
    manager_notes TEXT,
    last_updated DATETIME,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS INVENTORY_ITEM (
    inventory_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    supplier_id INT NOT NULL,
    quantity_on_hand DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (inventory_id, ingredient_id),
    FOREIGN KEY (inventory_id) REFERENCES BRANCH_INVENTORY(inventory_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS RECIPE (
    recipe_id INT PRIMARY KEY AUTO_INCREMENT,
    menu_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    default_quantity DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS RESERVATION (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (table_id) REFERENCES DINING_TABLE(table_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `ORDER` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    table_id INT NOT NULL,
    staff_id INT NOT NULL,
    branch_id INT NOT NULL,
    campaign_id INT,
    order_timestamp DATETIME NOT NULL,
    order_state VARCHAR(20) NOT NULL,
    order_type ENUM('Dine-In', 'Takeaway', 'Delivery') NOT NULL DEFAULT 'Dine-In',
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (table_id) REFERENCES DINING_TABLE(table_id),
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (campaign_id) REFERENCES CAMPAIGN(campaign_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ORDER_ITEM (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `ORDER`(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS MENU_INGREDIENT_SUBSTITUTION (
    substitution_id INT PRIMARY KEY AUTO_INCREMENT,
    menu_item_id INT NOT NULL,
    original_ingredient_id INT NOT NULL,
    replacement_ingredient_id INT NOT NULL,
    extra_cost DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id),
    FOREIGN KEY (original_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (replacement_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ORDER_ITEM_MODIFICATION (
    modification_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    removed_ingredient_id INT NULL,
    added_ingredient_id INT NULL,
    mod_quantity INT DEFAULT 1,
    extra_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES ORDER_ITEM(order_item_id),
    FOREIGN KEY (removed_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (added_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS PAYMENT (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    subtotal_amount DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) DEFAULT 0.00,
    final_amount DECIMAL(10,2) NOT NULL,
    payment_timestamp DATETIME NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `ORDER`(order_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
) ENGINE=InnoDB;

-- ==========================================
-- 4. INDEXES
-- ==========================================

CREATE INDEX idx_inv_lookup       ON INVENTORY_ITEM(inventory_id, ingredient_id);
CREATE INDEX idx_low_stock_search ON INVENTORY_ITEM(quantity_on_hand);
CREATE INDEX idx_report_lookup    ON `ORDER`(branch_id, order_timestamp);
CREATE INDEX idx_res_table_lookup ON RESERVATION(table_id, reservation_date);

-- ==========================================
-- 5. VIEW
-- ==========================================

CREATE OR REPLACE VIEW vw_waiter_active_orders AS
SELECT 
    o.order_id,
    o.table_id,
    dt.table_number,
    o.staff_id,
    o.branch_id,
    o.order_timestamp,
    o.order_state,
    o.order_type
FROM `ORDER` o
JOIN DINING_TABLE dt ON o.table_id = dt.table_id
WHERE o.order_state IN ('Pending', 'In Progress', 'Ready');

-- ==========================================
-- 6. FUNCTIONS
-- ==========================================

DELIMITER //

-- Get Order Count for a specific branch and date
CREATE FUNCTION GetBranchOrderCount(p_branch_id INT, p_date DATE) 
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM `ORDER`
    WHERE branch_id = p_branch_id AND DATE(order_timestamp) = p_date;
    RETURN v_count;
END //

-- Get Revenue for a specific branch and date
CREATE FUNCTION GetBranchRevenue(p_branch_id INT, p_date DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_rev DECIMAL(10,2);
    SELECT COALESCE(SUM(p.final_amount), 0.0) INTO v_rev
    FROM PAYMENT p
    INNER JOIN `ORDER` o ON p.order_id = o.order_id
    WHERE o.branch_id = p_branch_id AND DATE(p.payment_timestamp) = p_date;
    RETURN v_rev;
END //

-- Get Average Order Value for a specific branch and date
CREATE FUNCTION GetBranchAvgOrderValue(p_branch_id INT, p_date DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(10,2);
    SELECT COALESCE(AVG(p.final_amount), 0.0) INTO v_avg
    FROM PAYMENT p
    INNER JOIN `ORDER` o ON p.order_id = o.order_id
    WHERE o.branch_id = p_branch_id AND DATE(p.payment_timestamp) = p_date;
    RETURN v_avg;
END //

-- Get Today's Order Count for a specific branch (Simplified)
CREATE FUNCTION GetTodayOrderCount(p_branch_id INT) 
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE order_count INT;
    SELECT COUNT(*) INTO order_count
    FROM `ORDER`
    WHERE branch_id = p_branch_id 
      AND DATE(order_timestamp) = CURDATE();
    RETURN order_count;
END //

-- Get count of low-stock items for a branch
CREATE FUNCTION GetBranchLowStockCount(p_branch_id INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM INVENTORY_ITEM ii
    JOIN BRANCH_INVENTORY bi ON ii.inventory_id = bi.inventory_id
    JOIN INGREDIENT_CATALOG ic ON ii.ingredient_id = ic.ingredient_id
    WHERE bi.branch_id = p_branch_id
      AND ii.quantity_on_hand <= ic.global_min_threshold;
    RETURN v_count;
END //

DELIMITER ;

-- ==========================================
-- 7. PROCEDURES
-- ==========================================

DELIMITER //

CREATE PROCEDURE CompleteOrderAndDeductStock(IN p_order_id INT)
BEGIN
    UPDATE INVENTORY_ITEM ii
    INNER JOIN BRANCH_INVENTORY bi ON ii.inventory_id = bi.inventory_id
    INNER JOIN `ORDER` o ON bi.branch_id = o.branch_id
    INNER JOIN ORDER_ITEM oi ON o.order_id = oi.order_id
    INNER JOIN RECIPE r ON oi.menu_item_id = r.menu_item_id
    SET ii.quantity_on_hand = ii.quantity_on_hand - (r.default_quantity * oi.quantity)
    WHERE o.order_id = p_order_id AND ii.ingredient_id = r.ingredient_id;

    UPDATE DINING_TABLE dt
    INNER JOIN `ORDER` o ON dt.table_id = o.table_id
    SET dt.table_state = 'Available'
    WHERE o.order_id = p_order_id AND dt.table_state != 'Virtual';

    UPDATE `ORDER` SET order_state = 'Completed' WHERE order_id = p_order_id;
END //

CREATE PROCEDURE GenerateLowStockAlert(IN p_branch_id INT)
BEGIN
    SELECT ic.ingredient_name, ii.quantity_on_hand, s.supplier_name
    FROM INVENTORY_ITEM ii
    JOIN BRANCH_INVENTORY bi ON ii.inventory_id = bi.inventory_id
    JOIN INGREDIENT_CATALOG ic ON ii.ingredient_id = ic.ingredient_id
    JOIN SUPPLIER s ON ii.supplier_id = s.supplier_id
    WHERE bi.branch_id = p_branch_id AND ii.quantity_on_hand <= ic.global_min_threshold;
END //

DELIMITER ;

-- ==========================================
-- 8. TRIGGERS
-- ==========================================

DELIMITER //

CREATE TRIGGER trg_after_order_item_insert
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE `ORDER` SET subtotal = subtotal + (NEW.quantity * NEW.unit_price) WHERE order_id = NEW.order_id;
END //

CREATE TRIGGER trg_after_mod_insert
AFTER INSERT ON ORDER_ITEM_MODIFICATION
FOR EACH ROW
BEGIN
    UPDATE `ORDER` o
    JOIN ORDER_ITEM oi ON o.order_id = oi.order_id
    SET o.subtotal = o.subtotal + NEW.extra_cost
    WHERE oi.order_item_id = NEW.order_item_id;
END //

CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    UPDATE CUSTOMER SET total_points = total_points + FLOOR(NEW.final_amount / 10) WHERE customer_id = NEW.customer_id;
END //

CREATE TRIGGER trg_before_customer_update
BEFORE UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
    DECLARE new_tier_id INT;
    IF NEW.total_points != OLD.total_points THEN
        SELECT tier_id INTO new_tier_id FROM REWARD_TIER WHERE min_points_required <= NEW.total_points ORDER BY min_points_required DESC LIMIT 1;
        SET NEW.tier_id = new_tier_id;
    END IF;
END //

DELIMITER ;

-- ==========================================
-- 9. INITIAL SEED DATA
-- ==========================================

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE ORDER_ITEM_MODIFICATION;
TRUNCATE TABLE ORDER_ITEM;
TRUNCATE TABLE `ORDER`;
TRUNCATE TABLE PAYMENT;
TRUNCATE TABLE RESERVATION;
TRUNCATE TABLE INVENTORY_ITEM;
TRUNCATE TABLE BRANCH_INVENTORY;
TRUNCATE TABLE RECIPE;
TRUNCATE TABLE STAFF;
TRUNCATE TABLE DINING_TABLE;
TRUNCATE TABLE FURNITURE;
TRUNCATE TABLE Branch;
TRUNCATE TABLE MENU_ITEM;
TRUNCATE TABLE INGREDIENT_CATALOG;
TRUNCATE TABLE SUPPLIER;
TRUNCATE TABLE CAMPAIGN;
TRUNCATE TABLE CUSTOMER;
TRUNCATE TABLE ROLE;
TRUNCATE TABLE REWARD_TIER;
SET FOREIGN_KEY_CHECKS = 1;

-- 9.1 Role & Reward Tiers
INSERT INTO ROLE VALUES (1, 'Admin', 'Full system access'), (2, 'Manager', 'Branch management'), (3, 'Waiter', 'Order entry'), (4, 'Chef', 'Kitchen display'), (5, 'Cashier', 'Payment');
INSERT INTO REWARD_TIER VALUES (1, 'Starter', 0, 0.00), (2, 'Silver', 500, 0.05), (3, 'Gold', 1500, 0.10);

-- 9.2 Branches (Saviora)
INSERT INTO Branch VALUES (1, 'Saviora Lahore', 'Gulberg III', '042-35550101'), (2, 'Saviora Karachi', 'Clifton Block 5', '021-35550102'), (3, 'Saviora Islamabad', 'F-7 Markaz', '051-35550103'), (4, 'Saviora Peshawar', 'University Rd', '091-35550104');

-- 9.3 Staff (Sample)
INSERT INTO STAFF VALUES (1, 1, 1, 'admin1_b1', 'password', 'Ali'), (2, 1, 1, 'admin2_b1', 'password', 'Sara'), (3, 1, 3, 'waiter1_b1', 'password', 'W1');

-- 9.4 Ingredients & Menu
INSERT INTO INGREDIENT_CATALOG VALUES (1, 'Mutton', 'kg', 20, 'Proteins', 1500.00), (2, 'Chicken', 'kg', 30, 'Proteins', 600.00), (3, 'Basmati Rice', 'kg', 50, 'Grains', 350.00), (4, 'Yogurt', 'kg', 10, 'Dairy', 180.00), (5, 'Ghee', 'kg', 5, 'Fats', 600.00), (6, 'Masala Mix', 'kg', 5, 'Spices', 200.00), (7, 'Naan Dough', 'pcs', 100, 'Bread', 20.00);
INSERT INTO MENU_ITEM VALUES (1, 'Mutton Karahi', 1800.00, 0), (2, 'Chicken Biryani', 450.00, 0), (3, 'Seekh Kabab (4 pcs)', 600.00, 0), (4, 'Roghn Naan', 60.00, 0);

-- 9.5 Ingredient Substitution Rules (Granular)
INSERT INTO MENU_INGREDIENT_SUBSTITUTION (menu_item_id, original_ingredient_id, replacement_ingredient_id, extra_cost) VALUES 
(1, 1, 2, 0.00),   -- Karahi: Mutton to Chicken (Free)
(2, 2, 1, 150.00); -- Biryani: Chicken to Mutton (+150)

-- 9.6 Inventory & Recipes
INSERT INTO BRANCH_INVENTORY VALUES (1, 1, 'Fresh Stock', NOW());
INSERT INTO INVENTORY_ITEM VALUES (1, 1, 1, 50), (1, 2, 1, 100);
INSERT INTO SUPPLIER VALUES (1, 'Punjab Meats', 'Aslam', '0321-1234567');
INSERT INTO RECIPE VALUES (1, 1, 1, 0.5), (5, 2, 2, 0.25);

-- 9.7 Sample Customer
INSERT INTO CUSTOMER VALUES (1, 1, 'Ahmed Khan', '03001234567', 150);

-- ============================================================
-- SETUP COMPLETE
-- ============================================================
