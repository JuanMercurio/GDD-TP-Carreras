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
IF OBJECT_ID('GROUPBY4.BI_Performance', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Performance;
GO

--------------------------------------
------------- FUNCTIONS --------------
--------------------------------------

--------------------------------------
------------- BI_Performance --------------
--------------------------------------



CREATE TABLE GROUPBY4.BI_Tiempo
(
	fecha SMALLDATETIME PRIMARY KEY,
	anio INT,
	cuatrimestre INT,
	mes INT,
	semana INT,
	dia INT,
)

INSERT INTO GROUPBY4.BI_Tiempo
SELECT
	c.carr_fecha,
	YEAR(c.carr_fecha),
	DATEPART(Q, c.carr_fecha),
	DATEPART(M, c.carr_fecha),
	DATEPART(W, c.carr_fecha),
	DATEPART(D, c.carr_fecha)
FROM GROUPBY4.Carrera c
GROUP BY c.carr_fecha

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


GO
CREATE VIEW GROUPBY4.Mejor_tiempo_por_circuito AS
SELECT 
	YEAR(p.tiempo) [Año],
	p.escuderia [Escuderia],
	p.circuito [Circuito],
	MIN(p.tiempo_vuelta) [Mejor Tiempo de Vuelta]
	
FROM GROUPBY4.BI_Performance p
GROUP BY YEAR(p.tiempo), p.escuderia, p.circuito

GO
CREATE VIEW GROUPBY4.Circuitos_Mayor_Combustible AS
SELECT TOP 3 --checkear
	p.circuito,
	AVG(p.combustible_por_telemetria) [Combustible Promedio]
FROM GROUPBY4.BI_Performance p
GROUP BY p.circuito

GO
CREATE VIEW GROUPBY4.Velocidad_Maxima_Sector AS
SELECT 
	p.auto [Auto],
	p.tipo_sector [Sector],
	MAX(p.velocidad) [Velocidad Maxima]
FROM GROUPBY4.BI_Performance p
GROUP BY p.auto, p.tipo_sector
	










--------------------------------------
--------------- VIEWS ----------------
--------------------------------------

--------------------------------------
--------------- DROPS ----------------
--------------------------------------



