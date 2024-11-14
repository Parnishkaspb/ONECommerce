-- https://www.tutorialspoint.com/postgresql/postgresql_using_autoincrement.htm
-- Уточнялась информация про AI, так как MySQL -> Auto Increment

CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(25) NOT NULL,
);

CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(25) NOT NULL,
    expiration_date TIMESTAMP NOT NULL,
    category_id INT REFERENCES Category(category_id) ON DELETE SET NULL
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    order_number BIGINT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    order_product_count INT NOT NULL,
    order_product_id INT REFERENCES Products(product_id) ON DELETE SET NULL
);

INSERT INTO Category (category_name)
VALUES
    ('Молочные продукты'),
    ('Цитрусовые');

INSERT INTO Products (product_name, expiration_date, category_id)
VALUES
    ('Молоко фермерское', '2024-11-14 10:00:00', 1),
    ('Соевое молоко', '2025-01-31 15:00:00', 1),
    ('Апельсин', '2024-11-31 14:30:00', 2),
    ('Мандарин', '2024-11-31 17:30:00', 2);

INSERT INTO Orders (order_number, order_date, order_product_count, order_product_id)
VALUES
    (1, '2024-11-14 10:00:00', 5, 3),
    (2, '2024-11-14 11:00:00', 1, 2);

Create Table Statistics (
    statistic_id SERIAL PRIMARY KEY,
    statistic_category_count INT NOT NULL,
    statistic_category_id INT REFERENCES Category(category_id) ON DELETE SET NULL,
    statistic_product_count INT NOT NULL,
    statistic_product_id INT REFERENCES Products(product_id) ON DELETE SET NULL,
    statistic_date date NOT NULL
)

CREATE OR REPLACE FUNCTION update_statistics()
RETURNS TRIGGER AS $$
    DECLARE
        category_id INT;
        stat_id INT;
        stat_count INT;
    BEGIN

        SELECT category_id INTO category_id
        FROM Products
            WHERE Products.product_id = NEW.order_product_id;

        SELECT COUNT(statistic_id), statistic_id INTO stat_count, stat_id
        FROM Statistics
        WHERE statistic_category_id = category_id
            AND statistic_product_id = NEW.order_product_id
            AND statistic_date = CURRENT_DATE;

        IF stat_count != 0 THEN
            UPDATE Statistics
                SET statistic_category_count = statistic_category_count + 1,
                    statistic_product_count = statistic_product_count + NEW.order_product_count
            WHERE statistic_id = stat_id;
        ELSE

            INSERT INTO Statistics (statistic_category_count, statistic_category_id, statistic_product_count, statistic_product_id, statistic_date)
            VALUES (1, category_id, NEW.order_product_count, NEW.order_product_id, CURRENT_DATE);
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_statistic_trigger
AFTER INSERT ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_statistics();