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

IF OBJECT_ID('GROUPBY4.Hechos_Telemetria', 'U') IS NOT NULL DROP TABLE GROUPBY4.Hechos_Telemetria;

CREATE TABLE GROUPBY4.Hechos_Telemetria 
(
	anio CHAR(4) NOT NULL, 
	cuatrimestre CHAR(4) NOT NULL,
	auto INT NOT NULL,
	circuito INT NOT NULL,
	escuderia INT NOT NULL,
	piloto INT NOT NULL,
	n_vuelta DECIMAL(12,0) NOT NULL,
	neumaticos_desgaste DECIMAL(12,8) NOT NULL,
	frenos_desgaste DECIMAL(12,8) NOT NULL,
	motor_desgaste DECIMAL(12,8) NOT NULL,
	caja_desgaste DECIMAL(12,8) NOT NULL,
	tiempo_vuelta DECIMAL(12, 8) NOT NULL,
	velocidad DECIMAL(12, 8) NOT NULL,
	combustible DECIMAL(12, 8) NOT NULL,
	telemetria INT, --no es necesaria
	sector INT NOT NULL, -- es mejor poner tipo sector?
	PRIMARY KEY(anio, cuatrimestre, auto, circuito, escuderia, piloto, sector, telemetria)
)
GO

CREATE FUNCTION GROUPBY4.cuatrimestre(@fecha SMALLDATETIME)
	RETURNS CHAR(4)
BEGIN
	DECLARE @cuatrimestre INT
	SET @cuatrimestre = 0

	IF (MONTH(@fecha) > 0)
		SET @cuatrimestre = @cuatrimestre + 1

	IF (MONTH(@fecha) > 3)
		SET @cuatrimestre = @cuatrimestre + 1

	IF (MONTH(@fecha) > 6)
		SET @cuatrimestre = @cuatrimestre + 1

	IF (MONTH(@fecha) > 9)
		SET @cuatrimestre = @cuatrimestre + 1
	
	RETURN @cuatrimestre
	
END
GO


CREATE FUNCTION GROUPBY4.promedio_desgaste_neumaticos_tele(@tele_codigo INT)
	RETURNS DECIMAL(12,8)
BEGIN

	DECLARE @desgaste DECIMAL(12,8)

	SELECT @desgaste = AVG(nt.neum_tele_profundidad) FROM GROUPBY4.Neumatico_Tele nt
	WHERE nt.neum_tele_codigo = @tele_codigo
	GROUP BY nt.neum_tele_codigo

	RETURN @desgaste
END
GO

CREATE FUNCTION GROUPBY4.promedio_desgaste_frenos_tele(@tele_codigo INT)
	RETURNS DECIMAL(12,8)
BEGIN

	DECLARE @desgaste DECIMAL(12,8)

	SELECT @desgaste = AVG(ft.freno_tele_pastilla) FROM GROUPBY4.Freno_Tele ft
	WHERE ft.freno_tele_codigo = @tele_codigo
	GROUP BY ft.freno_tele_codigo

	RETURN @desgaste
END
GO

CREATE FUNCTION GROUPBY4.desgaste_motor_tele(@tele_codigo INT)
	RETURNS DECIMAL(12,8)
BEGIN
	DECLARE @desgaste DECIMAL(12,8)

	SELECT @desgaste = mt.motor_tele_potencia FROM GROUPBY4.Motor_Tele mt
	WHERE mt.motor_tele_codigo = @tele_codigo

	RETURN @desgaste
END
GO 

CREATE FUNCTION GROUPBY4.desgaste_caja_tele(@tele_codigo INT)
	RETURNS DECIMAL(12,8)
BEGIN
	DECLARE @desgaste DECIMAL(12,8)

	SELECT @desgaste = ct.caja_tele_desgaste FROM GROUPBY4.Caja_Tele ct
	WHERE ct.caja_tele_codigo = @tele_codigo

	RETURN @desgaste
END
GO 


---------------------------------------------------------
--------------------- INSERTS ---------------------------
---------------------------------------------------------

INSERT INTO GROUPBY4.Hechos_Telemetria
SELECT
	YEAR(ca.carr_fecha),
	GROUPBY4.cuatrimestre(ca.carr_fecha),
	a.auto_codigo,
	ca.carr_circuito,
	a.auto_escuderia,
	a.auto_piloto,
	t.tele_numero_vuelta,
	GROUPBY4.promedio_desgaste_neumaticos_tele(t.tele_codigo),
	GROUPBY4.promedio_desgaste_frenos_tele(t.tele_codigo),
	GROUPBY4.desgaste_motor_tele(t.tele_codigo),
	GROUPBY4.desgaste_caja_tele(t.tele_codigo),
	t.tele_tiempo_vuelta,
	t.tele_velocidad,
	t.tele_combustible,
	t.tele_codigo,
	t.tele_sector --se podria poner directamente el tipo de sector 	
FROM GROUPBY4.Telemetria t 
JOIN GROUPBY4.Carrera ca ON t.tele_carrera = ca.carr_codigo
JOIN GROUPBY4.Auto a ON t.tele_auto = a.auto_codigo


ALTER TABLE GROUPBY4.Hechos_Telemetria
ADD FOREIGN KEY (auto) REFERENCES GROUPBY4.Auto
ALTER TABLE GROUPBY4.Hechos_Telemetria
ADD FOREIGN KEY (circuito) REFERENCES GROUPBY4.Circuito
ALTER TABLE GROUPBY4.Hechos_Telemetria
ADD FOREIGN KEY (Escuderia) REFERENCES GROUPBY4.Escuderia
ALTER TABLE GROUPBY4.Hechos_Telemetria
ADD FOREIGN KEY (Piloto) REFERENCES GROUPBY4.Piloto
ALTER TABLE GROUPBY4.Hechos_Telemetria
ADD FOREIGN KEY (Sector) REFERENCES GROUPBY4.Sector


DROP FUNCTION GROUPBY4.cuatrimestre
DROP FUNCTION GROUPBY4.desgaste_caja_tele
DROP FUNCTION GROUPBY4.desgaste_motor_tele
DROP FUNCTION GROUPBY4.promedio_desgaste_neumaticos_tele
DROP FUNCTION GROUPBY4.promedio_desgaste_frenos_tele
GO


