CREATE TABLE IF NOT EXISTS card_holders
(
    id      SERIAL PRIMARY KEY,
    f_name  VARCHAR(255),
    l_name  VARCHAR(255),
    balance NUMERIC CHECK ( balance > 0 )
);

CREATE TABLE IF NOT EXISTS merchants
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255),
    balance NUMERIC CHECK ( balance > 0 )
);

CREATE TABLE IF NOT EXISTS transactions
(
    merchant_id    INTEGER REFERENCES merchants(id),
    card_holder_id INTEGER REFERENCES card_holders(id),
    amount         NUMERIC CHECK ( amount > 0 )
)