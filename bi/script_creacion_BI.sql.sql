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
GO

--------------------------------------
------------- FUNCTIONS --------------
--------------------------------------


--------------------------------------
----------- BI_Incidente -------------
--------------------------------------

CREATE TABLE GROUPBY4.BI_Incidente
(
	anio CHAR(4) NOT NULL,
	cuarimestre CHAR(4) NOT NULL,
	auto INT NOT NULL, --(FK)
	escuderia INT NOT NULL, --(FK)
	circuito INT NOT NULL, --  (FK)
	incidente INT NOT NULL, -- (FK)
	tipo_sector INT NOT NULL, -- (FK)
	PRIMARY KEY(auto, circuito, incidente, tipo_sector)
)
GO

INSERT INTO GROUPBY4.BI_Incidente
SELECT
	YEAR(c.carr_fecha),
	DATEPART(q, c.carr_fecha), --cambiar por dimension tiempo
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



--------------------------------------
------------- BI_Parada --------------
--------------------------------------

CREATE TABLE GROUPBY4.BI_Parada
(
	anio CHAR(4) NOT NULL,
	cuatrimestre CHAR(4) NOT NULL,
	auto INT NOT NULL, -- (FK)
	escuderia INT NOT NULL, --  (FK)
	circuito INT NOT NULL, --  (FK)
	parada INT NOT NULL, -- (FK)
	tiempo_parada INT NOT NULL
	PRIMARY KEY(anio, cuatrimestre, auto, escuderia, circuito, parada)
)

INSERT INTO GROUPBY4.BI_Parada
SELECT 
	YEAR(c.carr_fecha),
	DATEPART(Q, c.carr_fecha), --cambiar por dimension tiempo
	a.auto_codigo,
	a.auto_escuderia,
	c.carr_circuito,
	p.para_codigo,
	p.para_tiempo
FROM GROUPBY4.Parada p
JOIN GROUPBY4.Carrera c ON p.para_carrera = c.carr_codigo
JOIN GROUPBY4.Auto a ON p.para_auto = a.auto_codigo 

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

CREATE VIEW GROUPBY4.Circuitos_Mas_Peligrosos AS
SELECT TOP 3
	i.anio [Año],
	i.circuito [Circuito],
	COUNT(i.incidente) [Cantidad de Incidentes]
FROM GROUPBY4.BI_Incidente i
GROUP BY i.anio, i.circuito
ORDER BY COUNT(i.incidente) DESC
GO

CREATE VIEW GROUPBY4.Incidentes_Escuderia_Tipo_Sector AS
SELECT
	i.anio [Año],
	i.escuderia [Escuderia],
	i.tipo_sector [Tipo de Sector],
	COUNT(i.incidente) [Cantidad de Incidentes]
FROM GROUPBY4.BI_Incidente i
GROUP BY i.anio, i.escuderia, i.tipo_sector
GO



CREATE VIEW GROUPBY4.Tiempo_Promedio_En_Paradas AS
SELECT 
	p.cuatrimestre [Cuatrimestre],
	p.escuderia [Escuderia],
	AVG(p.tiempo_parada) [Tiempo Promedio En Paradas]
FROM GROUPBY4.BI_Parada p
GROUP BY p.cuatrimestre, p.escuderia
GO

CREATE VIEW GROUPBY4.Cant_Paradas_Circuito_Escuderia AS
SELECT 
	p.anio [Año], 
	p.circuito [Circuito],
	p.escuderia [Escuderia],
	COUNT(p.parada) [Cantidad de Paradas]
FROM GROUPBY4.BI_Parada p
GROUP BY p.anio, p.circuito, p.escuderia
GO

CREATE VIEW GROUPBY4.Circuitos_Mayor_Tiempo_Boxes AS
SELECT TOP 3
	p.circuito [Circuito],
	SUM(p.tiempo_parada) [Tiempo En Parada]
FROM GROUPBY4.BI_Parada p
GROUP BY p.circuito
ORDER BY SUM(P.tiempo_parada) DESC
GO


--------------------------------------
--------------- DROPS ----------------
--------------------------------------


DROP VIEW GROUPBY4.Circuitos_Mas_Peligrosos
DROP VIEW GROUPBY4.Incidentes_Escuderia_Tipo_Sector
DROP VIEW GROUPBY4.Tiempo_Promedio_En_Paradas
DROP VIEW GROUPBY4.Cant_Paradas_Circuito_Escuderia
DROP VIEW GROUPBY4.Circuitos_Mayor_Tiempo_Boxes