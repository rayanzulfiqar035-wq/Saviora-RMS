-- ============================================================
-- SAVIORA RESTAURANT MANAGEMENT SYSTEM — MASTER SETUP SCRIPT
-- ============================================================
-- This script creates the database, schema, and initial data.
-- Rebranded: Saviora RMS
-- ============================================================

CREATE DATABASE IF NOT EXISTS restaurant_db;
USE restaurant_db;

-- ==========================================
-- 1. REFERENCE TABLES (Parents)
-- ==========================================

CREATE TABLE  Branch (
    branch_id INT PRIMARY KEY auto_increment,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20)
) ;

CREATE TABLE  ROLE (
    role_id INT PRIMARY KEY auto_increment,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    permissions_description TEXT
) ;

CREATE TABLE  REWARD_TIER (
    tier_id INT PRIMARY KEY auto_increment,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    min_points_required INT NOT NULL,
    discount_per_point DECIMAL(5,2) NOT NULL
) ;

CREATE TABLE  INGREDIENT_CATALOG (
    ingredient_id INT PRIMARY KEY auto_increment,
    ingredient_name VARCHAR(100) UNIQUE NOT NULL,
    measurement_unit VARCHAR(20) NOT NULL,
    global_min_threshold DECIMAL(10,2) NOT NULL,
    substitution_category VARCHAR(50),
    add_on_price DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ;

CREATE TABLE  SUPPLIER (
    supplier_id INT PRIMARY KEY auto_increment,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20) UNIQUE
) ;

CREATE TABLE  CAMPAIGN (
    campaign_id INT PRIMARY KEY auto_increment,
    campaign_name VARCHAR(100) NOT NULL,
    point_multiplier DECIMAL(3,2) NOT NULL,
    end_date DATE
) ;

CREATE TABLE  MENU_ITEM (
    menu_item_id INT PRIMARY KEY auto_increment,
    item_name VARCHAR(100) UNIQUE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    rating INT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5)
) ;

-- ==========================================
-- 2. ENTITY TABLES
-- ==========================================

CREATE TABLE  STAFF (
    staff_id INT PRIMARY KEY auto_increment,
    branch_id INT NOT NULL,
    role_id INT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id)
) ;

CREATE TABLE  CUSTOMER (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    tier_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    total_points INT DEFAULT 0,
    FOREIGN KEY (tier_id) REFERENCES REWARD_TIER(tier_id)
) ;

CREATE TABLE  DINING_TABLE (
    table_id INT PRIMARY KEY auto_increment,
    branch_id INT NOT NULL,
    table_number INT NOT NULL,
    seating_capacity INT NOT NULL,
    table_state VARCHAR(20) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ;

CREATE TABLE  FURNITURE (
    furniture_id INT PRIMARY KEY auto_increment,
    branch_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ;

-- ==========================================
-- 3. JUNCTION & TRANSACTION TABLES
-- ==========================================

CREATE TABLE  BRANCH_INVENTORY (
    inventory_id INT PRIMARY KEY auto_increment,
    branch_id INT UNIQUE NOT NULL,
    manager_notes TEXT,
    last_updated DATETIME,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
) ;

CREATE TABLE  INVENTORY_ITEM (
    inventory_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    supplier_id INT NOT NULL,
    quantity_on_hand DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (inventory_id, ingredient_id),
    FOREIGN KEY (inventory_id) REFERENCES BRANCH_INVENTORY(inventory_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id)
) ;

CREATE TABLE  RECIPE (
    recipe_id INT PRIMARY KEY auto_increment,
    menu_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    default_quantity DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ;

CREATE TABLE  RESERVATION (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (table_id) REFERENCES DINING_TABLE(table_id)
) ;

CREATE TABLE  `ORDER` (
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
) ;

CREATE TABLE  ORDER_ITEM (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `ORDER`(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id)
) ;

CREATE TABLE MENU_INGREDIENT_SUBSTITUTION (
    substitution_id INT PRIMARY KEY AUTO_INCREMENT,
    menu_item_id INT NOT NULL,
    original_ingredient_id INT NOT NULL,
    replacement_ingredient_id INT NOT NULL,
    extra_cost DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id),
    FOREIGN KEY (original_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (replacement_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ;

CREATE TABLE  ORDER_ITEM_MODIFICATION (
    modification_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    removed_ingredient_id INT NULL,
    added_ingredient_id INT NULL,
    mod_quantity INT DEFAULT 1,
    extra_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES ORDER_ITEM(order_item_id),
    FOREIGN KEY (removed_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (added_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
) ;

CREATE TABLE  PAYMENT (
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
) ;

-- ==========================================
-- 4. INDEXES
-- ==========================================

CREATE INDEX idx_inv_lookup 
 ON INVENTORY_ITEM(inventory_id, ingredient_id);
 
CREATE INDEX idx_low_stock_search
 ON INVENTORY_ITEM(quantity_on_hand);
 
CREATE INDEX idx_report_lookup  
 ON `ORDER`(branch_id, order_timestamp);
 
CREATE INDEX idx_res_table_lookup
 ON RESERVATION(table_id, reservation_date);

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
