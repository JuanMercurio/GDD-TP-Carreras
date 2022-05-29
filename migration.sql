--Migration

--País
INSERT INTO GROUPBY4.Pais
SELECT distinct(CIRCUITO_PAIS) 
FROM gd_esquema.Maestra

--select *from groupby4.pais
-- Circuito 
INSERT INTO GROUPBY4.Circuito
SELECT distinct(CIRCUITO_NOMBRE), p.pais_codigo FROM gd_esquema.Maestra
join GROUPBY4.Pais p on CIRCUITO_PAIS = p.pais_nombre

--select *from groupby4.Circuito
DELETE from gd_esquema.Maestra
select *from gd_esquema.Maestra
-- Carrera 

INSERT INTO GROUPBY4.Carrera
SELECT (CODIGO_CARRERA), CARRERA_FECHA, CARRERA_CLIMA, CARRERA_TOTAL_CARRERA, CARRERA_CANT_VUELTAS, p.circ_codigo 
FROM gd_esquema.Maestra
join GROUPBY4.Circuito p on CIRCUITO_NOMBRE = p.circ_nombre
GROUP BY CODIGO_CARRERA, CARRERA_FECHA, CARRERA_CLIMA, CARRERA_TOTAL_CARRERA, CARRERA_CANT_VUELTAS, p.circ_codigo

select *from groupby4.Carrera


--Cursores
--circuito
DECLARE @circ_nombre VARCHAR(255) 
DECLARE @circ_pais INT

DECLARE db_cursor_circuito CURSOR FOR 
SELECT  
	CIRCUITO_NOMBRE,
	CIRCUITO_PAIS
FROM gd_esquema.Maestra
GROUP BY 
	CIRCUITO_NOMBRE,
	CIRCUITO_PAIS

OPEN db_cursor_circuito

FETCH NEXT FROM db_cursor_circuito INTO  @circ_nombre, @circ_pais

WHILE @@FETCH_STATUS = 0  
BEGIN
	BEGIN
				BEGIN TRY
							INSERT INTO GROUPBY4.Circuito(circ_nombre, circ_pais)
							VALUES (@circ_nombre, @circ_pais);
					
				END TRY
				BEGIN CATCH 
					PRINT ERROR_MESSAGE()
				END CATCH
			
			FETCH NEXT FROM db_cursor_circuito INTO  @circ_nombre, @circ_pais
	END 
	
END 

CLOSE db_cursor_circuito 
DEALLOCATE db_cursor_circuito

SELECT  
	CIRCUITO_NOMBRE,
	CIRCUITO_PAIS
FROM gd_esquema.Maestra
GROUP BY 
	CIRCUITO_NOMBRE,
	CIRCUITO_PAIS

go
select * from groupby4.carrera

select CIRCUITO_CODIGO from gd_esquema.Maestra


-- Carrera 
DECLARE @carr_fecha DATE
DECLARE @carr_clima NVARCHAR(100)
DECLARE @carr_total_carrera DECIMAL(18, 2)
DECLARE @carr_cant_vuelta INT
DECLARE @carr_circuito INT

DECLARE db_cursor_carrera CURSOR FOR 
SELECT  
	CARRERA_FECHA,
	CARRERA_FECHA,
	CARRERA_TOTAL_CARRERA,
	CARRERA_CANT_VUELTAS,
	CIRCUITO_CODIGO
FROM gd_esquema.Maestra
GROUP BY CARRERA_FECHA,
	CARRERA_FECHA,
	CARRERA_TOTAL_CARRERA,
	CARRERA_CANT_VUELTAS,
	CIRCUITO_CODIGO;

OPEN db_cursor_carrera 
FETCH NEXT FROM db_cursor_carrera INTO @carr_fecha, @carr_clima, @carr_total_carrera, @carr_cant_vuelta, @carr_circuito

WHILE @@FETCH_STATUS = 0  
BEGIN
	BEGIN
				BEGIN TRY
							INSERT INTO GROUPBY4.Carrera(carr_fecha ,carr_clima, carr_total_carrera, carr_cant_vueltas, carr_circuito)
							VALUES (@carr_fecha, @carr_clima, @carr_total_carrera, @carr_cant_vuelta, @carr_circuito);
					
				END TRY
				BEGIN CATCH 
					PRINT ERROR_MESSAGE()
				END CATCH
			
			FETCH NEXT FROM db_cursor_carrera INTO @carr_fecha, @carr_clima, @carr_total_carrera, @carr_cant_vuelta, @carr_circuito
	END 
	
END 

CLOSE db_cursor_carrera  
DEALLOCATE db_cursor_carrera

go
select * from groupby4.carrera

select CIRCUITO_CODIGO from gd_esquema.Maestra


select *from gd_esquema.Maestra