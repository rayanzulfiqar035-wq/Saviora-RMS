USE Restaurant_db;

DROP VIEW IF EXISTS vw_waiter_active_orders;

CREATE VIEW vw_waiter_active_orders AS
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
