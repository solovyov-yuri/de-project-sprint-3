TRUNCATE TABLE staging.user_order_log CONTINUE IDENTITY RESTRICT;
TRUNCATE TABLE mart.f_sales CONTINUE IDENTITY RESTRICT;
TRUNCATE TABLE mart.f_customer_retention CONTINUE IDENTITY RESTRICT;
TRUNCATE TABLE mart.d_item RESTART IDENTITY CASCADE;
TRUNCATE TABLE mart.d_customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE mart.d_city CONTINUE IDENTITY RESTRICT;
