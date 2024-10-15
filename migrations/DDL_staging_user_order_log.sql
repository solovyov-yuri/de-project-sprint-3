-- для тестирования
-- DO $$
-- BEGIN
--     IF EXISTS (SELECT 1 FROM information_schema.columns 
--                WHERE table_name='user_order_log' 
--                AND table_schema='staging' 
--                AND column_name='status') THEN
--         ALTER TABLE staging.user_order_log
--         DROP COLUMN status;
--     END IF;
-- END $$;

ALTER TABLE staging.user_order_log
ADD COLUMN status VARCHAR(10) DEFAULT 'shipped' CHECK (status IN ('shipped', 'refunded'));
