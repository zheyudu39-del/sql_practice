# 项目长期记忆：D:\sql_practice

SQL 学习练习库。用户是 SQL 初学者（也是 Git 新手），中文交流，喜欢「图示 + 可复制命令」的讲解方式。

## 文件约定
| 文件 | 内容 |
|---|---|
| `01_postgresql_practice.sql` | PostgreSQL 版练习脚本 |
| `02_mariadb_practice.sql` | MariaDB 版练习脚本，电商订单库 `shop`（customers / products / orders / order_items + 视图 v_customer_spending），分区 A~H |
| `03_crud_practice.sql` | CRUD 练习册，自带 `students` 练习表，每题「题目注释在前、参考答案在后」，重跑即重置 |

命名规则：两位序号 + `_` + 主题 + `_practice.sql`。

## 编码与格式约定（必须遵守）
- 所有 .sql 文件：**UTF-8 无 BOM、LF 换行**（与 01/02 一致，Write 工具新建时默认如此，写完用 `file` + `xxd -l 16` 验证）。
- 注释块用 `-- ===...===` 分隔线；中文注释、中文别名可直接用。
- 凡是给用户的 SQL 文件，头部都要写清运行方式（`source` 与 `mysql <`），并带 `--default-character-set=utf8mb4` 防中文乱码。

## 数据库环境
- MariaDB 12.3 装在 `D:\MariaDB\bin\`，交互客户端可用。
- **root 有密码，我无法从 bash 直连**（会报 ERROR 1045 using password: NO）——需要查库状态时只能给用户自检命令，别再尝试无密码连接。
- shop 库预期行数（脚本跑通后）：customers=6、products=8、orders=12、order_items=17。

## Git 与用户偏好
- 用户已配好全局身份：`哲宇 杜` / `1706643426@qq.com`。
- 教学时优先讲「VS Code 图形界面怎么做」，再附命令行对照。
- 反复出现的坑：手敲长 DDL 拼错关键字、把控制台报错文本粘回客户端。**推荐一律用 `source` 跑文件**。
- 不主动创建文档类文件（如 README / 速查表），用户明确要求时才建。
