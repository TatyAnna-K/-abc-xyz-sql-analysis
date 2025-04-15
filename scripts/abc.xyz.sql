-- АВС анализ:
-- Считаем общее количество проданных товаров, сумму выручки и сумму прибыли по каждому продукту:
WITH product_summa AS (
  SELECT o.product_id, p.product_name,
         SUM(o.quantity) AS quantity,
         ROUND(SUM(o.quantity * p.unit_price)::NUMERIC, 2) AS revenue,
         ROUND(SUM(p.unit_price - p.purchase_cost)::NUMERIC, 2) AS profit
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.product_id, p.product_name
),
-- Считаем кумулятивные суммы для количества проданных товаров, выручки и прибыли:
cumsumma AS (
  SELECT product_id,
         product_name,
         quantity,
         revenue,
         profit,
         SUM(quantity) OVER (ORDER BY quantity DESC) / SUM(quantity) OVER () AS cumsum_quantity,
         SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER () AS cumsum_revenue,
         SUM(profit) OVER (ORDER BY profit DESC) / SUM(profit) OVER () AS cumsum_profit
  FROM product_summa ps
),
abc_analiz AS (
  -- Проводим АВС - анализ (определяем группу товара):
  SELECT
    product_id,
    product_name,
    quantity,
    cumsum_quantity,
    CASE
      WHEN cumsum_quantity <= 0.8 THEN 'A'  -- АВС - анализ по количеству
      WHEN cumsum_quantity <= 0.95 THEN 'B'
      ELSE 'C'
    END AS abc_quantity,
    revenue,
    cumsum_revenue,
    CASE
      WHEN cumsum_revenue <= 0.8 THEN 'A'  -- АВС - анализ по выручке
      WHEN cumsum_revenue <= 0.95 THEN 'B'
      ELSE 'C'
    END AS abc_revenue,
    profit,
    cumsum_profit,
    CASE
      WHEN cumsum_profit <= 0.8 THEN 'A'  -- АВС - анализ по прибыли
      WHEN cumsum_profit <= 0.95 THEN 'B'
      ELSE 'C'
    END AS abc_profit
  FROM cumsumma
)
SELECT product_id, product_name, abc_quantity || abc_revenue || abc_profit AS ABC
FROM abc_analiz


-- XYZ - анализ:
-- Извлекаем название месяца, его номер и считаем количество проданного товара в каждом месяце:
WITH product_summa AS (
  SELECT o.product_id,
         p.product_name,
         TO_CHAR(o.purchase_date, 'Month') AS purchase_month,
         EXTRACT(MONTH FROM o.purchase_date) AS month_number,
         SUM(o.quantity) AS quantity
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.product_id, p.product_name, TO_CHAR(o.purchase_date, 'Month'), EXTRACT(MONTH FROM o.purchase_date)
  ORDER BY month_number
),
-- Считаем коэффициент вариации для каждого товара:
covars AS (
  SELECT product_id,
         product_name,
         purchase_month,
         quantity,
         ROUND(STDDEV_POP(quantity) OVER (PARTITION BY product_id) / AVG(quantity) OVER (PARTITION BY product_id), 3) AS covar
  FROM product_summa
),
-- Извлекаем единственное значение коэффициента вариации для каждого товара:
covars_2 AS (
  SELECT product_id,
         product_name,
         MIN(covar) AS cov
  FROM covars
  GROUP BY product_id, product_name
)
-- Проводим XYZ - анализ (определяем группу товара):
SELECT product_id, product_name, cov,
       CASE
         WHEN cov <= 0.1 THEN 'X'
         WHEN cov <= 0.25 THEN 'Y'
         ELSE 'Z'
       END XYZ_quantity
FROM covars_2


-- Создаем представления для объединения ABC/XYZ - анализа.
-- Создаем представление ABC - анализа:
CREATE VIEW result_abc AS (
  WITH product_summa AS (
    SELECT o.product_id, p.product_name,
           SUM(o.quantity) AS quantity,
           ROUND(SUM(o.quantity * p.unit_price)::NUMERIC, 2) AS revenue,
           ROUND(SUM(p.unit_price - p.purchase_cost)::NUMERIC, 2) AS profit
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.product_id, p.product_name
  ),
  cumsumma AS (
    SELECT product_id,
           product_name,
           quantity,
           revenue,
           profit,
           SUM(quantity) OVER (ORDER BY quantity DESC) / SUM(quantity) OVER () AS cumsum_quantity,
           SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER () AS cumsum_revenue,
           SUM(profit) OVER (ORDER BY profit DESC) / SUM(profit) OVER () AS cumsum_profit
    FROM product_summa ps
  ),
  abc_analiz AS (
    SELECT
      product_id,
      product_name,
      quantity,
      cumsum_quantity,
      CASE
        WHEN cumsum_quantity <= 0.8 THEN 'A'
        WHEN cumsum_quantity <= 0.95 THEN 'B'
        ELSE 'C'
      END AS abc_quantity,
      revenue,
      cumsum_revenue,
      CASE
        WHEN cumsum_revenue <= 0.8 THEN 'A'
        WHEN cumsum_revenue <= 0.95 THEN 'B'
        ELSE 'C'
      END AS abc_revenue,
      profit,
      cumsum_profit,
      CASE
        WHEN cumsum_profit <= 0.8 THEN 'A'
        WHEN cumsum_profit <= 0.95 THEN 'B'
        ELSE 'C'
      END AS abc_profit
    FROM cumsumma
  )
  SELECT product_id, product_name, abc_quantity, abc_revenue, abc_profit
  FROM abc_analiz
)

-- Создаем представление XYZ - анализа:
CREATE VIEW result_xyz AS (
  WITH product_summa AS (
    SELECT o.product_id,
           p.product_name,
           TO_CHAR(o.purchase_date, 'Month') AS purchase_month,
           EXTRACT(MONTH FROM o.purchase_date) AS month_number,
           SUM(o.quantity) AS quantity
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.product_id, p.product_name, TO_CHAR(o.purchase_date, 'Month'), EXTRACT(MONTH FROM o.purchase_date)
    ORDER BY month_number
  ),
  covars AS (
    SELECT product_id,
           product_name,
           purchase_month,
           quantity,
           ROUND(STDDEV_POP(quantity) OVER (PARTITION BY product_id) / AVG(quantity) OVER (PARTITION BY product_id), 3) AS covar
    FROM product_summa
  ),
  covars_2 AS (
    SELECT product_id,
           product_name,
           MIN(covar) AS cov
    FROM covars
    GROUP BY product_id, product_name
  )
  SELECT product_id, product_name, cov,
         CASE
           WHEN cov <= 0.1 THEN 'X'
           WHEN cov <= 0.25 THEN 'Y'
           ELSE 'Z'
         END XYZ_quantity
  FROM covars_2
)

-- Объединяем оба вида анализа:
SELECT ra.product_id, ra.product_name, ra.abc_quantity || rx.xyz_quantity AS abc_xyz
FROM result_abc ra
JOIN result_xyz rx ON ra.product_id = rx.product_id
ORDER BY ra.abc_quantity

