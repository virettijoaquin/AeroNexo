INSERT INTO AEROPUERTO (id_aeropuerto, codigo_iata, nombre, ciudad, pais, es_hub) VALUES
(1, 'AEP', 'Aeroparque Jorge Newbery', 'Buenos Aires', 'Argentina', 1),
(2, 'EZE', 'Aeropuerto Internacional Ministro Pistarini', 'Ezeiza', 'Argentina', 1),
(3, 'COR', 'Aeropuerto Internacional Ing. Taravella', 'Cordoba', 'Argentina', 0),
(4, 'MDZ', 'Aeropuerto Internacional El Plumerillo', 'Mendoza', 'Argentina', 0);

INSERT INTO RUTA (id_ruta, id_aerop_origen, id_aerop_destino, distancia_km, tipo_ruta, es_troncal) VALUES
(1, 1, 3, 650, 'Domestica', 1),
(2, 3, 1, 650, 'Domestica', 1),
(3, 1, 4, 985, 'Domestica', 1),
(4, 2, 4, 995, 'Domestica', 0);

INSERT INTO AERONAVE (id_aeronave, matricula, modelo, asientos_eco, asientos_plus, capacidad_carga_kg, estado) VALUES
(1, 'LV-NEXO', 'Boeing 737 MAX 8', 156, 16, 4500.00, 'Operativa'),
(2, 'LV-NEXA', 'Boeing 737 MAX 8', 156, 16, 4500.00, 'Operativa'),
(3, 'LV-NEXB', 'Embraer E195-E2', 120, 12, 3200.00, 'Operativa');

INSERT INTO TRIPULANTE (id_tripulante, legajo, nombre, apellido, rol, id_base, venc_licencia) VALUES
(1, 'LEG-101', 'Martin', 'Salaverry', 'Comandante', 1, '2027-08-15'),
(2, 'LEG-102', 'Lucia', 'Penaloza', 'Primer Oficial', 1, '2027-05-20'),
(3, 'LEG-103', 'Santiago', 'Kovacs', 'Jefe de Cabina', 1, '2027-11-30'),
(4, 'LEG-201', 'Federico', 'Alzamendi', 'Comandante', 2, '2027-06-18');

INSERT INTO VUELO (id_vuelo, nro_vuelo, fecha, id_ruta, id_aeronave, id_vuelo_previo, salida_programada, llegada_programada, salida_real, llegada_real, estado) VALUES
(1, 'AN-101', '2026-11-18', 1, 1, NULL, '2026-11-18 07:00:00', '2026-11-18 08:20:00', '2026-11-18 07:45:00', '2026-11-18 09:05:00', 'Demorado'),
(2, 'AN-102', '2026-11-18', 2, 1, 1, '2026-11-18 09:10:00', '2026-11-18 10:30:00', NULL, NULL, 'Demorado'),
(3, 'AN-103', '2026-11-18', 3, 1, 2, '2026-11-18 11:20:00', '2026-11-18 13:05:00', NULL, NULL, 'Programado'),
(4, 'AN-201', '2026-11-18', 4, 2, NULL, '2026-11-18 08:00:00', '2026-11-18 09:50:00', '2026-11-18 08:02:00', '2026-11-18 09:48:00', 'Aterrizado');

INSERT INTO ASIGNACION_TRIPULACION (id_vuelo, id_tripulante, funcion) VALUES
(1, 1, 'Comandante'),
(1, 2, 'Primer Oficial'),
(1, 3, 'Jefe de Cabina'),
(4, 4, 'Comandante');

INSERT INTO CLIENTE_CORPORATIVO (id_cliente, cuit, razon_social, tipo_cliente, plan_nexo_ops) VALUES
(1, '30-71548921-9', 'Despegar Viajes S.A.', 'Agencia', 'Enterprise'),
(2, '30-68912345-2', 'TechCorp Cono Sur S.R.L.', 'Corporativo', 'Pro'),
(3, '30-54129876-4', 'Aeropuertos Argentina 2000 S.A.', 'Aeropuerto', 'Enterprise');

INSERT INTO PASAJERO (id_pasajero, tipo_doc, nro_doc, nombre, apellido, email, telefono) VALUES
(1, 'DNI', '42891023', 'Joaquin', 'Viretti', 'jviretti@uade.edu.ar', '1155001122'),
(2, 'DNI', '39102938', 'Sofia', 'Mendizabal', 'sofia.m@techcorp.com.ar', '1166778899'),
(3, 'DNI', '35881122', 'Tomas', 'Echeverria', 'tomas.eche@gmail.com', '1144332211'),
(4, 'PASAPORTE', 'AAB99281', 'Mariana', 'Duarte', 'mduarte@consultora.cl', '988776655');

INSERT INTO RESERVA (id_reserva, codigo_pnr, id_cliente, fecha_reserva, canal_venta) VALUES
(1, 'NX881A', NULL, '2026-11-10', 'App'),
(2, 'NX902B', 2, '2026-11-11', 'Corporativo'),
(3, 'NX774C', 1, '2026-11-12', 'Agencia');

INSERT INTO PASAJE (id_pasaje, id_reserva, id_pasajero, id_vuelo, clase, asiento, tarifa, estado) VALUES
(1, 1, 1, 1, 'Nexo Plus', '01A', 180000.00, 'Abordado'),
(2, 2, 2, 2, 'Nexo Plus', '01C', 195000.00, 'Emitido'),
(3, 3, 3, 3, 'Economica', '14B', 95000.00, 'Emitido'),
(4, 3, 4, 4, 'Economica', '10F', 140000.00, 'Abordado');

INSERT INTO ENVIO_CARGA (id_envio, id_vuelo, id_cliente, peso_kg, tipo_carga, estado) VALUES
(1, 1, 2, 850.00, 'Prioritaria', 'En Bodega'),
(2, 3, 1, 1200.00, 'General', 'Registrado'),
(3, 4, 3, 420.00, 'Valiosa', 'Entregado');

INSERT INTO CUENTA_NEXO_PUNTOS (id_cuenta, id_pasajero, nivel, saldo_millas, fecha_alta) VALUES
(1, 1, 'Oro', 25000, '2025-03-10'),
(2, 2, 'Plata', 12000, '2025-07-22'),
(3, 4, 'Inicial', 3500, '2026-01-15');

INSERT INTO MOVIMIENTO_PUNTOS (id_movimiento, id_cuenta, id_pasaje, tipo, millas, fecha) VALUES
(1, 1, 1, 'Acreditacion', 975, '2026-11-18'),
(2, 1, NULL, 'Bonificacion', 1000, '2026-11-18'),
(3, 2, 2, 'Acreditacion', 975, '2026-11-18');

INSERT INTO CAUSA_DEMORA (codigo_causa, descripcion, categoria) VALUES
('MET-01', 'Tormenta electrica en aeropuerto de origen', 'Meteorologica'),
('ROT-01', 'Arribo tardio de aeronave en vuelo previo (Efecto Domino)', 'Efecto Domino'),
('TEC-01', 'Revision tecnica en plataforma', 'Tecnica');

INSERT INTO EVENTO_DEMORA (id_evento, id_vuelo, codigo_causa, minutos, es_propagada, registrado_en) VALUES
(1, 1, 'MET-01', 45, 0, '2026-11-18 06:40:00'),
(2, 2, 'ROT-01', 35, 1, '2026-11-18 08:30:00'),
(3, 3, 'ROT-01', 25, 1, '2026-11-18 10:40:00');

INSERT INTO OBSERVACION_METEO (id_observacion, id_aeropuerto, fecha_hora, visibilidad_m, viento_kt, precipitacion_mm, fenomeno, fuente) VALUES
(1, 1, '2026-11-18 06:00:00', 1500, 32, 15.00, 'Tormenta Electrica', 'SMN-METAR'),
(2, 3, '2026-11-18 06:00:00', 9000, 10, 0.00, 'Despejado', 'SMN-METAR'),
(3, 4, '2026-11-18 06:00:00', 8500, 12, 0.00, 'Despejado', 'SMN-METAR');

INSERT INTO PREDICCION_DEMORA (id_prediccion, id_vuelo, calculada_en, prob_demora, minutos_estimados, version_modelo) VALUES
(1, 2, '2026-11-18 07:10:00', 0.88, 35, 'NexoML-v1'),
(2, 3, '2026-11-18 08:40:00', 0.72, 25, 'NexoML-v1'),
(3, 4, '2026-11-18 07:00:00', 0.10, 0, 'NexoML-v1');

INSERT INTO NOTIFICACION (id_notificacion, id_prediccion, id_pasajero, canal, enviada_en, estado) VALUES
(1, 1, 1, 'App Push', '2026-11-18 07:11:00', 'Enviada'),
(2, 1, 2, 'Email', '2026-11-18 07:11:00', 'Enviada'),
(3, 2, 3, 'SMS', '2026-11-18 08:41:00', 'Enviada');

INSERT INTO CONFIGURACION_PREDICCION (
    id_config, umbral_demora_severa_min, umbral_demora_leve_min,
    umbral_visibilidad_baja_m, umbral_visibilidad_med_m,
    umbral_viento_fuerte_kt, umbral_viento_med_kt, umbral_precipitacion_mm,
    umbral_prob_alta, umbral_prob_media, factor_descuento_corp, factor_millas_km,
    txt_estado_demorado, txt_estado_en_horario, txt_estado_reprogramado,
    txt_estado_programado, txt_estado_cancelado,
    txt_demora_original, txt_demora_domino,
    txt_ruta_frecuente, txt_ruta_moderada, txt_ruta_puntual,
    txt_clima_severo, txt_clima_moderado, txt_clima_favorable,
    txt_recom_postergar, txt_recom_atencion, txt_recom_puntual, activa
) VALUES (
    1, 30, 15,
    2000, 5000,
    30, 20, 10.00,
    0.70, 0.40, 0.90, 1.50,
    'Demorado', 'En Horario', 'Reprogramado',
    'Programado', 'Cancelado',
    'Demora original', 'Efecto domino',
    'Demora Frecuente', 'Demora Moderada', 'Ruta Puntual',
    'Alta Probabilidad de Demora por Clima', 'Demora Leve Posible por Clima', 'Clima Favorable (Sin Demora)',
    'Demora Anticipada: Postergar salida hacia el aeropuerto',
    'Atencion: Posible demora moderada, revisar notificaciones',
    'Vuelo Puntual: Concurrir al aeropuerto en horario habitual', 1
);
GO
