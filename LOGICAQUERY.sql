USE REPOSITORY_GMF;
GO
SELECT * FROM Transacciones_con_cobro_GMF;

TRUNCATE TABLE Transacciones_con_cobro_GMF;

SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES
SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCCar.DBO.VINCULO_OPERACIONES
SELECT * FROM FYCBar.DBO.VINCULO_OPERACIONES
SELECT * FROM FYCBuc.DBO.VINCULO_OPERACIONES
SELECT * FROM FYCOTROS.DBO.VINCULO_OPERACIONES

USE FYCOTROS
GO

DROP TABLE VINCULO_OPERACIONES_HIST 

CREATE TABLE VINCULO_OPERACIONES_HIST (
    VOP_OrigenTipo NVARCHAR(50) NOT NULL,
    VOP_OrigenConsecutivo INT NOT NULL,
    VOP_DestinoTipo NVARCHAR(50) NOT NULL,
    VOP_DestinoConsecutivo INT NOT NULL,
    VOP_Clase NVARCHAR(50) NOT NULL,
    Fecha_insercion DATETIME DEFAULT GETDATE() -- Por defecto, la fecha actual
);


PRINT 'Guardando los datos en VINCULO_OPERACIONES_HIST antes de la limpieza.';
INSERT INTO VINCULO_OPERACIONES_HIST (VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase)
SELECT VOP_OrigenTipo, VOP_OrigenConsecutivo, VOP_DestinoTipo, VOP_DestinoConsecutivo, VOP_Clase
FROM VINCULO_OPERACIONES;



SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCCAR.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCBuc.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCOTROS.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM fycbar.DBO.VINCULO_OPERACIONES_HIST


select
LEFT(Número_de_producto, CHARINDEX('-', Número_de_producto) - 1) AS OPR_Tipo,
SUBSTRING(Número_de_producto, CHARINDEX('-', Número_de_producto) + 1, LEN(Número_de_producto)) AS OPR_DocumentoNumero,
LEFT(Numero_de_transaccion, CHARINDEX('-', Numero_de_transaccion) - 1) AS CIUDAD,
SUBSTRING(
                Numero_de_transaccion, 
                CHARINDEX('-', Numero_de_transaccion) + 1, 
                CHARINDEX('-', Numero_de_transaccion, CHARINDEX('-', Numero_de_transaccion) + 1) - CHARINDEX('-', Numero_de_transaccion) - 1
             )AS VOP_ORIGEN_TIPO,
RIGHT(Numero_de_transaccion, LEN(Numero_de_transaccion) - CHARINDEX('-', Numero_de_transaccion, CHARINDEX('-', Numero_de_transaccion) + 1)) AS CONSECUTIVO_ORIGEN,*
FROM Transacciones_con_cobro_GMF
ORDER BY OPR_DocumentoNumero ASC




IF OBJECT_ID('#TempResultados', 'U') IS NOT NULL
    DROP TABLE #TempResultados;


SELECT 
    B.Numero_de_transaccion,
    AOV.AOV_OperaciónTipo,
    AOV.AOV_OperaciónConsecutivo,
    AOV.AOV_ItemNombre,
    AOV.AOV_Valor
--INTO #TempResultados 
FROM FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES_HIST V 
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


SELECT * FROM Transacciones_con_cobro_GMF 
WHERE tipo_operacion is not null
ORDER BY BASE_GMF DESC

UPDATE Transacciones_con_cobro_GMF
SET tipo_operacion= B.AOV_OperaciónTipo,
    numero_operacion=B.AOV_OperaciónConsecutivo,
	valor_aplicado=B.AOV_Valor
FROM Transacciones_con_cobro_GMF A INNER JOIN #TempResultados B ON A.Numero_de_transaccion=B.Numero_de_transaccion

select * from #TempResultados 

SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCCAR.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCBuc.DBO.VINCULO_OPERACIONES_HIST
SELECT * FROM FYCOTROS.DBO.VINCULO_OPERACIONES_HIST

---SELECT TOP 10* FROM VINCULO_OPERACIONES_HIST

SELECT TOP 10* FROM fycbog.DBO.OPERACION
WHERE OPR_Consecutivo='100088174'
AND OPR_Tipo LIKE '%RetiroACH%'

RetiroACH	100088174

SELECT * FROM FYCBOG.DBO.ASPECTO_OPERACION_VALOR
WHERE AOV_OperaciónConsecutivo='104106189' 
AND AOV_OperaciónTipo LIKE '%GMF%'
AND AOV_ItemNombre='VrGMF'


SELECT * FROM FYCBOG.DBO.ASPECTO_OPERACION_VALOR
WHERE AOV_OperaciónConsecutivo='100245976' 
AND AOV_OperaciónTipo LIKE '%RetiroPagCartera%'

SELECT *
FROM FYCBOG.DBO.OPERACION O
	INNER JOIN FYCBOG.DBO.ASPECTO_OPERACION_VALOR A
		ON A.AOV_OperaciónConsecutivo = O.OPR_Consecutivo
			AND A.AOV_OperaciónTipo = O.OPR_Tipo
	INNER JOIN FYCBOG.DBO.PRODUCTO P
		ON P.PRO_AcuerdoTipo = O.OPR_DocumentoTipo
			AND PRO_Nombre = 'CavFai'
	INNER JOIN FYCBOG.DBO.ROL_PERSONA_DOCUMENTO R
		ON R.RPD_DocumentoNúmero = O.OPR_DocumentoNúmero
			AND R.RPD_DocumentoTipo = O.OPR_DocumentoTipo
	--INNER JOIN CAVIPETROL_REST040224.DBO.VISTA_AFILIADOS_TABLA V
		--ON V.Nit = R.RPD_IdNit
	INNER JOIN FYCBAR.DBO.ITEM_LIQUIDA_SECUENCIA L
		ON O.OPR_Tipo = L.ILS_OperaciónOrigen
		AND A.AOV_ItemNombre = L.ILS_Factor
	INNER JOIN FYCBAR.DBO.DOCUMENTO D
		ON D.DCT_Número = O.OPR_DocumentoNúmero
		AND D.DCT_Tipo = O.OPR_DocumentoTipo
 
WHERE --A.AOV_OperaciónConsecutivo = '203760400'
	 --AND
	 CONVERT(DATE,O.OPR_Fecha) = '2024-11-30'
	 --AND
	   --O.OPR_ConsecutivoSoporte = 9979926
	  --AND 
	   O.OPR_UsoConsecutivo = 'O'


	   	SELECT * FROM FYCBOG.DBO.ASPECTO_DOCUMENTO_NULO
	WHERE ADN_DocumentoTipo='AFAI' 
	AND ADN_ParámetroNombre LIKE '%GMF%'



SELECT  DISTINCT ADN_DocumentoTipo,ADN_DocumentoNúmero,ADN_ParámetroNombre 
FROM FYCBOG.DBO.ASPECTO_DOCUMENTO_NULO A
INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
ON A.ADN_DocumentoNúmero= SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
WHERE A.ADN_DocumentoTipo='AFAI' 
AND A.ADN_ParámetroNombre LIKE '%GMF%'
AND B. observaciones_proceso IS NOT NULL


UPDATE A
SET ADN_ParámetroNombre = '[AplicarGMF]'
FROM FYCBOG.DBO.ASPECTO_DOCUMENTO_NULO A
INNER JOIN REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B 
ON A.ADN_DocumentoNúmero = SUBSTRING(B.Número_de_producto, CHARINDEX('-', B.Número_de_producto) + 1, LEN(B.Número_de_producto))
WHERE A.ADN_DocumentoTipo = 'AFAI'
AND A.ADN_ParámetroNombre LIKE '%GMF%'
AND B.observaciones_proceso IS NOT NULL;
			
SELECT 
Número_de_producto,
LEFT(Número_de_producto, CHARINDEX('-', Número_de_producto) - 1) AS Prefijo,
SUBSTRING(Número_de_producto, CHARINDEX('-', Número_de_producto) + 1, LEN(Número_de_producto)) AS NumeroProducto,*
FROM REPOSITORY_GMF.DBO.Transacciones_con_cobro_GMF B
WHERE observaciones_proceso IS NOT NULL
AND fecha_insercion=GETDATE()




SELECT * FROM FYCBOG.DBO.ITEM_DOCUMENTO_NULO WHERE IDN_Nombre='[ExcentoGMF]'
SELECT * FROM MIDAS.FYC.DBO.ITEM_DOCUMENTO_NULO WHERE IDN_Nombre='[AplicarGMF]'


INSERT INTO FYCBOG.DBO.ITEM_DOCUMENTO_NULO (IDN_Tipo, IDN_Nombre, IDN_Descripción)
VALUES ('Afai', '[AplicarGMF]', 'Marca con GMF Cuenta Ahorros.');


select * from midas.FYC.DBO.ASPECTO_DOCUMENTO_FECHA  where ADF_ParámetroNombre like '%gmf%'
