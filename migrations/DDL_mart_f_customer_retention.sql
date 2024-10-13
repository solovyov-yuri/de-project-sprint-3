DROP TABLE IF EXISTS mart.f_customer_retention;
CREATE TABLE mart.f_customer_retention (
	new_customers_count bigint,
	returning_customers_count bigint,
	refunded_customer_count bigint,
	period_name varchar(6) ,
	period_id int,
	item_id bigint,
	new_customers_revenue numeric(15, 2),
	returning_customers_revenue numeric(15, 2),
	customers_refunded numeric(15, 2),
	CONSTRAINT customer_retention_pk PRIMARY KEY (period_id, item_id)
);