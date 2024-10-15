-- для тестирования
-- DO $$
-- BEGIN
--     IF EXISTS (SELECT 1 FROM information_schema.columns 
--                WHERE table_name='f_sales' 
--                AND table_schema='mart' 
--                AND column_name='status') THEN
--         ALTER TABLE mart.f_sales
--         DROP COLUMN status;
--     END IF;
-- END $$;

ALTER TABLE mart.f_sales
ADD COLUMN status VARCHAR(10) DEFAULT 'shipped' CHECK (status IN ('shipped', 'refunded'));
