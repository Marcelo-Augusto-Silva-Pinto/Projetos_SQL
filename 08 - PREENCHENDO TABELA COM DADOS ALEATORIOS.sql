SELECT TOP 1 [IDCLIENTE]
FROM CLIENTE
ORDER BY NEWID()
GO

SELECT TOP 1 [IDFORMA]
FROM [dbo].[FORMA_PAGAMENTO]
ORDER BY NEWID()
GO

SELECT TOP 1 [IDVENDEDOR]
FROM [dbo].[VENDEDOR]
ORDER BY NEWID()
GO

SELECT RAND() * 12

/*PREENCHENDO A TABELA NOTAS FISCAIS*/

DECLARE @ID_CLIENTE INT
		,@ID_VENDEDOR INT
		,@ID_FORMA INT
		,@DATA DATE
BEGIN

		SET @ID_CLIENTE =  (SELECT TOP 1 [IDCLIENTE] FROM CLIENTE ORDER BY NEWID())

		SET @ID_VENDEDOR = (SELECT TOP 1 [IDVENDEDOR] FROM [dbo].[VENDEDOR] ORDER BY NEWID())

		SET @ID_FORMA = (SELECT TOP 1 [IDFORMA] FROM [dbo].[FORMA_PAGAMENTO] ORDER BY NEWID())

		SET @DATA = (SELECT 
					 CONVERT(DATE,
						CONVERT(VARCHAR(15), '2015-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*12))+1)+ '-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*27))+1))))
		INSERT INTO NOTA_FISCAL(ID_CLIENTE,ID_VENDEDOR,ID_FORMA,DATA) 
		VALUES (@ID_CLIENTE,@ID_VENDEDOR,@ID_FORMA,@DATA)

END
GO 8000

DECLARE @ID_CLIENTE INT
		,@ID_VENDEDOR INT
		,@ID_FORMA INT
		,@DATA DATE
BEGIN

		SET @ID_CLIENTE =  (SELECT TOP 1 [IDCLIENTE] FROM CLIENTE ORDER BY NEWID())

		SET @ID_VENDEDOR = (SELECT TOP 1 [IDVENDEDOR] FROM [dbo].[VENDEDOR] ORDER BY NEWID())

		SET @ID_FORMA = (SELECT TOP 1 [IDFORMA] FROM [dbo].[FORMA_PAGAMENTO] ORDER BY NEWID())

		SET @DATA = (SELECT 
					 CONVERT(DATE,
						CONVERT(VARCHAR(15), '2016-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*12))+1)+ '-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*27))+1))))
		INSERT INTO NOTA_FISCAL(ID_CLIENTE,ID_VENDEDOR,ID_FORMA,DATA) 
		VALUES (@ID_CLIENTE,@ID_VENDEDOR,@ID_FORMA,@DATA)

END
GO 8400

DECLARE @ID_CLIENTE INT
		,@ID_VENDEDOR INT
		,@ID_FORMA INT
		,@DATA DATE
BEGIN

		SET @ID_CLIENTE =  (SELECT TOP 1 [IDCLIENTE] FROM CLIENTE ORDER BY NEWID())

		SET @ID_VENDEDOR = (SELECT TOP 1 [IDVENDEDOR] FROM [dbo].[VENDEDOR] ORDER BY NEWID())

		SET @ID_FORMA = (SELECT TOP 1 [IDFORMA] FROM [dbo].[FORMA_PAGAMENTO] ORDER BY NEWID())

		SET @DATA = (SELECT 
					 CONVERT(DATE,
						CONVERT(VARCHAR(15), '2017-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*12))+1)+ '-' +
						CONVERT(VARCHAR(5),(CONVERT(INT,RAND()*27))+1))))
		INSERT INTO NOTA_FISCAL(ID_CLIENTE,ID_VENDEDOR,ID_FORMA,DATA) 
		VALUES (@ID_CLIENTE,@ID_VENDEDOR,@ID_FORMA,@DATA)

END
GO 9000

SELECT COUNT(*) FROM NOTA_FISCAL
GO

/*PREENCHENDO A TABELA ITEM DE NOTA*/

USE COMERCIO_OLTP
GO

DECLARE
		@ID_PRODUTO INT
		,@ID_NOTA_FISCAL INT
		,@QUANTIDADE INT
		,@VALOR NUMERIC(10,2)
		,@TOTAL NUMERIC(10,2)


BEGIN
		SET @ID_PRODUTO = (SELECT TOP 1 IDPRODUTO FROM PRODUTO ORDER BY NEWID())

		SET @ID_NOTA_FISCAL = (SELECT TOP 1 IDNOTA FROM NOTA_FISCAL ORDER BY NEWID())

		SET @QUANTIDADE = (SELECT ROUND(RAND()*4+1,0))

		SET @VALOR = (SELECT VALOR FROM PRODUTO WHERE IDPRODUTO = @ID_PRODUTO)

		SET @TOTAL = @QUANTIDADE * @VALOR
		
		INSERT INTO ITEM_NOTA(ID_PRODUTO, ID_NOTA_FISCAL, QUANTIDADE, TOTAL)
		VALUES(@ID_PRODUTO,@ID_NOTA_FISCAL,@QUANTIDADE,@TOTAL)

END
GO 27000


/*CURSOR PARA PREENCHER NOTAS FISCAIS QUE FICARAM VAZIAS*/

SELECT * FROM ITEM_NOTA

SELECT * FROM ITEM_NOTA
ORDER BY ID_NOTA_FISCAL
GO

SELECT IDNOTA FROM NOTA_FISCAL
WHERE IDNOTA NOT IN(SELECT ID_NOTA_FISCAL FROM ITEM_NOTA)
ORDER BY 1
GO

CREATE PROCEDURE CAD_NOTAS AS
DECLARE
		C_NOTAS CURSOR FOR
		SELECT IDNOTA FROM NOTA_FISCAL
		WHERE IDNOTA NOT IN(SELECT ID_NOTA_FISCAL FROM ITEM_NOTA)
DECLARE 
		@IDNOTA INT
		,@ID_PRODUTO INT
		,@TOTAL DECIMAL(10,2)

OPEN C_NOTAS 

FETCH NEXT FROM C_NOTAS
INTO @IDNOTA

WHILE @@FETCH_STATUS = 0

BEGIN
		SET @ID_PRODUTO = (SELECT TOP 1 IDPRODUTO FROM PRODUTO ORDER BY NEWID())

		SET @TOTAL = (SELECT VALOR FROM PRODUTO WHERE IDPRODUTO = @ID_PRODUTO)

		INSERT INTO ITEM_NOTA(ID_PRODUTO, ID_NOTA_FISCAL, QUANTIDADE, TOTAL)
		VALUES(@ID_PRODUTO, @IDNOTA, 1, @TOTAL)

		FETCH NEXT FROM C_NOTAS
		INTO @IDNOTA

END
CLOSE C_NOTAS
DEALLOCATE C_NOTAS
GO

EXEC CAD_NOTAS
GO

/*PREENCHENDO A COLUNA DE VALORES TOTAIS DA TABELA NOTA FISCAL*/

CREATE VIEW V_ITEM_NOTA AS
SELECT ID_NOTA_FISCAL AS "NOTA FISCAL"
	   ,NOME AS "PRODUTO"
	   ,VALOR
	   ,QUANTIDADE
	   ,TOTAL AS "TOTAL DO ITEM"
FROM PRODUTO
INNER JOIN ITEM_NOTA
ON IDPRODUTO = ID_PRODUTO
GO

SELECT * FROM V_ITEM_NOTA
ORDER BY 1
GO

/*CRIANDO UMA VIEW DE UM RELATORIO DE NOTA FISCAL*/

SELECT C.NOME
	   ,C.SOBRENOME
	   ,C.GENERO
	   ,N.DATA
	   ,N.IDNOTA
	   ,P.NOME
	   ,N.TOTAL
FROM CLIENTE AS C
INNER JOIN NOTA_FISCAL AS N
ON C.IDCLIENTE = N.ID_CLIENTE
INNER JOIN ITEM_NOTA AS I
ON N.IDNOTA = I.ID_NOTA_FISCAL
INNER JOIN PRODUTO AS P
ON P.IDPRODUTO = I.ID_PRODUTO
GO

CREATE VIEW V_NOTA_FISCAL AS
SELECT ID_NOTA_FISCAL, SUM(TOTAL) AS SOMA
FROM ITEM_NOTA
GROUP BY ID_NOTA_FISCAL
GO

SELECT * FROM V_NOTA_FISCAL
GO

CREATE VIEW V_CARGA_NF AS
SELECT N.IDNOTA
	   ,N.TOTAL AS TOTALNOTA
	   ,I.SOMA
FROM NOTA_FISCAL AS N
INNER JOIN V_NOTA_FISCAL AS I
ON IDNOTA = ID_NOTA_FISCAL
GO

SELECT * FROM V_CARGA_NF
GO

UPDATE V_CARGA_NF SET TOTALNOTA = SOMA
GO

SELECT * FROM NOTA_FISCAL
GO

/*CRIANDO UM RELATORIO*/


CREATE VIEW V_RELATORIO_OLTP AS

SELECT C.NOME
	   ,C.SOBRENOME
	   ,C.GENERO
	   ,N.DATA
	   ,N.IDNOTA
	   ,P.NOME AS PRODUTO
	   ,N.TOTAL
FROM CLIENTE AS C
INNER JOIN NOTA_FISCAL AS N
ON C.IDCLIENTE = N.ID_CLIENTE
INNER JOIN ITEM_NOTA AS I
ON N.IDNOTA = I.ID_NOTA_FISCAL
INNER JOIN PRODUTO AS P
ON P.IDPRODUTO = I.ID_PRODUTO
GO

SELECT * FROM V_RELATORIO_OLTP
GO