USE [SICAV]
GO
/****** Object:  StoredProcedure [dbo].[SP_GMF_MARCACION]    Script Date: 4/03/2025 9:40:31 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec [SP_GMF_MARCACION] '1010180791'
ALTER PROCEDURE [dbo].[SP_GMF_MARCACION] 
	@PA_CEDULA VARCHAR (20)	
AS

BEGIN
DECLARE @TIPONIT			VARCHAR(16) = '', 
        @NIT				VARCHAR(16) = '' , 
        @Ciudad				VARCHAR(16) = '' , 
		@NumCtas_Ent		INT = 0 ,
		@NumCtas			INT = 0 ,
		@numDoc_Ent			INT = 0,
		@numDoc				INT = 0,
		@Fecha				SMALLDATETIME,
		@Servidor			VARCHAR(16),
		@Documento			VARCHAR(16),
		@AplicarGMF				VARCHAR(16),
		@ParExento			VARCHAR(16),		  
		@Consulta_Busq_Cta	NVARCHAR(1500),
		@ParDef_Busq_Cta	NVARCHAR(500),
		@Consulta_Busq_ADN	NVARCHAR(1500),
		@ParDef_Busq_ADN	NVARCHAR(500),
		@Consulta_Busq_ADF	NVARCHAR(500),
		@ParDef_Busq_ADF	NVARCHAR(500),
		@Inserta_ADN		NVARCHAR(500),
		@ParDef_Ins_ADN		NVARCHAR(500),
		@Inserta_ADF		NVARCHAR(500),
		@ParDef_Ins_ADF		NVARCHAR(500)
 
 
--paso 1 cargue en temporal
print @PA_CEDULA
IF EXISTS(SELECT TOP 1 1 
				FROM TMP_CC_GMF WITH(NOLOCK)) 
BEGIN
print 'a1'
	DELETE FROM TMP_CC_GMF
	INSERT INTO TMP_CC_GMF VALUES(@PA_CEDULA, GETDATE()) 
END
 select * from TMP_CC_GMF

--PASO 2 marcacion

SET @Fecha = GETDATE()
SET @Documento = 'Afai'
SET @AplicarGMF = '[AplicarGMF]'
SET @ParExento = 'GMFExcentoHasta'

SET @ParDef_Busq_Cta = N'@Documento VARCHAR(16), @TIPONIT  VARCHAR(16), @NIT VARCHAR(16), @numDoc_Ent INT OUTPUT, @NumCtas_Ent INT OUTPUT'
SET @ParDef_Busq_ADN = N'@Documento VARCHAR(16), @numDoc INT, @numCtas_Ent INT OUTPUT'
SET @ParDef_Ins_ADN = N'@Documento VARCHAR(16),  @numDoc INT, @AplicarGMF VARCHAR(16)' 
SET @ParDef_Busq_ADF = N'@Documento VARCHAR(16), @numDoc INT, @ParExento VARCHAR(16), @numCtas_Ent INT OUTPUT'
SET @ParDef_Ins_ADF = N'@Documento VARCHAR(16),  @numDoc INT, @ParExento VARCHAR(16)' 

DECLARE _Excentos CURSOR FOR 
 SELECT CPS_IdTipoNit, CPS_IdNit, CPS_CIUDAD
   FROM CINTAS_POR_SUCURSAL_TABLA_C 
  WHERE CPS_IdTipoNit IN('CC','CE')
    AND CPS_IdNit IN(SELECT CC 
					   FROM TMP_CC_GMF) 
OPEN _EXCENTOS
FETCH NEXT FROM _EXCENTOS INTO @TIPONIT, @NIT, @Ciudad
WHILE(@@FETCH_STATUS = 0)
BEGIN
	SET @NumCtas = 0
	SET @numDoc = 0
	SET @Servidor = CASE @Ciudad WHEN 'Bogota' THEN 'midas'
										  WHEN 'Barrancabermeja' THEN 'midas'
										  WHEN 'Bucaramanga' THEN 'midas'
										  WHEN 'Cartagena' THEN 'midas'
										  WHEN 'Cucuta' THEN 'midas'
						 END

	SET @Consulta_Busq_Cta = N'SELECT @NumCtas_Ent = COUNT(1),
									  @NumDoc_Ent = MAX(RPD_DocumentoNúmero)
								 FROM ' + @Servidor +
								   N'.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN ' + @Servidor +
								   N'.FYC.DBO.TERMINO ON(TER_DocumentoTipo = RPD_DocumentoTipo AND
														 TER_DocumentoNúmero = RPD_DocumentoNúmero)
								WHERE RPD_DocumentoTipo = @Documento
								  AND ISNULL(TER_HASTA, DATEADD(DAY, 1, GETDATE())) >= CONVERT(VARCHAR, DATEADD(DAY, 1, GETDATE()), 106)
								  AND RPD_IdTipoNit = @TIPONIT
								  AND RPD_IdNit = @NIT'
	EXECUTE SP_EXECUTESQL @Consulta_Busq_Cta, @ParDef_Busq_Cta, @Documento = @Documento, @TIPONIT = @TIPONIT, @NIT = @NIT, @NumCtas_Ent = @NumCtas OUTPUT, @numDoc_Ent = @numDoc OUTPUT;

	IF @NumCtas = 1
	BEGIN -- puede marcar cuenta excenta 
		SET @NumCtas = 0
		SET @Consulta_Busq_ADN = N'SELECT @NumCtas_Ent = COUNT(1) FROM ' + @Servidor + N'.FYC.DBO.ASPECTO_DOCUMENTO_NULO  WHERE ADN_DocumentoTipo = @Documento AND ADN_DocumentoNúmero = @numDoc'
		EXECUTE SP_EXECUTESQL @Consulta_Busq_ADN, @ParDef_Busq_ADN, @Documento = @Documento, @numDoc = @numDoc, @NumCtas_Ent = @NumCtas OUTPUT

		IF @NumCtas < 1
		BEGIN
			SET @NumCtas = 0
			SET @Inserta_ADN = N'INSERT INTO ' + @Servidor + N'.FYC.DBO.ASPECTO_DOCUMENTO_NULO VALUES (@Documento, @numDoc , @AplicarGMF) '
			EXECUTE SP_EXECUTESQL @Inserta_ADN, @ParDef_Ins_ADN, @Documento = @Documento, @numDoc = @numDoc, @AplicarGMF = @AplicarGMF

			SET @Consulta_Busq_ADF = N'SELECT @NumCtas_Ent = COUNT(1) FROM ' + @Servidor + N'.FYC.DBO.ASPECTO_DOCUMENTO_FECHA WHERE ADF_DocumentoTipo = @Documento AND ADF_ParámetroNombre = @ParExento AND ADF_DocumentoNúmero = @numDoc'
			EXECUTE SP_EXECUTESQL @Consulta_Busq_ADF, @ParDef_Busq_ADF, @Documento = @Documento, @numDoc = @numDoc, @ParExento = @ParExento, @NumCtas_Ent = @NumCtas OUTPUT

			IF @NumCtas < 1
			BEGIN
				SET @Inserta_ADF = N'INSERT INTO ' + @Servidor + N'.FYC.DBO.ASPECTO_DOCUMENTO_FECHA VALUES(@Documento, @numDoc, @ParExento, GETDATE())'
				EXECUTE SP_EXECUTESQL @Inserta_ADF, @ParDef_Ins_ADF, @Documento = @Documento, @numDoc = @numDoc, @ParExento = @ParExento
				INSERT INTO Registro_GMF VALUES(@TIPONIT, @NIT, @Documento, @numDoc, GETDATE(), @Servidor, 'Marcación Ok')
			END
			ELSE
			BEGIN
				SET @Inserta_ADF = N'UPDATE ADF SET ADF_Fecha = GETDATE() FROM ' + @Servidor + N'.FYC.DBO.ASPECTO_DOCUMENTO_FECHA ADF WHERE ADF_DocumentoTipo = @Documento AND ADF_ParámetroNombre = @ParExento AND ADF_DocumentoNúmero = @numDoc'
				EXECUTE SP_EXECUTESQL @Inserta_ADF, @ParDef_Ins_ADF, @Documento = @Documento, @numDoc = @numDoc, @ParExento = @ParExento
				INSERT INTO Registro_GMF VALUES(@TIPONIT, @NIT, @Documento, @numDoc, GETDATE(), @Servidor, 'Actualiza fecha')
			END
		END
		ELSE
		BEGIN
			DELETE FROM Registro_GMF 
			 WHERE RG_Nit = @NIT 
			   AND RG_Observacion = 'Ya marcada'
			INSERT INTO REGISTRO_GMF VALUES(@TIPONIT, @NIT, @Documento, @numDoc, GETDATE(), @Servidor, 'Ya marcada')
		END
	END-- puede marcar cuenta excenta 
	ELSE
	BEGIN-- no puede marcar cuenta excenta 
		INSERT INTO Registro_GMF VALUES(@TIPONIT, @NIT, @Documento, @numDoc, GETDATE(), @Servidor, 'Sin cuenta activa' )
	END -- no puede marcar cuenta excenta
	FETCH NEXT FROM _EXCENTOS INTO @TIPONIT, @NIT, @Ciudad
END
CLOSE _EXCENTOS
DEALLOCATE _EXCENTOS

SELECT A.*, 
		 ADF_Fecha,
		 RG_Observacion,
		 'midas' Servidor
  FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
       midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B, 
		 midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
		 REGISTRO_GMF
 WHERE RPD_DocumentoTipo = ADN_DocumentoTipo
   AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
   AND RPD_DocumentoTipo = RG_Documento
   AND RPD_DocumentoNúmero = RG_Numero
   AND RPD_DocumentoTipo = ADF_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
   AND ADN_ParámetroNombre ='[AplicarGMF]'
   AND RG_Fecha >= @Fecha
 UNION
SELECT A.*, 
		 ADF_Fecha,
		 RG_Observacion,
		 'midas' Servidor
  FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
       midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B, 
		 midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
		 REGISTRO_GMF
 WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
   AND RPD_DocumentoTipo = RG_Documento
   AND RPD_DocumentoNúmero = RG_Numero
   AND RPD_DocumentoTipo = ADF_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
   AND ADN_ParámetroNombre ='[AplicarGMF]'
   AND RG_Fecha >= @Fecha
 UNION
SELECT A.*,
		 ADF_Fecha,
		 RG_Observacion,
		 'midas' Servidor
  FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
       midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
		 midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
		 REGISTRO_GMF
 WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
   AND RPD_DocumentoTipo = RG_Documento
   AND RPD_DocumentoNúmero = RG_Numero
   AND RPD_DocumentoTipo = ADF_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
   AND ADN_ParámetroNombre ='[AplicarGMF]'
   AND RG_Fecha >= @Fecha
 UNION
SELECT A.*, ADF_Fecha,
		 RG_Observacion,
		 'midas' Servidor
  FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
       midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
		 midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
		 REGISTRO_GMF
 WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
   AND RPD_DocumentoTipo = RG_Documento
   AND RPD_DocumentoNúmero = RG_Numero
   AND RPD_DocumentoTipo = ADF_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
   AND ADN_ParámetroNombre ='[AplicarGMF]'
   AND RG_Fecha >= @Fecha
 UNION
SELECT A.*,
		 ADF_Fecha,
		 RG_Observacion,
		 'midas' Servidor
  FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
       midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
		 midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
		 REGISTRO_GMF
 WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
   AND RPD_DocumentoTipo = RG_Documento
   AND RPD_DocumentoNúmero = RG_Numero
   AND RPD_DocumentoTipo = ADF_DocumentoTipo 
   AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
   AND ADN_ParámetroNombre ='[AplicarGMF]'
   AND RG_Fecha >= @Fecha

SELECT Servidor,
		 RG_Observacion,
		 COUNT(1) 
  FROM (SELECT A.*,
					ADF_Fecha,
					RG_Observacion,
					'midas' Servidor
			 FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
					REGISTRO_GMF
			WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
			  AND RPD_DocumentoTipo = RG_Documento
			  AND RPD_DocumentoNúmero = RG_Numero
			  AND RPD_DocumentoTipo = ADF_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
			  AND ADN_ParámetroNombre ='[AplicarGMF]'
			  AND RG_Fecha >= @Fecha
			UNION
  		  SELECT A.*, 
  		  			ADF_Fecha,
  		  			RG_Observacion,
  		  			'midas' Servidor
  		    FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
  		  			midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
  		  			midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
  		  			REGISTRO_GMF
  		   WHERE RPD_DocumentoTipo = ADN_DocumentoTipo
  		     AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
  		  	  AND RPD_DocumentoTipo = RG_Documento
  		  	  AND RPD_DocumentoNúmero = RG_Numero
  		  	  AND RPD_DocumentoTipo = ADF_DocumentoTipo 
  		  	  AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
  		  	  AND ADN_ParámetroNombre ='[AplicarGMF]'
  		  	  AND RG_Fecha >= @Fecha
			UNION
		  SELECT A.*,
					ADF_Fecha,
					RG_Observacion,
					'midas' Servidor
			 FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B, 
					midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
					REGISTRO_GMF
			WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
			  AND RPD_DocumentoTipo = RG_Documento
			  AND RPD_DocumentoNúmero = RG_Numero
			  AND RPD_DocumentoTipo = ADF_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
			  AND ADN_ParámetroNombre ='[AplicarGMF]'
			  AND RG_Fecha >= @Fecha
			UNION
		  SELECT A.*,
					ADF_Fecha,
					RG_Observacion,
					'midas' Servidor
			 FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
					REGISTRO_GMF
			WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
			  AND RPD_DocumentoTipo = RG_Documento
			  AND RPD_DocumentoNúmero = RG_Numero
			  AND RPD_DocumentoTipo = ADF_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
			  AND ADN_ParámetroNombre ='[AplicarGMF]'
			  AND RG_Fecha >= @Fecha
			UNION
		  SELECT A.*,
					ADF_Fecha,
					RG_Observacion,
					'midas' Servidor
			 FROM midas.FYC.DBO.ROL_PERSONA_DOCUMENTO A,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_NULO B,
					midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA C,
					REGISTRO_GMF
			WHERE RPD_DocumentoTipo = ADN_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADN_DocumentoNúmero 
			  AND RPD_DocumentoTipo = RG_Documento
			  AND RPD_DocumentoNúmero = RG_Numero
			  AND RPD_DocumentoTipo = ADF_DocumentoTipo 
			  AND RPD_DocumentoNúmero = ADF_DocumentoNúmero 
			  AND ADN_ParámetroNombre ='[AplicarGMF]'
			  AND RG_Fecha >= @Fecha) T
 GROUP BY Servidor, RG_Observacion

			
----paso 3 consulta historico
 SELECT *  
FROM  CAVIPETROL.DBO.REGISTRO_GMF
WHERE RG_Nit = @PA_CEDULA
--WHERE RG_Nit in (1010180791)
--ORDER BY 2 DESC,5     
 
 END

 --EXEC SP_GMF_MARCACION '19315624'