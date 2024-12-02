CREATE TABLE image_record
(
    id           SERIAL PRIMARY KEY,
    image_name   VARCHAR(255) UNIQUE NOT NULL,
    paragraph_id INT
);