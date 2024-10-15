-- удаляем записи на дату загрузки, чтобы избежать дублей
DELETE FROM mart.f_sales fs
USING mart.d_calendar dc
WHERE fs.date_id = dc.date_id
	AND dc.date_actual = '{{ ds }}';

insert into mart.f_sales (
	date_id,
	item_id,
	customer_id,
	city_id,
	quantity,
	payment_amount,
	status
)
SELECT
	dc.date_id,
	item_id,
	customer_id,
	city_id,
	quantity,
	payment_amount * (CASE WHEN status = 'shipped' THEN 1 ELSE -1 END) AS payment_amount,
	status
from staging.user_order_log uol
left join mart.d_calendar as dc
	on uol.date_time::Date = dc.date_actual
where uol.date_time::Date = '{{ds}}';