WITH monthly_region_sales AS (
    SELECT DATE_FORMAT(sales_date, '%Y-%m') AS month,
           stores.store_region,
           good_name,
           SUM(s_sum) AS total_sales
    FROM sales
    JOIN stores ON sales.store_id = stores.store_id
    GROUP BY DATE_FORMAT(sales_date, '%Y-%m'), stores.store_region, good_name
),
yearly_region_sales AS (
	SELECT DATE_FORMAT(sales_date, '%Y') AS year,
		   stores.store_region,
		   SUM(s_sum) AS total_sales
	FROM sales
	JOIN stores ON sales.store_id = stores.store_id
	GROUP BY DATE_FORMAT(sales_date, '%Y'), stores.store_region
),
monthly_network_sales AS (
	SELECT DATE_FORMAT(sales_date, '%Y-%m') AS month,
		   SUM(s_sum) AS total_sales
	FROM sales
	GROUP BY DATE_FORMAT(sales_date, '%Y-%m')
	ORDER BY total_sales DESC
),
monthly_region_total_sales AS (
    SELECT DATE_FORMAT(sales_date, '%Y-%m') AS month,
           stores.store_region,
           SUM(s_sum) AS total_sales
    FROM sales
    JOIN stores ON sales.store_id = stores.store_id
    GROUP BY DATE_FORMAT(sales_date, '%Y-%m'), stores.store_region
),
ranked_sales AS (
    SELECT month,
           store_region,
           good_name,
           total_sales,
           RANK() OVER (PARTITION BY month, store_region ORDER BY total_sales DESC) as sales_rank  -- Получаем ТОП-3 товаров за месяц
    FROM monthly_region_sales
)
SELECT rs.month,
       rs.store_region,
       rs.good_name,
       rs.total_sales,
       CONCAT(rs.total_sales / NULLIF(yrs.total_sales, 0) * 100, "%") AS yearly_region_percentage,
       CONCAT(rs.total_sales / NULLIF(mns.total_sales, 0) * 100, "%") AS monthly_network_percentage,
       CONCAT(rs.total_sales / NULLIF(mrts.total_sales, 0) * 100, "%") AS monthly_region_percentage
FROM ranked_sales rs
JOIN yearly_region_sales yrs ON rs.store_region = yrs.store_region
JOIN monthly_network_sales mns ON rs.month = mns.month
JOIN monthly_region_total_sales mrts ON rs.store_region = mrts.store_region AND rs.month = mrts.month
WHERE rs.sales_rank <= 3;

