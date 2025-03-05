USE REPOSITORY_GMF;
GO

-- Tabla InconsistenciasPrevalidacion
IF OBJECT_ID('dbo.InconsistenciasPrevalidacion', 'U') IS NOT NULL
    DROP TABLE dbo.InconsistenciasPrevalidacion;

CREATE TABLE InconsistenciasPrevalidacion (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    transaccion_archivo_recibido VARCHAR(MAX),
    inconsistencias_correctivas VARCHAR(MAX),
    inconsistencias_informativas VARCHAR(MAX)
);

-- Tabla ReversosAplicados
IF OBJECT_ID('dbo.ReversosAplicados', 'U') IS NOT NULL
    DROP TABLE dbo.ReversosAplicados;

CREATE TABLE ReversosAplicados (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    tipo_de_registro VARCHAR(MAX),
    tipo_de_identificacion_del_titular VARCHAR(MAX),
    numero_identificacion_del_titular VARCHAR(MAX),
    digito_de_verificacion VARCHAR(MAX),
    numero_de_producto VARCHAR(MAX),
    tipo_de_producto VARCHAR(MAX),
    numero_de_transaccion VARCHAR(MAX),
    tipo_de_transaccion VARCHAR(MAX),
    indicador_transaccional_parcial VARCHAR(MAX),
    monto_aplicable_a_gmf VARCHAR(MAX),
    monto_total_transaccion VARCHAR(MAX),
    descripcion_de_la_transaccion VARCHAR(MAX),
    fecha_y_hora_de_la_transaccion VARCHAR(MAX),
    fecha_y_hora_de_la_utilizacion VARCHAR(MAX),
    codigo_transaccion_original VARCHAR(MAX),
    fecha_y_hora_transaccion_original VARCHAR(MAX)
);

-- Tabla Transacciones_con_cobro_GMF
IF OBJECT_ID('Transacciones_con_cobro_GMF', 'U') IS NOT NULL
    DROP TABLE Transacciones_con_cobro_GMF;

CREATE TABLE Transacciones_con_cobro_GMF (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_de_identificación_del_Titular VARCHAR(MAX),
    Número_de_identificación_del_Titular VARCHAR(MAX),
    [Dígito_de_verificación] VARCHAR(MAX),
    [Número_de_producto] VARCHAR(MAX),
    [Tipo_de_producto] VARCHAR(MAX),
    [Número_de_transacción] VARCHAR(MAX),
    [Tipo_transacción] VARCHAR(MAX),
    [Indicador_transacción_parcial] VARCHAR(MAX),
    [Monto_aplicable_GMF] VARCHAR(MAX),
    [Monto_total_transacción] VARCHAR(MAX),
    [Indicador_de_cobro] VARCHAR(MAX),
    [Base_GMF] VARCHAR(MAX),
    [Valor_sugerido_a_cobrar] VARCHAR(MAX),
    [Fecha_y_hora_de_ejecución] VARCHAR(MAX),
	fecha_insercion datetime default getdate(),
	estado_proceso varchar(100) default 'Pendiente',
    tipo_operacion varchar(100),
	numero_operacion varchar(100),
	tipo_operacion_asincronica varchar(100),
	numero_operacion_GMF varchar(100),
	valor_aplicado varchar(100),
	valor_aplicado_asincronico varchar(100),
	observaciones_proceso varchar(max) 

);

-- Tabla Transacciones_sin_cobro_GMF
IF OBJECT_ID('Transacciones_sin_cobro_GMF', 'U') IS NOT NULL
    DROP TABLE Transacciones_sin_cobro_GMF;

CREATE TABLE Transacciones_sin_cobro_GMF (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_de_identificación_del_Titular VARCHAR(MAX),
    Número_de_identificación_del_Titular VARCHAR(MAX),
    Dígito_de_verificación VARCHAR(MAX),
    Número_de_producto VARCHAR(MAX),
    Tipo_de_producto VARCHAR(MAX),
    Número_de_transacción VARCHAR(MAX),
    Tipo_transacción VARCHAR(MAX),
    Indicador_transacción_parcial VARCHAR(MAX),
    Monto_aplicable_GMF VARCHAR(MAX),
    Monto_total_transacción VARCHAR(MAX),
    Indicador_de_cobro VARCHAR(MAX),
    Valor_del_acumulador_antes_de_la_transacción VARCHAR(MAX),
    Valor_del_acumulador_despues_de_la_transacción VARCHAR(MAX),
    Fecha_y_hora_de_ejecución VARCHAR(MAX),
	fecha_insercion datetime default getdate(),
	estado_proceso varchar(100) default 'Pendiente',
    tipo_operacion varchar(100),
	numero_operacion varchar(100),
	tipo_operacion_asincronica varchar(100),
	numero_operacion_GMF varchar(100),
	valor_aplicado varchar(100),
	valor_aplicado_asincronico varchar(100),
	observaciones_proceso varchar(max) 
);

-- Tabla Control_de_registros
IF OBJECT_ID('dbo.Control_de_registros', 'U') IS NOT NULL
    DROP TABLE dbo.Control_de_registros;

CREATE TABLE Control_de_registros (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre_del_archivo_original VARCHAR(MAX),
    Fecha_ejecución VARCHAR(MAX),
    Tipo_de_entidad VARCHAR(MAX),
    Código_de_entidad VARCHAR(MAX),
    Nombre_de_la_entidad VARCHAR(MAX),
    Tipo_de_producto VARCHAR(MAX),
    Total_registros_procesados VARCHAR(MAX),
    Total_registros_con_indicador_de_cobro VARCHAR(MAX),
    Total_registros_con_indicador_de_NO_cobro VARCHAR(MAX),
    Valor_total_de_la_base_del_GMF VARCHAR(MAX),
    Total_registros_transacciones_débito_procesados VARCHAR(MAX),
    Total_registros_para_reversión_procesados VARCHAR(MAX),
    Total_registros_para_reintegros_procesados VARCHAR(MAX),
    Total_registros_con_novedades VARCHAR(MAX),
    Total_registros_con_alerta VARCHAR(MAX),
    Total_clientes_consultados VARCHAR(MAX)
);

-- Tabla InconsistenciasProcesamiento
IF OBJECT_ID('dbo.InconsistenciasProcesamiento', 'U') IS NOT NULL
    DROP TABLE dbo.InconsistenciasProcesamiento;

CREATE TABLE InconsistenciasProcesamiento (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    transaccion_archivo_recibido VARCHAR(MAX),
    inconsistencias_correctivas VARCHAR(MAX),
    inconsistencias_informativas VARCHAR(MAX)
);
--####################ARCHIVOS ESPECIALES####################################
-- Tabla novedades
IF OBJECT_ID('dbo.novedadesREIN', 'U') IS NOT NULL
    DROP TABLE dbo.novedadesREIN;

CREATE TABLE novedadesREIN (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_de_identificación_del_Titular VARCHAR(MAX),
    Número_de_identificación_del_Titular VARCHAR(MAX),
    digito_verificacion VARCHAR(MAX),
    Número_de_producto VARCHAR(MAX),
    tipo_producto VARCHAR(MAX),
    Número_de_transacción VARCHAR(MAX),
    tipo_transaccion VARCHAR(MAX),
    indicador_transaccion_parcial VARCHAR(MAX),
    tipo_novedad VARCHAR(MAX),
    monto_aplicable_gmf VARCHAR(MAX),
    monto_total_transaccion VARCHAR(MAX),
    indicador_cobro VARCHAR(MAX),
    base_gmf_anterior VARCHAR(MAX),
    base_gmf_actual VARCHAR(MAX),
    valor_sugerido_devolver VARCHAR(MAX),
    fecha_hora_ejecucion VARCHAR(MAX),
	fecha_insercion datetime default getdate(),
	estado_proceso varchar(100) default 'Pendiente',
    tipo_operacion varchar(100),
	numero_operacion varchar(100),
	tipo_operacion_asincronica varchar(100),
	numero_operacion_GMF varchar(100),
	valor_aplicado varchar(100),
	valor_aplicado_asincronico varchar(100),
	observaciones_proceso varchar(max) 
);

-- Tabla TITULARSUPERATOPE
IF OBJECT_ID('dbo.TITULARSUPERATOPE', 'U') IS NOT NULL
    DROP TABLE dbo.TITULARSUPERATOPE;

CREATE TABLE TITULARSUPERATOPE (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_de_identificacion_del_Titular VARCHAR(MAX),
    Numero_de_identificacion_del_Titular VARCHAR(MAX),
    Digito_de_verificacion VARCHAR(MAX),
    Supera_tope VARCHAR(MAX),
    Fecha_y_hora_novedad VARCHAR(MAX)
);
GO
--#####ARCHIVOS DE REINTEGRO######################
IF OBJECT_ID('dbo.InconsistenciasPrevalidacionReintegros', 'U') IS NOT NULL
    DROP TABLE dbo.InconsistenciasPrevalidacionReintegros;

CREATE TABLE InconsistenciasPrevalidacionReintegros (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    transaccion_archivo_recibido VARCHAR(MAX),
    inconsistencias_correctivas VARCHAR(MAX),
    inconsistencias_informativas VARCHAR(MAX)
);

IF OBJECT_ID('dbo.Control_de_registrosReintegros', 'U') IS NOT NULL
    DROP TABLE dbo.Control_de_registrosReintegros;

CREATE TABLE Control_de_registrosReintegros (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre_del_archivo_original VARCHAR(MAX),
    Fecha_ejecución VARCHAR(MAX),
    Tipo_de_entidad VARCHAR(MAX),
    Código_de_entidad VARCHAR(MAX),
    Nombre_de_la_entidad VARCHAR(MAX),
    Tipo_de_producto VARCHAR(MAX),
    Total_registros_procesados VARCHAR(MAX),
    Total_registros_con_indicador_de_cobro VARCHAR(MAX),
    Total_registros_con_indicador_de_NO_cobro VARCHAR(MAX),
    Valor_total_de_la_base_del_GMF VARCHAR(MAX),
    Total_registros_transacciones_débito_procesados VARCHAR(MAX),
    Total_registros_para_reversión_procesados VARCHAR(MAX),
    Total_registros_para_reintegros_procesados VARCHAR(MAX),
    Total_registros_con_novedades VARCHAR(MAX),
    Total_registros_con_alerta VARCHAR(MAX),
    Total_clientes_consultados VARCHAR(MAX)
);

IF OBJECT_ID('dbo.novedadesReintegro', 'U') IS NOT NULL
    DROP TABLE dbo.novedadesReintegro;

CREATE TABLE novedadesReintegro (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    tipo_identificacion_titular VARCHAR(MAX),
    numero_identificacion_titular VARCHAR(MAX),
    digito_verificacion VARCHAR(MAX),
    numero_producto VARCHAR(MAX),
    tipo_producto VARCHAR(MAX),
    numero_transaccion VARCHAR(MAX),
    tipo_transaccion VARCHAR(MAX),
    indicador_transaccion_parcial VARCHAR(MAX),
    tipo_novedad VARCHAR(MAX),
    monto_aplicable_gmf VARCHAR(MAX),
    monto_total_transaccion VARCHAR(MAX),
    indicador_cobro VARCHAR(MAX),
    base_gmf_anterior VARCHAR(MAX),
    base_gmf_actual VARCHAR(MAX),
    valor_sugerido_devolver VARCHAR(MAX),
    fecha_hora_ejecucion VARCHAR(MAX),
	fecha_insercion datetime default getdate(),
	estado_proceso varchar(100) default 'Pendiente',
    tipo_operacion varchar(100),
	numero_operacion varchar(100),
	tipo_operacion_asincronica varchar(100),
	numero_operacion_GMF varchar(100),
	valor_aplicado varchar(100),
	valor_aplicado_asincronico varchar(100),
	observaciones_proceso varchar(max) 
);


--################################################

-- Consultas de prueba
SELECT * FROM InconsistenciasPrevalidacion;
SELECT * FROM ReversosAplicados;
SELECT * FROM Transacciones_con_cobro_GMF ORDER BY Base_GMF DESC;
SELECT * FROM Transacciones_sin_cobro_GMF;
SELECT * FROM Control_de_registros;
SELECT * FROM InconsistenciasProcesamiento;
SELECT * FROM novedadesReintegro


SELECT * FROM novedadesREIN;
SELECT * FROM TITULARSUPERATOPE;
	

SELECT * FROM Transacciones_con_cobro_GMF;
SELECT * FROM Transacciones_sin_cobro_GMF
SELECT * FROM ARCHIVO_ENTRADA_GMF

SELECT * FROM fycbog.DBO.Aspecto_Documento_Nulo where ADN_DocumentoTipo like '%AFAI%'

/**lEER TABLA CON PENDIENTES
/// BUSCAR A QUE SERVIDOR PERTENCE CADA OPERACION -- EN NUMERO DE PRODUCTO HACER UN SPLIT AFAI(DOCUMENTO-TIPO) DEL GUION PARA ALLA DOCUMENTO NUMERO
//// TIPO DE OPERACION-->GMF_SupTope,NCReintegroGMF
*/

--SELECT  TOP 100000* from fycbog.dbo.operacion