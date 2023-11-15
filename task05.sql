-- Создаю таблицу заново с тестовыми данными
DROP TABLE IF EXISTS sales;
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
-- Одновременно продан товар01 и товар02.
INSERT INTO sales (check_num, sales_date, store_id, good_name, s_count, s_sum) VALUES
(1, '2023-11-13', 1, 'товар01', 8, 320),
(1, '2023-11-13', 2, 'товар02', 10, 450),
(1, '2023-11-13', 3, 'товар03', 12, 151),
(1, '2023-11-13', 4, 'товар04', 11, 122),
(1, '2023-11-13', 5, 'товар01', 6, 216),
(1, '2023-11-13', 6, 'товар02', 12, 500);
-- Сумма 1759

-- В чеке нету товара02.
INSERT INTO sales (check_num, sales_date, store_id, good_name, s_count, s_sum) VALUES
(3, '2023-11-12', 3, 'товар01', 9, 381),
(3, '2023-11-12', 2, 'товар03', 9, 342),
(3, '2023-11-12', 1, 'товар04', 9, 142),
(3, '2023-11-12', 4, 'товар01', 7, 325);
-- 1190

-- В чеке нету товара01.
INSERT INTO sales (check_num, sales_date, store_id, good_name, s_count, s_sum) VALUES
(5, '2023-11-12', 1, 'товар02', 11, 420),
(5, '2023-11-12', 2, 'товар03', 11, 481),
(5, '2023-11-12', 3, 'товар04', 11, 231),
(5, '2023-11-12', 4, 'товар02', 5, 250);
-- 1382

-- Ни товар01, ни товар02 не присутствуют в чеке.
INSERT INTO sales (check_num, sales_date, store_id, good_name, s_count, s_sum) VALUES
(7, '2023-11-12', 1, 'товар03', 2, 123),
(7, '2023-11-12', 2, 'товар04', 2, 421),
(7, '2023-11-12', 3, 'товар05', 3, 512),
(7, '2023-11-12', 4, 'товар07', 4, 654),
(7, '2023-11-12', 5, 'товар06', 5, 126);
-- 1836


SELECT 
    DATE_FORMAT(sales_date, '%Y-%m') as month,
    SUM(CASE WHEN check_num IN (SELECT check_num FROM sales WHERE good_name = 'товар01') AND check_num IN (SELECT check_num FROM sales WHERE good_name = 'товар02') THEN s_sum ELSE 0 END) as 'товар01 и товар02',
    SUM(CASE WHEN check_num IN (SELECT check_num FROM sales WHERE good_name = 'товар01') AND check_num NOT IN (SELECT check_num FROM sales WHERE good_name = 'товар02') THEN s_sum ELSE 0 END) as 'только товар01',
    SUM(CASE WHEN check_num IN (SELECT check_num FROM sales WHERE good_name = 'товар02') AND check_num NOT IN (SELECT check_num FROM sales WHERE good_name = 'товар01') THEN s_sum ELSE 0 END) as 'только товар02',
    SUM(CASE WHEN check_num NOT IN (SELECT check_num FROM sales WHERE good_name IN ('товар01', 'товар02')) THEN s_sum ELSE 0 END) as 'ни товар01, ни товар02'
FROM 
    sales
GROUP BY 
    month;
