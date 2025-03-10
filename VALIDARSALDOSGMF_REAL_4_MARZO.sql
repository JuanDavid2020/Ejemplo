USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[VALIDARSALDOSGMF]    Script Date: 4/03/2025 8:54:16 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[VALIDARSALDOSGMF]  
@DOC_TIPO VARCHAR(16), @DOC_NUM INT,  @NUM_TER INT, @VALOR_RETIRO FLOAT, @VALOR_GMF FLOAT OUTPUT
AS
-- -------------------------------------------------------------------------------------------------------
--      PROYECTO FYC
-- -------------------------------------------------------------------------------------------------------
--       COMPONENTE
--       MODULO: CENTRAN 						
--       PROCED: VALIDARSALDOSGMF							
--       VERSION:    1.0       REVISION:                                           
-- -------------------------------------------------------------------------------------------------------
--       AUTOR: Hugo Palacios
--       FECHA DE CREACION: 21 NOV 2017
--       REQUERIMIENTO No: 							
-- -------------------------------------------------------------------------------------------------------
--       MODIFICADO:
-- -------------------------------------------------------------------------------------------------------
--      1 Responsable: EDWIN SANCHEZ 
--         Fecha: 12-ENE-2018
--         Requerimiento No: 
--         Descripción: SE VALIDA EL NULO AL CONSULTAR LOS VALORES DE RETIROS DEL MES
-- -------------------------------------------------------------------------------------------------------
--         MACRO
-- -------------------------------------------------------------------------------------------------------
--   
-- -------------------------------------------------------------------------------------------------------


-- declaración valriables gmf 
DECLARE @GMF_FACTOR  FLOAT, -- PORCENTAJE DE GMF QUE APLICA
        @GMF_TOPE_EXCENTO FLOAT, -- VALOR MAXIMO EXENTO DE GMF
		@GMF_VALOR_RETIROS_MES FLOAT  -- VALOR DE RETIROS MES

SELECT @GMF_FACTOR = 0 , -- PORCENTAJE DE GMF QUE APLICA
        @GMF_TOPE_EXCENTO = 0, -- VALOR MAXIMO EXENTO DE GMF
		@GMF_VALOR_RETIROS_MES = 0 -- VALOR ACUMULADO RETIROS EN MES
		

BEGIN	  
	  BEGIN -- GENERA GMF
	    PRINT 'COBRAR GMF ASOCIADO'
		SELECT @GMF_FACTOR = ISNULL(MAX(CON_VALOR) ,0) , @GMF_VALOR_RETIROS_MES= COUNT(*) 
		   FROM CONSTANTE  
		WHERE CON_Nombre  = 'GMF_FACTOR'
		SELECT @GMF_VALOR_RETIROS_MES = 0   , @GMF_TOPE_EXCENTO = 0
		IF EXISTS( SELECT * FROM ASPECTO_DOCUMENTO_NULO 
		            WHERE ADN_DocumentoTipo = @DOC_TIPO AND ADN_DocumentoNúmero = @DOC_NUM AND ADN_ParámetroNombre = '[AplicarGMF]' ) 
		  Begin
				SELECT  @VALOR_GMF  = @VALOR_RETIRO * @GMF_FACTOR 
		  End
		ELSE
		BEGIN
				SELECT  @VALOR_GMF  = 0 
		END
END
END

