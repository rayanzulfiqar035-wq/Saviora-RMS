-- ==========================================
-- COMPLETE SEED DATA (PAKISTANI CUISINE)
-- ==========================================

USE Restaurant_db;

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

-- 1. ROLE
INSERT INTO ROLE (role_id, role_name, permissions_description) VALUES 
(1, 'Admin', 'Full system access'), (2, 'Manager', 'Branch management'),
(3, 'Waiter', 'Order entry'), (4, 'Chef', 'Kitchen display'), (5, 'Cashier', 'Payment');

-- 2. REWARD_TIER
INSERT INTO REWARD_TIER (tier_id, tier_name, min_points_required, discount_per_point) VALUES 
(1, 'Starter', 0, 0.00), (2, 'Silver', 500, 0.05), (3, 'Gold', 1500, 0.10);

-- 3. Branch
INSERT INTO Branch (branch_id, name, location, phone_number) VALUES 
(1, 'Saviora Lahore', 'Gulberg III', '042-35550101'), (2, 'Saviora Karachi', 'Clifton Block 5', '021-35550102'),
(3, 'Saviora Islamabad', 'F-7 Markaz', '051-35550103'), (4, 'Saviora Peshawar', 'University Rd', '091-35550104');

-- 4. STAFF
-- Branch 1 (IDs 1-12)
INSERT INTO STAFF (staff_id, branch_id, role_id, username, password_hash, first_name) VALUES 
(1, 1, 1, 'admin1_b1', 'password', 'Ali'), (2, 1, 1, 'admin2_b1', 'password', 'Bob'),
(3, 1, 3, 'waiter1_b1', 'password', 'W1'), (4, 1, 3, 'waiter2_b1', 'password', 'W2'), (5, 1, 3, 'waiter3_b1', 'password', 'W3'),
(6, 1, 3, 'waiter4_b1', 'password', 'W4'), (7, 1, 3, 'waiter5_b1', 'password', 'W5'), (8, 1, 3, 'waiter6_b1', 'password', 'W6'),
(9, 1, 3, 'waiter7_b1', 'password', 'W7'), (10, 1, 3, 'waiter8_b1', 'password', 'W8'), (11, 1, 3, 'waiter9_b1', 'password', 'W9'), (12, 1, 3, 'waiter10_b1', 'password', 'W10');

-- Branch 2 (IDs 13-24)
INSERT INTO STAFF (staff_id, branch_id, role_id, username, password_hash, first_name) VALUES 
(13, 2, 1, 'admin1_b2', 'password', 'Umer'), (14, 2, 1, 'admin2_b2', 'password', 'Zainab'),
(15, 2, 3, 'waiter1_b2', 'password', 'W1'), (16, 2, 3, 'waiter2_b2', 'password', 'W2'), (17, 2, 3, 'waiter3_b2', 'password', 'W3'), (18, 2, 3, 'waiter4_b2', 'password', 'W4'), (19, 2, 3, 'waiter5_b2', 'password', 'W5'), (20, 2, 3, 'waiter6_b2', 'password', 'W6'), (21, 2, 3, 'waiter7_b2', 'password', 'W7'), (22, 2, 3, 'waiter8_b2', 'password', 'W8'), (23, 2, 3, 'waiter9_b2', 'password', 'W9'), (24, 2, 3, 'waiter10_b2', 'password', 'W10');

-- Branch 3 (IDs 25-36)
INSERT INTO STAFF (staff_id, branch_id, role_id, username, password_hash, first_name) VALUES 
(25, 3, 1, 'admin1_b3', 'password', 'Hamza'), (26, 3, 1, 'admin2_b3', 'password', 'Fatima'),
(27, 3, 3, 'waiter1_b3', 'password', 'W1'), (28, 3, 3, 'waiter2_b3', 'password', 'W2'), (29, 3, 3, 'waiter3_b3', 'password', 'W3'), (30, 3, 3, 'waiter4_b3', 'password', 'W4'), (31, 3, 3, 'waiter5_b3', 'password', 'W5'), (32, 3, 3, 'waiter6_b3', 'password', 'W6'), (33, 3, 3, 'waiter7_b3', 'password', 'W7'), (34, 3, 3, 'waiter8_b3', 'password', 'W8'), (35, 3, 3, 'waiter9_b3', 'password', 'W9'), (36, 3, 3, 'waiter10_b3', 'password', 'W10');

-- Branch 4 (IDs 37-48)
INSERT INTO STAFF (staff_id, branch_id, role_id, username, password_hash, first_name) VALUES 
(37, 4, 1, 'admin1_b4', 'password', 'Bilal'), (38, 4, 1, 'admin2_b4', 'password', 'Ayesha'),
(39, 4, 3, 'waiter1_b4', 'password', 'W1'), (40, 4, 3, 'waiter2_b4', 'password', 'W2'), (41, 4, 3, 'waiter3_b4', 'password', 'W3'), (42, 4, 3, 'waiter4_b4', 'password', 'W4'), (43, 4, 3, 'waiter5_b4', 'password', 'W5'), (44, 4, 3, 'waiter6_b4', 'password', 'W6'), (45, 4, 3, 'waiter7_b4', 'password', 'W7'), (46, 4, 3, 'waiter8_b4', 'password', 'W8'), (47, 4, 3, 'waiter9_b4', 'password', 'W9'), (48, 4, 3, 'waiter10_b4', 'password', 'W10');

-- 5. DINING_TABLE
INSERT INTO DINING_TABLE (table_id, branch_id, table_number, seating_capacity, table_state) VALUES 
(1, 1, 1, 4, 'Available'), (2, 1, 2, 2, 'Available'), (3, 1, 3, 6, 'Available'), (4, 1, 4, 8, 'Available'), (5, 1, 0, 0, 'Virtual'),
(6, 2, 1, 4, 'Available'), (7, 2, 2, 2, 'Available'), (8, 2, 3, 6, 'Available'), (9, 2, 4, 8, 'Available'), (10, 2, 0, 0, 'Virtual'),
(11, 3, 1, 4, 'Available'), (12, 3, 2, 2, 'Available'), (13, 3, 3, 6, 'Available'), (14, 3, 4, 8, 'Available'), (15, 3, 0, 0, 'Virtual'),
(16, 4, 1, 4, 'Available'), (17, 4, 2, 2, 'Available'), (18, 4, 3, 6, 'Available'), (19, 4, 4, 8, 'Available'), (20, 4, 0, 0, 'Virtual');

-- 6. FURNITURE (Explicit IDs 1-6)
INSERT INTO FURNITURE (furniture_id, branch_id, type) VALUES 
(1, 1, 'Takht'), (2, 1, 'Charpai'), (3, 2, 'Round Table'), (4, 3, 'Modern Table'), (5, 4, 'Traditional Seating'), (6, 1, 'Table');

-- 7. INGREDIENT_CATALOG
INSERT INTO INGREDIENT_CATALOG (ingredient_id, ingredient_name, measurement_unit, global_min_threshold, substitution_category, add_on_price) VALUES 
(1, 'Mutton', 'kg', 20, 'Proteins', 1500.00),
(2, 'Chicken', 'kg', 30, 'Proteins', 600.00),
(3, 'Basmati Rice', 'kg', 50, 'Grains', 350.00),
(4, 'Yogurt', 'kg', 10, 'Dairy', 180.00),
(5, 'Ghee', 'kg', 5, 'Fats', 600.00),
(6, 'Masala Mix', 'kg', 5, 'Spices', 200.00),
(7, 'Naan Dough', 'pcs', 100, 'Bread', 20.00);

-- 8. SUPPLIER
INSERT INTO SUPPLIER (supplier_id, supplier_name, contact_name, phone) VALUES 
(1, 'Punjab Meats', 'Aslam', '0321-1234567'), (2, 'Super Grains', 'Rizwan', '0333-7654321');

-- 9. BRANCH_INVENTORY
INSERT INTO BRANCH_INVENTORY (inventory_id, branch_id, manager_notes) VALUES 
(1, 1, 'Fresh Stock'), (2, 2, 'Fresh Stock'), (3, 3, 'Fresh Stock'), (4, 4, 'Fresh Stock');

-- 10. INVENTORY_ITEM (Explicit IDs not required as primary key is (inventory_id, ingredient_id))
INSERT INTO INVENTORY_ITEM (inventory_id, ingredient_id, supplier_id, quantity_on_hand) VALUES 
(1, 1, 1, 50), (1, 2, 1, 100), (1, 3, 2, 200), (1, 7, 2, 500),
(2, 1, 1, 40), (3, 2, 1, 60);

-- 11. MENU_ITEM
INSERT INTO MENU_ITEM (menu_item_id, item_name, base_price) VALUES 
(1, 'Mutton Karahi', 1800.00),
(2, 'Chicken Biryani', 450.00),
(3, 'Seekh Kabab (4 pcs)', 600.00),
(4, 'Roghn Naan', 60.00);

-- 12. RECIPE
INSERT INTO RECIPE (recipe_id, menu_item_id, ingredient_id, default_quantity) VALUES 
(1, 1, 1, 0.5), (2, 1, 5, 0.1), (3, 1, 6, 0.05), (4, 1, 4, 0.1),
(5, 2, 2, 0.25), (6, 2, 3, 0.25), (7, 2, 6, 0.03),
(8, 3, 1, 0.3), (9, 3, 6, 0.04),
(10, 4, 7, 1), (11, 4, 5, 0.01);

-- 13. CUSTOMER
INSERT INTO CUSTOMER (customer_id, tier_id, name, phone, total_points) VALUES 
(1, 1, 'Ahmed Khan', '03001234567', 150), (2, 3, 'Sobia Malik', '03219876543', 2500);

-- 14. CAMPAIGN
INSERT INTO CAMPAIGN (campaign_id, campaign_name, point_multiplier, end_date) VALUES 
(1, 'Eid Special', 2.0, '2026-06-30');

-- 15. ORDER
INSERT INTO `ORDER` (order_id, table_id, staff_id, branch_id, order_state, order_type, subtotal, order_timestamp) VALUES 
(1, 1, 1, 1, 'Completed', 'Dine-In', 1800.00, NOW()), 
(2, 8, 15, 2, 'Completed', 'Dine-In', 900.00, NOW());

-- 16. ORDER_ITEM
INSERT INTO ORDER_ITEM (order_item_id, order_id, menu_item_id, quantity, unit_price) VALUES 
(1, 1, 1, 1, 1800.00), (2, 2, 2, 2, 450.00);

-- 17. ORDER_ITEM_MODIFICATION
INSERT INTO ORDER_ITEM_MODIFICATION (modification_id, order_item_id, added_ingredient_id, mod_quantity, extra_cost) VALUES 
(1, 1, 4, 1, 50.00);

-- 18. PAYMENT
INSERT INTO PAYMENT (payment_id, order_id, customer_id, payment_method, subtotal_amount, final_amount, payment_timestamp) VALUES 
(1, 1, 1, 'Card', 1800.00, 1800.00, NOW());

-- 19. RESERVATION
INSERT INTO RESERVATION (reservation_id, customer_id, table_id, reservation_date, reservation_time, party_size) VALUES 
(1, 2, 3, '2026-05-05', '20:00:00', 6);
