CREATE OR ALTER VIEW vista_demora_promedio_por_ruta AS
SELECT 
    r.id_ruta,
    ao.codigo_iata AS origen,
    ao.ciudad AS ciudad_origen,
    ad.codigo_iata AS destino,
    ad.ciudad AS ciudad_destino,
    COUNT(v.id_vuelo) AS vuelos_evaluados,
    ISNULL(AVG(ed.minutos), 0) AS promedio_minutos_demora,
    CASE 
        WHEN ISNULL(AVG(ed.minutos), 0) > cfg.umbral_demora_severa_min THEN cfg.txt_ruta_frecuente
        WHEN ISNULL(AVG(ed.minutos), 0) > cfg.umbral_demora_leve_min THEN cfg.txt_ruta_moderada
        ELSE cfg.txt_ruta_puntual
    END AS comportamiento_historico
FROM RUTA r
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN AEROPUERTO ad ON r.id_aerop_destino = ad.id_aeropuerto
JOIN CONFIGURACION_PREDICCION cfg ON cfg.activa = 1
LEFT JOIN VUELO v ON r.id_ruta = v.id_ruta
LEFT JOIN EVENTO_DEMORA ed ON v.id_vuelo = ed.id_vuelo
GROUP BY 
    r.id_ruta, ao.codigo_iata, ao.ciudad, ad.codigo_iata, ad.ciudad,
    cfg.umbral_demora_severa_min, cfg.umbral_demora_leve_min,
    cfg.txt_ruta_frecuente, cfg.txt_ruta_moderada, cfg.txt_ruta_puntual;
GO

CREATE OR ALTER VIEW vista_prediccion_por_vuelo_anterior AS
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
        WHEN ISNULL(ed.minutos, 0) > cfg.umbral_demora_severa_min THEN DATEADD(MINUTE, ed.minutos, v_actual.salida_programada)
        ELSE v_actual.salida_programada
    END AS nueva_salida_estimada,
    CASE 
        WHEN ISNULL(ed.minutos, 0) > cfg.umbral_demora_severa_min THEN cfg.txt_estado_demorado
        ELSE cfg.txt_estado_en_horario
    END AS estado_anticipado
FROM VUELO v_actual
JOIN AERONAVE a ON v_actual.id_aeronave = a.id_aeronave
JOIN CONFIGURACION_PREDICCION cfg ON cfg.activa = 1
LEFT JOIN VUELO v_previo ON v_actual.id_vuelo_previo = v_previo.id_vuelo
LEFT JOIN EVENTO_DEMORA ed ON v_previo.id_vuelo = ed.id_vuelo;
GO

CREATE OR ALTER VIEW vista_riesgo_clima_vuelo AS
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
        WHEN om.visibilidad_m < cfg.umbral_visibilidad_baja_m 
          OR om.viento_kt >= cfg.umbral_viento_fuerte_kt 
          OR om.precipitacion_mm >= cfg.umbral_precipitacion_mm 
            THEN cfg.txt_clima_severo
        WHEN om.visibilidad_m < cfg.umbral_visibilidad_med_m 
          OR om.viento_kt >= cfg.umbral_viento_med_kt 
            THEN cfg.txt_clima_moderado
        ELSE cfg.txt_clima_favorable
    END AS pronostico_operativo_clima
FROM VUELO v
JOIN RUTA r ON v.id_ruta = r.id_ruta
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN OBSERVACION_METEO om ON ao.id_aeropuerto = om.id_aeropuerto
JOIN CONFIGURACION_PREDICCION cfg ON cfg.activa = 1
WHERE CAST(om.fecha_hora AS DATE) = v.fecha;
GO

CREATE OR ALTER VIEW vista_tablero_pasajero_prediccion AS
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
        WHEN ISNULL(pd.prob_demora, 0) >= cfg.umbral_prob_alta 
          OR ISNULL(pd.minutos_estimados, 0) > cfg.umbral_demora_severa_min 
            THEN cfg.txt_recom_postergar
        WHEN ISNULL(pd.prob_demora, 0) >= cfg.umbral_prob_media 
            THEN cfg.txt_recom_atencion
        ELSE cfg.txt_recom_puntual
    END AS recomendacion_viajero
FROM PASAJE psj
JOIN RESERVA res ON psj.id_reserva = res.id_reserva
JOIN PASAJERO p ON psj.id_pasajero = p.id_pasajero
JOIN VUELO v ON psj.id_vuelo = v.id_vuelo
JOIN RUTA r ON v.id_ruta = r.id_ruta
JOIN AEROPUERTO ao ON r.id_aerop_origen = ao.id_aeropuerto
JOIN AEROPUERTO ad ON r.id_aerop_destino = ad.id_aeropuerto
JOIN CONFIGURACION_PREDICCION cfg ON cfg.activa = 1
LEFT JOIN PREDICCION_DEMORA pd ON v.id_vuelo = pd.id_vuelo;
GO
