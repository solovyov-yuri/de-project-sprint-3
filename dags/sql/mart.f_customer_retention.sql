WITH periods_items AS ( -- все недельные периоды, которые есть в user_order_log
	SELECT
		'weekly' AS period_name,
		date_part('week', date_time) AS period_id,
		item_id
	FROM staging.user_order_log
	GROUP BY date_part('week', date_time), item_id
), new_customers AS ( -- отбираем клиентов, тех, которые сделали только один заказ за неделю
	SELECT
		date_part('week', date_time) AS period_id,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM staging.user_order_log
	WHERE status = 'shipped'
	GROUP BY customer_id, date_part('week', date_time), item_id
	HAVING count(*) = 1
), returning_customers AS ( -- отбираем клиентов, тех, которые сделали больше одного заказа
	SELECT
		date_part('week', date_time) AS period_id,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM staging.user_order_log
	WHERE status = 'shipped'
	GROUP BY customer_id, date_part('week', date_time), item_id
	HAVING count(*) > 1
), refunded_customer AS (  -- отбираем клиентов, тех, оформивших возврат
	SELECT
		date_part('week', date_time) AS period_id,
		item_id,
		customer_id,
		sum(payment_amount) AS customer_revenue
	FROM staging.user_order_log
	WHERE status = 'refunded'
	GROUP BY customer_id, date_part('week', date_time), item_id
), new_customers_count AS ( -- считаем количество и выручку по новым клиентам
	SELECT
		period_id,
		item_id,
		count(customer_id) AS new_customers_count,
		sum(customer_revenue) AS new_customers_revenue
	FROM new_customers
	GROUP BY period_id, item_id
), returning_customers_count AS ( -- считаем количество и выручку по вернувшимся клиентам
	SELECT
		period_id,
		item_id,
		count(customer_id) AS returning_customers_count,
		sum(customer_revenue) AS returning_customers_revenue
	FROM returning_customers
	GROUP BY period_id, item_id
), refunded_customer_count AS ( -- считаем количество и суммарный возврат по клиентам оформившим возврат
	SELECT
		period_id,
		item_id,
		count(customer_id) AS refunded_customer_count,
		sum(customer_revenue) AS customers_refunded
	FROM refunded_customer
	GROUP BY period_id, item_id
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
	period_name,
	pi.period_id,
	pi.item_id,
	COALESCE(new_customers_revenue, 0),
	COALESCE(returning_customers_revenue, 0),
	COALESCE(customers_refunded, 0)
FROM periods_items AS pi
LEFT JOIN new_customers_count AS ncc
	ON pi.period_id = ncc.period_id AND pi.item_id = ncc.item_id
LEFT JOIN returning_customers_count AS rcc
	ON pi.period_id = rcc.period_id AND pi.item_id = rcc.item_id
LEFT JOIN refunded_customer_count AS rfcc
	ON pi.period_id = rfcc.period_id AND pi.item_id = rfcc.item_id
ORDER BY pi.period_id, pi.item_id
ON CONFLICT (period_id, item_id) -- при наличии записи по периоду и товару перещитывам данные
DO UPDATE SET
    new_customers_count = EXCLUDED.new_customers_count,
    returning_customers_count = EXCLUDED.returning_customers_count,
    refunded_customer_count = EXCLUDED.refunded_customer_count,
    period_name = EXCLUDED.period_name,
    new_customers_revenue = EXCLUDED.new_customers_revenue,
    returning_customers_revenue = EXCLUDED.returning_customers_revenue,
    customers_refunded = EXCLUDED.customers_refunded;
