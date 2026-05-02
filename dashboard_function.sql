USE Restaurant_db;

-- 1. Get Order Count for a specific branch and date
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

-- 2. Get Revenue for a specific branch and date
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

-- 3. Get Average Order Value for a specific branch and date
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
