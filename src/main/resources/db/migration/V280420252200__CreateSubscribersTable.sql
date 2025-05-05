CREATE TABLE IF NOT EXISTS subscribers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    unsubscribed_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT true,
    CONSTRAINT unique_email_on_table UNIQUE (email)
);