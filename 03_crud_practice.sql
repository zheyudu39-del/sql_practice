-- ============================================================
-- MariaDB 增删改查（CRUD）练习册
-- 配套：02_mariadb_practice.sql（电商库 shop）
--
-- 特点：
--   1. 自动建一张练习表 students，随便折腾，不碰 shop 的业务表
--   2. 每道题下面紧跟参考答案，建议先自己做，再往下看
--   3. 每次重跑本文件都会 DROP + 重建 students，环境自动重置
--
-- 运行方式（推荐，显式指定 utf8mb4，避免中文变乱码）：
--   "D:\MariaDB\bin\mysql.exe" --default-character-set=utf8mb4 -u root -p --table < 03_crud_practice.sql
-- 或进入交互后：
--   source D:/sql_practice/03_crud_practice.sql
--
-- 练习流程：先跑一遍看每步输出 -> 自己手敲一遍 -> 重跑本文件重置 -> 再来
-- ============================================================

CREATE DATABASE IF NOT EXISTS shop
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE shop;

-- ============================================================
-- 0. 准备练习环境（可反复执行）
-- ============================================================
-- 注意：DROP 用的是 IF EXISTS（表不存在也不报错）；不要写成 IF NOT EXISTS
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id         INT AUTO_INCREMENT PRIMARY KEY,   -- 自增主键，不用手填
    name       VARCHAR(20)   NOT NULL,           -- 姓名，必填
    class_name VARCHAR(20),                      -- 班级，可为空
    score      DECIMAL(5,2)  DEFAULT 0,          -- 成绩，不填默认 0
    email      VARCHAR(50)                       -- 邮箱，可为空
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO students (name, class_name, score, email) VALUES
    ('张伟','一班', 88.50,'zhangwei@test.com'),
    ('李娜','一班', 92.00,'lina@test.com'),
    ('王芳','二班', 76.00,NULL),
    ('刘强','二班', 59.50,'liuqiang@test.com'),
    ('陈静','三班', 85.00,NULL),
    ('赵磊','三班', 95.50,'zhaolei@test.com');

SELECT * FROM students;   -- 确认初始 6 行都在


-- ============================================================
-- 1. 增（INSERT）—— 对应 CRUD 的 C
-- ============================================================
-- 1.1 插入一条完整记录：孙悟空 / 四班 / 77 / sun@test.com
-- 1.2 插入一条不写 email 的记录：白骨精 / 四班 / 82  （email 留空）
-- 1.3 一次插入两条：猪八戒 / 四班 / 66.5 / pig@test.com ；沙悟净 / 四班 / 81 / sha@test.com
-- 1.4 插入白龙马 / 五班，只写 name 和 class_name（观察 score 自动变成 0、email 自动变成 NULL）
-- 1.5 用 DEFAULT 关键字插入一条：小明 / 不写班级 / score 用 DEFAULT / 不写 email
-- 1.6 检查一下现在的全部数据

-- ---------------- 参考答案（建议先自己做） ----------------

-- 1.1
INSERT INTO students (name, class_name, score, email)
VALUES ('孙悟空','四班', 77, 'sun@test.com');

-- 1.2
INSERT INTO students (name, class_name, score)
VALUES ('白骨精','四班', 82);

-- 1.3
INSERT INTO students (name, class_name, score, email) VALUES
    ('猪八戒','四班', 66.5,'pig@test.com'),
    ('沙悟净','四班', 81.00,'sha@test.com');

-- 1.4
INSERT INTO students (name, class_name)
VALUES ('白龙马','五班');

-- 1.5
INSERT INTO students (name, class_name, score, email)
VALUES ('小明', NULL, DEFAULT, NULL);

-- 1.6
SELECT * FROM students;


-- ============================================================
-- 2. 查（SELECT）—— 对应 CRUD 的 R
-- ============================================================
-- 2.1  查所有人全部字段
-- 2.2  只看姓名和成绩两列
-- 2.3  只看一班的人
-- 2.4  成绩 >= 85 的人，按成绩从高到低排
-- 2.5  成绩在 70 到 90 之间的人（用 BETWEEN）
-- 2.6  邮箱是空的人（注意：不能写 = NULL，要用 IS NULL）
-- 2.7  姓名里含"悟"字的人（用 LIKE）
-- 2.8  成绩最高的 3 个人
-- 2.9  一共几个人、平均分、最高分、最低分（一行结果）
-- 2.10 每个班的人数、平均分，按平均分倒序（观察 NULL 班级会单独成一组）
-- 2.11 人数 >= 2 的班级（用 HAVING）
-- 2.12 一共有哪几个班（去重）
-- 2.13 找出成绩高于全班平均分的人（子查询）

-- ---------------- 参考答案 ----------------

-- 2.1
SELECT * FROM students;

-- 2.2
SELECT name, score FROM students;

-- 2.3
SELECT * FROM students WHERE class_name = '一班';

-- 2.4
SELECT name, score FROM students WHERE score >= 85 ORDER BY score DESC;

-- 2.5
SELECT name, score FROM students WHERE score BETWEEN 70 AND 90 ORDER BY score;

-- 2.6
SELECT name, email FROM students WHERE email IS NULL;

-- 2.7
SELECT name FROM students WHERE name LIKE '%悟%';

-- 2.8
SELECT name, score FROM students ORDER BY score DESC LIMIT 3;

-- 2.9
SELECT COUNT(*) AS 人数, ROUND(AVG(score),2) AS 平均分,
       MAX(score) AS 最高分, MIN(score) AS 最低分
FROM students;

-- 2.10
SELECT class_name, COUNT(*) AS 人数, ROUND(AVG(score),2) AS 平均分
FROM students
GROUP BY class_name
ORDER BY 平均分 DESC;

-- 2.11
SELECT class_name, COUNT(*) AS 人数
FROM students
GROUP BY class_name
HAVING COUNT(*) >= 2;

-- 2.12
SELECT DISTINCT class_name FROM students;

-- 2.13
SELECT name, score FROM students
WHERE score > (SELECT AVG(score) FROM students)
ORDER BY score DESC;


-- ============================================================
-- 3. 改（UPDATE）—— 对应 CRUD 的 U
-- ============================================================
-- ⚠️ UPDATE 一定要带 WHERE，否则会改全表！养成习惯：先用 SELECT 把条件跑一遍确认，再改成 UPDATE
--
-- 3.1 把"刘强"的成绩改成 60
-- 3.2 把一班所有人的成绩各加 2 分（用表达式 score + 2）
-- 3.3 把所有 email 为空的人，邮箱统一填成 'unknown@test.com'
-- 3.4 把三班所有人的成绩乘以 0.9（观察小数位处理）
-- 3.5 只把成绩最高的那一个人加 1 分（UPDATE + ORDER BY + LIMIT）
-- 3.6 把没有班级的人（小明）分到"五班"
-- 3.7 危险操作演练：先 SELECT 出"成绩低于 60 的人"，确认无误后再把他们统一加 5 分

-- ---------------- 参考答案 ----------------

-- 3.1
SELECT * FROM students WHERE name = '刘强';          -- 先确认改的是哪一行
UPDATE students SET score = 60 WHERE name = '刘强';

-- 3.2
UPDATE students SET score = score + 2 WHERE class_name = '一班';

-- 3.3
UPDATE students SET email = 'unknown@test.com' WHERE email IS NULL;
--看到了这里
-- 3.4
UPDATE students SET score = score * 0.9 WHERE class_name = '三班';

-- 3.5
UPDATE students SET score = score + 1 ORDER BY score DESC LIMIT 1;

-- 3.6
UPDATE students SET class_name = '五班' WHERE class_name IS NULL;

-- 3.7
SELECT name, score FROM students WHERE score < 60;   -- 先看会改到谁
UPDATE students SET score = score + 5 WHERE score < 60;

-- 看一眼改完之后的样子
SELECT * FROM students ORDER BY id;


-- ============================================================
-- 4. 删（DELETE）—— 对应 CRUD 的 D
-- ============================================================
-- ⚠️ 同样的规矩：DELETE 不带 WHERE 会清空整张表，先 SELECT 确认再删
--
-- 4.1 删掉"白龙马"这一行
-- 4.2 删掉"四班"的所有人
-- 4.3 删掉成绩低于 60 的人
-- 4.4 用事务演练一次"误删全表"再救回来（重点题）
-- 4.5 对比 DELETE 与 TRUNCATE 的区别（观察自增 id 的变化）

-- ---------------- 参考答案 ----------------

-- 4.1
SELECT * FROM students WHERE name = '白龙马';
DELETE FROM students WHERE name = '白龙马';

-- 4.2
DELETE FROM students WHERE class_name = '四班';

-- 4.3
DELETE FROM students WHERE score < 60;

-- 4.4 误删全表 -> 查看 -> 全部撤回
START TRANSACTION;
    DELETE FROM students;                 -- 故意不写 WHERE，假装手滑
    SELECT COUNT(*) AS 现在还有几人 FROM students;   -- 0 人，吓一跳
ROLLBACK;                                 -- 撤回！
SELECT COUNT(*) AS 撤回后几人 FROM students;       -- 数据回来了

-- 4.5
-- DELETE 是逐行删，可以带 WHERE，自增 id 不会重置
DELETE FROM students WHERE score < 70;
-- TRUNCATE 是直接清空整张表，不能带 WHERE，自增 id 会重置回 1
-- TRUNCATE TABLE students;    -- 需要时再取消注释，会清空全部数据


-- ============================================================
-- 5. 综合练习
-- ============================================================
-- 5.1 每个班成绩最高的那个人是谁（提示：用 GROUP BY + MAX 子查询，或窗口函数 ROW_NUMBER）
-- 5.2 把"每班平均分"存成视图，然后直接查视图
-- 5.3 把 students 里成绩 >= 90 的人，插入到一张新表 honor_roll（光荣榜）
-- 5.4 统计每个班的"及格率"（成绩 >= 60 的人数 / 总人数）

-- ---------------- 参考答案 ----------------

-- 5.1 先算每班最高分，再回去找到对应的人
SELECT s.name, s.class_name, s.score
FROM students s
JOIN (
    SELECT class_name, MAX(score) AS 最高分
    FROM students GROUP BY class_name
) m ON s.class_name = m.class_name AND s.score = m.`最高分`
ORDER BY s.score DESC;

-- 5.2
CREATE OR REPLACE VIEW v_class_avg AS
SELECT class_name,
       COUNT(*) AS 人数,
       ROUND(AVG(score),2) AS 平均分
FROM students
GROUP BY class_name;

SELECT * FROM v_class_avg ORDER BY 平均分 DESC;

-- 5.3
DROP TABLE IF EXISTS honor_roll;
CREATE TABLE honor_roll (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    class_name VARCHAR(20),
    score      DECIMAL(5,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO honor_roll (name, class_name, score)
SELECT name, class_name, score FROM students WHERE score >= 90;

SELECT * FROM honor_roll;

-- 5.4 及格率（用 CASE WHEN 把及格的人记 1，再求平均就是比例）
SELECT class_name,
       COUNT(*) AS 人数,
       SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END) AS 及格人数,
       ROUND(AVG(CASE WHEN score >= 60 THEN 100 ELSE 0 END), 1) AS 及格率百分比
FROM students
GROUP BY class_name
ORDER BY 及格率百分比 DESC;


-- ============================================================
-- 6. 环境重置
-- ============================================================
-- 数据玩乱了？重跑一遍本文件即可（开头会自动 DROP + 重建 students）：
--   source D:/sql_practice/03_crud_practice.sql
--
-- 只想重置 students，不想重跑全部练习时，单独执行下面三行：
-- DROP TABLE IF EXISTS students;
-- 然后把上面第 0 节的 CREATE TABLE 和 INSERT 两句重新执行一遍
--
-- ---------- 顺手看一眼练习结果 ----------
SELECT 'students' AS 表名, COUNT(*) AS 行数 FROM students
UNION ALL SELECT 'honor_roll', COUNT(*) FROM honor_roll;
