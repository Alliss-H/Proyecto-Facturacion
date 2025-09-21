-- GRUPO #4			Parte 1: Conociendo la Data (4 preguntas)
USE facturacion;

-- 1. ¿Cuántos registros existen en la tabla de clientes?
SELECT COUNT(*) AS total_customers
FROM customers;

-- 2. ¿Cuántas facturas hay registradas en total?
SELECT COUNT(*) AS total_invoices
FROM invoices;

-- 3. ¿Cuántos productos diferentes están disponibles?
-- Opción 1:
SELECT count(product_id) AS productos_diferentes_tProducts
FROM products;

-- Opcion 2:
SELECT count(DISTINCT product_id) AS productos_diferentes_tInvoice_Items
FROM invoice_items;

-- 4. Muestra la estructura de la tabla de detalles de factura (campos y tipos de datos). (REVISAR)
DESC invoice_items;


-- Parte 2: Consultas de análisis (6 preguntas)
-- 5. ¿Cuál es el cliente con mayor monto total de compras?
SELECT c.customer_id, c.first_name, c.last_name, SUM(ii.amount) AS total_compras
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_compras DESC
LIMIT 1;

-- 6. ¿Muestre el top 5 de ciudades que han generado un mayor número de facturas?
SELECT c.city, COUNT(i.invoice_id) AS total_facturas
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.city
ORDER BY total_facturas DESC
LIMIT 5;

-- 7. ¿Qué categoría de productos concentra el mayor volumen de ventas (en monto total)?
SELECT c.category_name,
       SUM(ini.amount) AS total_sales
FROM invoice_items ini
JOIN products p ON ini.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC
LIMIT 1;

-- 8. ¿Cuál es el producto más vendido por cantidad de unidades?
SELECT p.product_name,
       SUM(ini.qty) AS total_units_sold
FROM invoice_items ini
JOIN products p ON ini.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 1;

-- 9. ¿Cómo ha variado el número de facturas emitidas por año y mes?
SELECT YEAR(i.invoice_date) AS year,
       MONTH(i.invoice_date) AS month,
       COUNT(*) AS total_invoices
FROM invoices i
GROUP BY YEAR(i.invoice_date), MONTH(i.invoice_date)
ORDER BY year, month;

-- 10. ¿Cúantos clientes han comprado productos de más de una categoría diferente?
SELECT COUNT(*) AS customers_multiple_categories
FROM (
    SELECT i.customer_id,
           COUNT(DISTINCT p.category_id) AS categories_count
    FROM invoices i
    JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
    JOIN products p ON ii.product_id = p.product_id
    GROUP BY i.customer_id
    HAVING COUNT(DISTINCT p.category_id) > 1
) AS subquery;


-- Nueva pregunta propia
-- PREGUNTA 1
-- ¿Qué días de la semana generan mayores ventas totales?
SELECT DAYNAME(i.invoice_date) AS day_of_week,
       SUM(ii.amount) AS total_sales
FROM invoices i
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- PREGUNTA 2
-- ¿Cuales son las 3 categorias de productos que tienen el ticket promedio más alto (monto promedio por factura)?
 SELECT 
    ca.category_name,
    p.category_id,
    SUM(ii.amount) / COUNT(DISTINCT i.invoice_id) AS promedio_ticket_por_factura
FROM invoices i
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
JOIN products p ON ii.product_id = p.product_id
JOIN categories ca ON p.category_id = ca.category_id
GROUP BY ca.category_name, p.category_id
order by promedio_ticket_por_factura desc;

-- PREGUNTA 3
-- ¿Cuales fueron los 7 productos menos vendidos?
SELECT 
    p.product_id,
    p.product_name,
    IFNULL(SUM(ii.qty), 0) AS total_unidades_vendidas
FROM products p
LEFT JOIN invoice_items ii ON p.product_id = ii.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_unidades_vendidas ASC
LIMIT 7;

-- PREGUNTA 4
-- ¿Cuál es el total de ventas por categoría de producto y cuál es la cantidad promedio de unidades vendidas por factura en cada categoría?
SELECT 
    c.category_name,
    SUM(ii.amount) AS total_ventas,
    AVG(ii.qty) AS promedio_unidades_por_factura
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN invoice_items ii ON p.product_id = ii.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_ventas DESC;

-- PREGUNTA 5
-- Los 3 clientes que han comprado en más meses distintos (independientemente del monto) y mostrar el total de dinero que han gastado
    WITH meses_por_cliente AS (
    SELECT 
        i.customer_id,
        COUNT(DISTINCT MONTH(i.invoice_date)) AS num_meses,
        CASE 
            WHEN COUNT(DISTINCT MONTH(i.invoice_date)) = 1 
                 THEN 'Todos los meses iguales'
            ELSE 'Meses diferentes'
        END AS verificacion
    FROM invoices i
    GROUP BY i.customer_id
)
SELECT 
    i.invoice_id,
    i.customer_id,
    cu.last_name,
    SUM(itms.amount) AS montoTotaldeCompraPorCliente,
    COUNT(MONTH(i.invoice_date)) AS numeroDeFacturas,
    m.num_meses,
    m.verificacion
FROM invoices i
JOIN customers cu ON i.customer_id = cu.customer_id
JOIN invoice_items itms ON i.invoice_id = itms.invoice_id
JOIN meses_por_cliente m ON i.customer_id = m.customer_id
GROUP BY i.invoice_id, i.customer_id, cu.last_name, m.num_meses, m.verificacion
ORDER BY montoTotaldeCompraPorCliente DESC
LIMIT 3;
