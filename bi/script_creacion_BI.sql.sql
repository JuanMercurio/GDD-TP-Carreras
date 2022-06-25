--------------------------------------
---------------- INIT ----------------
--------------------------------------

USE GD1C2022
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'GROUPBY4')
BEGIN 
	EXEC ('CREATE SCHEMA GROUPBY4')
END
GO

IF OBJECT_ID('GROUPBY4.BI_Incidente', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Incidente;
IF OBJECT_ID('GROUPBY4.BI_Parada', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Parada;
IF OBJECT_ID('GROUPBY4.BI_Tiempo', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Tiempo;
IF OBJECT_ID('GROUPBY4.BI_Escuderia', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Escuderia;
IF OBJECT_ID('GROUPBY4.BI_Performance', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Performance;
GO

--------------------------------------
------------ DINMENSIONS -------------
--------------------------------------



CREATE TABLE GROUPBY4.BI_Escuderia ( --dimension escuderia
	BI_Escuderia_codigo int IDENTITY(1,1) PRIMARY KEY,
	escu_codigo int,
	escu_nombre nvarchar(255)
)

CREATE TABLE GROUPBY4.BI_Sector( --dimension sector
	BI_sector_codigo int IDENTITY(1,1) PRIMARY KEY,
	sect_tipo_codigo int,
	sect_tipo_nombre nvarchar(255)
)


CREATE TABLE GROUPBY4.BI_Tiempo
(
	codigo INT IDENTITY PRIMARY KEY NOT NULL,
	anio INT,
	cuatrimestre INT,
	mes INT,
	semana INT,
	dia INT,
)

INSERT INTO GROUPBY4.BI_Tiempo
SELECT
	YEAR(c.carr_fecha),
	DATEPART(Q, c.carr_fecha),
	DATEPART(M, c.carr_fecha),
	DATEPART(W, c.carr_fecha),
	DATEPART(D, c.carr_fecha)
FROM GROUPBY4.Carrera c
GROUP BY c.carr_fecha


--------------------------------------
--------- TABLAS DE HECHOS -----------
--------------------------------------

-- Tabla de hecho
CREATE TABLE GROUPBY4.BI_Performance
(
	tiempo SMALLDATETIME NOT NULL,
	auto INT NOT NULL, --  (FK)
	circuito INT NOT NULL, -- (FK)
	escuderia INT NOT NULL, --(FK)
	n_vuelta INT NOT NULL, --(FK)
	instante DECIMAL(18,2),   -- verificar si es necesario  
	velocidad DECIMAL(18,2),
	combustible DECIMAL(18,2),
	combustible_por_telemetria DECIMAL(12,8),
	tiempo_vuelta DECIMAL(18,2),
	tipo_sector INT  -- (FK)
	-- PRIMARY KEY(tiempo, auto, circuito, escuderia, n_vuelta, tipo_sector) -- no funciona 
)

INSERT INTO GROUPBY4.BI_Performance
SELECT 
	c.carr_fecha,
	t.tele_auto,
	c.carr_circuito,
	a.auto_escuderia,
	t.tele_numero_vuelta,
	t.tele_tiempo_vuelta,
	t.tele_velocidad,
	t.tele_combustible,
	( -- checkear
		SELECT MAX(T2.tele_combustible) - MIN(t2.tele_combustible) / count(t2.tele_codigo) FROM GROUPBY4.Telemetria t2
		WHERE t2.tele_auto = t.tele_auto AND t2.tele_numero_vuelta = t.tele_numero_vuelta AND t.tele_carrera = t2.tele_carrera
		GROUP BY t2.tele_numero_vuelta
	),
	CASE 
		WHEN (
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.Telemetria t2
				WHERE t2.tele_auto = t.tele_auto AND t2.tele_numero_vuelta = t.tele_numero_vuelta AND t.tele_carrera = t2.tele_carrera
				GROUP BY t2.tele_numero_vuelta
			 ) = 0 THEN NULL 
			 ELSE
			 (
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.Telemetria t2
				WHERE t2.tele_auto = t.tele_auto AND t2.tele_numero_vuelta = t.tele_numero_vuelta AND t.tele_carrera = t2.tele_carrera
				GROUP BY t2.tele_numero_vuelta
			 )
	END,
	s.sect_codigo

FROM GROUPBY4.Telemetria t
JOIN GROUPBY4.Carrera c ON t.tele_carrera = c.carr_codigo
JOIN GROUPBY4.Auto a ON a.auto_codigo = t.tele_auto
JOIN GROUPBY4.Sector s ON t.tele_sector = s.sect_codigo



-- Tabla de hechos Incidente
CREATE TABLE GROUPBY4.BI_Incidente
(
	fecha INT NOT NULL,
	auto INT NOT NULL, --(FK)
	escuderia INT NOT NULL, --(FK)
	circuito INT NOT NULL, --  (FK)
	incidente INT NOT NULL, -- (FK)
	tipo_sector INT NOT NULL, -- (FK)
	PRIMARY KEY(fecha, auto, circuito, incidente, tipo_sector)
)
GO

INSERT INTO GROUPBY4.BI_Incidente
SELECT
	tbi.codigo,
	ii.invo_auto,
	a.auto_escuderia,
	c.carr_circuito,
	i.inci_codigo,
	s.sect_tipo
FROM GROUPBY4.Involucrados_Incidente ii
JOIN GROUPBY4.Incidente i ON ii.invo_incidente = i.inci_codigo
JOIN GROUPBY4.Carrera c ON i.inci_carrera = c.carr_codigo
JOIN GROUPBY4.Auto a ON ii.invo_auto = a.auto_codigo
JOIN GROUPBY4.Sector s on i.inci_sector = s.sect_codigo
JOIN GROUPBY4.BI_Tiempo tbi	ON YEAR(c.carr_fecha) = tbi.anio AND DATEPART(Q, c.carr_fecha) = tbi.cuatrimestre AND DATEPART(D, c.carr_fecha) = tbi.dia
GROUP BY a.auto_escuderia

ALTER TABLE GROUPBY4.BI_Incidente
ADD FOREIGN KEY (auto) REFERENCES GROUPBY4.Auto
ALTER TABLE GROUPBY4.BI_Incidente
ADD FOREIGN KEY (escuderia) REFERENCES GROUPBY4.Escuderia
ALTER TABLE GROUPBY4.BI_Incidente
ADD FOREIGN KEY (circuito) REFERENCES GROUPBY4.Circuito
ALTER TABLE GROUPBY4.BI_Incidente
ADD FOREIGN KEY (incidente) REFERENCES GROUPBY4.Incidente
ALTER TABLE GROUPBY4.BI_Incidente
ADD FOREIGN KEY (tipo_sector) REFERENCES GROUPBY4.Sector_Tipo

-- Tabla de HecHos Parada
CREATE TABLE GROUPBY4.BI_Parada
(
	fecha CHAR(4) NOT NULL,
	auto INT NOT NULL, -- (FK)
	escuderia INT NOT NULL, --  (FK)
	circuito INT NOT NULL, --  (FK)
	parada INT NOT NULL, -- (FK)
	tiempo_parada INT NOT NULL
	PRIMARY KEY(fecha, auto, escuderia, circuito, parada)
)

INSERT INTO GROUPBY4.BI_Parada
SELECT 
	tbi.codigo,
	a.auto_codigo,
	a.auto_escuderia,
	c.carr_circuito,
	p.para_codigo,
	p.para_tiempo
FROM GROUPBY4.Parada p
JOIN GROUPBY4.Carrera c ON p.para_carrera = c.carr_codigo
JOIN GROUPBY4.Auto a ON p.para_auto = a.auto_codigo 
JOIN GROUPBY4.BI_Tiempo tbi	ON YEAR(c.carr_fecha) = tbi.anio AND DATEPART(Q, c.carr_fecha) = tbi.cuatrimestre AND DATEPART(D, c.carr_fecha) = tbi.dia


ALTER TABLE GROUPBY4.BI_Parada
ADD FOREIGN KEY (auto) REFERENCES GROUPBY4.Auto
ALTER TABLE GROUPBY4.BI_Parada
ADD FOREIGN KEY (escuderia) REFERENCES GROUPBY4.Escuderia
ALTER TABLE GROUPBY4.BI_Parada
ADD FOREIGN KEY (circuito) REFERENCES GROUPBY4.Circuito
ALTER TABLE GROUPBY4.BI_Parada
ADD FOREIGN KEY (parada) REFERENCES GROUPBY4.Parada



--------------------------------------
--------------- VIEWS ----------------
--------------------------------------
GO

-- Vistas de tabla de hechos de Incidentes
CREATE VIEW GROUPBY4.Circuitos_Mas_Peligrosos AS
SELECT 
	t.anio [Año],
	i.circuito [Circuito],
	COUNT(DISTINCT i.incidente) [Cantidad de Incidentes]
FROM GROUPBY4.BI_Incidente i
JOIN GROUPBY4.BI_Tiempo t ON i.fecha = t.codigo
WHERE CONVERT(CHAR(4), t.anio) + CONVERT(CHAR(4), i.circuito) IN (
		SELECT TOP 3
			CONVERT(CHAR(4), T2.anio) + 
			CONVERT(CHAR(4), I2.circuito)	
		FROM GROUPBY4.BI_Incidente I2
		JOIN GROUPBY4.BI_Tiempo t2 ON I2.fecha = T2.codigo
		where t.anio = t2.anio 
		GROUP BY t2.anio, i2.circuito
		ORDER BY COUNT(DISTINCT i2.incidente)
	)
GROUP BY t.anio, i.circuito
ORDER BY COUNT(i.incidente) DESC
GO

CREATE VIEW GROUPBY4.Incidentes_Escuderia_Tipo_Sector AS
SELECT
	t.anio [Año],
	i.escuderia [Escuderia],
	i.tipo_sector [Tipo de Sector],
	COUNT(i.incidente) [Cantidad de Incidentes]
FROM GROUPBY4.BI_Incidente i
JOIN GROUPBY4.BI_Tiempo t ON t.codigo = i.fecha
GROUP BY t.anio, i.escuderia, i.tipo_sector
GO

-- Vistas de tabla de hechos de Paradas
CREATE VIEW GROUPBY4.Tiempo_Promedio_En_Paradas AS
SELECT 
	t.cuatrimestre [Cuatrimestre],
	p.escuderia [Escuderia],
	AVG(p.tiempo_parada) [Tiempo Promedio En Paradas]
FROM GROUPBY4.BI_Parada p
JOIN GROUPBY4.BI_Tiempo	t ON T.codigo = p.fecha
GROUP BY t.cuatrimestre, p.escuderia
GO

CREATE VIEW GROUPBY4.Cant_Paradas_Circuito_Escuderia AS
SELECT 
	t.anio [Año], 
	p.circuito [Circuito],
	p.escuderia [Escuderia],
	COUNT(p.parada) [Cantidad de Paradas] --distinct?
FROM GROUPBY4.BI_Parada p
JOIN GROUPBY4.BI_Tiempo	t ON T.codigo = p.fecha
GROUP BY t.anio, p.circuito, p.escuderia
GO

CREATE VIEW GROUPBY4.Circuitos_Mayor_Tiempo_Boxes AS
SELECT TOP 3
	p.circuito [Circuito],
	SUM(p.tiempo_parada) [Tiempo En Parada]
FROM GROUPBY4.BI_Parada p
GROUP BY p.circuito
ORDER BY SUM(P.tiempo_parada) DESC
GO

-- Vistas de tabla de hechos de performance
GO

CREATE VIEW GROUPBY4.Velocidad_Maxima_Sector AS
SELECT 
	p.auto [Auto],
	p.tipo_sector [Sector],
	p.circuito [Circuito],
	MAX(p.velocidad) [Velocidad Maxima]
FROM GROUPBY4.BI_Performance p
GROUP BY p.auto, p.circuito, p.tipo_sector
GO

CREATE VIEW GROUPBY4.Mejor_tiempo_por_circuito AS
SELECT 
	YEAR(p.tiempo) [Año],
	p.escuderia [Escuderia],
	p.circuito [Circuito],
	MIN(p.tiempo_vuelta) [Mejor Tiempo de Vuelta]
	
FROM GROUPBY4.BI_Performance p
GROUP BY YEAR(p.tiempo), p.escuderia, p.circuito
order by 1, 2, 3
GO

CREATE VIEW GROUPBY4.Circuitos_Mayor_Combustible AS
SELECT TOP 3 --checkear
	p.circuito,
	AVG(p.combustible_por_telemetria) [Combustible Promedio]
FROM GROUPBY4.BI_Performance p
GROUP BY p.circuito
GO

--------------------------------------
--------------- DROPS ----------------
--------------------------------------


DROP VIEW GROUPBY4.Circuitos_Mas_Peligrosos
DROP VIEW GROUPBY4.Incidentes_Escuderia_Tipo_Sector
DROP VIEW GROUPBY4.Tiempo_Promedio_En_Paradas
DROP VIEW GROUPBY4.Cant_Paradas_Circuito_Escuderia
DROP VIEW GROUPBY4.Circuitos_Mayor_Tiempo_Boxes



