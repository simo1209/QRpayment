BEGIN;

UPDATE accounts
SET balance = balance - 400
WHERE id = 2;

INSERT INTO transactions(buyer_id, amount, status)
VALUES (2, 400, 'PEN')
RETURNING id;

UPDATE accounts
SET balance = balance + 400
WHERE id = 1;

UPDATE transactions
SET seller_id = 1, status = 'COM'
WHERE id = 2;

COMMIT;