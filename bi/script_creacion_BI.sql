
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
IF OBJECT_ID('GROUPBY4.BI_Sector', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Sector;
IF OBJECT_ID('GROUPBY4.BI_Fact_desgaste', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Fact_desgaste;
IF OBJECT_ID('GROUPBY4.BI_Auto', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Auto;
IF OBJECT_ID('GROUPBY4.BI_Vuelta', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Vuelta;
IF OBJECT_ID('GROUPBY4.BI_Componente', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Componente;
IF OBJECT_ID('GROUPBY4.BI_Circuito', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Circuito;
IF OBJECT_ID('GROUPBY4.BI_Fact_Incidente', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Fact_Incidente;
IF OBJECT_ID('GROUPBY4.BI_Fact_Parada', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Fact_Parada;
IF OBJECT_ID('GROUPBY4.BI_Telemetria', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Telemetria;
IF OBJECT_ID('GROUPBY4.BI_Carrera', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Carrera;
IF OBJECT_ID('GROUPBY4.BI_Fact_Vuelta', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Fact_Vuelta;
IF OBJECT_ID('GROUPBY4.BI_Involucrados_Incidente', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Involucrados_Incidente;
IF OBJECT_ID('GROUPBY4.hEchos_telemetria', 'U') IS NOT NULL DROP TABLE GROUPBY4.BI_Fact_Performance;

IF OBJECT_ID('GROUPBY4.Circuitos_Mas_Peligrosos', 'V') IS NOT NULL DROP VIEW GROUPBY4.Circuitos_Mas_Peligrosos;
IF OBJECT_ID('GROUPBY4.Incidentes_Escuderia_Tipo_Sector', 'V') IS NOT NULL DROP VIEW GROUPBY4.Incidentes_Escuderia_Tipo_Sector;
IF OBJECT_ID('GROUPBY4.Tiempo_Promedio_En_Paradas', 'V') IS NOT NULL DROP VIEW GROUPBY4.Tiempo_Promedio_En_Paradas;
IF OBJECT_ID('GROUPBY4.Cant_Paradas_Circuito_Escuderia', 'V') IS NOT NULL DROP VIEW GROUPBY4.Cant_Paradas_Circuito_Escuderia;
IF OBJECT_ID('GROUPBY4.Circuitos_Mayor_Tiempo_Boxes', 'V') IS NOT NULL DROP VIEW GROUPBY4.Circuitos_Mayor_Tiempo_Boxes;
IF OBJECT_ID('GROUPBY4.Circuitos_mayor_combustible', 'V') IS NOT NULL DROP VIEW GROUPBY4.Circuitos_mayor_combustible;
IF OBJECT_ID('GROUPBY4.Desgaste', 'V') IS NOT NULL DROP VIEW GROUPBY4.Desgaste;
IF OBJECT_ID('GROUPBY4.Mayor_velocidad_por_sector ', 'V') IS NOT NULL DROP VIEW GROUPBY4.Mayor_velocidad_por_sector ;
IF OBJECT_ID('GROUPBY4.Mejor_tiempo_vuelta ', 'V') IS NOT NULL DROP VIEW GROUPBY4.Mejor_tiempo_vuelta ;


--------------------------------------
------------ DINMENSIONS -------------
--------------------------------------

CREATE TABLE GROUPBY4.BI_Escuderia 
( 
	BI_Escuderia_codigo int IDENTITY(1,1) PRIMARY KEY,
	escu_codigo int,
	escu_nombre nvarchar(255)
)

CREATE TABLE GROUPBY4.BI_Sector
( 
	BI_sector_codigo int PRIMARY KEY,
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

CREATE TABLE GROUPBY4.BI_Carrera
( 
	carr_codigo INT PRIMARY KEY,
	carr_fecha DATE NOT NULL,
	carr_circuito INT NOT NULL -- (fk)
)

INSERT INTO GROUPBY4.BI_Carrera
SELECT 
	carr_codigo,
	carr_fecha,
	carr_circuito
FROM GROUPBY4.Carrera

INSERT INTO GROUPBY4.BI_Tiempo
SELECT
	YEAR(c.carr_fecha),
	DATEPART(Q, c.carr_fecha),
	DATEPART(M, c.carr_fecha),
	DATEPART(W, c.carr_fecha),
	DATEPART(D, c.carr_fecha)
FROM GROUPBY4.Carrera c
GROUP BY c.carr_fecha


CREATE TABLE GROUPBY4.BI_Auto( --dimension auto
	BI_Auto_codigo int IDENTITY(1,1) PRIMARY KEY,
	auto_codigo int,
	auto_escuderia int
)

CREATE TABLE GROUPBY4.BI_Vuelta ( --dimension vuelta
	BI_Vuelta_codigo int IDENTITY(1,1) PRIMARY KEY,
	vuelta_numero decimal(18,0),
	vuelta_circuito int
)

CREATE TABLE GROUPBY4.BI_Componente ( --dimension componente
	BI_Componente_codigo int IDENTITY(1,1) PRIMARY KEY,
	componente_tipo nvarchar(255)
)

CREATE TABLE GROUPBY4.BI_Circuito( --dimension circuito
	BI_Circuito_codigo int IDENTITY(1,1) PRIMARY KEY,
	circ_codigo int,
	circ_nombre nvarchar(255)
)

CREATE TABLE GROUPBY4.BI_Telemetria 
(
	tele_codigo INT PRIMARY KEY,
	tele_auto INT NOT NULL, --(fk)
	tele_carrera INT NOT NULL,--(fk)
	tele_sector INT NOT NULL,--(fk)
	tele_numero_vuelta DECIMAL(18, 0) NOT NULL,
	tele_distancia_vuelta DECIMAL(18, 2) NOT NULL,
	tele_distancia_carrera DECIMAL(18, 6) NOT NULL,
	tele_posicion  DECIMAL(18, 0) NOT NULL,
	tele_tiempo_vuelta  DECIMAL(18, 10) NOT NULL ,
	tele_velocidad DECIMAL(18, 2) NOT NULL,
	tele_combustible DECIMAL(18, 2) NOT NULL,
	tele_vuelta INT NOT NULL, --(fk)
)

INSERT INTO GROUPBY4.BI_Auto
SELECT DISTINCT auto_codigo, auto_escuderia FROM GROUPBY4.Auto

INSERT INTO GROUPBY4.BI_Vuelta -- Las distintas vueltas que tiene un circuito
SELECT DISTINCT tele_numero_vuelta, c.carr_circuito
FROM GROUPBY4.Telemetria t INNER JOIN GROUPBY4.Carrera c ON t.tele_carrera = c.carr_codigo
ORDER BY c.carr_circuito

INSERT INTO GROUPBY4.BI_Circuito
SELECT circ_codigo, circ_nombre FROM GROUPBY4.Circuito

INSERT INTO GROUPBY4.BI_Sector
SELECT 
	sect_codigo,
	sect_tipo,
	sect_tipo_nombre
FROM GROUPBY4.Sector
JOIN GROUPBY4.Sector_Tipo ON sect_tipo = sect_tipo_codigo

INSERT INTO GROUPBY4.BI_Telemetria
SELECT
	tele_codigo,
	tele_auto, 
	tele_carrera,
	tele_sector, 
	tele_numero_vuelta,
	tele_distancia_vuelta,
	tele_distancia_carrera,
	tele_posicion,
	tele_tiempo_vuelta,
	tele_velocidad,
	tele_combustible,
	BI_Vuelta_codigo
FROM GROUPBY4.Telemetria
JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
JOIN GROUPBY4.BI_Vuelta ON tele_numero_vuelta = vuelta_numero AND carr_circuito = vuelta_circuito


  --------------------------------------
  --------- TABLAS DE HECHOS -----------
  --------------------------------------

	-- Tabla de hechos de vuelta --
	---------------------------------

	CREATE TABLE GROUPBY4.BI_Fact_Vuelta
	(
		tiempo INT NOT NULL, -- (fk)
		auto INT NOT NULL, -- (fk)
		circuito INT NOT NULL, -- (FK)
		escuderia INT NOT NULL, --(FK)
		vuelta INT NOT NULL, --(FK)
		combustible_gastado DECIMAL(12,2),
		tiempo_vuela DECIMAL(12,2),
		velocidad_maxima DECIMAL(12,2),
		velocidad_maxima_frenada DECIMAL(12,2),
		velocidad_maxima_recta DECIMAL(12,2),
		velocidad_maxima_curva DECIMAL(12,2),
		desgaste_neu_izq_tra DECIMAL(12,2),
		desgaste_neu_der_tra DECIMAL(12,2),
		desgaste_neu_izq_del DECIMAL(12,2),
		desgaste_neu_der_del DECIMAL(12,2),
		desgaste_fre_izq_tra DECIMAL(12,2),
		desgaste_fre_der_tra DECIMAL(12,2),
		desgaste_fre_izq_del DECIMAL(12,2),
		desgaste_fre_der_del DECIMAL(12,2),
		desgaste_caja DECIMAL(12,2),
		desgaste_motor DECIMAL(12,2)			
	)
	
	INSERT INTO GROUPBY4.BI_Fact_Vuelta
	SELECT
		tbi.codigo,
		t.tele_auto,
		c.carr_circuito,
		a.auto_escuderia,
		t.tele_vuelta,
		(
			SELECT MAX(tele_combustible) - MIN(tele_combustible) FROM GROUPBY4.BI_Telemetria
			WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto
			GROUP BY tele_vuelta
		),
			CASE 
		WHEN (
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto
				GROUP BY t2.tele_vuelta
			) = 0 THEN NULL 
				ELSE
			(
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto
				GROUP BY t2.tele_vuelta
			)
		END,
		MAX(t.tele_velocidad),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto AND sect_tipo_codigo = 1 -- Sector frenada
			GROUP BY tele_vuelta
		),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto AND sect_tipo_codigo = 2 -- Sector recta
			GROUP BY tele_vuelta
		),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			WHERE tele_vuelta = t.tele_vuelta AND tele_auto = T.tele_auto AND sect_tipo_codigo = 3 -- Sector curva
			GROUP BY tele_vuelta
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND neum_tele_posicion = 'Trasero Izquierdo'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND neum_tele_posicion = 'Trasero Derecho'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND neum_tele_posicion = 'Delantero Izquierdo'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND neum_tele_posicion = 'Delantero Derecho'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND freno_tele_posicion = 'Trasero Izquierdo'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND freno_tele_posicion = 'Trasero Derecho'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND freno_tele_posicion = 'Delantero Izquierdo'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			AND freno_tele_posicion = 'Delantero Derecho'
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(caja_tele_desgaste) - MIN(caja_tele_desgaste)FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Caja_Tele ON tele_codigo = caja_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			GROUP BY tele_vuelta	
		),
		(
			SELECT MAX(motor_tele_potencia) - MIN(motor_tele_potencia) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Motor_Tele ON tele_codigo = motor_tele_codigo
			WHERE tele_auto = T.tele_auto AND t.tele_vuelta = tele_vuelta
			GROUP BY tele_vuelta		
		)	
		
	FROM GROUPBY4.BI_Telemetria t
	JOIN GROUPBY4.BI_Carrera c ON t.tele_carrera = c.carr_codigo
	JOIN GROUPBY4.BI_Auto a ON a.auto_codigo = t.tele_auto
	JOIN GROUPBY4.BI_Tiempo tbi	ON YEAR(c.carr_fecha) = tbi.anio AND DATEPART(Q, c.carr_fecha) = tbi.cuatrimestre AND DATEPART(D, c.carr_fecha) = tbi.dia
	GROUP BY t.tele_vuelta, tbi.codigo, t.tele_auto, c.carr_circuito, a.auto_escuderia
	ORDER BY 1, 2, 3, 4, 5
	GO

	-- Vistas de tabla de hechos de Incidentes
		
		CREATE VIEW GROUPBY4.Desgaste AS
		SELECT 
			v.auto [Auto],
			v.circuito [Circuito],
			v.vuelta [Vuelta],
			AVG(desgaste_caja) [Desgaste Caja],
			AVG(desgaste_motor) [Desgaste Motor],
			AVG(desgaste_fre_der_del) [Desgaste Freno der-del],
			AVG(desgaste_fre_der_tra) [Desgaste Freno dre-tra],
			AVG(desgaste_fre_izq_del) [Desgaste Freno izq-del],
			AVG(desgaste_fre_izq_tra) [Desgaste Freno izq-tra],
			AVG(desgaste_neu_der_del) [Desgaste der-del],
			AVG(desgaste_neu_der_tra) [Desgaste dre-tra],
			AVG(desgaste_neu_izq_del) [Desgaste izq-del],
			AVG(desgaste_neu_izq_tra) [Desgaste izq-tra]
		FROM GROUPBY4.BI_Fact_Vuelta v
		GROUP BY v.auto, v.circuito, v.vuelta
		GO

		CREATE VIEW GROUPBY4.Mejor_tiempo_vuelta AS
		SELECT 
			t.anio [Año],
			v.circuito [Circuito],
			v.escuderia [Escuderia],
			MIN(tiempo_vuela) [Mejor Tiempo Vuelta]
		FROM GROUPBY4.BI_Fact_Vuelta v
		JOIN GROUPBY4.BI_Tiempo T ON t.codigo = v.tiempo
		GROUP BY t.anio, circuito, escuderia
		GO

		CREATE VIEW GROUPBY4.Circuitos_mayor_combustible AS
		SELECT TOP 3
			v.circuito [Circuito],
			SUM(combustible_gastado) [Combustible  Gastado]
		FROM GROUPBY4.BI_Fact_Vuelta v
		GROUP BY circuito
		ORDER BY SUM(combustible_gastado) DESC
		GO

		CREATE VIEW GROUPBY4.Mayor_velocidad_por_sector AS
		SELECT 
			v.circuito [Circuito],
			MAX(v.velocidad_maxima_recta) [Velocidad Maxima Rectas],
			MAX(v.velocidad_maxima_curva) [Velocidad Maxima Curvas],
			MAX(v.velocidad_maxima_frenada) [Velocidad Maxima Frenadas]
		FROM GROUPBY4.BI_Fact_Vuelta v
		GROUP BY circuito
		GO


	-- Tabla de hechos de incidente --
	----------------------------------

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
 

	-- Tabla de hechos de parada --
	-------------------------------

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
			COUNT(p.parada) [Cantidad de Paradas]
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
		GO


--------------------------------------
--------------- TESTS ----------------
--------------------------------------

-- SELECT * FROM GROUPBY4.Circuitos_Mas_Peligrosos
-- SELECT * FROM GROUPBY4.Incidentes_Escuderia_Tipo_Sector
-- SELECT * FROM GROUPBY4.Tiempo_Promedio_En_Paradas
-- SELECT * FROM GROUPBY4.Cant_Paradas_Circuito_Escuderia
-- SELECT * FROM GROUPBY4.Circuitos_Mayor_Tiempo_Boxes
-- SELECT * FROM GROUPBY4.Circuitos_mayor_combustible
-- SELECT * FROM GROUPBY4.Desgaste
-- SELECT * FROM GROUPBY4.Mayor_velocidad_por_sector 
-- SELECT * FROM GROUPBY4.Mejor_tiempo_vuelta 

