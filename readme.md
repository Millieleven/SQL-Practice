## 用户购买金额分层分析 实战案例

### 1. 项目目标

对用户的购买金额进行分层分析，统计不同消费层级的用户分布，并生成可视化的分析结果。

### 2. 数据库结构

表名：user_purchases

字段说明：

 - `user_id`：用户ID（整数，自增主键）
  - `amount`：购买金额（十进制，精确到小数点后两位）
  - `purchase_date`：购买时间（日期时间类型）

### 3. SQL操作记录

   #### 3.1 创建数据库和表

```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS user_analysis;

-- 使用数据库
USE user_analysis;

-- 创建表
CREATE TABLE user_purchases (  
    user_id INT,  
    purchase_date DATE,  
    amount DECIMAL(10,2)  
);  

```

   #### 3.2 插入模拟数据

```sql
INSERT INTO user_purchases VALUES  
(1, '2023-10-01', 150.00),  
(1, '2023-10-05', 300.00),  
(2, '2023-10-02', 200.00),  
(2, '2023-10-08', 450.00),  
(3, '2023-10-03', 100.00);  

```

   #### 3.3 分层分析

```sql
SELECT
    usr_id,
    amount,
    CASE
        WHEN amount < 100 THEN '低消费'
        WHEN amount BETWEEN 100 AND 300 THEN '中消费'
        ELSE '高消费'
    END AS consumption_level
FROM user_purchases;
```

#### 3.4具体指标分析

**按用户分组，对累计购买金额排名**  

```sql  
SELECT  
    user_id,  
    purchase_date,  
    amount,  
    SUM(amount) OVER (PARTITION BY user_id ORDER BY purchase_date) AS cumulative_amount,  
    RANK() OVER (PARTITION BY user_id ORDER BY purchase_date) AS purchase_rank,  
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY purchase_date) AS purchase_row_num  
FROM user_purchases;  
```

计算每个用户的**单笔最高消费金额**及其消费日期

```sql
SELECT usr_id, purchases_date, amount
FROM (
    SELECT  
        usr_id,  
        purchases_date,  
        amount,  
        ROW_NUMBER() OVER (PARTITION BY usr_id ORDER BY amount DESC, purchases_date DESC) AS row_num
    FROM user_purchases
) AS tmp
WHERE row_num = 1; 
```

### 4. 分析结果

   #### 4.1 数据概况

- 总用户数：3人
- 总购买金额：1200.00元
- 时间范围：2023年10月1日 - 2023年10月8日

   #### 4.2 用户消费分层

- **低消费**：0人（金额 < 100）
- **中消费**：2人（100 ≤ 金额 ≤ 400）
- **高消费**：1人（金额 > 400）

   #### 4.3 统计结果
   
   ##### **购买金额排名**

| usr_id | purchases_date | amount | cumulative_amount | purchase_rank | purchase_row_num |
| ------ | -------------- | ------ | ----------------- | ------------- | ---------------- |
| 1      | 2023-10-01     | 150.00 | 150.00            | 1             | 1                |
| 1      | 2023-10-05     | 300.00 | 450.00            | 2             | 2                |
| 2      | 2023-10-02     | 200.00 | 200.00            | 1             | 1                |
| 2      | 2023-10-08     | 450.00 | 650.00            | 2             | 2                |
| 3      | 2023-10-03     | 100.00 | 100.00            | 1             | 1                |

​       **单笔最高消费金额**

| usr_id | purchases_date | amount |
| ------ | -------------- | ------ |
| 1      | 2023-10-05     | 300.00 |
| 2      | 2023-10-08     | 450.00 |
| 3      | 2023-10-03     | 100.00 |

  **分层分析**

| usr_id | amount | consumption_level |
| ------ | ------ | ----------------- |
| 1      | 150.00 | 中消费            |
| 1      | 300.00 | 中消费            |
| 2      | 200.00 | 中消费            |
| 2      | 450.00 | 高消费            |
| 3      | 100.00 | 中消费            |

### 5.可视化

<img src="C:\Users\millie\Pictures\Screenshots\屏幕截图 2025-03-25 102229.png" style="zoom:50%;" />

### 6. 总结

通过此次分析，我们对用户的购买金额进行了分层。结果显示，大多数用户属于中消费层级，但也有少量高消费用户。未来可以进一步分析高消费用户的消费行为，以优化营销策略。



### 7.知识点

RANK() 若值相同则返回多条记录；

RANK_NUMBER() 会确保每天记录都有唯一的编号（即：返回一条记录）



