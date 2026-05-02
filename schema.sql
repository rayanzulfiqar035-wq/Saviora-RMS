CREATE DATABASE IF NOT EXISTS Restaurant_db;
USE Restaurant_db;

-- ==========================================
-- 1. REFERENCE TABLES (Parents)
-- ==========================================

CREATE TABLE Branch (
    branch_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20)
);

CREATE TABLE ROLE (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    permissions_description TEXT
);

CREATE TABLE REWARD_TIER (
    tier_id INT PRIMARY KEY,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    min_points_required INT NOT NULL,
    discount_per_point DECIMAL(5,2) NOT NULL
);

CREATE TABLE INGREDIENT_CATALOG (
    ingredient_id INT PRIMARY KEY,
    ingredient_name VARCHAR(100) UNIQUE NOT NULL,
    measurement_unit VARCHAR(20) NOT NULL,
    global_min_threshold DECIMAL(10,2) NOT NULL,
    substitution_category VARCHAR(50),
    add_on_price DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE SUPPLIER (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE CAMPAIGN (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    point_multiplier DECIMAL(3,2) NOT NULL,
    end_date DATE
);

CREATE TABLE MENU_ITEM (
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(100) UNIQUE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    rating INT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5)
);

-- ==========================================
-- 2. ENTITY TABLES
-- ==========================================

CREATE TABLE STAFF (
    staff_id INT PRIMARY KEY,
    branch_id INT NOT NULL,
    role_id INT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id)
);

CREATE TABLE CUSTOMER (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    tier_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    total_points INT DEFAULT 0,
    FOREIGN KEY (tier_id) REFERENCES REWARD_TIER(tier_id)
);

CREATE TABLE DINING_TABLE (
    table_id INT PRIMARY KEY,
    branch_id INT NOT NULL,
    table_number INT NOT NULL,
    seating_capacity INT NOT NULL,
    table_state VARCHAR(20) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

CREATE TABLE FURNITURE (
    furniture_id INT PRIMARY KEY,
    branch_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

-- ==========================================
-- 3. JUNCTION & TRANSACTION TABLES
-- ==========================================

CREATE TABLE BRANCH_INVENTORY (
    inventory_id INT PRIMARY KEY,
    branch_id INT UNIQUE NOT NULL,
    manager_notes TEXT,
    last_updated DATETIME,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

CREATE TABLE INVENTORY_ITEM (
    inventory_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    supplier_id INT NOT NULL,
    quantity_on_hand DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (inventory_id, ingredient_id),
    FOREIGN KEY (inventory_id) REFERENCES BRANCH_INVENTORY(inventory_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id)
);

CREATE TABLE RECIPE (
    recipe_id INT PRIMARY KEY,
    menu_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    default_quantity DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id),
    FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
);

CREATE TABLE RESERVATION (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (table_id) REFERENCES DINING_TABLE(table_id)
);

CREATE TABLE `ORDER` (
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
);

CREATE TABLE ORDER_ITEM (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `ORDER`(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id)
);

CREATE TABLE ORDER_ITEM_MODIFICATION (
    modification_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    removed_ingredient_id INT NULL,
    added_ingredient_id INT NULL,
    mod_quantity INT DEFAULT 1,
    extra_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES ORDER_ITEM(order_item_id),
    FOREIGN KEY (removed_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id),
    FOREIGN KEY (added_ingredient_id) REFERENCES INGREDIENT_CATALOG(ingredient_id)
);

CREATE TABLE PAYMENT (
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
);

-- ==========================================
-- 4. ANALYTIC FUNCTIONS
-- ==========================================

DROP FUNCTION IF EXISTS GetBranchOrderCount;
DELIMITER //
CREATE FUNCTION GetBranchOrderCount(p_branch_id INT, p_date DATE) 
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM `ORDER`
    WHERE branch_id = p_branch_id AND DATE(order_timestamp) = p_date;
    RETURN v_count;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetBranchRevenue;
DELIMITER //
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
DELIMITER ;

DROP FUNCTION IF EXISTS GetBranchAvgOrderValue;
DELIMITER //
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
DELIMITER ;
