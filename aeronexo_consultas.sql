-- Modificar tabla pasajero
ALTER TABLE PASAJERO ADD nacionalidad VARCHAR(50);
GO
ALTER TABLE PASAJERO ALTER COLUMN nacionalidad VARCHAR(60);
GO

-- Actualizar saldo de millas
UPDATE CUENTA_NEXO_PUNTOS
SET saldo_millas = saldo_millas + 1975
WHERE id_cuenta = 1;

-- Insertar y borrar causa de prueba
INSERT INTO CAUSA_DEMORA (codigo_causa, descripcion, categoria) VALUES ('PRU-99', 'Causa de prueba', 'Operativa');
DELETE FROM CAUSA_DEMORA WHERE codigo_causa = 'PRU-99';
GO

-- Anticipar demora segun el retraso del vuelo anterior
SELECT 
    v_actual.nro_vuelo AS vuelo_proximo,
    a.matricula AS avion,
    v_previo.nro_vuelo AS vuelo_anterior,
    ed.minutos AS min_atraso_avion,
    v_actual.estado AS estado_actual,
    CASE 
        WHEN ed.minutos > 30 THEN 'Demorado'
        ELSE 'En Horario'
    END AS estado_nuevo_anticipado,
    v_actual.salida_programada AS salida_original,
    CASE 
        WHEN ed.minutos > 30 THEN DATEADD(MINUTE, ed.minutos, v_actual.salida_programada)
        ELSE v_actual.salida_programada
    END AS nueva_salida_estimada
FROM VUELO v_actual
JOIN VUELO v_previo ON v_actual.id_vuelo_previo = v_previo.id_vuelo
JOIN AERONAVE a ON v_actual.id_aeronave = a.id_aeronave
JOIN EVENTO_DEMORA ed ON v_previo.id_vuelo = ed.id_vuelo
WHERE v_actual.estado = 'Programado'
  AND v_previo.estado = 'Demorado';

-- Comparar demoras originales contra efecto domino
SELECT 
    CASE 
        WHEN es_propagada = 0 THEN 'Demora original'
        ELSE 'Efecto domino'
    END AS tipo_de_demora,
    COUNT(*) AS cantidad_vuelos,
    SUM(minutos) AS total_minutos,
    AVG(minutos) AS promedio_minutos
FROM EVENTO_DEMORA
GROUP BY es_propagada;

-- Vuelos demorados y su aeronave
SELECT VUELO.nro_vuelo, AERONAVE.matricula, VUELO.estado
FROM VUELO
JOIN AERONAVE ON VUELO.id_aeronave = AERONAVE.id_aeronave
WHERE VUELO.estado = 'Demorado';

-- Ciudades con rutas troncales (UNION)
SELECT A.ciudad
FROM RUTA R JOIN AEROPUERTO A ON R.id_aerop_origen = A.id_aeropuerto
WHERE R.es_troncal = 1
UNION
SELECT A.ciudad
FROM RUTA R JOIN AEROPUERTO A ON R.id_aerop_destino = A.id_aeropuerto
WHERE R.es_troncal = 1;

-- Pasajeros que no son socios de Nexo Puntos (EXCEPT)
SELECT id_pasajero FROM PASAJERO
EXCEPT
SELECT id_pasajero FROM CUENTA_NEXO_PUNTOS;

-- Socios que recibieron notificaciones (INTERSECT)
SELECT id_pasajero FROM CUENTA_NEXO_PUNTOS
INTERSECT
SELECT id_pasajero FROM NOTIFICACION;

-- Vuelos con demora mayor al promedio general
SELECT id_vuelo, SUM(minutos) AS total_minutos_demora
FROM EVENTO_DEMORA
GROUP BY id_vuelo
HAVING SUM(minutos) > (
    SELECT AVG(total) FROM (
        SELECT id_vuelo, SUM(minutos) AS total
        FROM EVENTO_DEMORA
        GROUP BY id_vuelo
    ) AS sub
);

-- Cantidad de pasajes por pasajero
SELECT 
    nombre, 
    apellido,
    (SELECT COUNT(*) FROM PASAJE p WHERE p.id_pasajero = pas.id_pasajero) AS cantidad_pasajes
FROM PASAJERO pas;

-- Pasajes con tarifa mayor al promedio de su clase
SELECT p1.id_pasaje, p1.clase, p1.tarifa
FROM PASAJE p1
WHERE p1.tarifa > (
    SELECT AVG(p2.tarifa)
    FROM PASAJE p2
    WHERE p1.clase = p2.clase
);

-- Vuelos con prediccion registrada (EXISTS)
SELECT v.nro_vuelo, v.estado
FROM VUELO v
WHERE EXISTS (
    SELECT 1 FROM PREDICCION_DEMORA pd WHERE pd.id_vuelo = v.id_vuelo
);

-- Aeronaves sin vuelos cancelados (NOT EXISTS)
SELECT a.matricula, a.modelo
FROM AERONAVE a
WHERE NOT EXISTS (
    SELECT 1 FROM VUELO v WHERE v.id_aeronave = a.id_aeronave AND v.estado = 'Cancelado'
);

-- Ruta con mayor distancia (ALL)
SELECT id_ruta, distancia_km, tipo_ruta
FROM RUTA
WHERE distancia_km >= ALL (SELECT distancia_km FROM RUTA);
GO

-- Funcion para descuento corporativo
CREATE OR ALTER FUNCTION dbo.calcular_tarifa_corporativa (@precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @precio * 0.90;
END;
GO

-- Funcion para calcular millas por distancia
CREATE OR ALTER FUNCTION dbo.calcular_millas_vuelo (@distancia_km INT)
RETURNS INT
AS
BEGIN
    RETURN CAST(@distancia_km * 1.5 AS INT);
END;
GO

-- Prueba de funcion de descuento
SELECT 
    id_pasaje,
    clase,
    tarifa AS tarifa_original,
    dbo.calcular_tarifa_corporativa(tarifa) AS tarifa_con_descuento
FROM PASAJE;
GO

-- Procedimiento para filtrar vuelos por estado
CREATE OR ALTER PROCEDURE listar_vuelos_por_estado (
    @p_estado VARCHAR(20)
)
AS
BEGIN
    SELECT id_vuelo, nro_vuelo, fecha, salida_programada, llegada_programada, estado
    FROM VUELO
    WHERE estado = @p_estado;
END;
GO

-- Procedimiento para registrar demora y reprogramar vuelo siguiente
CREATE OR ALTER PROCEDURE registrar_demora_y_reprogramar (
    @p_id_vuelo      INT,
    @p_codigo_causa  VARCHAR(10),
    @p_minutos       INT
)
AS
BEGIN
    UPDATE VUELO
    SET salida_programada  = DATEADD(MINUTE, @p_minutos, salida_programada),
        llegada_programada = DATEADD(MINUTE, @p_minutos, llegada_programada),
        estado             = 'Demorado'
    WHERE id_vuelo = @p_id_vuelo;

    UPDATE VUELO
    SET salida_programada  = DATEADD(MINUTE, @p_minutos, salida_programada),
        llegada_programada = DATEADD(MINUTE, @p_minutos, llegada_programada),
        estado             = 'Reprogramado'
    WHERE id_vuelo_previo = @p_id_vuelo;
END;
GO

-- Permisos de rol operador
IF DATABASE_PRINCIPAL_ID('operador_vuelos') IS NULL
    CREATE ROLE operador_vuelos;

GRANT SELECT, INSERT, DELETE ON VUELO TO operador_vuelos;
REVOKE INSERT, DELETE ON VUELO FROM operador_vuelos;
GO
