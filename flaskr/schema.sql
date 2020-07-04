DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;


CREATE TABLE IF NOT EXISTS accounts
(
    id           SERIAL PRIMARY KEY,
    f_name       TEXT,
    l_name       TEXT,
    phone        TEXT,
    email        TEXT NOT NULL,
    password     TEXT NOT NULL,
    bank         TEXT,
    bank_details TEXT,
    balance      NUMERIC CHECK ( balance >= 0 ) DEFAULT 1000
);

CREATE TABLE IF NOT EXISTS transactions
(
    id               SERIAL PRIMARY KEY,
    buyer_id         INTEGER REFERENCES accounts (id),
    seller_id        INTEGER REFERENCES accounts (id),
    transaction_data TEXT NOT NULL,
    status           TEXT NOT NULL,
    amount           NUMERIC CHECK ( amount > 0 ) NOT NULL
)