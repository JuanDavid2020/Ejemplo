USE [FYC]
GO
/****** Object:  StoredProcedure [dbo].[LMP_Secueciacion]    Script Date: 6/12/2024 4:18:21 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 03/07/2004 07:53:43 p.m. ******/
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 05/29/2004 11:31:37 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 05/04/2004 05:24:11 PM ******/
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 12/26/2000 09:37:54 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 12/25/2000 08:22:06 AM ******/
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 08/19/2000 2:00:52 PM ******/ 
/****** Object:  Stored Procedure dbo.LMP_Secueciacion    Script Date: 03/17/2000 09:51:55 AM ******/
ALTER PROCEDURE [dbo].[LMP_Secueciacion] AS

/*************************************************************************

Título         : LMP_Causación 


Propósito      : Limpiar Operaciones de tipo 'retención'
		 de una fecha dada hacia atrás.

Modificado: Juan Leguizamon-TALYCAP      Fecha   : 9 DIC 2024
Descripcion: Copiar los datos de VINCULO_OPERACIONES a la tabla de historial
----------------------------------------------------------------------------
Autor  : Francisco Alvarado                        Estado : ( Falta probar )
*****************************************************************************/
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


DECLARE _operaciones CURSOR FOR

SELECT ASI_OPERACION    ,

       ASI_OPERACION_CONSECUTIVO ,
       MVC_AsientoConsecutivo,
       ASI_Tipo 
FROM   
       MOVIMIENTO,
       ASIENTO
WHERE  ASI_OPERACION    = 'SecRetencionFte' 	AND
       ASI_Tipo          =  MVC_AsientoTipo 	AND
       ASI_OPERACION_CONSECUTIVO   =  MVC_AsientoConsecutivo
       

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

SELECT @CualOperTipo='SecRetencionFte'

PRINT 'Comienza borrado sobre la tabla ASIENTO'

	DELETE FROM ASIENTO

	WHERE	ASI_OPERACION    = @CualOperTipo

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

PRINT 'Comienza borrado sobre la tabla GRUPO_TRANSACCIONAL'

	DELETE FROM GRUPO_TRANSACCIONAL

	WHERE	GTR_OpInternaTipo = @CualOperTipo
	/*AND	GTR_OpInternaConsecutivo = @CualOperNum*/



	DELETE FROM GRUPO_TRANSACCIONAL

	WHERE	GTR_OpExternaTipo = @CualOperTipo
	/*AND	GTR_OpExternaConsecutivo = @CualOperNum*/

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
        and     MCP_DocumentoNúmero>100000000  and
        MCP_DocumentoNúmero<100037100 

	/*AND	MCP_OperaciónConsecutivo = @CualOperNum*/

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

	WHERE	VOP_OrigenTipo  =@CualOperTipo
	/*AND	VOP_OrigenConsecutivo = @CualOperNum*/


	
    
/* -------------------------------------------------------------- */
/*  Limpia la tabla de OPERACION                                  */

/* -------------------------------------------------------------- */

PRINT 'Comienza borrado sobre la tabla OPERACION'

DELETE FROM OPERACION
WHERE	OPR_Tipo = @CualOperTipo

SELECT 'El proceso de limpieza de la operación RetencioFte ha finalizado satisfactoriamente' RESULTADO