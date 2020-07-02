BEGIN;
INSERT INTO transactions(merchant_id, card_holder_id, amount)
VALUES (1, 3, 400);
UPDATE card_holders
SET balance = balance - 400
WHERE id = 3;
UPDATE merchants
SET balance = balance + 400
WHERE id = 1;
COMMIT;