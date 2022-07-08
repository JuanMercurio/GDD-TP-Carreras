CREATE TABLE GROUPBY4.BI_Fact_Vuelta
	(
		tiempo SMALLDATETIME NOT NULL, -- (fk)
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
	
/*

	Esta solucione excede los 5 minutos, solucion sacar joins. Para eso 
	se agrega el campo tele_vuelta en BI_Telemetria. Es FK a la BI_Vuelta

	INSERT INTO GROUPBY4.BI_Fact_Vuelta
	SELECT
		tbi.codigo,
		t.tele_auto,
		c.carr_circuito,
		a.auto_escuderia,
		v.BI_Vuelta_codigo,
		AVG(t.tele_combustible),
			CASE 
		WHEN (
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
				JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
				WHERE BI_Vuelta_codigo = v.BI_Vuelta_codigo AND tele_auto = T.tele_auto
				GROUP BY t2.tele_numero_vuelta
			) = 0 THEN NULL 
				ELSE
			(
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
				JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
				WHERE BI_Vuelta_codigo = v.BI_Vuelta_codigo AND tele_auto = T.tele_auto
				GROUP BY t2.tele_numero_vuelta
			)
		END,
		MAX(t.tele_velocidad),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE BI_Vuelta_codigo = v.BI_Vuelta_codigo AND tele_auto = T.tele_auto AND sect_tipo_codigo = 1 -- Sector frenada
			GROUP BY BI_Vuelta_codigo
		),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE BI_Vuelta_codigo = v.BI_Vuelta_codigo AND tele_auto = T.tele_auto AND sect_tipo_codigo = 2 -- Sector recta
			GROUP BY BI_Vuelta_codigo
		),
		(	
			SELECT MAX(tele_velocidad) FROM GROUPBY4.Telemetria
			JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE BI_Vuelta_codigo = v.BI_Vuelta_codigo AND tele_auto = T.tele_auto AND sect_tipo_codigo = 3 -- Sector curva
			GROUP BY BI_Vuelta_codigo
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND neum_tele_posicion = 'Trasero Izquierdo'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND neum_tele_posicion = 'Trasero Derecho'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND neum_tele_posicion = 'Delantero Izquierdo'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND neum_tele_posicion = 'Delantero Derecho'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND freno_tele_posicion = 'Trasero Izquierdo'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND freno_tele_posicion = 'Trasero Derecho'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND freno_tele_posicion = 'Delantero Izquierdo'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			AND freno_tele_posicion = 'Delantero Derecho'
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT SUM(caja_tele_desgaste) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Caja_Tele ON tele_codigo = caja_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			GROUP BY BI_Vuelta_codigo	
		),
		(
			SELECT MAX(motor_tele_potencia) - MIN(motor_tele_potencia) FROM GROUPBY4.BI_Telemetria
			JOIN GROUPBY4.Motor_Tele ON tele_codigo = motor_tele_codigo
			JOIN GROUPBY4.BI_Carrera ON carr_codigo = tele_carrera
			JOIN GROUPBY4.BI_Vuelta ON  carr_circuito = vuelta_circuito AND vuelta_numero = tele_numero_vuelta
			WHERE tele_auto = T.tele_auto AND v.BI_Vuelta_codigo = BI_Vuelta_codigo
			GROUP BY BI_Vuelta_codigo	
		)
		
		
		
	FROM GROUPBY4.BI_Telemetria t
	JOIN GROUPBY4.BI_Carrera c ON t.tele_carrera = c.carr_codigo
	JOIN GROUPBY4.BI_Auto a ON a.auto_codigo = t.tele_auto
	JOIN GROUPBY4.BI_Vuelta v ON v.vuelta_circuito = c.carr_circuito AND v.vuelta_numero = t.tele_numero_vuelta 
	JOIN GROUPBY4.BI_Tiempo tbi	ON YEAR(c.carr_fecha) = tbi.anio AND DATEPART(Q, c.carr_fecha) = tbi.cuatrimestre AND DATEPART(D, c.carr_fecha) = tbi.dia
	GROUP BY BI_Vuelta_codigo, tbi.codigo, t.tele_auto, c.carr_circuito, a.auto_escuderia
	order by 1, 2, 3, 4, 5

*/

DROP TABLE GROUPBY4.BI_Telemetria

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
GO


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


-- insert en fact_Vuelta
	SELECT
		tbi.codigo,
		t.tele_auto,
		c.carr_circuito,
		a.auto_escuderia,
		t.tele_vuelta,
		AVG(t.tele_combustible),
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
			SELECT SUM(caja_tele_desgaste) FROM GROUPBY4.BI_Telemetria
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
	order by 1, 2, 3, 4, 5

	

		
			
		
