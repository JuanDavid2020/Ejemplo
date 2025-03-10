USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[LMP_Causación]    Script Date: 6/12/2024 4:10:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 03/07/2004 07:53:40 p.m. ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 05/29/2004 11:31:36 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 05/04/2004 05:24:11 PM ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 12/26/2000 09:37:53 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 12/25/2000 08:22:05 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 08/19/2000 2:00:51 PM ******/
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 03/17/2000 09:51:54 AM ******/ 
/****** Object:  Stored Procedure dbo.LMP_Causación    Script Date: 01/19/2000 08:37:03 AM ******/
ALTER PROCEDURE [dbo].[LMP_Causación] AS

/*************************************************************************

Título         : LMP_Causación 

Propósito      : Limpiar Operaciones de tipo 'causación'
		 de una fecha dada hacia atrás.

----------------------------------------------------------------------------
Autor  : Luz Paulina Chávez                           Fecha   : 18 Ene 1996
Modificado: EDWIN CESAR SANCHEZ PRITO
Estado : ( Falta probar )                	      Ult Act : 18 Ene 2000
Modificado: Juan Leguizamon-TALYCAP      Fecha   : 9 DIC 2024
Descripcion: Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
*****************************************************************************/

DECLARE 
	@CualOperTipo	VARCHAR(16),
	@CualOperNum	INT,
	@CualFecha	SMALLDATETIME

SELECT @CualFecha = DATEADD (MONTH
		,(SELECT	-VDS_Variable_Valor
		  FROM	VARIABLES_SISTEMA
		  WHERE	VDS_Nombre like 'LMP_Causación')
		,(SELECT	MIN(VDS_Variable_Fecha) 
		  FROM	VARIABLES_SISTEMA
		  WHERE	VDS_Nombre = 'CierreContable'
		  OR	VDS_Nombre = 'CierreOperación'))


-- Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
PRINT 'Guardando los datos en VINCULO_OPERACIONES_HIST antes de la limpieza.';
INSERT INTO VINCULO_OPERACIONES_HIST (VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase)
SELECT VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase
FROM VINCULO_OPERACIONES;

PRINT 'Datos guardados en VINCULO_OPERACIONES_HIST.';


DECLARE _operaciones CURSOR FOR
  SELECT OPR_Tipo,
         OPR_Consecutivo
    FROM OPERACION
   Where Opr_Tipo in (
          select distinct OPR_Destino from ESPEJO_TOTALIZADOR )
     AND OPR_Fecha <= @CualFecha
  FOR UPDATE 
OPEN _operaciones


FETCH NEXT FROM _operaciones
INTO	@CualOperTipo,
	@CualOperNum

WHILE (@@fetch_status<>-1)                   /* No es fin del cursor */

BEGIN
	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASIENTO Y MOVIMIENTO                       */
	/* -------------------------------------------------------------- */

	DELETE FROM MOVIMIENTO
	WHERE	MVC_AsientoTipo + CONVERT(VARCHAR,MVC_AsientoConsecutivo) = 
		(SELECT	ASI_Tipo + CONVERT(VARCHAR,ASI_Consecutivo)
		 FROM	ASIENTO
		 WHERE	ASI_OPERACION  = @CualOperTipo
		 AND	ASI_OPERACION_CONSECUTIVO = @CualOperNum)

	DELETE FROM ASIENTO

	WHERE	ASI_OPERACION    = @CualOperTipo

	AND	ASI_OPERACION_CONSECUTIVO = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_CADENA                   */
	/* -------------------------------------------------------------- */

	DELETE FROM ASPECTO_OPERACION_CADENA
	WHERE	AOC_OperaciónTipo = @CualOperTipo
	AND	AOC_OperaciónConsecutivo = @CualOperNum


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_FECHA                    */
	/* -------------------------------------------------------------- */

	DELETE FROM ASPECTO_OPERACION_FECHA

	WHERE	AOF_OperaciónTipo = @CualOperTipo
	AND	AOF_OperaciónConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_NULO                     */
	/* -------------------------------------------------------------- */

	DELETE FROM ASPECTO_OPERACION_NULO
	WHERE	AON_OperaciónTipo = @CualOperTipo
	AND	AON_OperaciónConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ASPECTO_OPERACION_VALOR                    */ 
	/* -------------------------------------------------------------- */

	DELETE FROM ASPECTO_OPERACION_VALOR
	WHERE	AOV_OperaciónTipo = @CualOperTipo
	AND	AOV_OperaciónConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de GRUPO_TRANSACCIONAL                        */
	/* -------------------------------------------------------------- */

	DELETE FROM GRUPO_TRANSACCIONAL
	WHERE	GTR_OpInternaTipo = @CualOperTipo
	AND	GTR_OpInternaConsecutivo = @CualOperNum



	DELETE FROM GRUPO_TRANSACCIONAL
	WHERE	GTR_OpExternaTipo = @CualOperTipo
	AND	GTR_OpExternaConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de MEDIOS_DE_PAGO                             */
	/* -------------------------------------------------------------- */

	DELETE FROM MEDIOS_DE_PAGO
	WHERE	MDP_OperaciónTipo = @CualOperTipo
	AND	MDP_OperaciónConsecutivo = @CualOperNum



	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de MOVIMIENTO_CUENTA_PARALELA                 */
	/* -------------------------------------------------------------- */

	DELETE FROM MOVIMIENTO_CUENTA_PARALELA

	WHERE	MCP_OperaciónTipo = @CualOperTipo


	AND	MCP_OperaciónConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de ROL_PERSONA_OPERACION                      */
	/* -------------------------------------------------------------- */

	DELETE FROM ROL_PERSONA_OPERACION
	WHERE	RPO_OperaciónTipo = @CualOperTipo
	AND	RPO_OperaciónConsecutivo = @CualOperNum


	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de VINCULO_DCTOPR                             */
	/* -------------------------------------------------------------- */

	DELETE FROM VINCULO_DCTOPR
	WHERE	VDO_OperaciónTipo = @CualOperTipo

	AND	VDO_OperaciónConsecutivo = @CualOperNum

	/* -------------------------------------------------------------- */
	/*  Limpia la tabla de VINCULO_OPERACIONES                        */
	/* -------------------------------------------------------------- */

	DELETE FROM VINCULO_OPERACIONES
	WHERE	VOP_OrigenTipo = @CualOperTipo
	AND	VOP_OrigenConsecutivo = @CualOperNum


	DELETE FROM VINCULO_OPERACIONES
	WHERE	VOP_DestinoTipo = @CualOperTipo
	AND	VOP_DestinoConsecutivo = @CualOperNum


        DELETE FROM OPERACION 
        WHERE CURRENT OF _operaciones


    FETCH NEXT FROM _operaciones
    INTO	@CualOperTipo,
		@CualOperNum
END




CLOSE _operaciones

DEALLOCATE _operaciones
                                             /* Fin Barrido del Cursor */

/* -------------------------------------------------------------- */
/*  Limpia la tabla de OPERACION                                  */
/* -------------------------------------------------------------- */



SELECT 'El proceso de limpieza de la operación CAUSACION ha finalizado satisfactoriamente' RESULTADO