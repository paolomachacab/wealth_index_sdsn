### Fuentes de Datos y Replicabilidad

El cálculo del índice se sustenta en los microdatos oficiales provenientes de los operativos censales del **Instituto Nacional de Estadística (INE)** de Bolivia. 

#### Descarga de Bases de Datos
Puede acceder a la documentación y descarga de datos originales en los siguientes enlaces:

* **[Censo de Población y Vivienda 2012](https://anda.ine.gob.bo/index.php/catalog/8)** (Microdatos y metadatos)
* **[Censo de Población y Vivienda 2024](https://anda.ine.gob.bo/index.php/catalog/132)** (Resultados y bases actualizadas)

---

### Instrucciones

Para asegurar la validez de los resultados y replicar el **Índice de Riqueza**, siga estos pasos:

1. **Preparación de Datos:** Descargue las bases originales y realice la conversión a formato `.dta` (Stata) o `.csv`.
2. **Criterio de Inclusión:** Note que para ambos periodos (2012 y 2024), la base de datos ha sido filtrada para incluir **únicamente viviendas particulares**. 
3. **Ejecución:** Descargue los archivos `.do` (Stata) de este repositorio y ejecútelos en el orden numérico indicado para procesar las variables y generar el componente principal (PCA).

