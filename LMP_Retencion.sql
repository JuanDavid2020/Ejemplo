USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[LMP_Retencion]    Script Date: 6/12/2024 4:17:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 03/07/2004 07:53:42 p.m. ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 05/29/2004 11:31:37 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 05/04/2004 05:24:11 PM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 9/9/01 11:46:37 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 12/26/2000 09:37:54 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 12/25/2000 08:22:06 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 08/19/2000 2:00:52 PM ******/
/****** Object:  Stored Procedure dbo.LMP_Retencion    Script Date: 03/17/2000 09:51:55 AM ******/ 
ALTER PROCEDURE [dbo].[LMP_Retencion] AS

/*************************************************************************

Título         : LMP_Retencion 

Propósito      : Limpiar Operaciones de tipo 'retención'
		 de una fecha dada hacia atrás.

----------------------------------------------------------------------------
Autor  : Francisco Alvarado                        
	Modificación: 	Agosto 22 2002
	                Enero 31  2010 
	                Marzo 09  2011
	                Abril 06  2011    
	                --Se ingreso copia  a la tabal de causación del producto FAI
*****************************************************************************/
-- -------------------------------------------------------------------------------------------------------
--      1 Responsable: NESTOR ACEVEDO 
--         Fecha: 19/02/2018
--         Requerimiento No: 
--         Descripción: Se realiza ajuste se cambia GETDATE por la funcion [fechaproceso]
-- -------------------------------------------------------------------------------------------------------
--Modificado: Juan Leguizamon-TALYCAP      Fecha   : 9 DIC 2024
--Descripcion: Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
/**************************************************/
/*Macro                                           */
/*Eliminar todas las operaciones haciendo barrido */
/**************************************************/

DECLARE 
	@CualOperTipo	VARCHAR(16),
	@CualOperNum	INT,
	@CualFecha	SMALLDATETIME,
        @CualAsiento    VARCHAR(16),
	@CualMovNum     INT


-- Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
PRINT 'Guardando los datos en VINCULO_OPERACIONES_HIST antes de la limpieza.';
INSERT INTO VINCULO_OPERACIONES_HIST (VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase)
SELECT VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase
FROM VINCULO_OPERACIONES;

PRINT 'Datos guardados en VINCULO_OPERACIONES_HIST.';

PRINT '...........................................................'

PRINT 'Tenga en cuenta las siguientes instrucciones:              '
PRINT '1. No pare el programa ya que solo actualiza en el momento '
PRINT '   de fin de cursor                                        '
PRINT '2. Asegurese de que se hubiera corrido el totalizador      '
PRINT '   Si no lo ha hecho detenga el proceso de inmediato  o    '
PRINT '   atengase a las consecuencias                            '          
PRINT '...........................................................'



/* SELECT @CualFecha = DATEADD (MONTH
		,(SELECT	-VDS_Variable_Valor
		  FROM	VARIABLES_SISTEMA
		  WHERE	VDS_Nombre like 'LMP_Causación')
		,(SELECT	MIN(VDS_Variable_Fecha) 
		  FROM	VARIABLES_SISTEMA
		  WHERE	VDS_Nombre = 'CierreContable'
		  OR	VDS_Nombre = 'CierreOperación')) */



SELECT @CualOperTipo='RetencionFte'

PRINT 'Comienza borrado sobre la tabla ASIENTO'

/*	DELETE FROM ASIENTO

	WHERE	ASI_OPERACION     = @CualOperTipo*/

	/*AND	ASI_OperaciónConsecutivo = @CualOperNum*/

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
	WHERE	AOV_OperaciónTipo = @CualOperTipo
	/*AND	AOV_OperaciónConsecutivo = @CualOperNum*/


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de GRUPO_TRANSACCIONAL                        */
	/* -------------------------------------------------------------- */

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

	INSERT INTO  MCP_TMP1
	select fyc.[dbo].[fechaproceso](),*,'N/A',null  
	FROM MOVIMIENTO_CUENTA_PARALELA
	WHERE	MCP_OperaciónTipo = @CualOperTipo
	
    INSERT INTO  MCP_TMP_CAUSACION_FAI
	select fyc.[dbo].[fechaproceso](),*,'N/A',null  
	FROM MOVIMIENTO_CUENTA_PARALELA
	WHERE	MCP_OperaciónTipo = @CualOperTipo

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

	WHERE	VOP_OrigenTipo  = 'RetencionFte'
	/*AND	VOP_OrigenConsecutivo = @CualOperNum*/

/* -------------------------------------------------------------- */
/*  Limpia la tabla de OPERACION                                  */
/* -------------------------------------------------------------- */

PRINT 'Comienza borrado sobre la tabla OPERACION'

DELETE OPERACION
WHERE	OPR_Tipo = 'RetencionFte'

DELETE cavinet_movimientos
WHERE CAVM_TipoOperacion = 'RetencionFte'

DELETE TMP_OPERACION


--- Inserta en el HST los LOGS de historicos de SMS
INSERT INTO  LOG_CONTROLES_FAI_SMS_HST 
SELECT * FROM  LOG_CONTROLES_FAI_SMS

DELETE LOG_CONTROLES_FAI_SMS

SELECT 'El proceso de limpieza de la operación RetencioFte ha finalizado satisfactoriamente' RESULTADO
PRINT 'COMIENZA LIMPIEZA DE LOS ESPEJOS'
DELETE ASPECTO_OPERACION_VR_TEMP_FRON


