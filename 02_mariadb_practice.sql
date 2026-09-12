-- ============================================================
-- MariaDB 12.3 练习库：电商订单 (shop)
-- 运行方式（会提示输入 root 密码）：
--   "D:\MariaDB\bin\mysql.exe" -u root -p < 02_mariadb_practice.sql
-- 或进入交互后：  source 02_mariadb_practice.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS shop
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE shop;

-- ---------- 1. 建表 ----------
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    city        VARCHAR(50),
    level       VARCHAR(10)  DEFAULT '普通',
    created_at  DATE         DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    category    VARCHAR(50),
    price       DECIMAL(10,2) NOT NULL,
    stock       INT          DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date  DATE         NOT NULL,
    status      VARCHAR(20)  DEFAULT '待发货',
    FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT,
    product_id  INT,
    quantity    INT          NOT NULL DEFAULT 1,
    unit_price  DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- 2. 插入数据 ----------
INSERT INTO customers (name, city, level, created_at) VALUES
    ('张伟','北京','VIP','2025-01-10'),
    ('李娜','上海','普通','2025-02-15'),
    ('王芳','广州','VIP','2025-03-20'),
    ('刘强','北京','普通','2025-05-08'),
    ('陈静','杭州','普通','2025-07-12'),
    ('赵磊','深圳','VIP','2025-09-01');

INSERT INTO products (name, category, price, stock) VALUES
    ('iPhone 15','手机',5999.00,50),
    ('华为Mate60','手机',6499.00,30),
    ('MacBook Air','电脑',7999.00,20),
    ('联想ThinkPad','电脑',6299.00,25),
    ('AirPods','配件',1299.00,100),
    ('机械键盘','配件',499.00,80),
    ('人体工学椅','家居',1899.00,15),
    ('升降桌','家居',2599.00,10);

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1,'2026-01-05','已完成'),
    (1,'2026-02-14','已完成'),
    (2,'2026-02-20','已完成'),
    (2,'2026-03-11','已取消'),
    (3,'2026-03-18','已完成'),
    (3,'2026-04-02','已完成'),
    (4,'2026-04-15','待发货'),
    (5,'2026-05-06','已完成'),
    (5,'2026-05-21','已完成'),
    (6,'2026-06-09','已完成'),
    (6,'2026-06-30','已完成'),
    (2,'2026-07-08','已完成');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1,1,1,5999.00),(1,5,2,1299.00),
    (2,6,1,499.00),
    (3,3,1,7999.00),
    (4,2,1,6499.00),
    (5,1,1,5999.00),(5,5,1,1299.00),
    (6,7,1,1899.00),
    (7,4,1,6299.00),
    (8,5,2,1299.00),(8,6,1,499.00),
    (9,8,1,2599.00),
    (10,2,1,6499.00),(10,5,1,1299.00),
    (11,3,1,7999.00),(11,6,2,499.00),
    (12,4,1,6299.00);

-- ============================================================
-- A. 基础查询
-- ============================================================

-- A1 查全部客户
SELECT * FROM customers;

-- A2 只要姓名和城市（投影）
SELECT name, city FROM customers;

-- A3 条件过滤：所有 VIP 客户
SELECT name, city FROM customers WHERE level = 'VIP';

-- A4 多条件 AND：北京且 VIP
SELECT name FROM customers WHERE city = '北京' AND level = 'VIP';

-- A5 多条件 OR：北京或上海
SELECT name, city FROM customers WHERE city = '北京' OR city = '上海';

-- A6 IN 简化 OR
SELECT name, city FROM customers WHERE city IN ('北京','上海');

-- A7 模糊匹配 LIKE：名字含"伟"
SELECT name FROM customers WHERE name LIKE '%伟%';

-- A8 范围 BETWEEN：单价 1000~7000 的商品
SELECT name, price FROM products WHERE price BETWEEN 1000 AND 7000;

-- A9 空值判断 IS NULL
SELECT name FROM customers WHERE city IS NULL;

-- A10 排序 ORDER BY：商品按价格倒序
SELECT name, price FROM products ORDER BY price DESC;

-- A11 多列排序：先按城市，再按姓名
SELECT name, city FROM customers ORDER BY city, name;

-- A12 限量 LIMIT：最贵的 3 个商品
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;

-- A13 分页：跳过前 3 条取 3 条（第 2 页）
SELECT name, price FROM products ORDER BY price LIMIT 3 OFFSET 3;

-- A14 去重 DISTINCT：有哪些城市
SELECT DISTINCT city FROM customers ORDER BY city;

-- ============================================================
-- B. 聚合与分组
-- ============================================================

-- B1 客户总数
SELECT COUNT(*) AS 客户数 FROM customers;

-- B2 商品最高价、最低价、平均价
SELECT MAX(price) AS 最高价, MIN(price) AS 最低价,
       ROUND(AVG(price),2) AS 平均价 FROM products;

-- B3 库存总量
SELECT SUM(stock) AS 总库存 FROM products;

-- B4 按城市统计客户数
SELECT city, COUNT(*) AS 人数 FROM customers GROUP BY city ORDER BY 人数 DESC;

-- B5 按品类统计：商品数、平均价
SELECT category, COUNT(*) AS 商品数, ROUND(AVG(price),2) AS 平均价
FROM products GROUP BY category;

-- B6 HAVING 过滤分组：客户数 ≥2 的城市
SELECT city, COUNT(*) AS 人数
FROM customers GROUP BY city HAVING COUNT(*) >= 2;

-- B7 按订单状态统计
SELECT status, COUNT(*) AS 订单数 FROM orders GROUP BY status;

-- ============================================================
-- C. 连接查询 JOIN
-- ============================================================

-- C1 内连接：订单 + 客户姓名
SELECT o.id AS 订单号, c.name AS 客户, o.order_date, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id
ORDER BY o.id;

-- C2 三表连接：客户 + 订单 + 商品明细
SELECT c.name AS 客户, p.name AS 商品, oi.quantity, oi.unit_price
FROM orders o
JOIN customers c   ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p    ON oi.product_id = p.id
ORDER BY o.id;

-- C3 左连接：所有客户及其订单数（含 0 单客户）
SELECT c.name, COUNT(o.id) AS 订单数
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY 订单数 DESC;

-- C4 左连接找"没有下单的客户"
SELECT c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- C5 计算每笔订单金额
SELECT o.id AS 订单号, SUM(oi.quantity * oi.unit_price) AS 订单金额
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id
ORDER BY 订单金额 DESC;

-- C6 每位客户的累计消费（只算已完成订单）
SELECT c.name AS 客户,
       SUM(oi.quantity * oi.unit_price) AS 累计消费
FROM customers c
JOIN orders o      ON o.customer_id = c.id AND o.status = '已完成'
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.name
ORDER BY 累计消费 DESC;

-- C7 每个品类的销售额
SELECT p.category AS 品类,
       SUM(oi.quantity * oi.unit_price) AS 销售额
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN orders o   ON oi.order_id = o.id
WHERE o.status = '已完成'
GROUP BY p.category
ORDER BY 销售额 DESC;

-- C8 自连接思路：与张伟同城市的客户
SELECT c2.name, c2.city
FROM customers c1
JOIN customers c2 ON c1.city = c2.city
WHERE c1.name = '张伟' AND c2.name <> '张伟';

-- ============================================================
-- D. 子查询
-- ============================================================

-- D1 标量子查询：价格高于平均价的商品
SELECT name, price FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price;

-- D2 IN 子查询：下过单的客户
SELECT name FROM customers
WHERE id IN (SELECT DISTINCT customer_id FROM orders);

-- D3 NOT IN：从没下过单的客户
SELECT name FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders WHERE customer_id IS NOT NULL);

-- D4 EXISTS：至少有一笔已完成订单的客户
SELECT c.name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o
              WHERE o.customer_id = c.id AND o.status = '已完成');

-- D5 FROM 子查询（派生表）：先算订单额再筛
SELECT * FROM (
    SELECT o.id, SUM(oi.quantity * oi.unit_price) AS 金额
    FROM orders o JOIN order_items oi ON oi.order_id = o.id
    GROUP BY o.id
) t
WHERE 金额 > 5000
ORDER BY 金额 DESC;

-- ============================================================
-- E. 窗口函数（MariaDB 10.2+ 支持）
-- ============================================================

-- E1 商品价格排名
SELECT name, category, price,
       RANK()       OVER (ORDER BY price DESC) AS 总排名,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS 品类内名次
FROM products;

-- E2 每个品类内最贵的商品
SELECT * FROM (
    SELECT name, category, price,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
    FROM products
) t WHERE rn = 1;

-- E3 累计销售额（按订单日期）
SELECT order_date,
       SUM(金额) OVER (ORDER BY order_date) AS 累计销售额
FROM (
    SELECT o.order_date, SUM(oi.quantity * oi.unit_price) AS 金额
    FROM orders o JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status = '已完成'
    GROUP BY o.id, o.order_date
) t
ORDER BY order_date;

-- E4 与上一笔订单的金额差 LAG
SELECT order_date, 金额,
       LAG(金额) OVER (ORDER BY order_date) AS 上一笔金额,
       金额 - LAG(金额) OVER (ORDER BY order_date) AS 差额
FROM (
    SELECT o.order_date, SUM(oi.quantity * oi.unit_price) AS 金额
    FROM orders o JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status = '已完成'
    GROUP BY o.id, o.order_date
) t
ORDER BY order_date;

-- ============================================================
-- F. CTE 公共表表达式
-- ============================================================

-- F1 用 WITH 改写 C6，可读性更好
WITH 有效订单 AS (
    SELECT o.id, o.customer_id
    FROM orders o
    WHERE o.status = '已完成'
)
SELECT c.name AS 客户, SUM(oi.quantity * oi.unit_price) AS 累计消费
FROM 有效订单 vo
JOIN customers c    ON c.id = vo.customer_id
JOIN order_items oi ON oi.order_id = vo.id
GROUP BY c.id, c.name
ORDER BY 累计消费 DESC;

-- F2 多个 CTE 串联
WITH 订单额 AS (
    SELECT o.id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS 金额
    FROM orders o JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status = '已完成'
    GROUP BY o.id, o.customer_id
),
客户汇总 AS (
    SELECT customer_id, SUM(金额) AS 总额, COUNT(*) AS 笔数
    FROM 订单额 GROUP BY customer_id
)
SELECT c.name, 总额, 笔数,
       ROUND(总额 / 笔数, 2) AS 平均每笔
FROM 客户汇总 ch
JOIN customers c ON c.id = ch.customer_id
ORDER BY 总额 DESC;

-- ============================================================
-- G. DDL / DML / 事务
-- ============================================================

-- G1 新增一个客户
INSERT INTO customers (name, city, level) VALUES ('孙悟空','广州','VIP');

-- G2 批量修改：把"配件"类商品涨价 10%
UPDATE products SET price = ROUND(price * 1.1, 2) WHERE category = '配件';

-- G3 删除：删掉已取消订单的明细
DELETE FROM order_items
WHERE order_id IN (SELECT id FROM orders WHERE status = '已取消');

-- G4 事务：要么全成功要么全回滚
START TRANSACTION;
UPDATE products SET stock = stock - 3 WHERE id = 1;
UPDATE products SET stock = stock + 3 WHERE id = 5;
-- 确认无误再 COMMIT，反悔用 ROLLBACK;
COMMIT;

-- G5 建索引加速查询
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);

-- G6 建视图：把常用查询固化
CREATE OR REPLACE VIEW v_customer_spending AS
SELECT c.id, c.name, c.city,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS 累计消费
FROM customers c
LEFT JOIN orders o       ON o.customer_id = c.id AND o.status = '已完成'
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.name, c.city;

SELECT * FROM v_customer_spending ORDER BY 累计消费 DESC;

-- ============================================================
-- H. 常用函数速查
-- ============================================================

-- H1 字符串
SELECT UPPER('hello') AS 大写, LOWER('HELLO') AS 小写,
       CHAR_LENGTH('数据库') AS 长度,
       SUBSTRING('MariaDB', 1, 4) AS 截取,
       REPLACE('a-b-c','-','/') AS 替换;

-- H2 数值
SELECT ROUND(3.14159, 2) AS 四舍五入,
       CEIL(3.2) AS 向上取整,
       FLOOR(3.8) AS 向下取整,
       ABS(-10) AS 绝对值;

-- H3 日期（注意：这部分与 PostgreSQL 语法差异最大）
SELECT CURDATE() AS 今天,
       NOW() AS 此刻,
       DATEDIFF('2026-09-06','2025-01-10') AS 相差天数,
       DATE_FORMAT(CURDATE(), '%Y年%m月%d日') AS 格式化,
       DATE_ADD(CURDATE(), INTERVAL 7 DAY) AS 一周后;

-- H4 条件表达式 CASE
SELECT name, price,
       CASE WHEN price >= 6000 THEN '高价'
            WHEN price >= 1000 THEN '中价'
            ELSE '低价' END AS 档位
FROM products ORDER BY price DESC;

-- H5 空值处理 COALESCE
SELECT name, COALESCE(city, '未知') AS 城市 FROM customers;

-- H6 字符串聚合 GROUP_CONCAT（MariaDB 对应 PostgreSQL 的 STRING_AGG）
SELECT city, GROUP_CONCAT(name ORDER BY name SEPARATOR '、') AS 客户名单
FROM customers GROUP BY city;

-- H7 类型转换（MariaDB 用 CAST，没有 :: 简写）
SELECT CAST('123' AS SIGNED) + 1 AS 转整数,
       CAST(price AS CHAR) AS 转文本 FROM products LIMIT 3;

-- H8 查看表结构（MariaDB 专属）
-- DESCRIBE products;
-- SHOW CREATE TABLE products\G
-- SHOW INDEX FROM orders;
