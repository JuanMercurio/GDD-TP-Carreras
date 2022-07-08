/*
	Esto funciona, el problema es que no estariamos usando la tabla BI_Vuelta
*/

SELECT
	tbi.codigo,
	t.tele_auto,
	c.carr_circuito,
	a.auto_escuderia,
	tele_numero_vuelta,
	AVG(t.tele_combustible),
	CASE 
		WHEN (
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				WHERE t2.tele_auto = t.tele_auto AND t2.tele_numero_vuelta = t.tele_numero_vuelta AND t.tele_carrera = t2.tele_carrera
				GROUP BY t2.tele_numero_vuelta
			) = 0 THEN NULL 
				ELSE
			(
				SELECT MAX(t2.tele_tiempo_vuelta) FROM GROUPBY4.BI_Telemetria t2
				WHERE t2.tele_auto = t.tele_auto AND t2.tele_numero_vuelta = t.tele_numero_vuelta AND t.tele_carrera = t2.tele_carrera
				GROUP BY t2.tele_numero_vuelta
			)
	END,
	MAX(t.tele_velocidad),
	(	
		SELECT MAX(tele_velocidad) FROM GROUPBY4.Bi_Telemetria
		JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND sect_tipo_codigo = 1 -- Sector curva
		AND tele_numero_vuelta = t.tele_numero_vuelta
		GROUP BY tele_numero_vuelta
	),
	(	
		SELECT MAX(tele_velocidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND sect_tipo_codigo = 2 -- Sector curva
		AND tele_numero_vuelta = t.tele_numero_vuelta
		GROUP BY tele_numero_vuelta
	),
	(	
		SELECT MAX(tele_velocidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.BI_Sector ON tele_sector = BI_sector_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND sect_tipo_codigo = 3 -- Sector curva
		AND tele_numero_vuelta = t.tele_numero_vuelta
		GROUP BY tele_numero_vuelta
	),
	(
		SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND neum_tele_posicion = 'Trasero Izquierdo'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND neum_tele_posicion = 'Trasero Derecho'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND neum_tele_posicion = 'Delantero Izquierdo'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(neum_tele_profundidad) - MIN(neum_tele_profundidad) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Neumatico_Tele ON tele_codigo = neum_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND neum_tele_posicion = 'Delantero Derecho'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND freno_tele_posicion = 'Trasero Izquierdo'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND freno_tele_posicion = 'Trasero Derecho'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND freno_tele_posicion = 'Delantero Izquierdo'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(freno_tele_pastilla) - MIN(freno_tele_pastilla) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Freno_Tele ON tele_codigo = freno_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		AND freno_tele_posicion = 'Delantero Derecho'
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT SUM(caja_tele_desgaste) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Caja_Tele ON tele_codigo = caja_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		GROUP BY tele_numero_vuelta	
	),
	(
		SELECT MAX(motor_tele_potencia) - MIN(motor_tele_potencia) FROM GROUPBY4.BI_Telemetria
		JOIN GROUPBY4.Motor_Tele ON tele_codigo = motor_tele_codigo
		WHERE tele_carrera = t.tele_carrera AND tele_auto = T.tele_auto AND tele_numero_vuelta = T.tele_numero_vuelta
		GROUP BY tele_numero_vuelta	
	)
			
FROM GROUPBY4.BI_Telemetria t
JOIN GROUPBY4.BI_Carrera c ON t.tele_carrera = c.carr_codigo
JOIN GROUPBY4.BI_Auto a ON a.auto_codigo = t.tele_auto
JOIN GROUPBY4.BI_Tiempo tbi	ON YEAR(c.carr_fecha) = tbi.anio AND DATEPART(Q, c.carr_fecha) = tbi.cuatrimestre AND DATEPART(D, c.carr_fecha) = tbi.dia
GROUP BY t.tele_numero_vuelta, tbi.codigo, t.tele_auto, c.carr_circuito, a.auto_escuderia, tele_carrera --si no agrupas por carrera rompe por los where de las subqueries
order by 1,2,3,4,5
