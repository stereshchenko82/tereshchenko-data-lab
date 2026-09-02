-- Завдання 1.3.
SELECT 'sales' AS t, COUNT(*) AS row_count
FROM sales
UNION ALL
SELECT 'stock_prices', COUNT(*)
FROM stock_prices;

-- Завдання 2.1. (GROUP BY)
SELECT
    store_id,
    SUM(total_amount) AS store_total
FROM sales
GROUP BY store_id
ORDER BY store_id;

-- Завдання 2.1. (OVER())
SELECT
    sale_id,
    store_id,
    total_amount,
    SUM(total_amount) OVER () AS total_sales
FROM sales
ORDER BY sale_id;

-- Завдання 2.2.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(AVG(total_amount) OVER (), 2) AS avg_all
FROM sales
ORDER BY sale_id;

-- Завдання 2.3.
SELECT
    sale_id,
    total_amount,
    COUNT(*) OVER () AS sales_count
FROM sales
ORDER BY sale_id;

-- Завдання 2.4.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(total_amount * 100.0 /SUM(total_amount) OVER (), 2) AS pct_of_total
FROM sales
ORDER BY sale_id;

-- Завдання 2.5.
SELECT
    sale_id,
    store_id,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS overall_rank
FROM sales
ORDER BY overall_rank, sale_id;

-- Завдання 3.1.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(AVG(total_amount) OVER (PARTITION BY store_id), 2) AS avg_store_sales
FROM sales
ORDER BY store_id, sale_id;

-- Завдання 3.2.
SELECT
    sale_id,
    store_id,
    total_amount,
    SUM(total_amount) OVER w AS store_total,
    MIN(total_amount) OVER w AS store_min,
    MAX(total_amount) OVER w AS store_max,
    COUNT(*) OVER w AS store_sales_cnt
FROM sales
WINDOW w AS (PARTITION BY store_id)
ORDER BY store_id, sale_id;

-- Завдання 3.3.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(total_amount - AVG(total_amount) OVER (PARTITION BY store_id), 2) AS diff_from_avg
FROM sales
ORDER BY store_id, sale_id;

-- Завдання 3.4.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(total_amount * 100.0 / SUM(total_amount) OVER (PARTITION BY store_id), 2) AS pct_of_store
FROM sales
ORDER BY store_id, sale_id;


-- Завдання 3.5.
WITH s AS (
    SELECT
        sale_id,
        store_id,
        total_amount,
        AVG(total_amount) OVER (PARTITION BY store_id) AS avg_store_sales
    FROM sales
)
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(avg_store_sales, 2) AS avg_store_sales
FROM s
WHERE total_amount > avg_store_sales
ORDER BY store_id, sale_id;

-- Завдання 4.1.
SELECT
    sale_id,
    store_id,
    sale_date,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY sale_date, sale_id) AS sale_rank
FROM sales
ORDER BY store_id, sale_id;

-- Завдання 4.2.
SELECT
    sale_id,
    store_id,
    total_amount,
    RANK() OVER (PARTITION BY store_id ORDER BY total_amount DESC) AS amount_rank
FROM sales
ORDER BY store_id, sale_id;

-- Завдання 4.3.
SELECT
    sale_id,
    store_id,
    total_amount,
    RANK() OVER (PARTITION BY store_id ORDER BY total_amount DESC) AS amount_rank,
    DENSE_RANK() OVER (PARTITION BY store_id ORDER BY total_amount DESC) AS amount_dense
FROM sales
ORDER BY store_id, total_amount DESC;

-- Завдання 4.4.
SELECT
    sale_id,
    store_id,
    total_amount,
    NTILE(2) OVER (PARTITION BY store_id ORDER BY total_amount DESC) AS half
FROM sales
ORDER BY store_id, total_amount DESC;

-- Завдання 4.5.
SELECT
    sale_id,
    sale_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY sale_date ORDER BY total_amount DESC, sale_id) AS date_rank
FROM sales
ORDER BY sale_date, date_rank;

-- Завдання 4.6.
SELECT
    sale_id,
    product_id,
    sale_date,
    ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY sale_date, sale_id) AS product_rank
FROM sales
ORDER BY product_id, sale_date, sale_id;

-- Завдання 5.1.
SELECT
    sale_id,
    store_id,
    total_amount,
    LAG(total_amount) OVER w AS previous_sale_amount
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 5.2.
SELECT
    sale_id,
    store_id,
    total_amount,
    LEAD(total_amount) OVER w AS next_sale_amount
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 5.3.
SELECT
    sale_id,
    store_id,
    total_amount,
    total_amount -
    LAG(total_amount) OVER w AS diff_prev
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 5.4.
SELECT
    sale_id,
    store_id,
    total_amount,
    COALESCE( LAG(total_amount) OVER w, 0) AS previous_sale_amount_coalesce,
    LAG(total_amount, 1, 0) OVER w AS previous_sale_amount_default
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 5.5.
SELECT
    sale_id,
    store_id,
    total_amount,
    LAG(total_amount, 2) OVER w AS two_sales_ago
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 5.6.
SELECT
    sale_id,
    store_id,
    total_amount,
    CASE
        WHEN LAG(total_amount) OVER w IS NULL
            THEN 'перший продаж'
        WHEN total_amount >
             LAG(total_amount) OVER w
            THEN 'зростання'
        WHEN total_amount <
             LAG(total_amount) OVER w
            THEN 'падіння'
        ELSE 'без змін'
    END AS trend
FROM sales
WINDOW w AS (PARTITION BY store_id ORDER BY sale_date, sale_id)
ORDER BY store_id, sale_date, sale_id;

-- Завдання 6.1.
SELECT
    sale_id,
    store_id,
    sale_date,
    total_amount,
    SUM(total_amount) OVER (PARTITION BY store_id ORDER BY sale_date, sale_id) AS cumulative_store_sales
FROM sales
ORDER BY store_id, sale_date, sale_id;

-- Завдання 6.2.
SELECT
    sale_id,
    store_id,
    quantity_sold,
    SUM(quantity_sold) OVER (PARTITION BY store_id ORDER BY sale_date, sale_id) AS cumulative_qty
FROM sales
ORDER BY store_id, sale_date, sale_id;

-- Завдання 6.3.
SELECT
    sale_id,
    store_id,
    total_amount,
    ROUND(
        AVG(total_amount) OVER (PARTITION BY store_id ORDER BY sale_date, sale_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3rows
FROM sales
ORDER BY store_id, sale_date, sale_id;

-- Завдання 6.4.
SELECT
    sale_id,
    store_id,
    sale_date,
    total_amount,
    ROUND(
        AVG(total_amount) OVER (PARTITION BY store_id ORDER BY sale_date, sale_id ROWS BETWEEN 2 preceding AND CURRENT ROW), 2) AS moving_avg_3rows,
    ROUND(
        AVG(total_amount) OVER (PARTITION BY store_id ORDER BY sale_date RANGE BETWEEN INTERVAL '2 days' PRECEDING AND CURRENT ROW), 2) AS moving_avg_3days
FROM sales
ORDER BY store_id, sale_date, sale_id;

-- Завдання 6.5.
SELECT
    sale_id,
    store_id,
    total_amount,
    MAX(total_amount) OVER (PARTITION BY store_id ORDER BY sale_date, sale_id) AS running_max
FROM sales
ORDER BY store_id, sale_date, sale_id;

-- Завдання 7.1.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    LAG(closing_price) OVER w AS yesterday_price,
    LEAD(closing_price) OVER w AS tomorrow_price
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY price_date)
ORDER BY stock_symbol, price_date;

-- Завдання 7.2.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    closing_price -
    LAG(closing_price) OVER w AS price_delta
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY price_date)
ORDER BY stock_symbol, price_date;

-- Завдання 7.3.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    ROUND(((closing_price - LAG(closing_price) OVER w) * 100.0) / LAG(closing_price) OVER w, 2) AS pct_change
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY price_date)
ORDER BY stock_symbol, price_date;

-- Завдання 7.4.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    FIRST_VALUE(closing_price) OVER w AS first_price,
    ROUND((closing_price - FIRST_VALUE(closing_price) OVER w) * 100.0 / FIRST_VALUE(closing_price) OVER w, 2) AS growth_from_start_pct
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY price_date)
ORDER BY stock_symbol, price_date;

-- Завдання 7.5.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    MAX(closing_price) OVER (PARTITION BY stock_symbol) AS max_price,
    MAX(closing_price) OVER (PARTITION BY stock_symbol) - closing_price AS diff_from_max
FROM stock_prices
ORDER BY stock_symbol, price_date;

-- Завдання 7.6.
WITH d AS (
    SELECT
        stock_symbol,
        price_date,
        closing_price,
        closing_price -
        LAG(closing_price) OVER (PARTITION BY stock_symbol ORDER BY price_date) AS price_delta
    FROM stock_prices
)
SELECT
    stock_symbol,
    price_date,
    closing_price,
    price_delta,
    SUM(COALESCE(price_delta, 0)) OVER (PARTITION BY stock_symbol ORDER BY price_date) AS cumulative_change
FROM d
ORDER BY stock_symbol, price_date;

-- Завдання 7.7.
SELECT
    stock_symbol,
    price_date,
    closing_price,
    CASE
        WHEN closing_price >
             LAG(closing_price, 1) OVER w AND LAG(closing_price, 1) OVER w > LAG(closing_price, 2) OVER w
        THEN 'так'
        ELSE 'ні'
    END AS three_day_growth
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY price_date)
ORDER BY stock_symbol, price_date;

-- Завдання 8.1.
SELECT
    store_id,
    sale_id,
    sale_date,
    total_amount
FROM (
    SELECT
        sale_id,
        store_id,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY total_amount DESC, sale_id) AS rn
    FROM sales) t
WHERE rn = 1
ORDER BY store_id;

-- Завдання 8.2.
SELECT DISTINCT
    store_id,
    MIN(sale_date) OVER (PARTITION BY store_id) AS first_sale_date,
    MAX(sale_date) OVER (PARTITION BY store_id) AS last_sale_date,
    MAX(sale_date) OVER (PARTITION BY store_id) - MIN(sale_date) OVER (PARTITION BY store_id) AS days_between
FROM sales
ORDER BY store_id;

-- Завдання 8.3.
SELECT
    product_id,
    product_total,
    RANK() OVER (ORDER BY product_total DESC) AS product_rank
FROM (
    SELECT
        product_id,
        SUM(total_amount) AS product_total
    FROM sales
    GROUP BY product_id) p
ORDER BY product_rank, product_id;
