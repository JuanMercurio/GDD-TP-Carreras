------------------------------------------- 24/06
------------------------------------------- creacion de tablas

CREATE TABLE GROUPBY4.BI_Auto( --dimension auto
BI_Auto_codigo int IDENTITY(1,1) PRIMARY KEY,
auto_codigo int,
auto_escuderia int
)

CREATE TABLE GROUPBY4.BI_Escuderia ( --dimension escuderia
BI_Escuderia_codigo int IDENTITY(1,1) PRIMARY KEY,
escu_codigo int,
escu_nombre nvarchar(255)
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

CREATE TABLE GROUPBY4.BI_Fact_desgaste( --Tabla de hechos de desgaste
desgaste_componente int,
desgaste_auto int,
desgaste_circuito int,
desgaste_vuelta int,
desgaste decimal(12,2)
PRIMARY KEY (desgaste_componente, desgaste_auto, desgaste_circuito, desgaste_vuelta)
)

------------------------------------------- insert en tablas

INSERT INTO GROUPBY4.BI_Componente values ('Neumaticos')
INSERT INTO GROUPBY4.BI_Componente values ('Motor')
INSERT INTO GROUPBY4.BI_Componente values ('Caja')
INSERT INTO GROUPBY4.BI_Componente values ('Frenos')

INSERT INTO GROUPBY4.BI_Auto
SELECT DISTINCT auto_codigo, auto_escuderia FROM GROUPBY4.Auto



INSERT INTO GROUPBY4.BI_Vuelta --Las distintas vueltas que tiene un circuito
SELECT DISTINCT tele_numero_vuelta, c.carr_circuito
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
ORDER BY c.carr_circuito

INSERT INTO GROUPBY4.BI_Circuito
SELECT circ_codigo, circ_nombre FROM GROUPBY4.Circuito


------------------------------------------- pruebas para desgaste
INSERT INTO GROUPBY4.BI_Fact_desgaste
SELECT 
BI_Componente_codigo,  
BI_Auto_codigo, 
BI_Circuito_codigo,
BI_Vuelta_codigo,
(SELECT 
avg(nt.neum_tele_profundidad)
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Neumatico_Tele nt
ON nt.neum_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MAX(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)-(SELECT 
avg(nt.neum_tele_profundidad)
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Neumatico_Tele nt
ON nt.neum_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MIN(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)
FROM GROUPBY4.BI_Auto, GROUPBY4.BI_Circuito
INNER JOIN GROUPBY4.BI_Componente ON componente_tipo = 'Neumaticos'
INNER JOIN GROUPBY4.BI_Vuelta ON vuelta_circuito = circ_codigo
order by BI_Componente_codigo, BI_Auto_codigo, BI_Circuito_codigo, BI_Vuelta_codigo

--DIFERENCIA ENTRE PASTILLA INICIAL Y PASTILLA FINAL SIEMPRE DA 0
INSERT INTO GROUPBY4.BI_Fact_desgaste
SELECT 
BI_Componente_codigo,  
BI_Auto_codigo, 
BI_Circuito_codigo,
BI_Vuelta_codigo,
(SELECT 
avg(ft.freno_tele_pastilla)
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Freno_Tele ft
ON ft.freno_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MAX(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)-
(SELECT 
avg(ft.freno_tele_pastilla)
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Freno_Tele ft
ON ft.freno_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT min(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)
FROM GROUPBY4.BI_Auto, GROUPBY4.BI_Circuito
INNER JOIN GROUPBY4.BI_Componente ON componente_tipo = 'Frenos'
INNER JOIN GROUPBY4.BI_Vuelta ON vuelta_circuito = circ_codigo
order by BI_Componente_codigo, BI_Auto_codigo, BI_Circuito_codigo, BI_Vuelta_codigo

--DESGASTE MOTOR
INSERT INTO GROUPBY4.BI_Fact_desgaste
SELECT 
BI_Componente_codigo,  
BI_Auto_codigo, 
BI_Circuito_codigo,
BI_Vuelta_codigo,
(SELECT 
motor_tele_potencia
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Motor_Tele mt
ON mt.motor_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY motor_tele_potencia, t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MAX(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)-
(
SELECT 
motor_tele_potencia
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Motor_Tele mt
ON mt.motor_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY motor_tele_potencia, t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MAX(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)
FROM GROUPBY4.BI_Auto, GROUPBY4.BI_Circuito
INNER JOIN GROUPBY4.BI_Componente ON componente_tipo = 'Motor'
INNER JOIN GROUPBY4.BI_Vuelta ON vuelta_circuito = circ_codigo
order by BI_Componente_codigo, BI_Auto_codigo, BI_Circuito_codigo, BI_Vuelta_codigo


--DESGASTE DE CAJA
INSERT INTO GROUPBY4.BI_Fact_desgaste
SELECT 
BI_Componente_codigo,  
BI_Auto_codigo, 
BI_Circuito_codigo,
BI_Vuelta_codigo,
(
SELECT
ct.caja_tele_desgaste
FROM GROUPBY4.Telemetria t
INNER JOIN GROUPBY4.Caja_Tele ct
ON ct.caja_tele_codigo = t.tele_codigo
INNER JOIN GROUPBY4.Carrera c
ON t.tele_carrera = c.carr_codigo
WHERE t.tele_numero_vuelta = vuelta_numero and c.carr_circuito = circ_codigo and t.tele_auto = auto_codigo
GROUP BY ct.caja_tele_desgaste, t.tele_tiempo_vuelta
HAVING t.tele_tiempo_vuelta = (SELECT MAX(tele_tiempo_vuelta) FROM GROUPBY4.Telemetria INNER JOIN GROUPBY4.Carrera c2 ON tele_carrera = c2.carr_codigo WHERE tele_numero_vuelta = vuelta_numero and tele_auto = auto_codigo and c2.carr_circuito = circ_codigo)
)
FROM GROUPBY4.BI_Auto, GROUPBY4.BI_Circuito
INNER JOIN GROUPBY4.BI_Componente ON componente_tipo = 'Caja'
INNER JOIN GROUPBY4.BI_Vuelta ON vuelta_circuito = circ_codigo
order by BI_Componente_codigo, BI_Auto_codigo, BI_Circuito_codigo, BI_Vuelta_codigo


CREATE VIEW GROUPBY4.Desgaste_promedio_componente AS
SELECT 
	componente_tipo,
	auto_codigo,
	circ_nombre,
	vuelta_numero,
	desgaste
FROM GROUPBY4.BI_Fact_desgaste
INNER JOIN GROUPBY4.BI_Componente
ON desgaste_componente = BI_Componente_codigo
INNER JOIN GROUPBY4.BI_Auto
ON desgaste_auto = auto_codigo
INNER JOIN GROUPBY4.BI_Circuito
ON desgaste_circuito = circ_codigo
INNER JOIN GROUPBY4.BI_Vuelta
ON desgaste_vuelta = BI_Vuelta_codigo
WHERE desgaste IS NOT NULL
GO

------------------------------------------- drop de tablas 
DROP TABLE GROUPBY4.BI_Componente
DROP TABLE GROUPBY4.BI_Vuelta
--DROP TABLE GROUPBY4.BI_Escuderia
DROP TABLE GROUPBY4.BI_Auto
DROP TABLE GROUPBY4.BI_Circuito

