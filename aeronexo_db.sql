CREATE TABLE AEROPUERTO (
    id_aeropuerto INT PRIMARY KEY,
    codigo_iata   CHAR(3) NOT NULL UNIQUE,
    nombre        VARCHAR(100) NOT NULL,
    ciudad        VARCHAR(80) NOT NULL,
    pais          VARCHAR(60) NOT NULL,
    es_hub        BIT NOT NULL
);

CREATE TABLE RUTA (
    id_ruta          INT PRIMARY KEY,
    id_aerop_origen  INT NOT NULL,
    id_aerop_destino INT NOT NULL,
    distancia_km     INT NOT NULL CHECK (distancia_km > 0),
    tipo_ruta        VARCHAR(20) NOT NULL CHECK (tipo_ruta IN ('Domestica', 'Regional')),
    es_troncal       BIT NOT NULL,
    FOREIGN KEY (id_aerop_origen) REFERENCES AEROPUERTO(id_aeropuerto),
    FOREIGN KEY (id_aerop_destino) REFERENCES AEROPUERTO(id_aeropuerto),
    CHECK (id_aerop_origen <> id_aerop_destino)
);

CREATE TABLE AERONAVE (
    id_aeronave        INT PRIMARY KEY,
    matricula          VARCHAR(10) NOT NULL UNIQUE,
    modelo             VARCHAR(60) NOT NULL,
    asientos_eco       INT NOT NULL CHECK (asientos_eco > 0),
    asientos_plus      INT NOT NULL CHECK (asientos_plus >= 0),
    capacidad_carga_kg DECIMAL(10,2) NOT NULL CHECK (capacidad_carga_kg > 0),
    estado             VARCHAR(25) NOT NULL
);

CREATE TABLE TRIPULANTE (
    id_tripulante INT PRIMARY KEY,
    legajo        VARCHAR(15) NOT NULL UNIQUE,
    nombre        VARCHAR(60) NOT NULL,
    apellido      VARCHAR(60) NOT NULL,
    rol           VARCHAR(30) NOT NULL,
    id_base       INT NOT NULL,
    venc_licencia DATE NOT NULL,
    FOREIGN KEY (id_base) REFERENCES AEROPUERTO(id_aeropuerto)
);

CREATE TABLE VUELO (
    id_vuelo           INT PRIMARY KEY,
    nro_vuelo          VARCHAR(10) NOT NULL,
    fecha              DATE NOT NULL,
    id_ruta            INT NOT NULL,
    id_aeronave        INT NOT NULL,
    id_vuelo_previo    INT NULL,
    salida_programada  DATETIME NOT NULL,
    llegada_programada DATETIME NOT NULL,
    salida_real        DATETIME NULL,
    llegada_real       DATETIME NULL,
    estado             VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_ruta) REFERENCES RUTA(id_ruta),
    FOREIGN KEY (id_aeronave) REFERENCES AERONAVE(id_aeronave),
    FOREIGN KEY (id_vuelo_previo) REFERENCES VUELO(id_vuelo),
    CHECK (llegada_programada > salida_programada)
);

CREATE TABLE ASIGNACION_TRIPULACION (
    id_vuelo      INT NOT NULL,
    id_tripulante INT NOT NULL,
    funcion       VARCHAR(40) NOT NULL,
    PRIMARY KEY (id_vuelo, id_tripulante),
    FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    FOREIGN KEY (id_tripulante) REFERENCES TRIPULANTE(id_tripulante) ON DELETE CASCADE
);

CREATE TABLE CLIENTE_CORPORATIVO (
    id_cliente    INT PRIMARY KEY,
    cuit          VARCHAR(13) NOT NULL UNIQUE,
    razon_social  VARCHAR(100) NOT NULL,
    tipo_cliente  VARCHAR(30) NOT NULL,
    plan_nexo_ops VARCHAR(20) NOT NULL
);

CREATE TABLE PASAJERO (
    id_pasajero INT PRIMARY KEY,
    tipo_doc    VARCHAR(10) NOT NULL,
    nro_doc     VARCHAR(20) NOT NULL,
    nombre      VARCHAR(60) NOT NULL,
    apellido    VARCHAR(60) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    telefono    VARCHAR(30) NOT NULL,
    UNIQUE (tipo_doc, nro_doc)
);

CREATE TABLE RESERVA (
    id_reserva    INT PRIMARY KEY,
    codigo_pnr    CHAR(6) NOT NULL UNIQUE,
    id_cliente    INT NULL,
    fecha_reserva DATE NOT NULL,
    canal_venta   VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE_CORPORATIVO(id_cliente)
);

CREATE TABLE PASAJE (
    id_pasaje   INT PRIMARY KEY,
    id_reserva  INT NOT NULL,
    id_pasajero INT NOT NULL,
    id_vuelo    INT NOT NULL,
    clase       VARCHAR(15) NOT NULL CHECK (clase IN ('Economica', 'Nexo Plus')),
    asiento     VARCHAR(4) NOT NULL,
    tarifa      DECIMAL(10,2) NOT NULL CHECK (tarifa > 0),
    estado      VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_reserva) REFERENCES RESERVA(id_reserva),
    FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero),
    FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo)
);

CREATE TABLE ENVIO_CARGA (
    id_envio   INT PRIMARY KEY,
    id_vuelo   INT NOT NULL,
    id_cliente INT NOT NULL,
    peso_kg    DECIMAL(10,2) NOT NULL CHECK (peso_kg > 0),
    tipo_carga VARCHAR(25) NOT NULL,
    estado     VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE_CORPORATIVO(id_cliente)
);

CREATE TABLE CUENTA_NEXO_PUNTOS (
    id_cuenta    INT PRIMARY KEY,
    id_pasajero  INT NOT NULL UNIQUE,
    nivel        VARCHAR(15) NOT NULL,
    saldo_millas INT NOT NULL CHECK (saldo_millas >= 0),
    fecha_alta   DATE NOT NULL,
    FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero)
);

CREATE TABLE MOVIMIENTO_PUNTOS (
    id_movimiento INT PRIMARY KEY,
    id_cuenta     INT NOT NULL,
    id_pasaje     INT NULL,
    tipo          VARCHAR(20) NOT NULL,
    millas        INT NOT NULL CHECK (millas > 0),
    fecha         DATE NOT NULL,
    FOREIGN KEY (id_cuenta) REFERENCES CUENTA_NEXO_PUNTOS(id_cuenta),
    FOREIGN KEY (id_pasaje) REFERENCES PASAJE(id_pasaje)
);

CREATE TABLE CAUSA_DEMORA (
    codigo_causa VARCHAR(10) PRIMARY KEY,
    descripcion  VARCHAR(150) NOT NULL,
    categoria    VARCHAR(30) NOT NULL
);

CREATE TABLE EVENTO_DEMORA (
    id_evento     INT PRIMARY KEY,
    id_vuelo      INT NOT NULL,
    codigo_causa  VARCHAR(10) NOT NULL,
    minutos       INT NOT NULL CHECK (minutos > 0),
    es_propagada  BIT NOT NULL,
    registrado_en DATETIME NOT NULL,
    FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo),
    FOREIGN KEY (codigo_causa) REFERENCES CAUSA_DEMORA(codigo_causa)
);

CREATE TABLE OBSERVACION_METEO (
    id_observacion   INT PRIMARY KEY,
    id_aeropuerto    INT NOT NULL,
    fecha_hora       DATETIME NOT NULL,
    visibilidad_m    INT NOT NULL,
    viento_kt        INT NOT NULL,
    precipitacion_mm DECIMAL(6,2) NOT NULL,
    fenomeno         VARCHAR(40) NOT NULL,
    fuente           VARCHAR(25) NOT NULL,
    FOREIGN KEY (id_aeropuerto) REFERENCES AEROPUERTO(id_aeropuerto)
);

CREATE TABLE PREDICCION_DEMORA (
    id_prediccion     INT PRIMARY KEY,
    id_vuelo          INT NOT NULL,
    calculada_en      DATETIME NOT NULL,
    prob_demora       DECIMAL(4,2) NOT NULL CHECK (prob_demora >= 0 AND prob_demora <= 1),
    minutos_estimados INT NOT NULL CHECK (minutos_estimados >= 0),
    version_modelo    VARCHAR(25) NOT NULL,
    FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo)
);

CREATE TABLE NOTIFICACION (
    id_notificacion INT PRIMARY KEY,
    id_prediccion   INT NOT NULL,
    id_pasajero     INT NOT NULL,
    canal           VARCHAR(15) NOT NULL,
    enviada_en      DATETIME NOT NULL,
    estado          VARCHAR(15) NOT NULL,
    FOREIGN KEY (id_prediccion) REFERENCES PREDICCION_DEMORA(id_prediccion),
    FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero)
);

CREATE TABLE CONFIGURACION_PREDICCION (
    id_config                 INT PRIMARY KEY,
    umbral_demora_severa_min  INT NOT NULL,
    umbral_demora_leve_min    INT NOT NULL,
    umbral_visibilidad_baja_m INT NOT NULL,
    umbral_visibilidad_med_m  INT NOT NULL,
    umbral_viento_fuerte_kt   INT NOT NULL,
    umbral_viento_med_kt      INT NOT NULL,
    umbral_precipitacion_mm   DECIMAL(6,2) NOT NULL,
    umbral_prob_alta          DECIMAL(4,2) NOT NULL,
    umbral_prob_media         DECIMAL(4,2) NOT NULL,
    factor_descuento_corp     DECIMAL(4,2) NOT NULL,
    factor_millas_km          DECIMAL(4,2) NOT NULL,
    txt_estado_demorado       VARCHAR(60) NOT NULL,
    txt_estado_en_horario     VARCHAR(60) NOT NULL,
    txt_estado_reprogramado   VARCHAR(60) NOT NULL,
    txt_estado_programado     VARCHAR(60) NOT NULL,
    txt_estado_cancelado      VARCHAR(60) NOT NULL,
    txt_demora_original       VARCHAR(60) NOT NULL,
    txt_demora_domino         VARCHAR(60) NOT NULL,
    txt_ruta_frecuente        VARCHAR(60) NOT NULL,
    txt_ruta_moderada         VARCHAR(60) NOT NULL,
    txt_ruta_puntual          VARCHAR(60) NOT NULL,
    txt_clima_severo          VARCHAR(80) NOT NULL,
    txt_clima_moderado        VARCHAR(80) NOT NULL,
    txt_clima_favorable       VARCHAR(80) NOT NULL,
    txt_recom_postergar       VARCHAR(100) NOT NULL,
    txt_recom_atencion        VARCHAR(100) NOT NULL,
    txt_recom_puntual         VARCHAR(100) NOT NULL,
    activa                    BIT NOT NULL
);
GO
