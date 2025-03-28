/*ESSE SCRIPT CONSOLIDA OS VALORES PARA A TABELA OLIST_ORDER_ITEMS_DATASET*/

CREATE VIEW VW_TAB_SOMA_ITEM_FRETE AS
SELECT I.order_id,
	   O.order_status,
	   SUM(I.price) AS total_price,
	   SUM(I.freight_value) AS TOTAL_FRETE,
	   P.payment_value
	   

FROM       [dbo].[OLIST_ORDER_ITEMS_DATASET]    AS I
INNER JOIN [dbo].[OLIST_ORDERS_DATASET]         AS O ON O.order_id = I.order_id
INNER JOIN [dbo].[OLIST_ORDER_PAYMENTS_DATASET] AS P ON P.order_id = i.order_id
WHERE O.order_status IN ('approved', 'delivered', 'invoiced', 'processing', 'shipped') AND 
						I.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
GROUP BY I.order_id, O.order_status, P.payment_value


CREATE VIEW TABELA_ORDER_CONSOLIDADA AS
WITH FREQUENCIA AS (
			SELECT
				 [order_id],
				 [order_status],
				 [total_price],
				 [TOTAL_FRETE],
				 [payment_value],
				 count(*) OVER (PARTITION BY [order_id], [total_price]) AS price_count
			FROM [OLIP].[dbo].[VW_TAB_SOMA_ITEM_FRETE]
),
RankedOrders AS (
    SELECT 
        [order_id],
        [order_status],
        [total_price],
        [TOTAL_FRETE],
        [payment_value],
        ROW_NUMBER() OVER (
            PARTITION BY [order_id] 
            ORDER BY price_count DESC
        ) AS rn
    FROM FREQUENCIA
)
SELECT 
    [order_id],
    [order_status],
    [total_price],
    [TOTAL_FRETE],
	[total_price] + [TOTAL_FRETE] AS TOTAL_PEDIDO
    
FROM RankedOrders
WHERE rn = 1 


