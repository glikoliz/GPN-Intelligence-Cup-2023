-- Показывается количество работников, которые находятся в здании в конкретный момент(раз в час)
-- Если сотрудник вошёл и вышел в течение одного часа, то показываться он, соответственно, не будет
SELECT
    DATE_FORMAT(all_hours.hour, '%Y-%m-%d %H:00:00') as full_date,
    -- Для проверки, сколько человек вошло и вышло в каждом часу
	-- COALESCE(entered, 0) as entered,
    -- COALESCE(exited, 0) as exited,
    all_hours.store_id,
    SUM(COALESCE(entered, 0) - COALESCE(exited, 0)) OVER (PARTITION BY all_hours.store_id ORDER BY all_hours.hour) as total_inside
FROM (
    SELECT
        TIMESTAMPADD(HOUR, t.n, '2023-11-11 08:00:00') as hour,
        stores.store_id
    FROM (
        SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13
    ) t
    CROSS JOIN (
        SELECT DISTINCT store_id FROM store_acs
    ) stores
) all_hours
LEFT JOIN (
    SELECT
        DATE_FORMAT(TIMESTAMPADD(HOUR, 1, event_ts), '%Y-%m-%d %H:00:00') as hour,
        store_id,
        -- Получаем количество вошедших и вышедших на каждый час
        COUNT(DISTINCT CASE WHEN event_type = 1 THEN employee_id END) as entered, 
        COUNT(DISTINCT CASE WHEN event_type = -1 THEN employee_id END) as exited
    FROM
        store_acs
    WHERE
        event_ts BETWEEN '2023-11-11 09:00:00' AND '2023-11-11 21:00:00'
    GROUP BY
        hour, store_id
) entry_info ON all_hours.hour = entry_info.hour AND all_hours.store_id = entry_info.store_id;
