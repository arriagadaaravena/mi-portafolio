-- ============================================================
-- Proyecto Alke Wallet - Base de Datos Relacional (MySQL)
-- Abigail Arriagada Aravena
-- ============================================================

-- ---------- Creación de la base de datos ----------
CREATE DATABASE AlkeWallet;
USE AlkeWallet;
SHOW DATABASES;

-- ---------- DDL: definición de tablas ----------
CREATE TABLE usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);

CREATE TABLE transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    currency_id INT NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_user_id) REFERENCES usuario(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES usuario(user_id),
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id),
    INDEX idx_user_fecha (sender_user_id, transaction_date)
);

-- ---------- DML: carga de datos de prueba ----------
INSERT INTO usuario (nombre, correo_electronico, contrasena, saldo) VALUES
('Ana', 'ana@email.com', 'passw123', 1000.00),
('Luis', 'luis@email.com', 'passw456', 2000.00),
('Maria', 'maria@email.com', 'passw789', 200.00);

INSERT INTO moneda (currency_name, currency_symbol) VALUES
('Peso Chileno', '$'),
('Dólar Estadounidense', 'US$'),
('Euro', '€');

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date) VALUES
(1, 2, 1, 50000.00, '2026-09-20 10:15:00'),
(2, 3, 1, 20000.00, '2026-09-21 14:30:00'),
(3, 1, 2, 100.00, '2026-09-22 09:00:00');

-- ---------- Actualización de saldos tras una transacción ----------
UPDATE usuario SET saldo = saldo - 50000.00 WHERE user_id = 1;
UPDATE usuario SET saldo = saldo + 50000.00 WHERE user_id = 2;

-- ---------- Transacción controlada con START TRANSACTION y COMMIT ----------
START TRANSACTION;

UPDATE usuario SET saldo = saldo - 50000.00 WHERE user_id = 3;
UPDATE usuario SET saldo = saldo + 50000.00 WHERE user_id = 1;
INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date)
VALUES (3, 1, 1, 50000.00, NOW());

COMMIT;

-- ---------- Simulación de error de integridad referencial y ROLLBACK ----------
START TRANSACTION;

UPDATE usuario SET saldo = saldo - 10000.00 WHERE user_id = 2;

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date)
VALUES (2, 999, 1, 10000.00, NOW());
-- Error esperado: el usuario 999 no existe

ROLLBACK;

-- ---------- Consultas ----------

-- Nombre de la moneda elegida por un usuario específico (Maria, user_id = 3)
SELECT DISTINCT m.currency_name, m.currency_symbol
FROM transaccion t
INNER JOIN moneda m ON t.currency_id = m.currency_id
WHERE t.sender_user_id = 3 OR t.receiver_user_id = 3;

-- Todas las transacciones registradas, con nombres en lugar de IDs
SELECT
    t.transaction_id,
    e.nombre AS emisor,
    r.nombre AS receptor,
    m.currency_name AS moneda,
    t.importe,
    t.transaction_date
FROM transaccion t
INNER JOIN usuario e ON t.sender_user_id = e.user_id
INNER JOIN usuario r ON t.receiver_user_id = r.user_id
INNER JOIN moneda m ON t.currency_id = m.currency_id;

-- Transacciones realizadas por un usuario específico (Ana, user_id = 1)
SELECT * FROM transaccion
WHERE sender_user_id = 1 OR receiver_user_id = 1;

-- Consulta adicional: total transferido por usuario (agregación)
SELECT
    u.nombre AS usuario,
    SUM(t.importe) AS total_enviado
FROM transaccion t
INNER JOIN usuario u ON t.sender_user_id = u.user_id
GROUP BY u.nombre;

-- ---------- DML: modificar el correo electrónico de un usuario ----------
UPDATE usuario SET correo_electronico = 'luis.nuevo@email.com' WHERE user_id = 2;

-- ---------- DML: eliminar una transacción ----------
DELETE FROM transaccion WHERE transaction_id = 2;
