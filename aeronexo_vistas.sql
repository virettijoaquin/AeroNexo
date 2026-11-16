CREATE VIEW vista_demora_promedio_por_ruta AS
SELECT 
    r.id_ruta,
    ao.codigo_iata AS origen,
    ao.ciudad AS ciudad_origen,
    ad.codigo_iata AS destino,
    ad.ciudad AS ciudad_destino,
    COUNT(v.id_vuelo) AS vuelos_evaluados,
    ISNULL(AVG(ed.minutos), 0) AS promedio_minutos_demora,
    CASE 
        WHEN ISNULL(AVG(ed.minutos), 0) > 30 THEN 'Demora Frecuente'
        WHEN ISNULL(AVG(ed.minutos), 0) > 15 THEN 'Demora Moderada'
        ELSE 'Ruta Puntual'
    END AS comportamiento_historico
FROM RUTA r
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN AEROPUERTO ad ON r.id_aerop_destino = ad.id_aeropuerto
LEFT JOIN VUELO v ON r.id_ruta = v.id_ruta
LEFT JOIN EVENTO_DEMORA ed ON v.id_vuelo = ed.id_vuelo
GROUP BY r.id_ruta, ao.codigo_iata, ao.ciudad, ad.codigo_iata, ad.ciudad;
GO

CREATE VIEW vista_prediccion_por_vuelo_anterior AS
SELECT 
    v_actual.id_vuelo,
    v_actual.nro_vuelo,
    v_actual.fecha,
    a.matricula AS aeronave,
    v_previo.nro_vuelo AS vuelo_anterior,
    v_previo.estado AS estado_vuelo_anterior,
    ISNULL(ed.minutos, 0) AS minutos_atraso_avion,
    v_actual.salida_programada AS salida_original,
    CASE 
        WHEN ISNULL(ed.minutos, 0) > 30 THEN DATEADD(MINUTE, ed.minutos, v_actual.salida_programada)
        ELSE v_actual.salida_programada
    END AS nueva_salida_estimada,
    CASE 
        WHEN ISNULL(ed.minutos, 0) > 30 THEN 'Demorado por Vuelo Anterior'
        ELSE 'En Horario'
    END AS estado_anticipado
FROM VUELO v_actual
JOIN AERONAVE a ON v_actual.id_aeronave = a.id_aeronave
LEFT JOIN VUELO v_previo ON v_actual.id_vuelo_previo = v_previo.id_vuelo
LEFT JOIN EVENTO_DEMORA ed ON v_previo.id_vuelo = ed.id_vuelo;
GO

CREATE VIEW vista_riesgo_clima_vuelo AS
SELECT 
    v.id_vuelo,
    v.nro_vuelo,
    ao.codigo_iata AS aeropuerto_salida,
    ao.ciudad,
    v.salida_programada,
    om.fenomeno AS condicion_climatica,
    om.visibilidad_m,
    om.viento_kt,
    om.precipitacion_mm,
    CASE 
        WHEN om.visibilidad_m < 2000 OR om.viento_kt >= 30 OR om.precipitacion_mm >= 10 THEN 'Alta Probabilidad de Demora por Clima'
        WHEN om.visibilidad_m < 5000 OR om.viento_kt >= 20 THEN 'Demora Leve Posible por Clima'
        ELSE 'Clima Favorable (Sin Demora)'
    END AS pronostico_operativo_clima
FROM VUELO v
JOIN RUTA r ON v.id_ruta = r.id_ruta
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN OBSERVACION_METEO om ON ao.id_aeropuerto = om.id_aeropuerto
WHERE CAST(om.fecha_hora AS DATE) = v.fecha;
GO

CREATE VIEW vista_tablero_pasajero_prediccion AS
SELECT 
    p.id_pasajero,
    p.nombre,
    p.apellido,
    res.codigo_pnr,
    psj.asiento,
    psj.clase,
    v.nro_vuelo,
    ao.ciudad AS origen,
    ad.ciudad AS destino,
    v.salida_programada,
    ISNULL(pd.prob_demora, 0) AS probabilidad_demora,
    ISNULL(pd.minutos_estimados, 0) AS minutos_demora_estimados,
    DATEADD(MINUTE, ISNULL(pd.minutos_estimados, 0), v.salida_programada) AS horario_salida_estimado,
    (
        SELECT ISNULL(AVG(ed2.minutos), 0)
        FROM VUELO v2
        JOIN EVENTO_DEMORA ed2 ON v2.id_vuelo = ed2.id_vuelo
        WHERE v2.id_ruta = v.id_ruta
    ) AS promedio_historico_ruta_min,
    CASE 
        WHEN ISNULL(pd.prob_demora, 0) >= 0.70 OR ISNULL(pd.minutos_estimados, 0) > 30 
            THEN 'Demora Anticipada: Postergar salida hacia el aeropuerto'
        WHEN ISNULL(pd.prob_demora, 0) >= 0.40 
            THEN 'Atencion: Posible demora moderada, revisar notificaciones'
        ELSE 'Vuelo Puntual: Concurrir al aeropuerto en horario habitual'
    END AS recomendacion_viajero
FROM PASAJE psj
JOIN RESERVA res ON psj.id_reserva = res.id_reserva
JOIN PASAJERO p ON psj.id_pasajero = p.id_pasajero
JOIN VUELO v ON psj.id_vuelo = v.id_vuelo
JOIN RUTA r ON v.id_ruta = r.id_ruta
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN AEROPUERTO ad ON r.id_aerop_destino = ad.id_aeropuerto
LEFT JOIN PREDICCION_DEMORA pd ON v.id_vuelo = pd.id_vuelo;
GO
