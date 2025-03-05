USE FYC
GO

IF OBJECT_ID('VINCULO_OPERACIONES_HIST', 'U') IS NOT NULL
BEGIN
    DROP TABLE VINCULO_OPERACIONES_HIST;
    PRINT 'Tabla VINCULO_OPERACIONES_HIST eliminada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla VINCULO_OPERACIONES_HIST no existe.';
END

CREATE TABLE VINCULO_OPERACIONES_HIST (
    VOP_OrigenTipo NVARCHAR(50) NOT NULL,
    VOP_OrigenConsecutivo INT NOT NULL,
    VOP_DestinoTipo NVARCHAR(50) NOT NULL,
    VOP_DestinoConsecutivo INT NOT NULL,
    VOP_Clase NVARCHAR(50) NOT NULL,
    Fecha_insercion DATETIME DEFAULT GETDATE() -- Por defecto, la fecha actual
);
