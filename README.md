# The Wealth Index (SDSN 2026)

Este repositorio contiene los **datos de salida** y el **código reproducible (Stata)** para construir el **Índice de Riqueza estilo DHS (DHS-style Wealth Index)** usando los **Censos de Población y Vivienda de Bolivia (2012 y 2024)**.

La construcción sigue la lógica del **DHS Wealth Index**, que utiliza **Análisis de Componentes Principales (PCA)** sobre un conjunto de variables de activos y condiciones de vivienda para aproximar el **estatus económico** del hogar (no ingreso ni consumo). :contentReference[oaicite:0]{index=0}

### Contenido del Repositorio

* **Código reproducible:** Archivos .do de Stata para el procesamiento y cálculo del índice de riqueza.
* **Quintiles de riqueza:** Bases de datos con la estratificación socioeconómica resultante.
* **Datos municipales:** Resultados del índice agregados a nivel geográfico municipal.

---

## Requisitos de software

Este proyecto fue desarrollado y probado en **[Stata 17](https://www.stata.com/stata17/)**. Se recomienda utilizar esta versión o una superior para asegurar la compatibilidad de los scripts.

---

## Metodología

El índice se construye con PCA aplicado a variables de activos y características del hogar. El flujo general (estilo DHS) es:

1. Selección de variables que reflejen bienestar material (vivienda, servicios, activos, etc.).
2. Transformación a indicadores (principalmente dummies) y armonización para que **2012 y 2024** queden con **los mismos nombres finales** de variables.
3. Consolidación a nivel hogar usando el identificador del hogar/vivienda.
4. Tratamiento de faltantes (según el criterio definido en el documento titulado Steps to constructing the new DHS Wealth Index).
5. Análisis de Componentes Principales.
6. Uso del **primer componente** como puntaje de riqueza.
7. Estandarización del puntaje (z-score).
8. Clasificación en **quintiles** (o deciles/cuartiles).
9. Agregación a nivel municipal (promedios, proporciones por quintil, etc.). 

---

## Datos fuente

Los insumos utilizados en este análisis provienen exclusivamente del **Censo de Población y Vivienda 2012** y **Censo de Población y Vivienda 2024** de Bolivia.

Para acceder a los enlaces de descarga y documentación oficial, diríjase a la carpeta denominada `base-de-datos` dentro de este repositorio, donde encontrará la información al respecto.

---

## Variables utilizadas 

Las variables finales (ya construidas como dummies/indicadores a nivel hogar) se agrupan en:

### Calidad de vivienda
- Material de piso
- Material de pared
- Material de techo
- Personas por dormitorio

### Servicios básicos
- Fuente de agua
- Tipo de sanitario
- Tipo de desagüe
- Energía eléctrica
- Combustible para cocinar

### Bienes durables
- Radio, TV, teléfono, computadora
- Bicicleta, motocicleta, vehículo
- Cuarto exclusivo para cocinar
- Carreta/carretón
- Bote/canoa/balsa

### Tenencia y trabajo del hogar
- Tenencia/propiedad de la vivienda
- Presencia de ayuda doméstica

---

## Salidas (outputs)

El script produce (por año):

- `wealth_hogar_YYYY.dta`  
  Puntaje de riqueza a nivel hogar + clasificación (quintiles u otra)

- `wealth_municipio_YYYY.dta`  
  Resumen municipal del índice (promedios y distribución por grupos)

---

## Codebook (variables principales)

| Variable | Definición |
|---|---|
| `wealth_score` | Puntaje crudo del primer componente del PCA |
| `wealth_z` | Puntaje estandarizado (z-score) |
| `wealth_quintile` | Quintil (1=Más pobre, 5=Más rico) |
| `MUN` / `IMUN` | Código de municipio (según el año/base) |
| `hogares` | Número de hogares considerados |
| `mean_wealth` | Promedio municipal del puntaje de riqueza |
| `q1_share` | % de hogares del municipio en Q1 |
| `q5_share` | % de hogares del municipio en Q5 |

---

