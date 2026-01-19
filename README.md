# The Wealth Index (SDSN 2026)

Este repositorio contiene los **datos de salida** y el **código reproducible (Stata)** para construir el **Índice de Riqueza estilo DHS usando los **Censos de Población y Vivienda de Bolivia (2012 y 2024)**.

La construcción sigue la lógica del **[DHS Wealth Index](https://dhsprogram.com/topics/wealth-index/Index.cfm)**, que utiliza **Análisis de Componentes Principales (PCA)** sobre un conjunto de variables de activos y condiciones de vivienda para aproximar el **estatus económico** del hogar (no ingreso ni consumo).

Esta metodología se basa en las directrices de Rutstein (2008, 2015), adaptadas a información censal.

El índice permite:
- Medir el nivel socioeconómico estructural de los hogares.
- Clasificar hogares en quintiles de riqueza.
- Agregar resultados a nivel municipal.


---

## Requisitos de software

Este proyecto fue desarrollado y probado en **[Stata 17](https://www.stata.com/stata17/)**. Se recomienda utilizar esta versión o una superior para asegurar la compatibilidad de los scripts.

---

## Metodología

El índice se construye mediante **Análisis de Componentes Principales (PCA)** aplicado a variables que capturan condiciones materiales y activos del hogar.

La secuencia metodológica es la siguiente:

1. Selección de activos y características de la vivienda.
2. Transformación de variables categóricas en dummies binarias o continuas.
3. Agregación de información individual a nivel hogar.
4. Imputación de valores perdidos .
5. Aplicación de Análisis de Componentes Principales (PCA).
6. Extracción del primer componente principal.
7. Estandarización del puntaje de riqueza (z-score).
8. Clasificación de hogares en quintiles de riqueza.
9. Agregación del índice a nivel municipal.

---

## Datos fuente

Los insumos provienen únicamente de los operativos oficiales publicados por el INE

* **[Censo de Población y Vivienda 2012](https://anda.ine.gob.bo/index.php/catalog/8)**
* **[Censo de Población y Vivienda 2024](https://anda.ine.gob.bo/index.php/catalog/132)**

> **NOTA:** Para garantizar la comparabilidad, la base de datos se filtró únicamente para **viviendas particulares** en ambos periodos.

---

## Variables utilizadas en el Índice de Riqueza

> **NOTA:** Las variables enumeradas a continuación son las seleccionadas preliminarmente para el modelo. **No representan la lista final**, ya que están sujetas a pruebas de varianza y consistencia estadística durante la fase de validación del PCA.

### Calidad de la vivienda
- Material del piso
- Material del techo
- Material de las paredes
- Hacinamiento (variable continua: personas por dormitorio)

### Servicios básicos
- Fuente de agua.
- Tipo de servicio sanitario y sistema de desagüe
- Fuente de electricidad
- Combustible para cocinar

### Bienes 
- Radio, Televisor, Teléfono, Computadora.
- Medios de transporte: Bicicleta, Motocicleta, Vehículo automotor, Carreta, Bote/Canoa.
- Equipamiento: Cocina exclusiva.

### Tenencia y condiciones del hogar
- Vivienda propia.
- Presencia de ayuda doméstica.

---

## Codebook (resumen)

### Variables de entrada (hogar)
*Nota: Estas variables se transforman en indicadores binarios (1=Posee, 0=No posee) o continuas antes del análisis.

| Variable | Descripción |
|--------|------------|
| piso_*_hog | Material del piso |
| techo*_hog | Material del techo |
| pared*_hog | Material de las paredes |
| agua_*_hog | Fuente de agua |
| sanit*_hog | Tipo de servicio sanitario |
| desag_*_hog | Tipo de desagüe |
| elec*_hog | Fuente de electricidad |
| comb_*_hog | Combustible para cocinar |
| radio_hog | Tiene radio |
| tv_hog | Tiene televisor |
| telef_hog | Tiene teléfono |
| comput_hog | Tiene computadora |
| bici_hog | Tiene bicicleta |
| moto_hog | Tiene motocicleta |
| vehic_hog | Tiene vehículo |
| cocina_hog | Cocina exclusiva |
| carreta_hog | Tiene carreta |
| bote_hog | Tiene bote |
| vivprop_hog | Vivienda propia |
| hacin_viv | Hacinamiento |
| ayuda_dom_viv | Ayuda doméstica |

### Variables de salida

| Variable | Descripción |
|--------|------------|
| wealth_score | Puntaje bruto del PCA (primer componente) |
| wealth_z | Puntaje estandarizado del índice de riqueza |
| q_wealth | Quintil de riqueza (1 = más pobre, 5 = más rico) |
| mun | Código de municipio |
| hogares | Número de hogares |
| mean_wealth | Promedio del índice de riqueza (municipal) |
| q1_share | Proporción de hogares en el quintil más pobre |
| q5_share | Proporción de hogares en el quintil más rico |


## Referencias

- **[Rutstein, S. O. (2008). The DHS wealth index: Approaches for rural and urban areas (DHS Working Paper No. 60). United States Agency for International Development.]([https://dhsprogram.com/publications/publication-cr15-comparative-reports.cfm](https://dhsprogram.com/pubs/pdf/wp60/wp60.pdf))**
- **[Rutstein, S. O. (2015). Steps to constructing the new DHS wealth index (DHS Methodological Report No. 9). ICF International.]([https://www.jstor.org/stable/3088292](https://dhsprogram.com/programming/wealth%20index/Steps_to_constructing_the_new_DHS_Wealth_Index.pdf))**



