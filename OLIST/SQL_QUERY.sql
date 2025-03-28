SELECT * FROM [dbo].[OLIST_ORDER_ITEMS_DATASET]
GO

SELECT * FROM [dbo].[OLIST_ORDER_PAYMENTS_DATASET]
GO

SELECT * FROM [dbo].[OLIST_ORDERS_DATASET]
GO

SELECT I.order_id,
	   O.order_status,
	   I.price AS total_price,
	   I.freight_value AS TOTAL_FRETE,
	   P.payment_value
	   

FROM       [dbo].[OLIST_ORDER_ITEMS_DATASET]    AS I
INNER JOIN [dbo].[OLIST_ORDERS_DATASET]         AS O ON O.order_id = I.order_id
INNER JOIN [dbo].[OLIST_ORDER_PAYMENTS_DATASET] AS P ON P.order_id = i.order_id
WHERE O.order_status IN ('approved', 'delivered', 'invoiced', 'processing', 'shipped') AND 
						I.order_id = '8272b63d03f5f79c56e9e4120aec44ef'


/*ESSE SCRIPT CONSOLIDA OS VALORES PARA A TABELA OLIST_ORDER_ITEMS_DATASET*/
/*PRIMEIRA PARTE*/
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

/*TESTE*/

SELECT I.order_id,
	   O.order_status,
	   I.price AS total_price,
	   I.freight_value AS TOTAL_FRETE,
	   P.payment_value
	   

FROM       [dbo].[OLIST_ORDER_ITEMS_DATASET]    AS I
INNER JOIN [dbo].[OLIST_ORDERS_DATASET]         AS O ON O.order_id = I.order_id
INNER JOIN [dbo].[OLIST_ORDER_PAYMENTS_DATASET] AS P ON P.order_id = i.order_id
WHERE O.order_status IN ('approved', 'delivered', 'invoiced', 'processing', 'shipped') AND 
						I.order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'

/*FAZER UM SCRIPT PARA CONSOLIDAR OS VALORES DA TABELA [dbo].[OLIST_ORDER_PAYMENTS_DATASET] */
/*SEGUNDA PARTE*/

CREATE VIEW VW_TAB_SOMA_TOTAL_PAGAMENTO AS
SELECT I.order_id,
	   
	   SUM(P.payment_value) AS TOTAL_PAGAMENTO
	   

FROM       [dbo].[OLIST_ORDER_ITEMS_DATASET]    AS I
INNER JOIN [dbo].[OLIST_ORDERS_DATASET]         AS O ON O.order_id = I.order_id
INNER JOIN [dbo].[OLIST_ORDER_PAYMENTS_DATASET] AS P ON P.order_id = i.order_id
WHERE O.order_status IN ('approved', 'delivered', 'invoiced', 'processing', 'shipped') AND 
						I.order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
GROUP BY I.order_id



/*'approved', 'delivered', 'invoiced', 'processing', 'shipped'*/