SELECT
	usr_id,
	purchases_date,
	amount,
	SUM( amount ) OVER ( PARTITION BY usr_id ORDER BY purchases_date ) AS cumulative_amount,
	RANK() OVER ( PARTITION BY usr_id ORDER BY purchases_date ) AS purchase_rank,
	ROW_NUMBER() OVER ( PARTITION BY usr_id ORDER BY purchases_date ) AS purchase_row_num 
FROM
	user_purchases;
