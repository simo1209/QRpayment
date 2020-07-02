CREATE TABLE IF NOT EXISTS accounts
(
    id           SERIAL PRIMARY KEY,
    f_name       VARCHAR(255),
    l_name       VARCHAR(255),
    phone        VARCHAR(10),
    email        VARCHAR(255),
    bank         VARCHAR(255),
    bank_details VARCHAR(255),
    balance      NUMERIC CHECK ( balance >= 0 )
);

CREATE TABLE IF NOT EXISTS transactions
(
    id               SERIAL PRIMARY KEY,
    buyer_id         INTEGER REFERENCES accounts (id),
    seller_id        INTEGER REFERENCES accounts (id),
    transaction_data TEXT,
    status           VARCHAR(3),
    amount           NUMERIC CHECK ( amount > 0 )
)