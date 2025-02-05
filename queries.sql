
-- 1. What are the top 5 brands by receipts scanned for most recent month?

WITH BrandReceipts AS (
    SELECT
		b.brandcode,
		b.barcode,
        b.brandname, 
        COUNT(DISTINCT r.id) AS receipts_scanned
    FROM 
        RewardsReceiptItems ri
    JOIN 
        Receipts r ON ri.receiptid = r.id
    JOIN 
        Brands b ON ri.brandcode = b.brandcode AND ri.barcode = b.barcode
    WHERE 
        DATE_TRUNC('month', TO_TIMESTAMP(r.date_scanned)) = DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY 
        b.brandcode,b.barcode, b.brandname
)
SELECT 
    brandname,
    RANK() OVER (ORDER BY receipts_scanned DESC) AS rank
FROM 
    BrandReceipts
WHERE 
    rank <= 5
ORDER BY 
    rank;

	
-- 2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

WITH CurrentMonthBrandReceipts AS (
    SELECT 
        b.brandcode,
		b.barcode,
        b.brandname, 
        COUNT(DISTINCT r.id) AS receipts_scanned
    FROM 
        RewardsReceiptItems ri
    JOIN 
        Receipts r ON ri.receiptid = r.id
    JOIN 
        Brands b ON ri.brandcode = b.brandcode AND ri.barcode = b.barcode
    WHERE 
        DATE_TRUNC('month', TO_TIMESTAMP(r.date_scanned)) = DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY 
        b.brandcode, b.barcode, b.brandname
),
PreviousMonthBrandReceipts AS (
    SELECT 
        b.brandcode, 
		b.barcode,
        b.brandname, 
        COUNT(DISTINCT r.id) AS receipts_scanned
    FROM 
        RewardsReceiptItems ri
    JOIN 
        Receipts r ON ri.receiptid = r.id
    JOIN 
        Brands b ON ri.brandcode = b.brandcode AND ri.barcode = b.barcode
    WHERE 
        DATE_TRUNC('month', TO_TIMESTAMP(r.date_scanned)) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY 
        b.brandcode, b.barcode, b.brandname
),
RankedCurrentMonth AS (
    SELECT 
        brandcode, 
		barcode,
        brandname, 
        receipts_scanned,
        RANK() OVER (ORDER BY receipts_scanned DESC) AS rank
    FROM 
        CurrentMonthBrandReceipts
),
RankedPreviousMonth AS (
    SELECT 
        brandcode, 
		barcode,
        brandname, 
        receipts_scanned,
        RANK() OVER (ORDER BY receipts_scanned DESC) AS rank
    FROM 
        PreviousMonthBrandReceipts
)
SELECT 
    current.brandname,
    current.receipts_scanned AS current_month_receipts,
    current.rank AS current_month_rank,
    COALESCE(previous.receipts_scanned, 0) AS previous_month_receipts,
    COALESCE(previous.rank, 0) AS previous_month_rank
FROM 
    RankedCurrentMonth current
LEFT JOIN 
    RankedPreviousMonth previous 
    ON current.brandcode = previous.brandcode and current.barcode= previous.barcode
WHERE 
    current.rank <= 5 
ORDER BY 
    current.rank;

	
	
	
	
--3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

WITH StatusAverage AS (
    SELECT 
        rewards_receipt_status,
        AVG(total_spent) AS avg_spend
    FROM 
        Receipts
    WHERE 
        rewards_receipt_status IN ('Accepted', 'Rejected')
    GROUP BY 
        rewards_receipt_status
)
SELECT 
    rewards_receipt_status AS status_with_higher_avg_spend
FROM 
    StatusAverage
ORDER BY 
    avg_spend DESC
LIMIT 1;



-- 4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

WITH StatusItemTotals AS (
    SELECT 
        rewards_receipt_status,
        SUM(purchased_item_count) AS total_items
    FROM 
        Receipts
    WHERE 
        rewards_receipt_status IN ('Accepted', 'Rejected')
    GROUP BY 
        rewards_receipt_status
)
SELECT 
    rewards_receipt_status AS status_with_more_items
FROM 
    StatusItemTotals
ORDER BY 
    total_items DESC
LIMIT 1;

-- 5. Which brand has the most spend among users who were created within the past 6 months??

WITH RecentUsers AS (
    SELECT 
        userId
    FROM 
        Users
    WHERE 
        createDate >= DATEADD(MONTH, -6, CURRENT_DATE)
)
BrandTransactions AS (
select
	b.barcode, 
	b.brandcode, 
	b.brandname, 
	RANK() OVER (ORDER BY sum(ri.final_price) DESC) AS rank 
FROM
	RecentUsers u
	JOIN 
		Receipts r on u.userId = r.userid
	JOIN 
		RewardsReceiptItems ri on r.id= ri.receiptid
	JOIN
		brand b on b.barcode=ri.barcode and b.brandcode = ri.brandcode
GROUP BY
	b.barcode, b.brandcode, b.brandname
)
SELECT 
    barcode, 
    brandcode, 
    brandname
FROM BrandTransactions
WHERE rank = 1;  

-- 6. Which brand has the most transactions among users who were created within the past 6 months?


WITH RecentUsers AS (
    SELECT 
        userId
    FROM 
        Users
    WHERE 
        createDate >= DATEADD(MONTH, -6, CURRENT_DATE)
)
BrandTransactions AS (
select
	b.barcode, 
	b.brandcode, 
	b.brandname, 
	RANK() OVER (ORDER BY COUNT(DISTINCT r.id) DESC) AS rank 
FROM
	RecentUsers u
	JOIN 
		Receipts r on u.userId = r.userid
	JOIN 
		RewardsReceiptItems ri on r.id= ri.receiptid
	JOIN
		brand b on b.barcode=ri.barcode and b.brandcode = ri.brandcode
GROUP BY
	b.barcode, b.brandcode, b.brandname
)
SELECT 
    barcode, 
    brandcode, 
    brandname
FROM BrandTransactions
WHERE rank = 1;  