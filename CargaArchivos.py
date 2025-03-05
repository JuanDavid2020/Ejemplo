import math
import rich as r
import pandas as pd
import pyodbc
import os

# Parámetros de conexión
server = 'mercurio'  # Cambia esto por el nombre de tu servidor SQL Server
database = 'REPOSITORY_GMF'  # Cambia esto por el nombre de tu base de datos
driver = '{ODBC Driver 17 for SQL Server}'  # Asegúrate de tener este driver instalado

# Conexión usando autenticación de Windows
connection_string = f"""
DRIVER={{ODBC Driver 17 for SQL Server}};
SERVER={server};
DATABASE={database};
Trusted_Connection=yes;
"""
# Establecer la conexión
try:
    connection = pyodbc.connect(connection_string)
    cursor = connection .cursor()
    print("Conexión exitosa a SQL Server.")
except Exception as e:
    print("Error al conectar a SQL Server:", e)

# Ruta de la carpeta con los archivos .txt
ruta_carpeta = r'C:\Users\JuanL\OneDrive - Cavipetrol\Documentos\HU_JUANLEGUIZAMON\GMF\ArchivosEjemplo'  # Cambia esto por la ruta de tu carpeta

# Leer todos los archivos .txt de la carpeta
for archivo in os.listdir(ruta_carpeta):
    if archivo.endswith('.txt'):
        ruta_archivo = os.path.join(ruta_carpeta, archivo)
        
        if(archivo.split('-')[-1]=='INCONSISTENCIAS.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep=';', header=None, encoding='utf-8', dtype=str)
                df.columns = ['transaccion_archivo_recibido','inconsistencias_correctivas','inconsistencias_informativas']  # Ajusta los nombres
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    cursor.execute("""
                    INSERT INTO REPOSITORY_GMF.dbo.InconsistenciasPrevalidacion (transaccion_archivo_recibido, inconsistencias_correctivas, inconsistencias_informativas) 
                    VALUES (?, ?, ?)
                    """, 
                    row['transaccion_archivo_recibido'], row['inconsistencias_correctivas'], row['inconsistencias_informativas']
                    )
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue
        if(archivo.split('-')[-1]=='REVERSOSAPLICADOS.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = [  'tipo_de_registro',
                                'tipo_de_identificacion_del_titular',
                                'numero_identificacion_del_titular',
                                'digito_de_verificacion' ,
                                'numero_de_producto' ,
                                'tipo_de_producto' ,
                                'numero_de_transaccion' ,
                                'tipo_de_transaccion' ,
                                'indicador_transaccional_parcial',
                                'monto_aplicable_a_gmf' ,
                                'monto_total_transaccion' ,
                                'descripcion_de_la_transaccion' ,
                                'fecha_y_hora_de_la_transaccion',
                                'fecha_y_hora_de_la_utilizacion' ,
                                'codigo_transaccion_original',
                                'fecha_y_hora_transaccion_original']  # Ajusta los nombres
                
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    cursor.execute("""
                        INSERT INTO REPOSITORY_GMF.dbo.ReversosAplicados (
                            tipo_de_registro,
                            tipo_de_identificacion_del_titular,
                            numero_identificacion_del_titular,
                            digito_de_verificacion,
                            numero_de_producto,
                            tipo_de_producto,
                            numero_de_transaccion,
                            tipo_de_transaccion,
                            indicador_transaccional_parcial,
                            monto_aplicable_a_gmf,
                            monto_total_transaccion,
                            descripcion_de_la_transaccion,
                            fecha_y_hora_de_la_transaccion,
                            fecha_y_hora_de_la_utilizacion,
                            codigo_transaccion_original,
                            fecha_y_hora_transaccion_original
                        )
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)
                        """,
                        row['tipo_de_registro'],
                        row['tipo_de_identificacion_del_titular'],
                        row['numero_identificacion_del_titular'],
                        row['digito_de_verificacion'],
                        row['numero_de_producto'],
                        row['tipo_de_producto'],
                        row['numero_de_transaccion'],
                        row['tipo_de_transaccion'],
                        row['indicador_transaccional_parcial'],
                        row['monto_aplicable_a_gmf'],
                        row['monto_total_transaccion'],
                        row['descripcion_de_la_transaccion'],
                        row['fecha_y_hora_de_la_transaccion'],
                        row['fecha_y_hora_de_la_utilizacion'],
                        row['codigo_transaccion_original'],
                        row['fecha_y_hora_transaccion_original']
                    )
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue           
        if(archivo.split('-')[-1]=='TXCONCOBROGMF.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = ['Tipo_de_identificación_del_Titular',
                    'Número_de_identificación_del_Titular',
                    'Dígito_de_verificación',
                    'Número_de_producto',
                    'Tipo_de_producto',
                    'Número_de_transacción',
                    'Tipo_transacción',
                    'Indicador_transacción_parcial',
                    'Monto_aplicable_GMF',
                    'Monto_total_transacción',
                    'Indicador_de_cobro',
                    'Base_GMF',
                    'Valor_sugerido_a_cobrar',
                    'Fecha_y_hora_de_ejecución']  # Ajusta los nombres
                
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    
                    cursor.execute("""
                    INSERT INTO REPOSITORY_GMF.dbo.Transacciones_con_cobro_GMF (
                    Tipo_de_identificación_del_Titular,
                    Número_de_identificación_del_Titular,
                    Dígito_de_verificación,
                    Número_de_producto,
                    Tipo_de_producto,
                    Número_de_transacción,
                    Tipo_transacción,
                    Indicador_transacción_parcial,
                    Monto_aplicable_GMF,
                    Monto_total_transacción,
                    Indicador_de_cobro,
                    Base_GMF,
                    Valor_sugerido_a_cobrar,
                    Fecha_y_hora_de_ejecución
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    row['Tipo_de_identificación_del_Titular'],
                    row['Número_de_identificación_del_Titular'],
                    row['Dígito_de_verificación'],
                    row['Número_de_producto'],
                    row['Tipo_de_producto'],
                    row['Número_de_transacción'],
                    row['Tipo_transacción'],
                    row['Indicador_transacción_parcial'],
                    row['Monto_aplicable_GMF'],
                    row['Monto_total_transacción'],
                    row['Indicador_de_cobro'],
                    row['Base_GMF'],
                    row['Valor_sugerido_a_cobrar'],
                    row['Fecha_y_hora_de_ejecución']
                    )
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue           
        if(archivo.split('-')[-1]=='TXSINCOBROGMF.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = [
                'Tipo_de_identificación_del_Titular',
                'Número_de_identificación_del_Titular',
                'Dígito_de_verificación',
                'Número_de_producto',
                'Tipo_de_producto',
                'Número_de_transacción',
                'Tipo_transacción',
                'Indicador_transacción_parcial',
                'Monto_aplicable_GMF',
                'Monto_total_transacción',
                'Indicador_de_cobro',
                'Valor_del_acumulador_antes_de_la_transacción',
                'Valor_del_acumulador_despues_de_la_transacción',
                'Fecha_y_hora_de_ejecución'
                ]  # Ajusta los nombres
                
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    
                    cursor.execute("""
                    INSERT INTO REPOSITORY_GMF.dbo.Transacciones_sin_cobro_GMF (
                        Tipo_de_identificación_del_Titular,
                        Número_de_identificación_del_Titular,
                        Dígito_de_verificación,
                        Número_de_producto,
                        Tipo_de_producto,
                        Número_de_transacción,
                        Tipo_transacción,
                        Indicador_transacción_parcial,
                        Monto_aplicable_GMF,
                        Monto_total_transacción,
                        Indicador_de_cobro,
                        Valor_del_acumulador_antes_de_la_transacción,
                        Valor_del_acumulador_despues_de_la_transacción,
                        Fecha_y_hora_de_ejecución
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, 
                    row['Tipo_de_identificación_del_Titular'],
                    row['Número_de_identificación_del_Titular'],
                    row['Dígito_de_verificación'],
                    row['Número_de_producto'],
                    row['Tipo_de_producto'],
                    row['Número_de_transacción'],
                    row['Tipo_transacción'],
                    row['Indicador_transacción_parcial'],
                    row['Monto_aplicable_GMF'],
                    row['Monto_total_transacción'],
                    row['Indicador_de_cobro'],
                    row['Valor_del_acumulador_antes_de_la_transacción'],
                    row['Valor_del_acumulador_despues_de_la_transacción'],
                    row['Fecha_y_hora_de_ejecución'])
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue            
        if(archivo.split('-')[-1]=='CONTROLTX.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = [
                    'Nombre_del_archivo_original',
                    'Fecha_ejecución',
                    'Tipo_de_entidad',
                    'Código_de_entidad',
                    'Nombre_de_la_entidad',
                    'Tipo_de_producto',
                    'Total_registros_procesados',
                    'Total_registros_con_indicador_de_cobro',
                    'Total_registros_con_indicador_de_NO_cobro',
                    'Valor_total_de_la_base_del_GMF',
                    'Total_registros_transacciones_débito_procesados',
                    'Total_registros_para_reversión_procesados',
                    'Total_registros_para_reintegros_procesados',
                    'Total_registros_con_novedades',
                    'Total_registros_con_alerta',
                    'Total_clientes_consultados'
                ]
                
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    cursor.execute("""
                    INSERT INTO REPOSITORY_GMF.dbo.Control_de_registros (
                    Nombre_del_archivo_original,
                    Fecha_ejecución,
                    Tipo_de_entidad,
                    Código_de_entidad,
                    Nombre_de_la_entidad,
                    Tipo_de_producto,
                    Total_registros_procesados,
                    Total_registros_con_indicador_de_cobro,
                    Total_registros_con_indicador_de_NO_cobro,
                    Valor_total_de_la_base_del_GMF,
                    Total_registros_transacciones_débito_procesados,
                    Total_registros_para_reversión_procesados,
                    Total_registros_para_reintegros_procesados,
                    Total_registros_con_novedades,
                    Total_registros_con_alerta,
                    Total_clientes_consultados
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, row["Nombre_del_archivo_original"],
                    row["Fecha_ejecución"],
                    row["Tipo_de_entidad"],
                    row["Código_de_entidad"],
                    row["Nombre_de_la_entidad"],
                    row["Tipo_de_producto"],
                    row["Total_registros_procesados"],
                    row["Total_registros_con_indicador_de_cobro"],
                    row["Total_registros_con_indicador_de_NO_cobro"],
                    row["Valor_total_de_la_base_del_GMF"],
                    row["Total_registros_transacciones_débito_procesados"],
                    row["Total_registros_para_reversión_procesados"],
                    row["Total_registros_para_reintegros_procesados"],
                    row["Total_registros_con_novedades"],
                    row["Total_registros_con_alerta"],
                    row["Total_clientes_consultados"])   
                    
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue           
        if(archivo.split('-')[-1]=='INCONSISTENCIASPROC.txt'):
            try:
                df = pd.read_csv(ruta_archivo, sep=';', header=None, encoding='utf-8', dtype=str)
                df.columns = ['transaccion_archivo_recibido','inconsistencias_correctivas','inconsistencias_informativas']  # Ajusta los nombres
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)
                # Eliminar el último registro
                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    cursor.execute("""
                    INSERT INTO REPOSITORY_GMF.dbo.InconsistenciasProcesamiento (transaccion_archivo_recibido, inconsistencias_correctivas, inconsistencias_informativas) 
                    VALUES (?, ?, ?)
                    """, 
                    row['transaccion_archivo_recibido'], row['inconsistencias_correctivas'], row['inconsistencias_informativas']
                    )
                connection .commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")
            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")
                continue
        if(archivo.split('-')[-1]=='NOVEDADESREIN.txt'):
            try:
                # Leer el archivo como un DataFrame de pandas
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = [
                    'tipo_identificacion_titular',
                    'numero_identificacion_titular',
                    'digito_verificacion',
                    'numero_producto',
                    'tipo_producto',
                    'numero_transaccion',
                    'tipo_transaccion',
                    'indicador_transaccion_parcial',
                    'tipo_novedad',
                    'monto_aplicable_gmf',
                    'monto_total_transaccion',
                    'indicador_cobro',
                    'base_gmf_anterior',
                    'base_gmf_actual',
                    'valor_sugerido_devolver',
                    'fecha_hora_ejecucion'
                ]
                
                # Mostrar el DataFrame para ver los datos procesados
                print(f"Archivo procesado: {ruta_archivo}")
                print(df)
                df = df.iloc[:-1, :]
                df.fillna('', inplace=True)
                for index, row in df.iterrows():
                    cursor.execute("""
                        INSERT INTO REPOSITORY_GMF.dbo.novedades (
                            tipo_identificacion_titular,
                            numero_identificacion_titular,
                            digito_verificacion,
                            numero_producto,
                            tipo_producto,
                            numero_transaccion,
                            tipo_transaccion,
                            indicador_transaccion_parcial,
                            tipo_novedad,
                            monto_aplicable_gmf,
                            monto_total_transaccion,
                            indicador_cobro,
                            base_gmf_anterior,
                            base_gmf_actual,
                            valor_sugerido_devolver,
                            fecha_hora_ejecucion
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, 
                    row['tipo_identificacion_titular'], 
                    row['numero_identificacion_titular'], 
                    row['digito_verificacion'], 
                    row['numero_producto'], 
                    row['tipo_producto'], 
                    row['numero_transaccion'], 
                    row['tipo_transaccion'], 
                    row['indicador_transaccion_parcial'], 
                    row['tipo_novedad'], 
                    row['monto_aplicable_gmf'], 
                    row['monto_total_transaccion'], 
                    row['indicador_cobro'], 
                    row['base_gmf_anterior'], 
                    row['base_gmf_actual'], 
                    row['valor_sugerido_devolver'], 
                    row['fecha_hora_ejecucion']
                    )
                connection.commit()
                print(f"Datos del archivo {ruta_archivo} insertados exitosamente.")

            except Exception as e:
                print(f"Error al leer el archivo {ruta_archivo}: {e}")
        if(archivo.split('-')[-1]=='TITULARSUPERATOPE.txt'):
            try:
                
                df = pd.read_csv(ruta_archivo, sep='|', header=None, encoding='utf-8', dtype=str)
                df.columns = ['Tipo_de_identificacion_del_Titular', 
                            'Numero_de_identificacion_del_Titular', 
                            'Digito_de_verificacion', 
                            'Supera_tope', 
                            'Fecha_y_hora_novedad']
                
                r.print(f"Archivo procesado: {archivo}")
                r.print(df)

                df = df.iloc[:-1, :]   # Selecciona todas las filas excepto la última
                df.fillna('', inplace=True)  # Rellenar valores nulos con cadenas vacías

                # Insertar los registros en la base de datos
                for index, row in df.iterrows():
                    cursor.execute("""
                    INSERT INTO TITULARSUPERATOPE (
                        Tipo_de_identificacion_del_Titular, 
                        Numero_de_identificacion_del_Titular, 
                        Digito_de_verificacion, 
                        Supera_tope, 
                        Fecha_y_hora_novedad
                    ) 
                    VALUES (?, ?, ?, ?, ?)
                    """, 
                    row['Tipo_de_identificacion_del_Titular'], 
                    row['Numero_de_identificacion_del_Titular'], 
                    row['Digito_de_verificacion'], 
                    row['Supera_tope'], 
                    row['Fecha_y_hora_novedad']
                    )

                # Confirmar los cambios en la base de datos
                connection.commit()
                print(f"Datos del archivo {archivo} insertados exitosamente.")

            except Exception as e:
                r.print(f"Error al leer el archivo {archivo}: {e}")


