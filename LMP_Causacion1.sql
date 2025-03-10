USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[LMP_Causacion1]    Script Date: 9/12/2024 8:40:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[LMP_Causacion1] AS

-- -------------------------------------------------------------------------------------------------------
--      PROYECTO FYC
-- -------------------------------------------------------------------------------------------------------
--       COMPONENTE 
--       MODULO:  						
--       PROCED:							
--       VERSION:    1.0       REVISION:                                           
-- -------------------------------------------------------------------------------------------------------
--       AUTOR:   Francisco Alvarado 	             
--       FECHA DE CREACION: 10 Agosto 2002
--       REQUERIMIENTO No:							
-- -------------------------------------------------------------------------------------------------------
--       MODIFICADO:
-- -------------------------------------------------------------------------------------------------------
--      1 Responsable: Francisco Alvarado
--         Fecha:  24 Octubre 2006
--         Requerimiento No: 759
--         Descripción: Limpia las transacciones de control Semanales
-- -------------------------------------------------------------------------------------------------------
--      2 Responsable: Francisco Alvarado
--         Fecha:  27 de Marzo del 2007
--         Requerimiento No: 2506
--         Descripción: Limpia las transacciones de seguros TMP_PAGOS_SEGUROS
--     Modificado: Juan Leguizamon-TALYCAP      Fecha   : 9 DIC 2024
--     Descripcion: Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
-- -------------------------------------------------------------------------------------------------------
--         MACRO
-- -------------------------------------------------------------------------------------------------------
-- Propósito      : Limpiar Operaciones de tipo 'retención'
--                        de una fecha dada hacia atrás.
--
-- -------------------------------------------------------------------------------------------------------

DECLARE 
	@CualOperTipo	VARCHAR(16),
	@CualOperNum	INT,
	--@CualFecha	SMALLDATETIME,
     @CualAsiento    VARCHAR(16),
	@CualMovNum     INT,
	@FECHA_INICIO_PROCESO DATETIME
PRINT '...........................................................'
PRINT 'Tenga en cuenta las siguientes instrucciones:              '
PRINT '1. No pare el programa ya que solo actualiza en el momento '
PRINT '   de fin de cursor                                        '
PRINT '2. Asegurese deque se hubiera corrido el totalizador      '
PRINT '   Si no lo ha hecho detenga el proceso de inmediato  o    '
PRINT '   atengase a las consecuencias                            '          
PRINT '...........................................................'

SET @FECHA_INICIO_PROCESO = GETDATE () 

INSERT INTO CONTROL_PROCESOS
VALUES (@FECHA_INICIO_PROCESO ,NULL,'MaestraSeguros','LMP_Causacion1',fyc.[dbo].[fechaproceso]())		
-- ACTUALIZA LA INFORAMCIÓN DE LA TABLA CENTRALIZADA DE FYC



--SELECT @CualFecha = DATEADD (MONTH
--		,(SELECT	-VDS_Variable_Valor
--		  FROM	VARIABLES_SISTEMA
--		  WHERE	VDS_Nombre like 'LMP_Causación')

--		,(SELECT	MIN(VDS_Variable_Fecha) 
--		  FROM	VARIABLES_SISTEMA
--		  WHERE	VDS_Nombre = 'CierreContable'
--		  OR	VDS_Nombre = 'CierreOperación'))


DELETE FROM MOVIMIENTO
FROM   ASIENTO
WHERE  ASI_OPERACION    = 'Causacion' 	AND
       ASI_Tipo          =  MVC_AsientoTipo 	AND
       ASI_Consecutivo   =  MVC_AsientoConsecutivo

DELETE  FROM TMP_MOVIMIENTO
DELETE  FROM TMP_ASIENTO

-- Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
PRINT 'Guardando los datos en VINCULO_OPERACIONES_HIST antes de la limpieza.';
INSERT INTO VINCULO_OPERACIONES_HIST (VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase)
SELECT VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase
FROM VINCULO_OPERACIONES;

PRINT 'Datos guardados en VINCULO_OPERACIONES_HIST.';


DECLARE _operaciones CURSOR FOR


SELECT ASI_OPERACION    ,
       ASI_OPERACION_CONSECUTIVO,
       MVC_AsientoConsecutivo,
       ASI_Tipo 
FROM   
       MOVIMIENTO,
       ASIENTO
WHERE  ASI_OPERACION   = 'Causacion' 	AND
       ASI_Tipo          =  MVC_AsientoTipo 	AND
       ASI_OPERACION_CONSECUTIVO =  MVC_AsientoConsecutivo
       

OPEN _operaciones


FETCH NEXT FROM _operaciones
INTO	@CualOperTipo,
	@CualOperNum,
        @CualMovNum,

        @CualAsiento 



WHILE (@@fetch_status<>-1)                   /* No es fin del cursor */

BEGIN
	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASIENTO Y MOVIMIENTO                       */
	/* -------------------------------------------------------------- */

	/*DELETE FROM MOVIMIENTO
	WHERE	MVC_AsientoTipo + CONVERT(VARCHAR,MVC_AsientoConsecutivo) = 
		(SELECT	ASI_Tipo + CONVERT(VARCHAR,ASI_Consecutivo)
		 FROM	ASIENTO
		 WHERE	ASI_OperaciónTipo = @CualOperTipo

		 /*AND	ASI_OperaciónConsecutivo = @CualOperNum*/

                 AND    ASI_OperaciónConsecutivo>=4359  
                 AND    ASI_OperaciónConsecutivo<=10000)*/
       
       SELECT @CualOperTipo,
	@CualOperNum,
        @CualMovNum,
        @CualAsiento 

       DELETE 
       FROM 	MOVIMIENTO
       WHERE    MVC_AsientoTipo       = @CualAsiento    AND

                MVC_AsientoConsecutivo= @CualMovNum     

    print 'borro'

    FETCH NEXT FROM _operaciones
    INTO	@CualOperTipo,

		@CualOperNum,
                @CualMovNum,
                @CualAsiento 

END
CLOSE _operaciones
DEALLOCATE _operaciones

SELECT @CualOperTipo='Causacion'



PRINT 'Comienza borrado sobre la tabla ASIENTO'

	DELETE FROM ASIENTO

	WHERE	ASI_OPERACION= @CualOperTipo

	/*AND	ASI_OPERACION_CONSECUTIVO = @CualOperNum*/

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_CADENA                   */

	/* -------------------------------------------------------------- */


PRINT 'Comienza borrado sobre la tabla ASPECTO_OPERACION_CADENA'

	DELETE FROM ASPECTO_OPERACION_CADENA
	WHERE	AOC_OperaciónTipo = @CualOperTipo
	/*AND	AOC_OperaciónConsecutivo = @CualOperNum*/


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_FECHA                    */
	/* -------------------------------------------------------------- */

PRINT 'Comienza borrado sobre la tabla ASPECTO_OPERACION_FECHA'

	DELETE FROM ASPECTO_OPERACION_FECHA
	WHERE	AOF_OperaciónTipo = @CualOperTipo
	/*AND	AOF_OperaciónConsecutivo = @CualOperNum*/

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_NULO                     */

	/* -------------------------------------------------------------- */


PRINT 'Comienza borrado sobre la tabla ASPECTO_OPERACION_NULO'

	DELETE FROM ASPECTO_OPERACION_NULO

	WHERE	AON_OperaciónTipo = @CualOperTipo
	/*AND	AON_OperaciónConsecutivo = @CualOperNum*/


	/* -------------------------------------------------------------- */

	/*  Limpia la tabla de ASPECTO_OPERACION_VALOR                    */ 
	/* -------------------------------------------------------------- */

PRINT 'Comienza borrado sobre la tabla ASPECTO_OPERACION_VALOR'

	DELETE FROM ASPECTO_OPERACION_VALOR
	WHERE	AOV_OperaciónTipo = 'Causacion'
	/*AND	AOV_OperaciónConsecutivo = @CualOperNum*/

Select  @CualOperTipo = 'Causacion'

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de MEDIOS_DE_PAGO                             */
	/* -------------------------------------------------------------- */


	DELETE FROM MEDIOS_DE_PAGO
	WHERE	MDP_OperaciónTipo = @CualOperTipo

	/*AND	MDP_OperaciónConsecutivo = @CualOperNum*/


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de MOVIMIENTO_CUENTA_PARALELA                 */
	/* -------------------------------------------------------------- */


PRINT 'Comienza borrado sobre la tabla MOVIMIENTO_CUENTA_PARALELA'

	DELETE FROM MOVIMIENTO_CUENTA_PARALELA

	WHERE	MCP_OperaciónTipo = @CualOperTipo

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ROL_PERSONA_OPERACION                      */


	/* -------------------------------------------------------------- */

	DELETE FROM ROL_PERSONA_OPERACION
	WHERE	RPO_OperaciónTipo = @CualOperTipo
	/*AND	RPO_OperaciónConsecutivo = @CualOperNum*/


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de VINCULO_DCTOPR                             */
	/* -------------------------------------------------------------- */

	DELETE FROM VINCULO_DCTOPR
	WHERE	VDO_OperaciónTipo = @CualOperTipo

	/*AND	VDO_OperaciónConsecutivo = @CualOperNum*/

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de VINCULO_OPERACIONES                        */

	/* -------------------------------------------------------------- */

	DELETE FROM VINCULO_OPERACIONES

	WHERE	VOP_OrigenTipo  = 'Causacion'
	/*AND	VOP_OrigenConsecutivo = @CualOperNum*/
  
/* -------------------------------------------------------------- */

/*  Limpia la tabla de OPERACION                                  */
/* -------------------------------------------------------------- */

PRINT 'Comienza borrado sobre la tabla OPERACION'

DELETE FROM OPERACION
WHERE	OPR_Tipo = 'Causacion'

DELETE TMP_OPERACION

SELECT 'El proceso de limpieza de la operación RetencioFte ha finalizado satisfactoriamente' RESULTADO
PRINT 'COMIENZA LIMPIEZA DE LOS ESPEJOS DEL CLIENTE NO TOCAR...'
DELETE ASPECTO_OPERACION_VR_TEMP_FRON
DELETE ASPECTO_OPERACION_CD_TEMP_FRON
DELETE ASPECTO_OPERACION_VR_TEMP
DELETE TMP_ASPECTO_OPERACION_VALOR
DELETE TMP_ASPECTO_OPERACION_CADENA
DELETE TMP_ROL_PERSONA_OPERACION

SELECT 'SE VAN A LIMPIAR CENTROS TRANSACCIONALES'
DELETE EVOLUCION_TERMINO
WHERE ETE_EstadoNombre  ='ABIERTA'

DELETE EVOLUCION_TERMINO
FROM  EVOLUCION_TERMINO O
WHERE O.ETE_EstadoNombre  ='CERRADA' AND

      O.ETE_Fecha<(SELECT MAX(P.ETE_Fecha )
                   FROM   EVOLUCION_TERMINO P
                   WHERE  O.ETE_DeDocumentoTipo   = P.ETE_DeDocumentoTipo	AND
                          O.ETE_DeDocumentoNúmero =P.ETE_DeDocumentoNúmero	AND
                          O.ETE_DeNúmeroTérmino   =P.ETE_DeNúmeroTérmino	AND
                          O.ETE_EstadoProducto    =P.ETE_EstadoProducto
       )
DELETE GRUPO_TRANSACCIONAL
DELETE TMP_LIBRO_DE_BANCOS_CAJA
DELETE TMP_ASPECTOS_INTERPRODUCTOS
DELETE MOV_LAC
DELETE VINCULO_OPERACIONES
DELETE RELACION_SOPORTES_ORIGENES    
DELETE RELACION_SOPORTES_DESTINO
DELETE AUTORIZADOR_OPERACIONES
-- Borra las inconsistencias en las garantias para cargar listyado de errores
EXEC BORRA_GARANTIAS_HIPOTECARIAS_INC
-- Borra la tabla de control para iniciar control de giros solo los días domingos

IF  DATEPART(dW, fyc.[dbo].[fechaproceso]()) =1--nacevedo modificacion 10/05/2017
BEGIN
  DELETE  T_APLICA_TRANSFERENCIA_MONTO
END

UPDATE CONTROL_PROCESOS
SET  CTRT_Fecha_Final =GETDATE ()
WHERE CTRT_Proceso ='MaestraSeguros' AND
CTRT_SubProceso='LMP_Causacion1' and CTRT_Fecha_Proceso = fyc.[dbo].[fechaproceso] ()

