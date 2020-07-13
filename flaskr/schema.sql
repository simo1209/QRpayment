DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;


CREATE TABLE IF NOT EXISTS accounts
(
    id         SERIAL PRIMARY KEY,
    first_name TEXT    NOT NULL,
    last_name  TEXT    NOT NULL,
    phone      TEXT    NOT NULL,
    email      TEXT    NOT NULL,
    password   TEXT    NOT NULL,
    balance    NUMERIC NOT NULL CHECK ( balance >= 0 ) DEFAULT 1000.0
);

CREATE TABLE IF NOT EXISTS transactions
(
    id               SERIAL PRIMARY KEY,
    paypal_id        TEXT    NOT NULL,
    buyer_id         INTEGER REFERENCES accounts (id),
    seller_id        INTEGER REFERENCES accounts (id),
    transaction_desc TEXT      NOT NULL,
    status           TEXT      NOT NULL,
    time_completed   TIMESTAMP NOT NULL DEFAULT NOW(),
    amount           NUMERIC   NOT NULL CHECK ( amount > 0 )
)