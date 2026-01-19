# The Wealth Index (SDSN 2026)

Este repositorio contiene los **datos de salida** y el **código reproducible (Stata)** para construir un **Índice de Riqueza estilo DHS (DHS-style Wealth Index)** usando los **Censos de Población y Vivienda de Bolivia (2012 y 2024)**.

La construcción sigue la lógica del **DHS Wealth Index**, que utiliza **Análisis de Componentes Principales (PCA)** sobre un conjunto de variables de activos y condiciones de vivienda para aproximar el **estatus económico** del hogar (no ingreso ni consumo). :contentReference[oaicite:0]{index=0}

El repositorio provee:
- Código reproducible (Stata)
- Quintiles (o deciles/cuartiles, si se desea)
- Agregación a nivel municipal

---

## Requisitos de software

Este proyecto fue escrito y probado en **Stata 17**. Se recomienda instalar Stata 17 (o una versión posterior compatible) antes de ejecutar los scripts. :contentReference[oaicite:1]{index=1}

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
9. Agregación a nivel municipal (promedios, proporciones por quintil, etc.). :contentReference[oaicite:2]{index=2}

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

