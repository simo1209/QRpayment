CREATE TABLE IF NOT EXISTS accounts
(
    id      SERIAL PRIMARY KEY,
    f_name  VARCHAR(255),
    email   VARCHAR(255),
    l_name  VARCHAR(255),
    balance NUMERIC CHECK ( balance >= 0 )
);

CREATE TABLE IF NOT EXISTS transactions
(
    id        SERIAL PRIMARY KEY,
    buyer_id  INTEGER REFERENCES accounts (id),
    seller_id INTEGER REFERENCES accounts (id),
    status    VARCHAR(3),
    amount    NUMERIC CHECK ( amount > 0 )
)