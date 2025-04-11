CREATE TABLE users (
    id varchar(20) primary key,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(50) NOT NULL UNIQUE,
    last_connection character varying(100) NOT NULL,
    website character varying(100) NOT NULL
);

CREATE TABLE products (
    id serial primary key,
    name character varying(50) NOT NULL,
    description TEXT,
    stock integer CHECK (stock > 0),
    price double precision CHECK (price > 0),
    stockmin integer,
    stockmax integer
);

CREATE TABLE orders (
    id serial primary key,
    orderdate date,
    user_id character varying(50) NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_details (
    id serial primary key,
    order_id integer, 
    product_id integer,
    quantity smallint,
    price double precision CHECK (price > 0),
	FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
-- INSERCIONES

INSERT INTO users VALUES 
('U001', 'Juan', 'Pérez', 'juanp@example.com', '2025-04-10 10:00:00', 'juanp.com'),
('U002', 'María', 'López', 'marial@example.com', '2025-04-09 12:30:00', 'marial.com'),
('U003', 'Carlos', 'Ramírez', 'carlosr@example.com', '2025-04-08 08:45:00', 'carlosr.net'),
('U004', 'Ana', 'Martínez', 'anam@example.com', '2025-04-07 09:15:00', 'anamartinez.org'),
('U005', 'Pedro', 'García', 'pedrog@example.com', '2025-04-06 11:25:00', 'pedrog.com'),
('U006', 'Lucía', 'Mendoza', 'luciam@example.com', '2025-04-05 15:00:00', 'luciam.net'),
('U007', 'Jorge', 'Navarro', 'jorgen@example.com', '2025-04-04 16:20:00', 'jorgeweb.com'),
('U008', 'Sofía', 'Torres', 'sofiat@example.com', '2025-04-03 14:50:00', 'sofiatorres.org'),
('U009', 'Andrés', 'Ríos', 'andresr@example.com', '2025-04-02 17:30:00', 'andresrios.co'),
('U010', 'Diana', 'Vargas', 'dianav@example.com', '2025-04-01 13:40:00', 'dianavargas.info');

INSERT INTO products(name, description, stock, price, stockmin, stockmax) VALUES 
('Laptop Lenovo', 'Laptop de 14 pulgadas, Ryzen 5', 50, 2300.00, 10, 100),
('Mouse Logitech', 'Mouse inalámbrico M185', 150, 70.00, 30, 300),
('Teclado Redragon', 'Teclado mecánico retroiluminado', 80, 150.00, 20, 200),
('Monitor Samsung', 'Monitor LED 24 pulgadas', 40, 850.00, 10, 100),
('Silla Gamer', 'Silla ergonómica con soporte lumbar', 25, 600.00, 5, 50),
('Disco SSD 1TB', 'Almacenamiento sólido SATA', 100, 400.00, 20, 150),
('Memoria RAM 16GB', 'DDR4 3200MHz', 120, 250.00, 25, 180),
('Auriculares Sony', 'Bluetooth con cancelación de ruido', 60, 380.00, 15, 90),
('Cámara Web', '1080p Full HD con micrófono', 90, 120.00, 20, 130),
('Tablet Samsung', 'Galaxy Tab A7, 10.4 pulgadas', 30, 980.00, 10, 60);

INSERT INTO orders(orderdate, user_id) VALUES 
('2025-04-01', 'U001'),
('2025-04-02', 'U002'),
('2025-04-03', 'U003'),
('2025-04-04', 'U004'),
('2025-04-05', 'U005'),
('2025-04-06', 'U006'),
('2025-04-07', 'U007'),
('2025-04-08', 'U008'),
('2025-04-09', 'U009'),
('2025-04-10', 'U010');

INSERT INTO order_details(order_id, product_id, quantity, price) VALUES 
(1, 1, 1, 2300.00),
(2, 2, 2, 70.00),
(3, 3, 1, 150.00),
(4, 4, 2, 850.00),
(5, 5, 1, 600.00),
(6, 6, 2, 400.00),
(7, 7, 2, 250.00),
(8, 8, 1, 380.00),
(9, 9, 3, 120.00),
(10, 10, 1, 980.00);

--########### Reto: Auditoría de Ventas

CREATE TABLE sales_audit (
  audit_id SERIAL PRIMARY KEY,
  order_id INT,
  user_id VARCHAR(20),
  total_value NUMERIC,
  audit_date TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Funcionalidad para registrar auditoría
CREATE OR REPLACE FUNCTION fn_register_audit()
RETURNS TRIGGER AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT SUM(quantity * price)
  INTO total
  FROM order_details
  WHERE order_id = NEW.id;

  INSERT INTO sales_audit(order_id, user_id, total_value)
  VALUES (NEW.id, NEW.user_id, total);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
CREATE TRIGGER trg_audit_sale
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_register_audit();

-- Vista con historial de ventas
CREATE VIEW vw_sales_history AS
SELECT sa.audit_id, u.first_name || ' ' || u.last_name AS username, sa.total_value, sa.audit_date
FROM sales_audit sa
JOIN users u ON sa.user_id = u.id;

-- Vista materializada con resumen diario
CREATE MATERIALIZED VIEW mv_daily_sales_summary AS
SELECT DATE(audit_date) AS sale_date, SUM(total_value) AS daily_total
FROM sales_audit
GROUP BY DATE(audit_date);
REFRESH MATERIALIZED VIEW mv_daily_sales_summary;


SELECT * FROM order_details;
SELECT * FROM vw_sales_history;
SELECT * FROM mv_daily_sales_summary;



-- Eliminar el trigger
DROP TRIGGER trg_audit_sale ON orders;

-- Eliminar la función
DROP FUNCTION fn_register_audit();

--## RETOOOOO DOOOOOS

-- PROCEDURE para registrar venta
CREATE OR REPLACE PROCEDURE prc_register_sale(
  p_user_id VARCHAR(20),
  p_product_id INT,
  p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
  stock_actual INT;
  v_price DOUBLE PRECISION;
  v_order_id INT;
BEGIN
  SELECT stock INTO stock_actual FROM products WHERE id = p_product_id;
  IF stock_actual < p_quantity THEN
    RAISE EXCEPTION 'Stock insuficiente';
  END IF;

  -- 1. Registrar orden
  INSERT INTO orders(orderdate, user_id) VALUES (CURRENT_DATE, p_user_id) RETURNING id INTO v_order_id;

  -- 2. Obtener precio
  SELECT price INTO v_price FROM products WHERE id = p_product_id;

  -- 3. Registrar detalle
  INSERT INTO order_details(order_id, product_id, quantity, price)
  VALUES (v_order_id, p_product_id, p_quantity, v_price);

  -- 4. Actualizar stock
  UPDATE products SET stock = stock - p_quantity WHERE id = p_product_id;
END;
$$;

-- Vista de productos con bajo stock
CREATE VIEW vw_products_low_stock AS
SELECT id, name, stock
FROM products
WHERE stock < 10;

CALL prc_register_sale('U001', 1, 2);
SELECT * FROM orders ORDER BY id DESC;
SELECT * FROM order_details ORDER BY id DESC;
SELECT id, name, stock FROM products WHERE id = 1;
SELECT * FROM sales_audit ORDER BY audit_id DESC;
SELECT * FROM vw_sales_history ORDER BY audit_id DESC;
REFRESH MATERIALIZED VIEW mv_daily_sales_summary;

SELECT * FROM mv_daily_sales_summary ORDER BY sale_date DESC;
CALL prc_register_sale('U001', 1, 999);

-- ### RETO TRESSSSS
-- Tabla de log para updates de pedidos
CREATE TABLE orders_update_log (
  log_id SERIAL PRIMARY KEY,
  order_id INT,
  old_user_id VARCHAR(20),
  new_user_id VARCHAR(20),
  old_order_date DATE,
  new_order_date DATE,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function para registrar actualizaciones
CREATE OR REPLACE FUNCTION fn_log_order_update()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO orders_update_log(order_id, old_user_id, new_user_id, old_order_date, new_order_date)
  VALUES (OLD.id, OLD.user_id, NEW.user_id, OLD.orderdate, NEW.orderdate);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar actualizaciones
CREATE TRIGGER trg_log_order_update
AFTER UPDATE ON orders
FOR EACH ROW
WHEN (OLD.user_id IS DISTINCT FROM NEW.user_id OR OLD.orderdate IS DISTINCT FROM NEW.orderdate)
EXECUTE FUNCTION fn_log_order_update();

-- Function para evitar eliminación si tiene detalles
CREATE OR REPLACE FUNCTION fn_prevent_order_delete()
RETURNS TRIGGER AS $$
DECLARE
  exists_detail BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM order_details WHERE order_id = OLD.id) INTO exists_detail;
  IF exists_detail THEN
    RAISE EXCEPTION 'No se puede eliminar una orden con detalles asociados';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger para evitar eliminación
CREATE TRIGGER trg_prevent_order_delete
BEFORE DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_order_delete();

-- Procedure para actualizar user_id
CREATE OR REPLACE PROCEDURE prc_update_order_user(
  p_order_id INT,
  p_new_user_id VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE orders
  SET user_id = p_new_user_id
  WHERE id = p_order_id;
END;
$$;

-- Procedure para actualizar order_date
CREATE OR REPLACE PROCEDURE prc_update_order_date(
  p_order_id INT,
  p_new_order_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE orders
  SET orderdate = p_new_order_date
  WHERE id = p_order_id;
END;
$$;

CALL prc_register_sale('U001', 1, 1);
CALL prc_update_order_user(1, 'U002');
CALL prc_update_order_date(1, '2025-04-10');
SELECT * FROM orders_update_log ORDER BY log_id DESC;










