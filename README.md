<h1 align="center"> Telemetria </h1>
<p align="center">
<img src="https://user-images.githubusercontent.com/48862380/179887084-0306fa7c-c7b9-4901-a46f-540c35165692.png") width=50% height=50% >
</p>
<p align="center"> Trabajo Practico - Gestion de Datos - UTN FRBA 2022 1C  <p>

## Objetivos del Trabajo Práctico

- Promover la investigación de técnicas de base de datos.
- Aplicar la teoría vista en la asignatura en una aplicación concreta.
- Desarrollar y probar distintos algoritmos sobre datos reales.
- Fomentar la delegación y el trabajo en grupo.

### Descripción general

Mediante este trabajo práctico se intenta simular la implementación de un nuevo sistema. El mismo consiste en un software para la gestión de carreras de autos de Fórmula 1, donde se registra cierta información de las mismas, teniendo como principal función la recolección y centralización de información de telemetría generada por los sensores de los autos de las distintas escuderías.

La implementación de dicho sistema, requiere previamente realizar la migración de los datos que se tenían registrados hasta el momento. Para ello es necesario que se reformule el diseño de la base de datos actual y los procesos, de manera tal que cumplan con los nuevos requerimientos.

Además, se solicita la implementación de un segundo modelo, con sus
correspondientes procedimientos y vistas, que pueda ser utilizado para la obtención de indicadores de gestión, análisis de escenarios y proyección para la toma de decisiones (Business Intelligence).

*Ver enunciado completo [aca](https://drive.google.com/file/d/14okhmql67K0IYSROQHwo1CJTEW71LtO1/view "aca")*

## Como Correr

### Requisitos Previos

Tener disponible el motor SQL Server. 

Cargar la los datos ya registrados: 
1. Descomprimir el archivo [Database/gd_esquema.Maestra.Table.rar](https://github.com/JuanMercurio/utn-gdd-tp/blob/master/Database/gd_esquema.Maestra.Table.rar "Database/gd_esquema.Maestra.Table.rar") 
2. Ejecutar el archivo [Database/EjecutarScriptTablaMaestra.bat](https://github.com/JuanMercurio/utn-gdd-tp/blob/master/Database/EjecutarScriptTablaMaestra.bat "EjecutarScriptTablaMaestra.bat"). Si encuentra errores corregir el comando de este script

### Ejecucion de Scripts

Primer se debe crear el Modelo Operativo corriendo el script

	script_creacion_inical.sql

Luego podemos crear el Modelo BI corriendo

	script_creacion_inicial_BI.sql

Ya podemos hacer consultas libremente sobre el modelo OLPT y el OLAP

