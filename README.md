---
title: "README"
author: "Kevin Tapia-Rodriguez"
date: "2025-10-17"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Análisis de Salinidad Oceánica

## Descripción

Script en R para análisis de datos de salinidad oceánica a partir de archivos NetCDF. Incluye series temporales, mapas espaciales y cálculo de anomalías.

## Características

-   Análisis de series temporales
-   Visualización espacial
-   Cálculo de anomalías
-   Informes automáticos en HTML/PDF

## Requisitos

Paquetes necesarios:

-   satin
-   lubridate
-   terra
-   ggplot2
-   kableExtra
-   devtools::install_github("hvillalo/satin")
