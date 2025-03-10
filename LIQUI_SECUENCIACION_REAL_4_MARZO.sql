USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[LIQUI_SECUENCIACION]    Script Date: 3/03/2025 4:39:59 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 5/29/2004 11:52:29 PM ******/
/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 05/04/2004 05:24:11 PM ******/
/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 12/26/2000 09:37:50 AM ******/
/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 12/25/2000 08:22:02 AM ******/
/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 08/19/2000 2:00:49 PM ******/
/****** Object:  Stored Procedure dbo.LIQUI_SECUENCIACION    Script Date: 03/17/2000 09:51:52 AM ******/
ALTER PROCEDURE [dbo].[LIQUI_SECUENCIACION] @TIPO_OP VARCHAR(16), @NUMERO_OP INT,
                              @DOC_TIPO VARCHAR(16), @DOC_NUM INT,
                              @NUM_TER INT AS 


/* ******************************************************************************* *
 *                 -PROYECTO SISTEMA FINANCIERO Y CONTABLE CAVIPETROL-             *
 *                                                                                 *
 *       COMPONENTE: PROCESADOR DE OPERACIONES                                     *
 *       PROCED:     Liquidación por Secuenciación UNO                                *
 *                                                                                 *
 *       VERSION:    1.0                                                           *
 * ------------------------------------------------------------------------------- *
 *       AUTOR: Hector Camilo Gonzalez.   -MANAGEMENT-                             *
 * ------------------------------------------------------------------------------- *
 * CREACION: AGO-1995.             ULTIMA MODIFICACION: FEB-1996                   *
 * estado:   OK.                                                                   *
 * ******************************************************************************* */

/* DESCRIPCION ******************************************************************* *
 * Creación de parámetros de operación. Dependen de operaciones Origen - Destino   *
 * ******************************************************************************* */

/* PARAMETROS ******************************************************************** *
 * TIPO_OP  : Tipo de la operación a la cual se le verificarán los parámetros.     *
 * NUMERO_OP: Número consecutivo de dicha operación                                *
 * DOC_TIPO : Documento Tipo                                                       *
 * DOC_NUM  : Documento Número                                                     *
 * NUM_TER  : Número Término                                                       *
 * ******************************************************************************* */
-- -------------------------------------------------------------------------------------------------------
--       MODIFICADO: 
-- -------------------------------------------------------------------------------------------------------
--      1 Responsable: EDWIN CESAR SANCHEZ PRIETO
--         Fecha: 29 NOV 2017
--         Requerimiento No: 
--         Descripción: Se habilita la liquidacion por secuenciación para el GMF.
--           * La operación con el item nulo [GMFASOCIADO], aplia el calculo de GMF para el afiliado por FAI 
--           * En la operación el nombre del parametro se define en el item_cadena con  la descripcion '%[AplicaGMF]%'.
--             de esta forma no es un elemento fijo. 
--           * La cuenta FAI se marca con el documento nulo [ExcentoGMF] para que aplique los topes excentos.
--           * La cuenta FAI control el valor de los retiros por mes en la cuenta GMFControlND.
-- -------------------------------------------------------------------------------------------------------
--      2 Responsable: EDWIN SANCHEZ 
--         Fecha: 12-ENE-2018
--         Requerimiento No: 
--         Descripción: SE VALIDA EL NULO AL CONSULTAR LOS VALORES DE RETIROS DEL MES
-- -------------------------------------------------------------------------------------------------------
--      3 Responsable: EDWIN SANCHEZ 
--         Fecha: 28-ENE-2021
--         Requerimiento No: 
--         Descripción: SE AJUSTA LA CONSULTA DE LOS RETIROS DEL MES
--                      SE INCLUYE EL MANEJO  PARA NO BLOQUEAR EN LA CONSULTA.
-- -------------------------------------------------------------------------------------------------------

/* 
 * Declaración de variables 
 */

DECLARE @ITEM_NOMBRE    VARCHAR(16), /* Nombre parámetro operación              */
        @ITEM_VALOR     FLOAT,       /* Valor parámetro operación               */
        @ITEM_VALOR_TMP FLOAT,        /* Temporal Valor parámetro                */
        @OP_ORIGEN      VARCHAR(16), /* Operación Origen                        */
        @OP_ORI_CONSEC  INT,         /* Consecutivo de la operación Origen      */
        @FACTOR         VARCHAR(16), /* OJO, es el item de la operación origen  */
        @FACTOR_VALOR   FLOAT,       /* Valor de dicho factor                   */
        @COEFICIENTE    FLOAT,       /* Coeficiente                             */
        @HOY            DATETIME     /* Fecha del dia de hoy                    */

-- declaración valriables gmf 
DECLARE @GMF_FACTOR  FLOAT, -- PORCENTAJE DE GMF QUE APLICA
        @GMF_TOPE_EXCENTO FLOAT, -- VALOR MAXIMO EXENTO DE GMF
		@GMF_VALOR_RETIROS_MES FLOAT  , -- VALOR DE RETIROS MES
		@GMF_VALOR_APLICAR FLOAT

SELECT @GMF_FACTOR = 0 , -- PORCENTAJE DE GMF QUE APLICA
        @GMF_TOPE_EXCENTO = 0, -- VALOR MAXIMO EXENTO DE GMF
		@GMF_VALOR_RETIROS_MES = 0 , -- VALOR ACUMULADO RETIROS EN MES
		@GMF_VALOR_APLICAR = 0 

/*
 * En vinculo operación se estabece cual es la operación origen
 * de la cual proviene la actual operación. 
 */

 

SELECT @OP_ORIGEN     = VOP_OrigenTipo,
       @OP_ORI_CONSEC = VOP_OrigenConsecutivo
FROM   VINCULO_OPERACIONES
WHERE  VOP_DestinoTipo        = @TIPO_OP AND
       VOP_DestinoConsecutivo = @NUMERO_OP 

SELECT @HOY = GETDATE()

/*
 * Se busca en LIQUIDACION_POR_SECUENCIACION para obtener el nombre del
 * parámetro que se va a generar, para la operación que se esta tramitando.
 * Luego en ITEM_LIQUIDACION_SECUENCIACION se obtiene los factores y los
 * coeficientes de multiplicación.
 */

DECLARE CU_Liq_Secuenciación CURSOR FOR
   SELECT LPS_ItemNombre

   FROM   LIQUIDACION_POR_SECUENCIACION
   WHERE  LPS_OperaciónOrigen  = @OP_ORIGEN AND
          LPS_OperaciónDestino = @TIPO_OP 

OPEN CU_Liq_Secuenciación

FETCH NEXT FROM CU_Liq_Secuenciación INTO @ITEM_NOMBRE
WHILE (@@fetch_status <> -1)
BEGIN

   IF (@@fetch_status <> -2)
   BEGIN

      
      SELECT @ITEM_VALOR = 0
      


            /*
             * Se obtiene el valor del parámetro de la operación,
             * asi podemos calcular el parámetro que se secuencia a la
             * operación destino (operación actual)
             */
            /* 
             * En este caso 'FACTOR' es el item de la operacion origen !!!
             */


   SELECT @ITEM_VALOR = SUM(ISNULL(ILS_Coeficiente,0) * AOV_Valor)
   FROM   ITEM_LIQUIDA_SECUENCIA, 
                TMP_ASPECTO_OPERACION_VALOR
   WHERE  ILS_OperaciónOrigen      = @OP_ORIGEN   AND
          ILS_OperaciónDestino     = @TIPO_OP     AND
          ILS_ItemNombre           = @ITEM_NOMBRE AND
          AOV_OperaciónTipo        = @OP_ORIGEN AND 
          AOV_OperaciónConsecutivo = @OP_ORI_CONSEC AND 
          AOV_ItemNombre           = ILS_Factor
            SELECT @ITEM_VALOR_TMP = 0

            SELECT @ITEM_VALOR_TMP = SUM (CASE
                     WHEN AOV_Valor IS NULL Then 1
                     ELSE 0
                   END)
            FROM   ITEM_LIQUIDA_SECUENCIA LEFT JOIN TMP_ASPECTO_OPERACION_VALOR  ON  
                   (ILS_OperaciónOrigen     = AOV_OperaciónTipo   AND
                    AOV_ItemNombre          = ILS_Factor )       
            WHERE  ILS_OperaciónDestino     = @TIPO_OP     AND
                   ILS_ItemNombre           = @ITEM_NOMBRE AND
                   AOV_OperaciónTipo        = @OP_ORIGEN AND 
                   AOV_OperaciónConsecutivo = @OP_ORI_CONSEC
                   

            IF @ITEM_VALOR_TMP <> 0
            BEGIN
               EXEC REGISTRAR_ERROR @HOY, 'LIQUI_SECUECIA', @TIPO_OP, 141, 'No encontrado item valor', 1

            END

            /* Cálculo del valor del parámetro de la operación */      
     
      INSERT ASPECTO_OPERACION_VALOR
             (AOV_OperaciónTipo, AOV_OperaciónConsecutivo, AOV_ItemNombre, AOV_Valor)
      VALUES (@TIPO_OP, @NUMERO_OP, @ITEM_NOMBRE, ROUND(@ITEM_VALOR,0))
/***************************************************************************/
/*Cambio realizado por : Francisco alvarado                                */
/*Objetivo   Mejorar rendimiuento base de datos en la base de datos access */
/***************************************************************************/

      INSERT ASPECTO_OPERACION_VR_TEMP_FRON
             (AOV_OperaciónTipo, AOV_OperaciónConsecutivo, AOV_ItemNombre, AOV_Valor)
      VALUES (@TIPO_OP, @NUMERO_OP, @ITEM_NOMBRE, ROUND(@ITEM_VALOR,0))

	  -- VALIDA SI REQUIERE CALCULAR EL PARAMETRO DE GMF
	  -----------------------------------------------------------------------
	  IF EXISTS( SELECT * FROM ITEM_OPERACION_NULO WHERE ION_Tipo = @TIPO_OP AND ION_Nombre = '[GMFASOCIADO]') 
	  BEGIN -- GENERA GMF
	    PRINT 'COBRAR GMF ASOCIADO'
		SELECT @GMF_FACTOR = ISNULL(MAX(CON_VALOR) ,0) , @GMF_VALOR_RETIROS_MES= COUNT(*) 
		   FROM CONSTANTE  
		WHERE CON_Nombre  = 'GMF_FACTOR'
		SELECT @GMF_VALOR_RETIROS_MES = 0   , @GMF_TOPE_EXCENTO = 0
		IF EXISTS( SELECT * FROM ASPECTO_DOCUMENTO_NULO 
		            WHERE ADN_DocumentoTipo = @DOC_TIPO AND ADN_DocumentoNúmero = @DOC_NUM AND ADN_ParámetroNombre = '[AplicarGMF]' ) 
		begin
		    SELECT  @GMF_VALOR_APLICAR  = @ITEM_VALOR * @GMF_FACTOR 
		end 
		else
		begin
			 SELECT  @GMF_VALOR_APLICAR  = 0 
		end

	   INSERT INTO ASPECTO_OPERACION_VALOR 
       select DISTINCT @TIPO_OP, @NUMERO_OP, IOV_Nombre ,  ABS(ROUND(@GMF_VALOR_APLICAR,3))
	     from ITEM_OPERACION_VALOR 
		 Join ITEM_OPERACION_CADENA 
		 on ( IOV_Tipo = IOC_Tipo  and IOV_Nombre = IOC_Nombre ) 
	   where IOV_Tipo = @TIPO_OP
	     and IOC_Descripción like '%[AplicaGMF]%' 

	   INSERT ASPECTO_OPERACION_VR_TEMP_FRON
		select @TIPO_OP, @NUMERO_OP, IOV_Nombre ,  ABS(ROUND(@GMF_VALOR_APLICAR,3))
	     from ITEM_OPERACION_VALOR 
		 Join ITEM_OPERACION_CADENA 
		 on ( IOV_Tipo = IOC_Tipo  and IOV_Nombre = IOC_Nombre ) 
	   where IOV_Tipo = @TIPO_OP
	     and IOC_Descripción like '%[AplicaGMF]%' 
	  END 	  
	  ----------------------------------------------------------------------- 
   END
   FETCH NEXT FROM CU_Liq_Secuenciación INTO @ITEM_NOMBRE

END



CLOSE CU_Liq_Secuenciación
DEALLOCATE CU_Liq_Secuenciación 


RETURN 0



