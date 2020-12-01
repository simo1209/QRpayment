DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;

CREATE TYPE account_type AS ENUM ('user', 'company');
CREATE TYPE transaction_status AS ENUM ('created', 'done', 'expired', 'declined');

CREATE TABLE IF NOT EXISTS accounts
(
    id      SERIAL PRIMARY KEY,
    type    account_type NOT NULL,
    balance NUMERIC      NOT NULL CHECK ( balance >= 0 ) DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS contact_details
(
    id         SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name  TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS addresses
(
    id          SERIAL PRIMARY KEY,
    address_1   TEXT        NOT NULL,
    address_2   TEXT,
    address_3   TEXT,
    city        TEXT        NOT NULL,
    country     CHAR(2)     NOT NULL,
    postal_code VARCHAR(16) NOT NULL
);

CREATE TABLE IF NOT EXISTS login_details
(
    id       SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_accounts
(
    id              SERIAL PRIMARY KEY,
    contact_details INTEGER NOT NULL REFERENCES contact_details (id),
    address         INTEGER NOT NULL REFERENCES addresses (id),
    login_details   INTEGER NOT NULL REFERENCES login_details (id),
    account_id      INTEGER REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS companies
(
    id               SERIAL PRIMARY KEY,
    company_name     TEXT    NOT NULL UNIQUE,
    company_intel_id INTEGER NOT NULL REFERENCES contact_details (id)
);

CREATE TABLE IF NOT EXISTS company_accounts
(
    id              SERIAL PRIMARY KEY,
    company         INTEGER NOT NULL REFERENCES companies (id),
    contact_details INTEGER NOT NULL REFERENCES contact_details (id),
    address         INTEGER NOT NULL REFERENCES addresses (id),
    login_details   INTEGER NOT NULL REFERENCES login_details (id),
    account_id      INTEGER NOT NULL REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS transactions
(
    id               SERIAL PRIMARY KEY,
    buyer_id         INTEGER            NOT NULL REFERENCES accounts (id),
    seller_id        INTEGER            NOT NULL REFERENCES accounts (id),
    transaction_desc TEXT               NOT NULL,
    status           transaction_status NOT NULL,
    time_created     TIMESTAMP          NOT NULL DEFAULT NOW(),
    amount           NUMERIC            NOT NULL CHECK ( amount > 0 )
);

CREATE TABLE IF NOT EXISTS categories
(
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    creator_id INTEGER REFERENCES accounts (id)
);

CREATE TABLE IF NOT EXISTS transaction_categories
(
    transaction_id INTEGER,
    category_id    INTEGER,
    PRIMARY KEY (transaction_id, category_id)
)