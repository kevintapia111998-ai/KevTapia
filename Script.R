#Define zona de trabajo

#Paquetes necesarios
library(satin)
library(lubridate)
library(terra)

#RUTA
ruta_archivo <- file.choose()

#ZONA DE INTERÉS
coordenadas_interes <- data.frame(
  x = -80,   # Longitud
  y = 3      # Latitud
)

message("Leyendo archivo: ", basename(ruta_archivo))

# Leer el archivo NetCDF
datos_nc <- read.cmems(ruta_archivo)

# Inspección básica
message("\n=== INFORMACIÓN DEL ARCHIVO ===")
print(datos_nc)

message("\n=== METADATOS DETALLADOS ===")
cat("Título:", datos_nc@attribs$title, "\n")
cat("Nombre largo:", datos_nc@attribs$longname, "\n")
cat("Variable principal:", datos_nc@attribs$name, "\n")
cat("Unidades:", datos_nc@attribs$units, "\n")
cat("Rango temporal:", as.character(range(datos_nc@period$tmStart)), "\n")
cat("Profundidades disponibles:", datos_nc@depth, "\n")
cat("Dimensión espacial:", length(datos_nc@lon), "x", length(datos_nc@lat), "\n")
cat("Resolución temporal:", datos_nc@attribs$temporal, "\n")
cat("Resolución espacial:", datos_nc@attribs$spatial, "\n")

message("\n=== MAPA INICIAL ===")
plot(datos_nc)

message("\n=== EXTRACCIÓN EN PUNTOS ESPECÍFICOS ===")

# Extraer datos en las coordenadas especificadas
datos_puntos <- extractPts(datos_nc, points = coordenadas_interes)

# Mostrar estructura de los datos extraídos
message("Estructura de datos extraídos:")
print(dim(datos_puntos))
print(head(datos_puntos[, 1:10]))

message("\n=== PREPARANDO SERIE TEMPORAL ===")

# Función para formatear datos extraídos (simplificada)
formatear_serie_temporal <- function(datos_extraidos) {
  n_fechas <- length(datos_nc@period$tmStart)
  n_profundidades <- length(datos_nc@depth)
  
  # Tomar solo los datos de valores (columnas 7 en adelante)
  valores <- as.data.frame(t(datos_extraidos[, 7:ncol(datos_extraidos)]))
  
  # Crear data frame con fechas
  serie_temporal <- data.frame(
    fecha = datos_nc@period$tmStart,
    valor = valores[, 1]  # Primer punto extraído
  )
  
  return(serie_temporal)
}

# Aplicar la función
serie_s <- formatear_serie_temporal(datos_puntos)
head(serie_s)

message("\n=== ANÁLISIS TEMPORAL ===")

# Gráfico de serie temporal básica
plot(serie_s$fecha, serie_s$valor, type = "l", 
     main = "Serie Temporal - Punto de Interés",
     xlab = "Fecha", 
     ylab = paste(datos_nc@attribs$name, "(", datos_nc@attribs$units, ")"), 
     col = "blue", lwd = 1)

# Agregar información mensual
serie_s$mes <- month(serie_s$fecha)
serie_s$año <- year(serie_s$fecha)


message("\n=== RESUMENES MENSUALES ===")

# Promedios mensuales por año
resumen_mensual <- aggregate(serie_s$valor, 
                            by = list(mes = serie_s$mes, año = serie_s$año), 
                            mean)
print(resumen_mensual)

# Gráfico de promedios mensuales
meses_plot <- as.Date(paste(resumen_mensual$año, resumen_mensual$mes, "15", sep = "-"))
plot(meses_plot, resumen_mensual$x, type = "b", 
     xlab = "Fecha", 
     ylab = paste("Promedio Mensual", datos_nc@attribs$name, "(", datos_nc@attribs$units, ")"),
     main = "Promedios Mensuales", pch = 16, col = "red")

message("\n=== ANÁLISIS ESPACIAL ===")

# Calcular promedio anual
promedio_anual <- satinMean(datos_nc, by = "%Y") 
#%Y es para años y #m es para meses

message("Promedio anual calculado:")
print(promedio_anual)

# Visualizar promedios anuales
plot(promedio_anual, main = "Promedio Anual")
plot(promedio_anual, period = 1, by = "%Y") 
plot(promedio_anual, period = 4, by = "%Y")

# ANOMALÍAS (muy bueno, actualizar y explorar)

if (length(unique(year(datos_nc@period$tmStart))) >= 2) {
message("\n=== CÁLCULO DE ANOMALÍAS ===")
  
  promedio_climatologico <- satinMean(datos_nc, by = "%m")
  datos_mensuales <- satinMean(datos_nc, by = "%Y-%m")
  anomalias <- anomaly(datos_mensuales, promedio_climatologico)
  #%Y es para años y #m es para meses
  # Visualizar primera anomalía
  plot(anomalias, period = 1, main = "Anomalía - Primer Mes")
}

# RESULTADOS

# Guardar serie temporal (para analisis mensuales del IPIAP)
write.csv(serie_ts, "serie_temporal_extraida.csv", row.names = FALSE)
message("Serie temporal guardada como 'serie_temporal_extraida.csv'")

# RESUMEN FINAL

message("\n=== ANÁLISIS COMPLETADO ===")
message("Archivo procesado: ", basename(ruta_archivo))
message("Variable analizada: ", datos_nc@attribs$longname)
message("Punto analizado: Lon = ", coordenadas_interes$x, ", Lat = ", coordenadas_interes$y)
message("Rango temporal: ", as.character(range(datos_nc@period$tmStart)))

