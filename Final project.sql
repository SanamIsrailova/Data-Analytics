#создаем таблицы 
CREATE DATABASE final_project_full;


CREATE TABLE customer_info (
    id_client INT,
    total_amount DECIMAL(10,2),
    gender VARCHAR(10),
    age INT,
    count_city INT,
    response_communication INT,
    communication_3month INT,
    tenure INT
);

CREATE TABLE transactions (
    date_new VARCHAR(20),
    id_check BIGINT,
    id_client INT,
    count_products DECIMAL(10,3),
    sum_payment DECIMAL(10,2)
);

#чистим данные и удаляем мусор
UPDATE transactions
SET date_new = STR_TO_DATE(date_new, '%d/%m/%Y');

DELETE FROM transactions
WHERE sum_payment <= 0 OR count_products <= 0;


#делаем join
SELECT 
    t.id_client,
    t.date_new,
    t.sum_payment,
    t.count_products,
    c.gender,
    c.age
FROM transactions t
JOIN customer_info c
    ON t.id_client = c.id_client;
    
#AOV

SELECT 
    AVG(sum_payment) AS avg_check
FROM transactions;

#count of clients

SELECT 
    id_client,
    COUNT(id_check) AS total_operations
FROM transactions
GROUP BY id_client;

#LV
SELECT 
    id_client,
    SUM(sum_payment) AS lifetime_value
FROM transactions
GROUP BY id_client;

#средний чек в месяц 
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(sum_payment) AS avg_check
FROM transactions
GROUP BY month;


#количество операций в месяц
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(*) AS operations
FROM transactions
GROUP BY month;

#активные клиенты в месяц 
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(DISTINCT id_client) AS active_clients
FROM transactions
GROUP BY month;

#доля выручки 
WITH total AS (
    SELECT SUM(sum_payment) AS total_revenue FROM transactions
)
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    SUM(sum_payment) AS revenue,
    SUM(sum_payment) * 100 / (SELECT total_revenue FROM total) AS share_percent
FROM transactions
GROUP BY month;

#гендерная аналитика

WITH total AS (
    SELECT SUM(sum_payment) AS total_revenue FROM transactions
)
SELECT 
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    SUM(sum_payment) AS revenue,
    SUM(sum_payment) * 100 / (SELECT total_revenue FROM total) AS share_percent
FROM transactions
GROUP BY month;

#возрастные группы

SELECT 
    CASE 
        WHEN c.age IS NULL THEN 'NA'
        WHEN c.age < 20 THEN '0-19'
        WHEN c.age < 30 THEN '20-29'
        WHEN c.age < 40 THEN '30-39'
        WHEN c.age < 50 THEN '40-49'
        WHEN c.age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(t.id_check) AS operations,
    SUM(t.sum_payment) AS revenue
FROM transactions t
JOIN customer_info c
    ON t.id_client = c.id_client
GROUP BY age_group;

#клиенты с истории более 12 месяцев 
WITH monthly AS (
    SELECT 
        id_client,
        DATE_FORMAT(date_new, '%Y-%m') AS month
    FROM transactions
    GROUP BY id_client, month
)
SELECT id_client
FROM monthly
GROUP BY id_client
HAVING COUNT(DISTINCT month) = 12;





