START TRANSACTION;

-- =========================
-- 1. Branch
-- =========================
INSERT INTO Branch VALUES
(1,'Saviora DHA Lahore','DHA Phase 6 Lahore','03000000001'),
(2,'Saviora Bahria RWP','Bahria Town Rawalpindi','03000000002'),
(3,'Saviora F-10 Islamabad','F-10 Islamabad','03000000003');

-- =========================
-- 2. ROLE
-- =========================
INSERT INTO ROLE VALUES
(1,'Manager','Full access'),
(2,'Assistant Manager','Assist operations'),
(3,'Chef','Cooking'),
(4,'Head Chef','Kitchen control'),
(5,'Waiter','Serving'),
(6,'Cashier','Billing'),
(7,'Cleaner','Hygiene'),
(8,'Inventory Manager','Stock control'),
(9,'Delivery Rider','Delivery'),
(10,'Supervisor','Monitoring');

-- =========================
-- 3. REWARD_TIER
-- =========================
INSERT INTO REWARD_TIER VALUES
(1,'Bronze',0,0.02),
(2,'Silver',200,0.05),
(3,'Gold',500,0.10),
(4,'Platinum',1000,0.15),
(5,'Diamond',2000,0.20),
(6,'VIP',5000,0.25),
(7,'Elite',8000,0.30),
(8,'Royal',12000,0.35),
(9,'Premium',15000,0.40),
(10,'Ultimate',20000,0.50);

-- =========================
-- 4. INGREDIENT_CATALOG
-- =========================
INSERT INTO INGREDIENT_CATALOG VALUES
(1,'Chicken','kg',5,'Meat',200),
(2,'Beef','kg',5,'Meat',250),
(3,'Mutton','kg',3,'Meat',400),
(4,'Rice','kg',10,'Grain',50),
(5,'Flour','kg',8,'Grain',30),
(6,'Yogurt','litre',5,'Dairy',40),
(7,'Butter','kg',2,'Dairy',100),
(8,'Green Chili','g',300,'Vegetable',10),
(9,'Tomato','kg',6,'Vegetable',20),
(10,'Spices','g',500,'Spice',25);

-- =========================
-- 5. SUPPLIER
-- =========================
INSERT INTO SUPPLIER VALUES
(1,'Al Madina Meat','Hassan','03210000001'),
(2,'Karachi Meat Hub','Bilal','03210000002'),
(3,'Punjab Grains','Ahmed','03210000003'),
(4,'Fresh Farms','Usman','03210000004'),
(5,'Dairy Best','Saad','03210000005'),
(6,'Green Valley','Zain','03210000006'),
(7,'Spice Bazaar','Imran','03210000007'),
(8,'Sabzi Mandi','Ali','03210000008'),
(9,'Quality Foods','Hamza','03210000009'),
(10,'Prime Supplies','Farhan','03210000010');

-- =========================
-- 6. CAMPAIGN
-- =========================
INSERT INTO CAMPAIGN VALUES
(1,'Ramadan Deal',2.0,'2026-03-30'),
(2,'Eid Offer',1.5,'2026-04-15'),
(3,'Weekend Deal',1.2,'2026-06-30'),
(4,'Summer Feast',1.3,'2026-08-01'),
(5,'Winter Deal',1.4,'2026-12-01'),
(6,'Student Discount',1.1,'2026-07-01'),
(7,'Family Deal',1.6,'2026-09-01'),
(8,'New Year',2.5,'2026-01-05'),
(9,'Independence',1.7,'2026-08-14'),
(10,'Flash Sale',1.8,'2026-05-30');

-- =========================
-- 7. MENU_ITEM
-- =========================
INSERT INTO MENU_ITEM VALUES
(1,'Chicken Biryani',450,5),
(2,'Beef Biryani',500,5),
(3,'Mutton Karahi',1200,5),
(4,'Chicken Karahi',900,4),
(5,'Chicken Handi',850,4),
(6,'Nihari',600,5),
(7,'Haleem',350,4),
(8,'Seekh Kabab',400,5),
(9,'Paratha Roll',250,4),
(10,'Kheer',200,5);

-- =========================
-- 8. STAFF (21)
-- =========================
INSERT INTO STAFF VALUES
(1,1,1,'b1_admin1','pass','Ali'),
(2,1,2,'b1_admin2','pass','Ahmed'),
(3,1,5,'b1_w1','pass','Usman'),
(4,1,5,'b1_w2','pass','Bilal'),
(5,1,5,'b1_w3','pass','Hassan'),
(6,1,5,'b1_w4','pass','Zain'),
(7,1,5,'b1_w5','pass','Saad'),

(8,2,1,'b2_admin1','pass','Hamza'),
(9,2,2,'b2_admin2','pass','Farhan'),
(10,2,5,'b2_w1','pass','Adeel'),
(11,2,5,'b2_w2','pass','Raza'),
(12,2,5,'b2_w3','pass','Imran'),
(13,2,5,'b2_w4','pass','Junaid'),
(14,2,5,'b2_w5','pass','Kashif'),

(15,3,1,'b3_admin1','pass','Tariq'),
(16,3,2,'b3_admin2','pass','Noman'),
(17,3,5,'b3_w1','pass','Shahid'),
(18,3,5,'b3_w2','pass','Adnan'),
(19,3,5,'b3_w3','pass','Waqas'),
(20,3,5,'b3_w4','pass','Asif'),
(21,3,5,'b3_w5','pass','Sajid');

-- =========================
-- 9. CUSTOMER
-- =========================
INSERT INTO CUSTOMER VALUES
(1,1,'Ali Khan','03011111111',100),
(2,2,'Sara Malik','03022222222',300),
(3,3,'Ahmed Raza','03033333333',600),
(4,4,'Fatima Noor','03044444444',1200),
(5,5,'Usman Tariq','03055555555',2500),
(6,6,'Hassan Ali','03066666666',6000),
(7,7,'Ayesha Khan','03077777777',9000),
(8,8,'Bilal Ahmed','03088888888',13000),
(9,9,'Zain Malik','03099999999',16000),
(10,10,'Hamza Khan','03100000000',21000);

-- =========================
-- 10. DINING_TABLE (10 + Virtual per branch)
-- =========================
INSERT INTO DINING_TABLE VALUES
-- Branch 1
(1,1,1,4,'Available'),(2,1,2,4,'Occupied'),(3,1,3,6,'Reserved'),
(4,1,4,2,'Available'),(5,1,5,4,'Available'),(6,1,6,6,'Occupied'),
(7,1,7,2,'Reserved'),(8,1,8,8,'Available'),(9,1,9,4,'Available'),
(10,1,10,6,'Occupied'),(11,1,0,0,'Virtual'),

-- Branch 2
(12,2,1,4,'Available'),(13,2,2,4,'Occupied'),(14,2,3,6,'Reserved'),
(15,2,4,2,'Available'),(16,2,5,4,'Available'),(17,2,6,6,'Occupied'),
(18,2,7,2,'Reserved'),(19,2,8,8,'Available'),(20,2,9,4,'Available'),
(21,2,10,6,'Occupied'),(22,2,0,0,'Virtual'),

-- Branch 3
(23,3,1,4,'Available'),(24,3,2,4,'Occupied'),(25,3,3,6,'Reserved'),
(26,3,4,2,'Available'),(27,3,5,4,'Available'),(28,3,6,6,'Occupied'),
(29,3,7,2,'Reserved'),(30,3,8,8,'Available'),(31,3,9,4,'Available'),
(32,3,10,6,'Occupied'),(33,3,0,0,'Virtual');

-- =========================
-- 11. FURNITURE
-- =========================
INSERT INTO FURNITURE VALUES
(1,1,'Chair'),(2,1,'Table'),(3,1,'Sofa'),
(4,2,'Chair'),(5,2,'Table'),(6,2,'Sofa'),
(7,3,'Chair'),(8,3,'Table'),(9,3,'Sofa'),
(10,1,'Table');

-- =========================
-- 12. BRANCH_INVENTORY
-- =========================
INSERT INTO BRANCH_INVENTORY VALUES
(1,1,'OK','2026-05-01'),
(2,2,'OK','2026-05-01'),
(3,3,'OK','2026-05-01');

-- =========================
-- 13. INVENTORY_ITEM
-- =========================
INSERT INTO INVENTORY_ITEM VALUES
(1,1,1,20),(1,2,2,15),(1,3,3,10),
(2,4,4,50),(2,5,5,40),(2,6,6,25),
(3,7,7,12),(3,8,8,8),(3,9,9,30),(3,10,10,60);

-- =========================
-- 14. RECIPE
-- =========================
INSERT INTO RECIPE VALUES
(1,1,1,0.5),(2,1,4,0.3),
(3,2,2,0.5),(4,3,3,0.7),
(5,4,1,0.6),(6,5,1,0.5),
(7,6,2,0.4),(8,7,4,0.3),
(9,8,2,0.2),(10,10,6,0.2);

-- =========================
-- 15. RESERVATION
-- =========================
INSERT INTO RESERVATION VALUES
(1,1,1,'2026-05-02','19:00:00',4),
(2,2,12,'2026-05-02','20:00:00',6),
(3,3,23,'2026-05-03','18:30:00',2),
(4,4,2,'2026-05-03','21:00:00',6),
(5,5,13,'2026-05-04','19:30:00',2),
(6,6,24,'2026-05-04','20:30:00',4),
(7,7,3,'2026-05-05','18:00:00',6),
(8,8,14,'2026-05-05','21:30:00',2),
(9,9,25,'2026-05-06','19:00:00',6),
(10,10,33,'2026-05-06','20:00:00',4);

-- =========================
-- 16. ORDER
-- =========================
INSERT INTO `ORDER` VALUES
(1,1,3,1,1,'2026-05-02 19:10:00','Completed','Dine-In',900),
(2,12,4,1,NULL,'2026-05-02 20:10:00','Completed','Dine-In',1200),
(3,11,5,1,2,'2026-05-02 21:00:00','Completed','Takeaway',850),
(4,22,6,2,1,'2026-05-03 18:40:00','Completed','Takeaway',600),
(5,33,7,3,NULL,'2026-05-03 19:20:00','Completed','Delivery',700),
(6,23,8,3,3,'2026-05-04 20:00:00','Completed','Dine-In',950),
(7,1,9,1,NULL,'2026-05-05 19:00:00','Completed','Dine-In',500),
(8,12,10,2,4,'2026-05-05 20:40:00','Completed','Dine-In',1100),
(9,23,11,3,NULL,'2026-05-06 21:00:00','Completed','Dine-In',650),
(10,33,12,3,NULL,'2026-05-06 21:30:00','Completed','Dine-In',800);

-- =========================
-- 17. ORDER_ITEM
-- =========================
INSERT INTO ORDER_ITEM VALUES
(1,1,1,2,450),(2,2,3,1,1200),(3,3,5,1,850),
(4,4,6,1,600),(5,5,8,1,400),(6,6,4,1,900),
(7,7,7,1,350),(8,8,2,1,500),(9,9,3,1,1200),(10,10,6,1,600);

-- =========================
-- 18. MENU_INGREDIENT_SUBSTITUTION
-- =========================

INSERT INTO MENU_INGREDIENT_SUBSTITUTION VALUES
(1,1,1,2,100),(2,2,2,3,150),(3,3,3,1,120),
(4,4,1,2,80),(5,5,1,3,200),
(6,6,2,1,90),(7,7,4,5,50),
(8,8,2,3,100),(9,9,5,4,40),(10,10,6,7,60);

-- =========================
-- 19. ORDER_ITEM_MODIFICATION
-- =========================
INSERT INTO ORDER_ITEM_MODIFICATION VALUES
(1,1,NULL,8,1,10),(2,2,9,NULL,1,0),
(3,3,NULL,7,1,20),(4,4,8,NULL,1,0),
(5,5,NULL,9,1,15),(6,6,NULL,10,1,25),
(7,7,7,NULL,1,0),(8,8,NULL,6,1,30),
(9,9,NULL,8,1,10),(10,10,9,NULL,1,0);

-- =========================
-- 20. PAYMENT
-- =========================
INSERT INTO PAYMENT VALUES
(1,1,1,'Cash',900,50,850,'2026-05-02 19:30:00'),
(2,2,2,'Card',1200,100,1100,'2026-05-02 20:30:00'),
(3,3,3,'Cash',850,0,850,'2026-05-02 21:10:00'),
(4,4,4,'Card',600,50,550,'2026-05-03 19:00:00'),
(5,5,5,'Cash',700,0,700,'2026-05-03 19:50:00'),
(6,6,6,'Card',950,100,850,'2026-05-04 20:30:00'),
(7,7,7,'Cash',500,0,500,'2026-05-05 19:20:00'),
(8,8,8,'Card',1100,100,1000,'2026-05-05 21:00:00'),
(9,9,9,'Cash',650,50,600,'2026-05-06 21:10:00'),
(10,10,10,'Card',800,0,800,'2026-05-06 21:40:00');

COMMIT;
