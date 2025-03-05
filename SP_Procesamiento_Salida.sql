USE REPOSITORY_GMF;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;
GO

/*SELECT * FROM MIDAS.FYC.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación LIKE '%GMF%'

INSERT INTO FYCBOG.DBO.TOPE_DE_LIQUIDACION (TDL_Operación,TDL_Cuenta,TDL_ItemNombre)
SELECT ION_Tipo,NULL,'Vr.GMF'
FROM FYCBOG.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='ReintGMFAsync'


SELECT * FROM MIDAS.FYC.DBO.ITEM_OPERACION_VALOR WHERE IOV_Tipo LIKE '%GMF%'
SELECT * FROM FYCBOG.DBO.ITEM_OPERACION_VALOR WHERE IOV_Tipo LIKE '%GMF%'
UPDATE FYCBOG.DBO.ITEM_OPERACION_VALOR 
SET IOV_OrdenPago = 'N',
    IOV_Factor = 1
WHERE IOV_Tipo = 'NCReintegroGMF';

*/
-- Crear o redefinir el procedimiento
/*ROLLBACK
BEGIN TRAN
EXEC SP_Proceso_GMF 1*/

--SELECT * FROM FYCBOG.DBO.EDAD_CARTERA_PAGOS

CREATE OR ALTER PROCEDURE [dbo].[SP_Proceso_GMF]
    @OpcionProceso INT
AS
BEGIN
    SET NOCOUNT ON;

DECLARE @CentroCosto VARCHAR(50) = 'BOGOTA',
		@FechaRegistro DATETIME = GETDATE(),
		@estado INT,
		@Iterador INT = 1,
		@Fecha_Cierre DATETIME ,
		@MsgSalida Varchar(25),
		@MaxIterador INT,
		@TipoDocumento VARCHAR(50),
		@NumDocumento VARCHAR(50),
		@NumDocumentoUnico VARCHAR(50),
		@Termino INT,
		@Producto VARCHAR(50),
		@ValorPago DECIMAL(18, 2),
		@TipoPago VARCHAR(50),
		@TipoNitAfiliado VARCHAR(50),
		@NumNitAfiliado VARCHAR(50),
		@TipoSoporte VARCHAR(50),
		@NumSoporte INT,
		@NumOper INT,
		@servidor VARCHAR(16),
		@CiudadServidorActual Varchar(16),
		@Número_de_transacción Varchar(50),
		@ITEMNOMBRE VARCHAR(MAX);

if @OpcionProceso=1
BEGIN

	DECLARE @TransaccionesVinculoOperaciones TABLE (
		Numero_de_transaccion NVARCHAR(100),
		AOV_OperacionTipo NVARCHAR(50),
		AOV_OperacionConsecutivo NVARCHAR(50),
		AOV_ItemNombre NVARCHAR(50),
		AOV_Valor DECIMAL(18, 2)
	);


	INSERT INTO @TransaccionesVinculoOperaciones(Numero_de_transaccion, AOV_OperacionTipo, AOV_OperacionConsecutivo, AOV_ItemNombre, AOV_Valor)
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM  FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN  Transacciones_con_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBAR.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_con_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCCar.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCCAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_con_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBUC.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBUC.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_con_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCOtros.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCOtros.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_con_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'


	SELECT * FROM @TransaccionesVinculoOperaciones

	UPDATE Transacciones_con_cobro_GMF
	SET tipo_operacion= B.AOV_OperaciónTipo,
		numero_operacion=B.AOV_OperaciónConsecutivo,
		valor_aplicado=B.AOV_Valor
	FROM Transacciones_con_cobro_GMF A INNER JOIN @TransaccionesVinculoOperaciones B ON A.Numero_de_transaccion=B.Numero_de_transaccion

	--SELECT * FROM Transacciones_con_cobro_GMF WHERE tipo_operacion ORDER BY Fecha_y_hora_de_ejecución DESC

	-- Limpia el campo 'tipo_operacion_asincronica' y 'valor_aplicado_asincronico'
	UPDATE Transacciones_con_cobro_GMF
	SET tipo_operacion_asincronica = NULL, 
		valor_aplicado_asincronico = NULL,
		estado_proceso=NULL,
		numero_operacion_GMF=NULL,
		observaciones_proceso=NULL;


	SELECT * FROM Transacciones_con_cobro_GMF

	-- Actualiza para 'ReintGMFAsync' cuando la diferencia > 0 
	UPDATE Transacciones_con_cobro_GMF
	SET tipo_operacion_asincronica = (SELECT ION_Tipo FROM FYCBOG.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='GMFAsync'),
		valor_aplicado_asincronico = ABS(CAST(Valor_sugerido_a_cobrar AS DECIMAL(18, 2)) - CAST(valor_aplicado AS DECIMAL(18, 2)))
	WHERE 
		numero_operacion IS NOT NULL
		AND ((CAST(Valor_sugerido_a_cobrar AS DECIMAL(18, 2)) - CAST(valor_aplicado AS DECIMAL(18, 2)))) > 0
		AND CAST(valor_aplicado AS DECIMAL(18, 2)) >= 0;

	-- Actualiza para 'ReintGMFAsync' cuando la diferencia < 0 
	UPDATE Transacciones_con_cobro_GMF
	SET tipo_operacion_asincronica =(SELECT ION_Tipo FROM FYCBOG.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='ReintGMFAsync'),
		valor_aplicado_asincronico = ABS(CAST(Valor_sugerido_a_cobrar AS DECIMAL(18, 2)) - CAST(valor_aplicado AS DECIMAL(18, 2)))
	WHERE 
		numero_operacion IS NOT NULL
		AND ((CAST(Valor_sugerido_a_cobrar AS DECIMAL(18, 2)) - CAST(valor_aplicado AS DECIMAL(18, 2)))) < 0
		AND CAST(valor_aplicado AS DECIMAL(18, 2)) > 0;

	SELECT 
	Valor_sugerido_a_cobrar,
	valor_aplicado,
	(CAST(Valor_sugerido_a_cobrar AS DECIMAL(18, 2)) - CAST(valor_aplicado AS DECIMAL(18, 2))) AS DIFERENCIA,*
	FROM Transacciones_con_cobro_GMF
	WHERE numero_operacion IS NOT NULL
	ORDER BY numero_de_producto ASC

	DECLARE @Transacciones TABLE (
			RowID INT IDENTITY(1,1),
			DocumentoTipo VARCHAR(50),
			DocumentoNúmeroUnico VARCHAR(50),
			NúmeroTérmino INT,
			TER_ReinaProducto VARCHAR(50),
			VALOR_APLICAR DECIMAL(18, 2),
			TipoPago VARCHAR(50),
			TipoNitAfiliado VARCHAR(50),
			NumNitAfiliado VARCHAR(50),
			Ciudad VARCHAR(50),
			NumeroDeTransaccion VARCHAR(50)
		);


	INSERT INTO @Transacciones(DocumentoTipo,DocumentoNúmeroUnico,NúmeroTérmino,TER_ReinaProducto,VALOR_APLICAR, TipoPago, TipoNitAfiliado, NumNitAfiliado,Ciudad,NumeroDeTransaccion)
	SELECT 
		LEFT(Numero_de_producto, CHARINDEX('-', Numero_de_producto) - 1),
		RIGHT(Numero_de_producto, LEN(Numero_de_producto) - CHARINDEX('-', Numero_de_producto)),
		1,
		'CavFai',
		valor_aplicado_asincronico,
		tipo_operacion_asincronica,
		CASE 
			WHEN Tipo_de_identificación_del_Titular = 1 THEN 'CC'
			WHEN Tipo_de_identificación_del_Titular = 2 THEN 'NIT'
			ELSE 'OTRO' -- Por si hay otros valores posibles
		END AS TipoIdentificacion,
		Número_de_identificación_del_Titular,
		SUBSTRING(Número_de_transacción, 1, CHARINDEX('-', Número_de_transacción) - 1) ,
		Número_de_transacción
	FROM Transacciones_con_cobro_GMF A
	WHERE tipo_operacion_asincronica IS NOT NULL
	--AND tipo_operacion_asincronica='GMF_SupTope'
	--AND Numero_de_producto='AFAI-100008763'
	--AND Número_de_identificación_del_Titular='13879195'

	--select top 10* from Transacciones_con_cobro_GMF

	select * from @Transacciones
	SELECT @MaxIterador = COUNT(*) FROM @Transacciones;
	SELECT @MaxIterador

	/*###########################################################################################*/
	WHILE @Iterador <= @MaxIterador
	BEGIN

		BEGIN TRY 
			-- Obtener el registro actual
			SELECT 
				@TipoDocumento = DocumentoTipo,
				@NumDocumentoUnico = DocumentoNúmeroUnico,
				@Termino =NúmeroTérmino,
				@Producto = TER_ReinaProducto,
				@ValorPago = VALOR_APLICAR,
				@TipoPago = TipoPago,
				@TipoNitAfiliado = TipoNitAfiliado,
				@NumNitAfiliado = NumNitAfiliado,
				@CiudadServidorActual=Ciudad,
				@Número_de_transacción=NumeroDeTransaccion
			FROM  @Transacciones
			WHERE RowID = @Iterador;


			IF EXISTS (
				SELECT 1 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado)
			)
			BEGIN
				SELECT @servidor = ISNULL(MAX(servidor), '') 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado);
			END
			ELSE
			BEGIN
				SET @servidor = 'FYCOTROS';
			END

			-- Selección dinámica según el prefijo
			IF @servidor = 'FYCBOG'
			BEGIN
		    
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbog.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto =DCT_CiudadAdju
				FROM fycbog.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número =@NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCCar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico  AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fyccar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCBuc.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbuc.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCOtros.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycotros.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE
			BEGIN
				PRINT 'SERVIDOR NO EXISTE.';
			END

			-- Obtener el Tipo de Soporte
			SELECT @TipoSoporte = OPT_Soporte_Contable 
			FROM FYCBOG.DBO.OPERACION_TIPO
			WHERE OPT_Nombre = @TipoPago;

			-- Actualizar y obtener el número de soporte
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END

			-- Actualizar y obtener el número de operación
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBOG.dbo.VARIABLES_SISTEMA, FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBAR.dbo.VARIABLES_SISTEMA, FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCCAR.dbo.VARIABLES_SISTEMA, FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBUC.dbo.VARIABLES_SISTEMA, FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCOTROS.dbo.VARIABLES_SISTEMA, FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END

			-- Insertar en OPERACION

			SELECT @CentroCosto,@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME()

			IF @servidor  = 'FYCBOG'
			BEGIN

	
			SELECT @ITEMNOMBRE= TDL_ItemNombre FROM FYCBOG.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación=@TipoPago

			SELECT @ITEMNOMBRE,@NumOper

				SELECT * FROM  FYCBOG.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc
	

			INSERT INTO FYCBOG.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

						
			 INSERT INTO FYCBOG.DBO.ASPECTO_OPERACION_VALOR
			 VALUES (@TipoPago, @NumOper,@ITEMNOMBRE,@ValorPago);


				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBOG.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBOG.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBOG.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBOG.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE Transacciones_con_cobro_GMF 
				SET estado_proceso='PROCESADO',
					numero_operacion_GMF=@NumOper,
					observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
				FROM Transacciones_con_cobro_GMF
				WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
				and Número_de_transacción=@Número_de_transacción
				and Número_de_identificación_del_Titular=@NumNitAfiliado
				
				SELECT * FROM  FYCBOG.DBO.MOVIMIENTO_CUENTA_PARALELA
				WHERE MCP_OperaciónConsecutivo=@NumOper
				AND MCP_OperaciónTipo=@TipoPago

				SELECT * FROM  FYCBOG.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc


				/******MARCACION DE LAS CUENTAS QUE SE APLICO COBRO GMF******/	
				UPDATE A
				SET ADN_ParámetroNombre = '[AplicarGMF]'
				FROM FYCBOG.DBO.ASPECTO_DOCUMENTO_NULO A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADN_DocumentoTipo = 'AFAI'
				AND A.ADN_ParámetroNombre LIKE '%GMF%'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				UPDATE A
				SET ADF_ParámetroNombre='GMFExcentoHasta',
					ADF_Fecha= DATEADD(day, -1, B.fecha_insercion)
				FROM FYCBOG.DBO.ASPECTO_DOCUMENTO_FECHA A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADF_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADF_DocumentoTipo = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				INSERT INTO cavcrm.cavipetrol.DBO.Registro_GMF(RG_TipoNit,RG_Nit,RG_Documento,RG_Numero,RG_Fecha,RG_Servidor,RG_Observación)
				SELECT DISTINCT 
				CASE WHEN B.Tipo_de_identificación_del_Titular = 1 THEN 'CC'
				WHEN  B.Tipo_de_identificación_del_Titular = 2 THEN  'NIT'
				WHEN  B.Tipo_de_identificación_del_Titular = 3 THEN  'CE' 
				WHEN  B.Tipo_de_identificación_del_Titular = 4 THEN 'TI'
				--NO EXISTEN HASTA EL MOMENTO----
				WHEN  B.Tipo_de_identificación_del_Titular = 5 THEN 'PASAPORTE'
				WHEN  B.Tipo_de_identificación_del_Titular = 6 THEN 'TARJETA DEL SEGURO SOCIAL EXTRANJERO'
				WHEN  B.Tipo_de_identificación_del_Titular = 7 THEN 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA'
				WHEN  B.Tipo_de_identificación_del_Titular = 8 THEN 'FIDEICOMISO' 
				WHEN  B.Tipo_de_identificación_del_Titular = 9 THEN 'REGISTRO CIVIL'
				WHEN  B.Tipo_de_identificación_del_Titular = 10 THEN 'CARNET DIPLOMÁTICO'
				WHEN  B.Tipo_de_identificación_del_Titular= 11 THEN 'PATRIMONIO AUTÓNOMO'
				WHEN  B.Tipo_de_identificación_del_Titular= 12 THEN 'PERMISO ESPECIAL DE PERMANENCIA - PEP'
				ELSE 'PERMISO PROTECCION TEMPORAL'
				END AS Tipo_de_identificacion_del_titular ,
				B.Número_de_identificación_del_Titular,
				'AFAI',
				SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto)),
				GETDATE()
				,RG_Servidor,
				'Marcación Ok'
				from  cavcrm.cavipetrol.DBO.Registro_GMF RG
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON RG.RG_Numero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE RG.RG_Documento = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				/***********************************************************/

			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN

				SELECT @ITEMNOMBRE= TDL_ItemNombre FROM FYCBAR.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación=@TipoPago

				SELECT @ITEMNOMBRE,@NumOper

				SELECT * FROM  FYCBAR.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc
	

				INSERT INTO FYCBAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

						
				INSERT INTO FYCBAR.DBO.ASPECTO_OPERACION_VALOR
				VALUES (@TipoPago, @NumOper,@ITEMNOMBRE,@ValorPago);

				INSERT INTO FYCBAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_con_cobro_GMF 
					SET estado_proceso='PROCESADO',
						numero_operacion_GMF=@NumOper,
						observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
					FROM Transacciones_con_cobro_GMF
					WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
					and Número_de_transacción=@Número_de_transacción
					and Número_de_identificación_del_Titular=@NumNitAfiliado



				/******MARCACION DE LAS CUENTAS QUE SE APLICO COBRO GMF******/	
				UPDATE A
				SET ADN_ParámetroNombre = '[AplicarGMF]'
				FROM FYCBAR.DBO.ASPECTO_DOCUMENTO_NULO A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADN_DocumentoTipo = 'AFAI'
				AND A.ADN_ParámetroNombre LIKE '%GMF%'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				UPDATE A
				SET ADF_ParámetroNombre='GMFExcentoHasta',
					ADF_Fecha= DATEADD(day, -1, B.fecha_insercion)
				FROM FYCBAR.DBO.ASPECTO_DOCUMENTO_FECHA A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADF_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADF_DocumentoTipo = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				INSERT INTO cavcrm.cavipetrol.DBO.Registro_GMF(RG_TipoNit,RG_Nit,RG_Documento,RG_Numero,RG_Fecha,RG_Servidor,RG_Observación)
				SELECT DISTINCT 
				CASE WHEN B.Tipo_de_identificación_del_Titular = 1 THEN 'CC'
				WHEN  B.Tipo_de_identificación_del_Titular = 2 THEN  'NIT'
				WHEN  B.Tipo_de_identificación_del_Titular = 3 THEN  'CE' 
				WHEN  B.Tipo_de_identificación_del_Titular = 4 THEN 'TI'
				--NO EXISTEN HASTA EL MOMENTO----
				WHEN  B.Tipo_de_identificación_del_Titular = 5 THEN 'PASAPORTE'
				WHEN  B.Tipo_de_identificación_del_Titular = 6 THEN 'TARJETA DEL SEGURO SOCIAL EXTRANJERO'
				WHEN  B.Tipo_de_identificación_del_Titular = 7 THEN 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA'
				WHEN  B.Tipo_de_identificación_del_Titular = 8 THEN 'FIDEICOMISO' 
				WHEN  B.Tipo_de_identificación_del_Titular = 9 THEN 'REGISTRO CIVIL'
				WHEN  B.Tipo_de_identificación_del_Titular = 10 THEN 'CARNET DIPLOMÁTICO'
				WHEN  B.Tipo_de_identificación_del_Titular= 11 THEN 'PATRIMONIO AUTÓNOMO'
				WHEN  B.Tipo_de_identificación_del_Titular= 12 THEN 'PERMISO ESPECIAL DE PERMANENCIA - PEP'
				ELSE 'PERMISO PROTECCION TEMPORAL'
				END AS Tipo_de_identificacion_del_titular ,
				B.Número_de_identificación_del_Titular,
				'AFAI',
				SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto)),
				GETDATE()
				,RG_Servidor,
				'Marcación Ok'
				from  cavcrm.cavipetrol.DBO.Registro_GMF RG
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON RG.RG_Numero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE RG.RG_Documento = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				/***********************************************************/

			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN

			    SELECT @ITEMNOMBRE= TDL_ItemNombre FROM FYCCAR.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación=@TipoPago

				SELECT @ITEMNOMBRE,@NumOper

				SELECT * FROM  FYCCAR.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc
	

				INSERT INTO FYCCAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

						
				INSERT INTO FYCCAR.DBO.ASPECTO_OPERACION_VALOR
				VALUES (@TipoPago, @NumOper,@ITEMNOMBRE,@ValorPago);

				INSERT INTO FYCCAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());
				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCCar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCCar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCCar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCCar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_con_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_con_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado


				/******MARCACION DE LAS CUENTAS QUE SE APLICO COBRO GMF******/	
				UPDATE A
				SET ADN_ParámetroNombre = '[AplicarGMF]'
				FROM FYCCAR.DBO.ASPECTO_DOCUMENTO_NULO A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADN_DocumentoTipo = 'AFAI'
				AND A.ADN_ParámetroNombre LIKE '%GMF%'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				UPDATE A
				SET ADF_ParámetroNombre='GMFExcentoHasta',
					ADF_Fecha= DATEADD(day, -1, B.fecha_insercion)
				FROM FYCCAR.DBO.ASPECTO_DOCUMENTO_FECHA A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADF_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADF_DocumentoTipo = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				INSERT INTO cavcrm.cavipetrol.DBO.Registro_GMF(RG_TipoNit,RG_Nit,RG_Documento,RG_Numero,RG_Fecha,RG_Servidor,RG_Observación)
				SELECT DISTINCT 
				CASE WHEN B.Tipo_de_identificación_del_Titular = 1 THEN 'CC'
				WHEN  B.Tipo_de_identificación_del_Titular = 2 THEN  'NIT'
				WHEN  B.Tipo_de_identificación_del_Titular = 3 THEN  'CE' 
				WHEN  B.Tipo_de_identificación_del_Titular = 4 THEN 'TI'
				--NO EXISTEN HASTA EL MOMENTO----
				WHEN  B.Tipo_de_identificación_del_Titular = 5 THEN 'PASAPORTE'
				WHEN  B.Tipo_de_identificación_del_Titular = 6 THEN 'TARJETA DEL SEGURO SOCIAL EXTRANJERO'
				WHEN  B.Tipo_de_identificación_del_Titular = 7 THEN 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA'
				WHEN  B.Tipo_de_identificación_del_Titular = 8 THEN 'FIDEICOMISO' 
				WHEN  B.Tipo_de_identificación_del_Titular = 9 THEN 'REGISTRO CIVIL'
				WHEN  B.Tipo_de_identificación_del_Titular = 10 THEN 'CARNET DIPLOMÁTICO'
				WHEN  B.Tipo_de_identificación_del_Titular= 11 THEN 'PATRIMONIO AUTÓNOMO'
				WHEN  B.Tipo_de_identificación_del_Titular= 12 THEN 'PERMISO ESPECIAL DE PERMANENCIA - PEP'
				ELSE 'PERMISO PROTECCION TEMPORAL'
				END AS Tipo_de_identificacion_del_titular ,
				B.Número_de_identificación_del_Titular,
				'AFAI',
				SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto)),
				GETDATE()
				,RG_Servidor,
				'Marcación Ok'
				from  cavcrm.cavipetrol.DBO.Registro_GMF RG
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON RG.RG_Numero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE RG.RG_Documento = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				/***********************************************************/
					

			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
			    

				SELECT @ITEMNOMBRE= TDL_ItemNombre FROM FYCBUC.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación=@TipoPago

				SELECT @ITEMNOMBRE,@NumOper

				SELECT * FROM  FYCBUC.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc
	

				INSERT INTO FYCBUC.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

						
				INSERT INTO FYCBUC.DBO.ASPECTO_OPERACION_VALOR
				VALUES (@TipoPago, @NumOper,@ITEMNOMBRE,@ValorPago);

				INSERT INTO FYCBUC.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBUC.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBUC.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCBUC.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBUC.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_con_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_con_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado


				/******MARCACION DE LAS CUENTAS QUE SE APLICO COBRO GMF******/	
				UPDATE A
				SET ADN_ParámetroNombre = '[AplicarGMF]'
				FROM FYCBUC.DBO.ASPECTO_DOCUMENTO_NULO A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADN_DocumentoTipo = 'AFAI'
				AND A.ADN_ParámetroNombre LIKE '%GMF%'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				UPDATE A
				SET ADF_ParámetroNombre='GMFExcentoHasta',
					ADF_Fecha= DATEADD(day, -1, B.fecha_insercion)
				FROM FYCBUC.DBO.ASPECTO_DOCUMENTO_FECHA A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADF_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADF_DocumentoTipo = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				INSERT INTO cavcrm.cavipetrol.DBO.Registro_GMF(RG_TipoNit,RG_Nit,RG_Documento,RG_Numero,RG_Fecha,RG_Servidor,RG_Observación)
				SELECT DISTINCT 
				CASE WHEN B.Tipo_de_identificación_del_Titular = 1 THEN 'CC'
				WHEN  B.Tipo_de_identificación_del_Titular = 2 THEN  'NIT'
				WHEN  B.Tipo_de_identificación_del_Titular = 3 THEN  'CE' 
				WHEN  B.Tipo_de_identificación_del_Titular = 4 THEN 'TI'
				--NO EXISTEN HASTA EL MOMENTO----
				WHEN  B.Tipo_de_identificación_del_Titular = 5 THEN 'PASAPORTE'
				WHEN  B.Tipo_de_identificación_del_Titular = 6 THEN 'TARJETA DEL SEGURO SOCIAL EXTRANJERO'
				WHEN  B.Tipo_de_identificación_del_Titular = 7 THEN 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA'
				WHEN  B.Tipo_de_identificación_del_Titular = 8 THEN 'FIDEICOMISO' 
				WHEN  B.Tipo_de_identificación_del_Titular = 9 THEN 'REGISTRO CIVIL'
				WHEN  B.Tipo_de_identificación_del_Titular = 10 THEN 'CARNET DIPLOMÁTICO'
				WHEN  B.Tipo_de_identificación_del_Titular= 11 THEN 'PATRIMONIO AUTÓNOMO'
				WHEN  B.Tipo_de_identificación_del_Titular= 12 THEN 'PERMISO ESPECIAL DE PERMANENCIA - PEP'
				ELSE 'PERMISO PROTECCION TEMPORAL'
				END AS Tipo_de_identificacion_del_titular ,
				B.Número_de_identificación_del_Titular,
				'AFAI',
				SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto)),
				GETDATE()
				,RG_Servidor,
				'Marcación Ok'
				from  cavcrm.cavipetrol.DBO.Registro_GMF RG
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON RG.RG_Numero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE RG.RG_Documento = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				/***********************************************************/

			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN


			    SELECT @ITEMNOMBRE= TDL_ItemNombre FROM FYCOTROS.DBO.TOPE_DE_LIQUIDACION WHERE TDL_Operación=@TipoPago

				SELECT @ITEMNOMBRE,@NumOper

				SELECT * FROM  FYCOTROS.DBO.SALDO_CUENTA_PARALELA
				WHERE SCP_DocumentoTipo='AFAI'
				AND SCP_DocumentoNúmero=@NumDocumentoUnico
				AND SCP_NúmeroTérmino=@Termino
				ORDER BY SCP_Fecha desc
	

				INSERT INTO FYCOTROS.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

						
				INSERT INTO FYCOTROS.DBO.ASPECTO_OPERACION_VALOR
				VALUES (@TipoPago, @NumOper,@ITEMNOMBRE,@ValorPago);
		
		
				INSERT INTO FYCOTROS.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCOtros.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCOtros.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCOtros.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCOtros.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper    

			
				UPDATE Transacciones_con_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_con_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado


				/******MARCACION DE LAS CUENTAS QUE SE APLICO COBRO GMF******/	
				UPDATE A
				SET ADN_ParámetroNombre = '[AplicarGMF]'
				FROM FYCOtros.DBO.ASPECTO_DOCUMENTO_NULO A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADN_DocumentoTipo = 'AFAI'
				AND A.ADN_ParámetroNombre LIKE '%GMF%'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				UPDATE A
				SET ADF_ParámetroNombre='GMFExcentoHasta',
					ADF_Fecha= DATEADD(day, -1, B.fecha_insercion)
				FROM FYCOtros.DBO.ASPECTO_DOCUMENTO_FECHA A
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON A.ADF_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE A.ADF_DocumentoTipo = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				INSERT INTO cavcrm.cavipetrol.DBO.Registro_GMF(RG_TipoNit,RG_Nit,RG_Documento,RG_Numero,RG_Fecha,RG_Servidor,RG_Observación)
				SELECT DISTINCT 
				CASE WHEN B.Tipo_de_identificación_del_Titular = 1 THEN 'CC'
				WHEN  B.Tipo_de_identificación_del_Titular = 2 THEN  'NIT'
				WHEN  B.Tipo_de_identificación_del_Titular = 3 THEN  'CE' 
				WHEN  B.Tipo_de_identificación_del_Titular = 4 THEN 'TI'
				--NO EXISTEN HASTA EL MOMENTO----
				WHEN  B.Tipo_de_identificación_del_Titular = 5 THEN 'PASAPORTE'
				WHEN  B.Tipo_de_identificación_del_Titular = 6 THEN 'TARJETA DEL SEGURO SOCIAL EXTRANJERO'
				WHEN  B.Tipo_de_identificación_del_Titular = 7 THEN 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA'
				WHEN  B.Tipo_de_identificación_del_Titular = 8 THEN 'FIDEICOMISO' 
				WHEN  B.Tipo_de_identificación_del_Titular = 9 THEN 'REGISTRO CIVIL'
				WHEN  B.Tipo_de_identificación_del_Titular = 10 THEN 'CARNET DIPLOMÁTICO'
				WHEN  B.Tipo_de_identificación_del_Titular= 11 THEN 'PATRIMONIO AUTÓNOMO'
				WHEN  B.Tipo_de_identificación_del_Titular= 12 THEN 'PERMISO ESPECIAL DE PERMANENCIA - PEP'
				ELSE 'PERMISO PROTECCION TEMPORAL'
				END AS Tipo_de_identificacion_del_titular ,
				B.Número_de_identificación_del_Titular,
				'AFAI',
				SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto)),
				GETDATE()
				,RG_Servidor,
				'Marcación Ok'
				from  cavcrm.cavipetrol.DBO.Registro_GMF RG
				INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
				ON RG.RG_Numero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
				WHERE RG.RG_Documento = 'AFAI'
				AND B.observaciones_proceso IS NOT NULL
				AND fecha_insercion=GETDATE();

				/***********************************************************/

			END
		
			PRINT @Iterador;
			-- Incrementar el iterador para el siguiente registro
			SET @Iterador = @Iterador + 1;

		 END TRY 
		 BEGIN CATCH 

			PRINT 'ALGUN ERROR SE PRESENTO';
			SELECT ERROR_MESSAGE();

		 END CATCH
	END

	SELECT * FROM Transacciones_con_cobro_GMF
	WHERE estado_proceso='PROCESADO'
END
/*__________TRANSACCION_SIN_COBRO__________*/
ELSE IF @OpcionProceso=2
BEGIN
	DECLARE @TransaccionesSinCobroVinculoOperaciones TABLE (
		Numero_de_transaccion NVARCHAR(100),
		AOV_OperacionTipo NVARCHAR(50),
		AOV_OperacionConsecutivo NVARCHAR(50),
		AOV_ItemNombre NVARCHAR(50),
		AOV_Valor DECIMAL(18, 2)
	);

	INSERT INTO @TransaccionesSinCobroVinculoOperaciones(Numero_de_transaccion, AOV_OperacionTipo, AOV_OperacionConsecutivo, AOV_ItemNombre, AOV_Valor)
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM  FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_sin_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBAR.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_sin_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCCar.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCCAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_sin_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBUC.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBUC.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_sin_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCOtros.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCOtros.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN Transacciones_sin_cobro_GMF B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'

   	UPDATE Transacciones_sin_cobro_GMF
	SET tipo_operacion_asincronica = NULL, 
		valor_aplicado_asincronico = NULL,
		estado_proceso=NULL,
		numero_operacion_GMF=NULL,
		observaciones_proceso=NULL;

	UPDATE Transacciones_sin_cobro_GMF
	SET tipo_operacion= B.AOV_OperaciónTipo,
		numero_operacion=B.AOV_OperaciónConsecutivo,
		valor_aplicado=B.AOV_Valor,
		tipo_operacion_asincronica=(SELECT ION_Tipo FROM FYCBOG.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='GMFAsync'),
		valor_aplicado_asincronico=B.AOV_Valor
	FROM Transacciones_sin_cobro_GMF A INNER JOIN @TransaccionesSinCobroVinculoOperaciones B ON A.Numero_de_transaccion=B.Numero_de_transaccion

	select * from Transacciones_sin_cobro_GMF

	DECLARE @TransaccionesSinCobros TABLE (
			RowID INT IDENTITY(1,1),
			DocumentoTipo VARCHAR(50),
			DocumentoNúmeroUnico VARCHAR(50),
			NúmeroTérmino INT,
			TER_ReinaProducto VARCHAR(50),
			VALOR_APLICAR DECIMAL(18, 2),
			TipoPago VARCHAR(50),
			TipoNitAfiliado VARCHAR(50),
			NumNitAfiliado VARCHAR(50),
			Ciudad VARCHAR(50),
			NumeroDeTransaccion VARCHAR(50)
		);

	INSERT INTO @TransaccionesSinCobros(DocumentoTipo,DocumentoNúmeroUnico,NúmeroTérmino,TER_ReinaProducto,VALOR_APLICAR, TipoPago, TipoNitAfiliado, NumNitAfiliado,Ciudad,NumeroDeTransaccion)
	SELECT
		LEFT(Numero_de_producto, CHARINDEX('-', Numero_de_producto) - 1),
		RIGHT(Numero_de_producto, LEN(Numero_de_producto) - CHARINDEX('-', Numero_de_producto)),
		1,
		'CavFai',
		valor_aplicado_asincronico,
		tipo_operacion_asincronica,
		CASE 
			WHEN Tipo_de_identificación_del_Titular = 1 THEN 'CC'
			WHEN Tipo_de_identificación_del_Titular = 2 THEN 'NIT'
			ELSE 'OTRO' -- Por si hay otros valores posibles
		END AS TipoIdentificacion,
		Número_de_identificación_del_Titular,
		SUBSTRING(Número_de_transacción, 1, CHARINDEX('-', Número_de_transacción) - 1) ,
		Número_de_transacción
	FROM Transacciones_sin_cobro_GMF A
	WHERE tipo_operacion_asincronica IS NOT NULL

	select * from @TransaccionesSinCobros
	SELECT @MaxIterador = COUNT(*) FROM @TransaccionesSinCobros;
	SELECT @MaxIterador

	/*###########################################################################################*/
	WHILE @Iterador <= @MaxIterador
	BEGIN

		BEGIN TRY 



       				-- Obtener el registro actual
			SELECT 
				@TipoDocumento = DocumentoTipo,
				@NumDocumentoUnico = DocumentoNúmeroUnico,
				@Termino =NúmeroTérmino,
				@Producto = TER_ReinaProducto,
				@ValorPago = VALOR_APLICAR,
				@TipoPago = TipoPago,
				@TipoNitAfiliado = TipoNitAfiliado,
				@NumNitAfiliado = NumNitAfiliado,
				@CiudadServidorActual=Ciudad,
				@Número_de_transacción=NumeroDeTransaccion
			FROM  @TransaccionesSinCobros
			WHERE RowID = @Iterador;


			IF EXISTS (
				SELECT 1 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado)
			)
			BEGIN
				SELECT @servidor = ISNULL(MAX(servidor), '') 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado);
			END
			ELSE
			BEGIN
				SET @servidor = 'FYCOTROS';
			END

			-- Selección dinámica según el prefijo
			IF @servidor = 'FYCBOG'
			BEGIN
		    
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbog.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto =DCT_CiudadAdju
				FROM fycbog.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número =@NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCCar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico  AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fyccar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCBuc.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbuc.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCOtros.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycotros.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE
			BEGIN
				PRINT 'SERVIDOR NO EXISTE.';
			END

			-- Obtener el Tipo de Soporte
			SELECT @TipoSoporte = OPT_Soporte_Contable 
			FROM FYCBOG.DBO.OPERACION_TIPO
			WHERE OPT_Nombre = @TipoPago;

			-- Actualizar y obtener el número de soporte
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END

			-- Actualizar y obtener el número de operación
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBOG.dbo.VARIABLES_SISTEMA, FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBAR.dbo.VARIABLES_SISTEMA, FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCCAR.dbo.VARIABLES_SISTEMA, FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBUC.dbo.VARIABLES_SISTEMA, FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCOTROS.dbo.VARIABLES_SISTEMA, FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END

			-- Insertar en OPERACION

			SELECT @CentroCosto,@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME()

			IF @servidor  = 'FYCBOG'
			BEGIN

				INSERT INTO FYCBOG.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBOG.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBOG.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBOG.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBOG.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE Transacciones_sin_cobro_GMF 
				SET estado_proceso='PROCESADO',
					numero_operacion_GMF=@NumOper,
					observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
				FROM Transacciones_sin_cobro_GMF
				WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
				and Número_de_transacción=@Número_de_transacción
				and Número_de_identificación_del_Titular=@NumNitAfiliado
		

			
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				INSERT INTO FYCBAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_sin_cobro_GMF 
					SET estado_proceso='PROCESADO',
						numero_operacion_GMF=@NumOper,
						observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
					FROM Transacciones_sin_cobro_GMF
					WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
					and Número_de_transacción=@Número_de_transacción
					and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				INSERT INTO FYCCAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());
				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCCar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCCar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCCar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCCar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_sin_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_sin_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado
					

			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN

				INSERT INTO FYCBUC.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBUC.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBUC.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCBUC.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBUC.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE Transacciones_sin_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_sin_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
		
		
				INSERT INTO FYCOTROS.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCOtros.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCOtros.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCOtros.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCOtros.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper    

			
				UPDATE Transacciones_sin_cobro_GMF 
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM Transacciones_sin_cobro_GMF
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
		
			PRINT @Iterador;
			-- Incrementar el iterador para el siguiente registro
			SET @Iterador = @Iterador + 1;

		 END TRY 
		 BEGIN CATCH 

			PRINT 'ALGUN ERROR SE PRESENTO';
			SELECT ERROR_MESSAGE();

		 END CATCH
	END

	SELECT * FROM Transacciones_sin_cobro_GMF
	WHERE estado_proceso='PROCESADO'
END
/*__________REINTEGROS__________*/
ELSE IF @OpcionProceso = 3
BEGIN

DECLARE @TransaccionesREINVinculoOperaciones TABLE (
		Numero_de_transaccion NVARCHAR(100),
		AOV_OperacionTipo NVARCHAR(50),
		AOV_OperacionConsecutivo NVARCHAR(50),
		AOV_ItemNombre NVARCHAR(50),
		AOV_Valor DECIMAL(18, 2)
	);

	INSERT INTO @TransaccionesREINVinculoOperaciones(Numero_de_transaccion, AOV_OperacionTipo, AOV_OperacionConsecutivo, AOV_ItemNombre, AOV_Valor)
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM  FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN novedadesREIN B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBAR.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN novedadesREIN B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCCar.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCCAR.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN novedadesREIN B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCBUC.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCBUC.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN novedadesREIN B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'
	UNION ALL
	SELECT 
		B.Numero_de_transaccion,
		AOV.AOV_OperaciónTipo,
		AOV.AOV_OperaciónConsecutivo,
		AOV.AOV_ItemNombre,
		AOV.AOV_Valor
	FROM FYCOtros.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN FYCOtros.DBO.VINCULO_OPERACIONES_HIST V 
		ON AOV.AOV_OperaciónConsecutivo = V.VOP_DestinoConsecutivo
	INNER JOIN novedadesREIN B 
		ON V.VOP_OrigenTipo = SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		)
		AND V.VOP_OrigenConsecutivo = RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		)
	WHERE 
		AOV.AOV_OperaciónTipo = 'GMF_FAI'
		AND AOV.AOV_ItemNombre = 'VrGMF'

   	UPDATE novedadesREIN
	SET tipo_operacion_asincronica = NULL, 
		valor_aplicado_asincronico = NULL,
		estado_proceso=NULL,
		numero_operacion_GMF=NULL,
		observaciones_proceso=NULL;

	UPDATE novedadesREIN
	SET tipo_operacion= B.AOV_OperaciónTipo,
		numero_operacion=B.AOV_OperaciónConsecutivo,
		valor_aplicado=B.AOV_Valor,
		tipo_operacion_asincronica=(SELECT ION_Tipo FROM FYCBOG.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='ReintGMFAsync'),
		valor_aplicado_asincronico=A.valor_sugerido_devolver
	FROM novedadesREIN A INNER JOIN @TransaccionesREINVinculoOperaciones B ON A.Numero_de_transaccion=B.Numero_de_transaccion
	where A.tipo_novedad='2'

SELECT * FROM @TransaccionesREINVinculoOperaciones
SELECT * FROM novedadesREIN

DECLARE @TransaccionesREIN TABLE (
			RowID INT IDENTITY(1,1),
			DocumentoTipo VARCHAR(50),
			DocumentoNúmeroUnico VARCHAR(50),
			NúmeroTérmino INT,
			TER_ReinaProducto VARCHAR(50),
			VALOR_APLICAR DECIMAL(18, 2),
			TipoPago VARCHAR(50),
			TipoNitAfiliado VARCHAR(50),
			NumNitAfiliado VARCHAR(50),
			Ciudad VARCHAR(50),
			NumeroDeTransaccion VARCHAR(50)
		);

	INSERT INTO @TransaccionesREIN(DocumentoTipo,DocumentoNúmeroUnico,NúmeroTérmino,TER_ReinaProducto,VALOR_APLICAR, TipoPago, TipoNitAfiliado, NumNitAfiliado,Ciudad,NumeroDeTransaccion)
	SELECT
		LEFT(Numero_de_producto, CHARINDEX('-', Numero_de_producto) - 1),
		RIGHT(Numero_de_producto, LEN(Numero_de_producto) - CHARINDEX('-', Numero_de_producto)),
		1,
		'CavFai',
		valor_aplicado_asincronico,
		tipo_operacion_asincronica,
		CASE 
			WHEN Tipo_de_identificación_del_Titular = 1 THEN 'CC'
			WHEN Tipo_de_identificación_del_Titular = 2 THEN 'NIT'
			ELSE 'OTRO' -- Por si hay otros valores posibles
		END AS TipoIdentificacion,
		Número_de_identificación_del_Titular,
		SUBSTRING(Número_de_transacción, 1, CHARINDEX('-', Número_de_transacción) - 1) ,
		Número_de_transacción
	FROM  novedadesREIN A
	WHERE tipo_operacion_asincronica IS NOT NULL

	select * from @TransaccionesREIN
	SELECT @MaxIterador = COUNT(*) FROM @TransaccionesREIN;
	SELECT @MaxIterador


	/*###########################################################################################*/
	WHILE @Iterador <= @MaxIterador
	BEGIN

		BEGIN TRY 



       				-- Obtener el registro actual
			SELECT 
				@TipoDocumento = DocumentoTipo,
				@NumDocumentoUnico = DocumentoNúmeroUnico,
				@Termino =NúmeroTérmino,
				@Producto = TER_ReinaProducto,
				@ValorPago = VALOR_APLICAR,
				@TipoPago = TipoPago,
				@TipoNitAfiliado = TipoNitAfiliado,
				@NumNitAfiliado = NumNitAfiliado,
				@CiudadServidorActual=Ciudad,
				@Número_de_transacción=NumeroDeTransaccion
			FROM  @TransaccionesREIN
			WHERE RowID = @Iterador;


			IF EXISTS (
				SELECT 1 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado)
			)
			BEGIN
				SELECT @servidor = ISNULL(MAX(servidor), '') 
				FROM fyc.dbo.servidor 
				WHERE ciudad = (SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado);
			END
			ELSE
			BEGIN
				SET @servidor = 'FYCOTROS';
			END

			-- Selección dinámica según el prefijo
			IF @servidor = 'FYCBOG'
			BEGIN
		    
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbog.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto =DCT_CiudadAdju
				FROM fycbog.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número =@NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM fycbar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCCar.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico  AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fyccar.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
			
				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCBuc.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycbuc.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN

				SELECT @NumDocumento=(SELECT DCT_Número FROM FYCOtros.dbo.DOCUMENTO WHERE DCT_Tipo = @TipoDocumento AND DCT_NumeroUnico = @NumDocumentoUnico AND DCT_Ciudad=(SELECT CPS_Ciudad FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA WHERE  cps_idTiponit =  @TipoNitAfiliado and  cps_idnit = @NumNitAfiliado))
				SELECT @CentroCosto = DCT_Ciudad
				FROM fycotros.dbo.DOCUMENTO
				WHERE DCT_Tipo = @TipoDocumento AND DCT_Número = @NumDocumento;
			END
			ELSE
			BEGIN
				PRINT 'SERVIDOR NO EXISTE.';
			END

			-- Obtener el Tipo de Soporte
			SELECT @TipoSoporte = OPT_Soporte_Contable 
			FROM FYCBOG.DBO.OPERACION_TIPO
			WHERE OPT_Nombre = @TipoPago;

			-- Actualizar y obtener el número de soporte
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_SOPORTE_CONTABILID
				SET CNC_Consecutivo = CNC_Consecutivo + 1,
					@NumSoporte = CNC_Consecutivo + 1
				WHERE CNC_TipoSoporteConta = @TipoSoporte AND CNC_CiudadSoporteConta = @CentroCosto;
			END

			-- Actualizar y obtener el número de operación
			IF @servidor  = 'FYCBOG'
			BEGIN
				UPDATE FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBOG.dbo.VARIABLES_SISTEMA, FYCBOG.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				UPDATE FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBAR.dbo.VARIABLES_SISTEMA, FYCBAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				UPDATE FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCCAR.dbo.VARIABLES_SISTEMA, FYCCAR.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN
				UPDATE FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCBUC.dbo.VARIABLES_SISTEMA, FYCBUC.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
				UPDATE FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				SET @NumOper = CNO_Consecutivo + VDS_Variable_Valor + 1,
					CNO_Consecutivo = CNO_Consecutivo + 1
				FROM FYCOTROS.dbo.VARIABLES_SISTEMA, FYCOTROS.dbo.CONSECUTIVO_OPERACIONES
				WHERE CNO_Operación = @TipoPago AND VDS_Nombre = 'BaseConsecutivo';
			END

			-- Insertar en OPERACION

			SELECT @CentroCosto,@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME()

			IF @servidor  = 'FYCBOG'
			BEGIN

				INSERT INTO FYCBOG.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBOG.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBOG.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBOG.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBOG.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE novedadesREIN
				SET estado_proceso='PROCESADO',
					numero_operacion_GMF=@NumOper,
					observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
				FROM novedadesREIN
				WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
				and Número_de_transacción=@Número_de_transacción
				and Número_de_identificación_del_Titular=@NumNitAfiliado
		

			
			END
			ELSE IF @servidor  = 'FYCBAR'
			BEGIN
				INSERT INTO FYCBAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCBar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE novedadesREIN
					SET estado_proceso='PROCESADO',
						numero_operacion_GMF=@NumOper,
						observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
					FROM novedadesREIN
					WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
					and Número_de_transacción=@Número_de_transacción
					and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
			ELSE IF @servidor  = 'FYCCAR'
			BEGIN
				INSERT INTO FYCCAR.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());
				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCCar.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCCar.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
													'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
													-101,
													'Proc PROCESADOR_OP retorna con Error',
													0
				END

				UPDATE FYCCar.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCCar.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE novedadesREIN
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM novedadesREIN
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado
					

			END
			ELSE IF @servidor  = 'FYCBUC'
			BEGIN

				INSERT INTO FYCBUC.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCBUC.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCBUC.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCBUC.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCBUC.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

			
				UPDATE novedadesREIN
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM novedadesREIN
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
			ELSE IF @servidor  = 'FYCOTROS'
			BEGIN
		
		
				INSERT INTO FYCOTROS.dbo.OPERACION
				VALUES (@TipoPago, @NumOper, @FechaRegistro, @CentroCosto, 
						@TipoDocumento, @NumDocumento, @Termino, @Producto, 
						NULL, NULL, 'P', @TipoSoporte, @NumSoporte, @CentroCosto, 
						'N/A', USER_NAME());

				-- Llamar al procedimiento PROCESADOR_OP
				EXEC @estado = FYCOtros.DBO.PROCESADOR_OP @TipoPago, @NumOper, @TipoSoporte, @NumSoporte, @CentroCosto, 'N/A';
				IF @estado <> 0
				BEGIN
				ROLLBACK TRANSACTION -- PROCESA_OP_V
				SET @Fecha_Cierre = GETDATE()
				set @Estado = -1  
				SET @MsgSalida = 'Error al llamar Procesador Op'
				EXEC @estado = FYCOtros.DBO.REGISTRAR_ERROR @Fecha_Cierre, 
											'FYC', 'MOVIMIENTO INTERESES ACUMULADOS',
											-101,
											'Proc PROCESADOR_OP retorna con Error',
											0
				END

				UPDATE FYCOtros.DBO.OPERACION SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper

				UPDATE FYCOtros.DBO.TMP_OPERACION  SET OPR_UsoConsecutivo = 'O'  
				WHERE OPR_Tipo = @TipoPago AND OPR_Consecutivo = @NumOper    

			
				UPDATE novedadesREIN
						SET estado_proceso='PROCESADO',
							numero_operacion_GMF=@NumOper,
							observaciones_proceso='OPERACION_EXITOSA HORA:'+ CONVERT(VARCHAR(20), GETDATE(), 120)
						FROM novedadesREIN
						WHERE Numero_de_producto=@TipoDocumento+'-'+@NumDocumentoUnico
						and Número_de_transacción=@Número_de_transacción
						and Número_de_identificación_del_Titular=@NumNitAfiliado

			END
		
			PRINT @Iterador;
			-- Incrementar el iterador para el siguiente registro
			SET @Iterador = @Iterador + 1;

		 END TRY 
		 BEGIN CATCH 

			PRINT 'ALGUN ERROR SE PRESENTO';
			SELECT ERROR_MESSAGE();

		 END CATCH
	END

	SELECT * FROM novedadesREIN
	WHERE estado_proceso='PROCESADO'

END
/*__________TITULARES_TOPE__________*/
ELSE IF @OpcionProceso = 4
BEGIN
SELECT * FROM TITULARSUPERATOPE
	SELECT *
FROM 
    TITULARSUPERATOPE TS
INNER JOIN 
    cavcrm.cavipetrol.DBO.Registro_GMF RG
ON 
    TS.Numero_de_identificacion_del_Titular = RG.RG_Nit;
END
END
