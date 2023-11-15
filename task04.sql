DROP TABLE IF EXISTS sales, stores, store_acs;
-- 1
CREATE TABLE IF NOT EXISTS stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(255),
    store_region VARCHAR(255)
);
INSERT INTO stores (store_id, store_name, store_region)
WITH RECURSIVE seq AS (
  SELECT 1 AS number
  UNION ALL
  SELECT number + 1 FROM seq WHERE number < 15  -- числа от 1 до 15
),
regions AS (
  SELECT 'Регион01' AS region
  UNION ALL SELECT 'Регион02'
  UNION ALL SELECT 'Регион03'
  UNION ALL SELECT 'Регион04'
  UNION ALL SELECT 'Регион05'
),
shops AS (
  SELECT ROW_NUMBER() OVER (ORDER BY region, number) AS id,
         CONCAT('Магазин', LPAD(ROW_NUMBER() OVER (ORDER BY region, number), 2, '0')) AS sname,
         region
  FROM seq
  JOIN regions
  ON seq.number <= FLOOR(1 + RAND() * 3) -- Получаем случайное количество магазинов от 1 до 3
)
SELECT id, sname, region
FROM shops;

-- 2
CREATE TABLE IF NOT EXISTS sales (
    check_num INT,
    sales_date DATE,
    store_id INT,
    good_name VARCHAR(255),
    s_count INT,
    s_sum INT,
    PRIMARY KEY (check_num, sales_date, store_id),
    FOREIGN KEY (store_id) REFERENCES stores (store_id)
);
INSERT INTO sales (check_num, sales_date, store_id, good_name, s_count, s_sum)
-- Генерируем имена 20 товаров
WITH RECURSIVE generate_product_names AS (
  SELECT 1 AS num, 'товар01' AS product_name
  UNION ALL
  SELECT num + 1, CONCAT('товар', LPAD(num + 1, 2, '0')) AS product_name
  FROM generate_product_names
  WHERE num < 20
),
-- Генерируем даты за последние 3 месяца
generate_dates AS (
  SELECT CURDATE() - INTERVAL 3 MONTH AS sales_date
  UNION ALL
  SELECT sales_date + INTERVAL 1 DAY
  FROM generate_dates
  WHERE sales_date < CURDATE()
),
generate_stores AS (
  SELECT store_id
  FROM stores
),
-- Делаем CROSS JOIN всех дат, магазинов и товаров
cross_join_all AS (
  SELECT gd.sales_date, gs.store_id, gp.product_name
  FROM generate_dates gd
  CROSS JOIN generate_stores gs
  CROSS JOIN generate_product_names gp
)
SELECT ROW_NUMBER() OVER (), sales_date, store_id, product_name, FLOOR(5 + RAND() * 11), FLOOR(100 + RAND() * 401)  -- Число продаж-от 5 до 15, сумма чека от 100 до 500
FROM cross_join_all;

-- 3
CREATE TABLE IF NOT EXISTS store_acs (
    store_id INT,
    employee_id INT,
    event_ts TIMESTAMP,
    event_type INT,
    FOREIGN KEY (store_id) REFERENCES stores (store_id)
);

SET @MIN = '2023-11-11 09:00:00';
SET @MAX = '2023-11-11 21:00:00';
INSERT INTO store_acs (store_id, employee_id, event_ts, event_type) -- Генерирует данные входов сотрудников
WITH entry_data AS (
    SELECT
        store_id,
        (store_id * 10) + n.num as employee_id, -- Генерирует id для 5 сотрудников в каждом магазине
        TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, @MIN, @MAX)), @MIN) as event_ts, -- Случайное время между началом и концом рабочего дня
        1 as event_type
    FROM
        stores
    CROSS JOIN (
        SELECT 1 as num UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 -- 5 сотрудников
    ) n
    WHERE store_id <= 2
)
SELECT * FROM entry_data;
INSERT INTO store_acs (store_id, employee_id, event_ts, event_type) -- Добавление записей с event_type -1 для каждой записи с event_type 1
WITH exit_data AS (
    SELECT
        store_id,
        employee_id,
        TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, event_ts, @MAX)), event_ts), -- Случайное время между входом и концом рабочего дня
        -1 as event_type
    FROM
        store_acs
)
SELECT * FROM exit_data;
