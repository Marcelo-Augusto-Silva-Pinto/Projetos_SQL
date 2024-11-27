		------------------------
		---CONEXAO COM O DW-----
		------------------------

		USE COMERCIO_DW
		GO

		------------------------
		--CRIA�AO DA PROCEDURE--
		------------------------

		CREATE PROC CARGA_FATO
		AS

		DECLARE @FINAL DATETIME 
		DECLARE	@INICIAL DATETIME
		
		SELECT  @FINAL = MAX(DATA)
		FROM COMERCIO_DW.DBO.DIM_TEMPO T

		SELECT @INICIAL = MAX(DATA)
			FROM COMERCIO_DW.DBO.DIM_FATO FT
			JOIN COMERCIO_DW.DBO.DIM_TEMPO T ON (FT.IDTEMPO=T.IDSK)

		IF @INICIAL IS NULL
		BEGIN
			SELECT @INICIAL = MIN(DATA)
			FROM COMERCIO_DW.DBO.DIM_TEMPO T
		END

		INSERT INTO COMERCIO_DW.DBO.DIM_FATO(
			IDNOTA ,
			IDCLIENTE ,
			IDVENDEDOR ,
			IDFORMA ,
			IDFORNECEDOR,
			IDPRODUTO,
			IDTEMPO,
			QUANTIDADE,
			TOTAL_ITEM,
			CUSTO_TOTAL,
			LUCRO_TOTAL )
		SELECT
			N.IDSK AS IDNOTA,
			C.IDSK AS IDCLIENTE,
			V.IDSK AS IDVENDEDOR,
		   FO.IDSK AS IDFORMA,
		   FN.IDSK AS IDFORNECEDOR,
			P.IDSK AS IDPRODUTO,	
			T.IDSK as IDTEMPO,
			F.QUANTIDADE,
			F.TOTAL_ITEM,
			F.CUSTO_TOTAL,
			F.LUCRO_TOTAL
	
		FROM
			COMERCIO_STAGE.DBO.ST_FATO F

			INNER JOIN DBO.DIM_FORMA FO
			on (F.IDFORMA=FO.IDFORMA)	 

			INNER JOIN DBO.DIM_NOTA N
			on (F.IDNOTA=N.IDNOTA)

				INNER JOIN DBO.DIM_FORNECEDOR FN
			on (F.IDFORNECEDOR=FN.IDFORNECEDOR
				AND (FN.INICIO <= F.DATA AND (FN.FIM >= F.DATA) or (FN.FIM IS NULL)))

			INNER JOIN DBO.DIM_CLIENTE C
			on (F.IDCLIENTE=C.IDCLIENTE
				AND (C.INICIO <= F.DATA
				AND (C.FIM >= F.DATA) or (C.FIM IS NULL)))

				INNER JOIN DBO.DIM_VENDEDOR V
			on (F.IDVENDEDOR=V.IDVENDEDOR
				AND (V.INICIO <= F.DATA
				AND (V.FIM >= F.DATA) or (V.FIM IS NULL)))

				INNER JOIN DBO.DIM_PRODUTO P
			ON (F.IDPRODUTO=P.IDPRODUTO 
			AND (P.INICIO <= F.DATA 
			AND (P.FIM >= F.DATA) OR (P.FIM IS NULL)))

			INNER JOIN DBO.DIM_TEMPO T
			ON (CONVERT(VARCHAR, T.DATA,102) = CONVERT(VARCHAR,
			F.DATA,102))
			--WHERE F.DATA > @INICIAL AND F.DATA < @FINAL
			WHERE F.DATA BETWEEN @INICIAL AND @FINAL
GO










