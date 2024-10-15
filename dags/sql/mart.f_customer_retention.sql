WITH new_customers AS ( -- отбираем клиентов, тех, которые сделали только один заказ за неделю
	SELECT
		week_of_year,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM mart.f_sales fs
	JOIN mart.d_calendar dc
		ON fs.date_id = dc.date_id
	WHERE status = 'shipped' AND week_of_year = date_part('week', '{{ds}}'::date)
	GROUP BY week_of_year, item_id, customer_id
	HAVING count(customer_id) = 1
), returning_customers AS ( -- отбираем клиентов, тех, которые сделали больше одного заказа
	SELECT
		week_of_year,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM mart.f_sales fs
	JOIN mart.d_calendar dc
		ON fs.date_id = dc.date_id
	WHERE status = 'shipped' AND week_of_year = date_part('week', '{{ds}}'::date)
	GROUP BY week_of_year, item_id, customer_id
	HAVING count(customer_id) > 1
), refunded_customer AS (  -- отбираем клиентов, тех, оформивших возврат
	SELECT
		week_of_year,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM mart.f_sales fs
	JOIN mart.d_calendar dc
		ON fs.date_id = dc.date_id
	WHERE status = 'refunded' AND week_of_year = date_part('week', '{{ds}}'::date)
	GROUP BY week_of_year, item_id, customer_id
), new_customers_count AS ( -- считаем количество и выручку по новым клиентам
	SELECT 
		week_of_year,
		item_id,
		count(customer_id) AS new_customers_count,
		sum(customer_revenue) AS new_customers_revenue
	FROM new_customers
	GROUP BY week_of_year, item_id
), returning_customers_count AS ( -- считаем количество и выручку по вернувшимся клиентам
	SELECT 
		week_of_year,
		item_id,
		count(customer_id) AS returning_customers_count,
		sum(customer_revenue) AS returning_customers_revenue
	FROM returning_customers
	GROUP BY week_of_year, item_id
), refunded_customer_count AS ( -- считаем количество и суммарный возврат по клиентам оформившим возврат
	SELECT 
		week_of_year,
		item_id,
		count(customer_id) AS refunded_customer_count,
		sum(customer_revenue) AS customers_refunded
	FROM refunded_customer
	GROUP BY week_of_year, item_id
)
INSERT INTO mart.f_customer_retention (
	new_customers_count,
	returning_customers_count,
	refunded_customer_count,
	period_name,
	period_id,
	item_id,
	new_customers_revenue,
	returning_customers_revenue,
	customers_refunded
)
SELECT
	COALESCE(new_customers_count, 0),
	COALESCE(returning_customers_count, 0),
	COALESCE(refunded_customer_count, 0),
	'weekly',
	ncc.week_of_year,
	ncc.item_id,
	COALESCE(new_customers_revenue, 0),
	COALESCE(returning_customers_revenue, 0),
	-COALESCE(customers_refunded, 0)
FROM new_customers_count AS ncc
FULL JOIN returning_customers_count AS rcc
	ON ncc.week_of_year = rcc.week_of_year AND ncc.item_id = rcc.item_id
FULL JOIN refunded_customer_count AS rfcc
	ON ncc.week_of_year = rfcc.week_of_year AND ncc.item_id = rfcc.item_id
ON CONFLICT (period_id, item_id) -- при наличии записи по периоду и товару пересчитывам данные
DO UPDATE SET
    new_customers_count = EXCLUDED.new_customers_count,
    returning_customers_count = EXCLUDED.returning_customers_count,
    refunded_customer_count = EXCLUDED.refunded_customer_count,
    period_name = EXCLUDED.period_name,
    new_customers_revenue = EXCLUDED.new_customers_revenue,
    returning_customers_revenue = EXCLUDED.returning_customers_revenue,
    customers_refunded = EXCLUDED.customers_refunded;
