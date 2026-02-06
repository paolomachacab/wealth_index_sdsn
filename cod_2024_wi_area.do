/****************************************************************************************
CENSO 2024 — DUMMIES PARA DHS WEALTH INDEX + PCA + QUINTILES
****************************************************************************************/

********************************************************************************
* CONFIGURACIÓN DE RUTAS
********************************************************************************
clear all
set more off
version 17.0

global path "C:\Users\Paolo\Desktop\censo_2024" 
global in   "$path"
global out  "$path\_out"
global code "$path\_code"
global tbl  "$path\_tbl"

cap mkdir "$out"
cap mkdir "$code"
cap mkdir "$tbl"

********************************************************************************
* IMPORTAR Y UNIR BASES
********************************************************************************

capture confirm file "$in\persona.dta"
if _rc==0 {
    use "$in\persona.dta", clear
    compress
    save "$out\persona_2024.dta", replace
}
else exit

capture confirm file "$in\vivienda.dta"
if _rc==0 {
    use "$in\vivienda.dta", clear
    compress
    save "$out\vivienda_2024.dta", replace
}
else exit

********************************************************************************
* UNIÓN PERSONA (m:1) VIVIENDA (1:1)
********************************************************************************
use "$out\personas.dta", clear
confirm variable i00

merge m:1 i00 using "$out\vivienda_2024.dta"
keep if _merge==3
drop _merge

********************************************************************************
* FILTRAR VIVIENDAS PARTICULARES
********************************************************************************

capture confirm variable v01_tipoviv
if _rc==0 keep if inrange(v01_tipoviv,1,6)

compress
save "$out\censo_2024_unido.dta", replace

********************************************************************************
* VARIABLES DEMOGRÁFICAS
********************************************************************************


********************************************************************************
* DUMMIES (ACTIVOS Y SERVICIOS)
********************************************************************************

* --- 1) PISO --- (OK)
cap drop piso_tierra_hog
gen piso_tierra_ind = .
replace piso_tierra_ind = 1 if v06_piso==1
replace piso_tierra_ind = 0 if !missing(v06_piso) & v06_piso!=1
bys i00: egen piso_tierra_hog = max(piso_tierra_ind)
drop piso_tierra_ind
label var piso_tierra_hog "Piso: Tierra"
tab piso_tierra_hog, m

cap drop piso_tablon_hog
gen piso_tablon_ind = .
replace piso_tablon_ind = 1 if v06_piso==2
replace piso_tablon_ind = 0 if !missing(v06_piso) & v06_piso!=2
bys i00: egen piso_tablon_hog = max(piso_tablon_ind)
drop piso_tablon_ind
label var piso_tablon_hog "Piso: Tablón madera"
tab piso_tablon_hog, m

cap drop piso_machi_parq_hog
gen piso_machi_parq_ind = .
replace piso_machi_parq_ind = 1 if v06_piso==3
replace piso_machi_parq_ind = 0 if !missing(v06_piso) & v06_piso!=3
bys i00: egen piso_machi_parq_hog = max(piso_machi_parq_ind)
drop piso_machi_parq_ind
label var piso_machi_parq_hog "Piso: Machimbre/Parquet"
tab piso_machi_parq_hog, m

cap drop piso_mos_cer_hog
gen piso_mos_cer_ind = .
replace piso_mos_cer_ind = 1 if inlist(v06_piso,4,6)
replace piso_mos_cer_ind = 0 if !missing(v06_piso) & !inlist(v06_piso,4,6)
bys i00: egen piso_mos_cer_hog = max(piso_mos_cer_ind)
drop piso_mos_cer_ind
label var piso_mos_cer_hog "Piso: Mosaico/Baldosa/Cerámica"
tab piso_mos_cer_hog, m

cap drop piso_cemento_hog
gen piso_cemento_ind = .
replace piso_cemento_ind = 1 if v06_piso==5
replace piso_cemento_ind = 0 if !missing(v06_piso) & v06_piso!=5
bys i00: egen piso_cemento_hog = max(piso_cemento_ind)
drop piso_cemento_ind
label var piso_cemento_hog "Piso: Cemento"
tab piso_cemento_hog, m

cap drop piso_ladrillo_hog
gen piso_ladrillo_ind = .
replace piso_ladrillo_ind = 1 if v06_piso==7
replace piso_ladrillo_ind = 0 if !missing(v06_piso) & v06_piso!=7
bys i00: egen piso_ladrillo_hog = max(piso_ladrillo_ind)
drop piso_ladrillo_ind
label var piso_ladrillo_hog "Piso: Ladrillo"
tab piso_ladrillo_hog, m


* --- 2) TECHO --- (OK)
* 1=Calamina, 2=Teja, 3=Losa, 4=Paja/Barro 
forvalues c=1/4 {
    cap drop techo`c'_hog
    gen techo`c'_ind = .
    replace techo`c'_ind = 1 if v05_techo==`c'
    replace techo`c'_ind = 0 if !missing(v05_techo) & v05_techo!=`c'
    bys i00: egen techo`c'_hog = max(techo`c'_ind)
    drop techo`c'_ind
    tab techo`c'_hog, m
}


* --- 3) PARED --- (OK)
* 1=Ladrillo, 2=Adobe, 3=Tabique, 4=Piedra, 5=Madera, 6=Caña 
forvalues c=1/6 {
    cap drop pared`c'_hog
    gen pared`c'_ind = .
    replace pared`c'_ind = 1 if v03_pared==`c'
    replace pared`c'_ind = 0 if !missing(v03_pared) & v03_pared!=`c'
    bys i00: egen pared`c'_hog = max(pared`c'_ind)
    drop pared`c'_ind
    tab pared`c'_hog, m
}


* --- 4) AGUA --- (OK)
foreach s in red pileta aguatero pozobomba pozosin rio {
    cap drop agua_`s'_hog
}

gen agua_red_ind = .
replace agua_red_ind = 1 if v07_aguapro==1
replace agua_red_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=1
bys i00: egen agua_red_hog = max(agua_red_ind)
drop agua_red_ind
label var agua_red_hog "Agua: Red"
tab agua_red_hog, m

gen agua_pileta_ind = .
replace agua_pileta_ind = 1 if v07_aguapro==2
replace agua_pileta_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=2
bys i00: egen agua_pileta_hog = max(agua_pileta_ind)
drop agua_pileta_ind
label var agua_pileta_hog "Agua: Pileta pública"
tab agua_pileta_hog, m

gen agua_aguatero_ind = .
replace agua_aguatero_ind = 1 if v07_aguapro==8
replace agua_aguatero_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=8
bys i00: egen agua_aguatero_hog = max(agua_aguatero_ind)
drop agua_aguatero_ind
label var agua_aguatero_hog "Agua: Aguatero"
tab agua_aguatero_hog, m

gen agua_pozobomba_ind = .
replace agua_pozobomba_ind = 1 if v07_aguapro==4
replace agua_pozobomba_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=4
bys i00: egen agua_pozobomba_hog = max(agua_pozobomba_ind)
drop agua_pozobomba_ind
label var agua_pozobomba_hog "Agua: Pozo con bomba"
tab agua_pozobomba_hog, m

gen agua_pozosin_ind = .
replace agua_pozosin_ind = 1 if v07_aguapro==5
replace agua_pozosin_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=5
bys i00: egen agua_pozosin_hog = max(agua_pozosin_ind)
drop agua_pozosin_ind
label var agua_pozosin_hog "Agua: Pozo sin bomba"
tab agua_pozosin_hog, m

gen agua_rio_ind = .
replace agua_rio_ind = 1 if v07_aguapro==7
replace agua_rio_ind = 0 if !missing(v07_aguapro) & v07_aguapro!=7
bys i00: egen agua_rio_hog = max(agua_rio_ind)
drop agua_rio_ind
label var agua_rio_hog "Agua: Río/acequia/vertiente"
tab agua_rio_hog, m

*******************
* 5) Desague desagregado en copartido o no compartido
*******************
cap drop desag_alcantarillado_hog_v desag_septica_hog_v desag_pozo_ciego_hog_v desag_superficie_hog_v

* Combinando las dos preguntas
gen baño_exclusivo = v15_servsan == 1 if !missing(v15_servsan)
gen baño_compartido = v15_servsan == 2 if !missing(v15_servsan)
gen sin_baño = v15_servsan == 3 if !missing(v15_servsan)

* Red de alcantarillado
cap drop red_exclusivo
gen red_exclusivo = v16_desague == 1 & baño_exclusivo==1
tab red_exclusivo,m

cap drop red_compartido
gen red_compartido = v16_desague == 1 & baño_compartido==1
tab red_compartido,m

* Cámara séptica
cap drop septica_exclusivo
gen septica_exclusivo = v16_desague == 2 & baño_exclusivo==1
tab septica_exclusivo,m

cap drop septica_compartido
gen septica_compartido = v16_desague == 2 & baño_compartido==1
tab septica_compartido,m

* Pozo ciego 
cap drop pozo_ciego_exclusivo
gen pozo_ciego_exclusivo = v16_desague == 3 & baño_exclusivo==1
tab pozo_ciego_exclusivo,m

cap drop  pozo_ciego_compartido
gen pozo_ciego_compartido = v16_desague == 3 & baño_compartido==1
tab pozo_ciego_compartido,m

* Superficie 
cap drop superficie_exclusivo
gen superficie_exclusivo = inlist(v16_desague,4,5) & baño_exclusivo==1
tab superficie_exclusivo,m

cap drop superficie_compartido
gen superficie_compartido = inlist(v16_desague,4,5) & baño_compartido==1
tab superficie_compartido,m
	// quite el baño ecológico


* --- 6) ELECTRICIDAD ---
* 1=Red, 2=Generador, 3=Solar 
foreach c in 1 2 3 {
    cap drop elec`c'_hog
    gen elec`c'_ind = .
    replace elec`c'_ind = 1 if v09_energia==`c'
    replace elec`c'_ind = 0 if !missing(v09_energia) & v09_energia!=`c'
    bys i00: egen elec`c'_hog = max(elec`c'_ind)
    drop elec`c'_ind
    tab elec`c'_hog, m
}


* --- 7) COMBUSTIBLE ---
cap drop comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog

gen comb_gas_ind = .
replace comb_gas_ind = 1 if inlist(v10_combus,1,2)
replace comb_gas_ind = 0 if !missing(v10_combus) & !inlist(v10_combus,1,2)
bys i00: egen comb_gas_hog = max(comb_gas_ind)
drop comb_gas_ind
label var comb_gas_hog "Combustible: gas"
tab comb_gas_hog, m

gen comb_elec_ind = .
replace comb_elec_ind = 1 if v10_combus==5
replace comb_elec_ind = 0 if !missing(v10_combus) & v10_combus!=5
bys i00: egen comb_elec_hog = max(comb_elec_ind)
drop comb_elec_ind
label var comb_elec_hog "Combustible: electricidad"
tab comb_elec_hog, m

gen comb_solar_ind = .
replace comb_solar_ind = 1 if v10_combus==6
replace comb_solar_ind = 0 if !missing(v10_combus) & v10_combus!=6
bys i00: egen comb_solar_hog = max(comb_solar_ind)
drop comb_solar_ind
label var comb_solar_hog "Combustible: solar"
tab comb_solar_hog, m

gen comb_lena_ind = .
replace comb_lena_ind = 1 if v10_combus==3
replace comb_lena_ind = 0 if !missing(v10_combus) & v10_combus!=3
bys i00: egen comb_lena_hog = max(comb_lena_ind)
drop comb_lena_ind
label var comb_lena_hog "Combustible: leña"
tab comb_lena_hog, m

gen comb_guano_ind = .
replace comb_guano_ind = 1 if v10_combus==4
replace comb_guano_ind = 0 if !missing(v10_combus) & v10_combus!=4
bys i00: egen comb_guano_hog = max(comb_guano_ind)
drop comb_guano_ind
label var comb_guano_hog "Combustible: guano/estiercol"
tab comb_guano_hog, m


* --- 8) BIENES ---
gen radio_ind = 0
replace radio_ind = 1 if v19a_radio==1
bys i00: egen radio_hog = max(radio_ind)
drop radio_ind
label var radio_hog "Tiene radio"
tab radio_hog, m

gen tv_ind = 0
replace tv_ind = 1 if v19b_tv==1
bys i00: egen tv_hog = max(tv_ind)
drop tv_ind
label var tv_hog "Tiene TV"
tab tv_hog, m

gen telef_ind = 0
replace telef_ind = 1 if (v19h_telfijo==1 | v19d_celular==1)
bys i00: egen telef_hog = max(telef_ind)
drop telef_ind
label var telef_hog "Tiene teléfono (fijo o celular)"
tab telef_hog, m

gen comput_ind = 0
replace comput_ind = 1 if v19c_compu==1
bys i00: egen comput_hog = max(comput_ind)
drop comput_ind
label var comput_hog "Tiene computadora"
tab comput_hog, m

gen bici_ind = 0
replace bici_ind = 1 if v18a_bici==1
bys i00: egen bici_hog = max(bici_ind)
drop bici_ind
label var bici_hog "Tiene bicicleta"
tab bici_hog, m

gen moto_ind = 0
replace moto_ind = 1 if v18b_moto==1
bys i00: egen moto_hog = max(moto_ind)
drop moto_ind
label var moto_hog "Tiene moto"
tab moto_hog, m

gen vehic_ind = 0
replace vehic_ind = 1 if v18c_auto==1
bys i00: egen vehic_hog = max(vehic_ind)
drop vehic_ind
label var vehic_hog "Tiene vehículo"
tab vehic_hog, m

gen carreta_ind = 0
replace carreta_ind = 1 if v18d_carreta==1
bys i00: egen carreta_hog = max(carreta_ind)
drop carreta_ind
label var carreta_hog "Tiene carreta"
tab carreta_hog, m

gen bote_ind = 0
replace bote_ind = 1 if v18e_bote==1
bys i00: egen bote_hog = max(bote_ind)
drop bote_ind
label var bote_hog "Tiene bote/canoa"
tab bote_hog, m

gen cocina_ind = 0
replace cocina_ind = 1 if v12_cocina==1
bys i00: egen cocina_hog = max(cocina_ind)
drop cocina_ind
label var cocina_hog "Tiene cuarto cocina"
tab cocina_hog, m


*===================================================================
* 9) Combinación de variables "Tipos de vivienda "con: Vivienda propia* 1 y 2
*====================================================================
cap drop prop_casa
gen prop_casa = 0
replace prop_casa = 1 if inlist(v17_tenencia,1,2) & inlist(v01_tipoviv,1,2)
tab prop_casa,m

cap drop prop_depto
gen prop_depto = 0
replace prop_depto = 1 if inlist(v17_tenencia,1,2) & v01_tipoviv == 2
tab prop_depto,m

cap drop prop_cuarto
gen prop_cuarto = 0
replace prop_cuarto = 1 if inlist(v17_tenencia,1,2) & v01_tipoviv == 3
tab prop_cuarto,m

cap drop prop_viv_improvisada
gen prop_viv_improvisada = 0
replace prop_viv_improvisada = 1 if inlist(v17_tenencia,1,2) & v01_tipoviv == 4
tab prop_viv_improvisada,m

cap drop prop_viv_local_no_viv
gen prop_viv_local_no_viv = 0
replace prop_viv_local_no_viv = 1 if inlist(v17_tenencia,1,2) & v01_tipoviv == 5
tab prop_viv_local_no_viv,m



* --- 10 Personas por dormitorio-
cap drop TOT_PERS pers_dorm_temp hacin_viv


* 1. Ajuste de dormitorios (Paso 1: si es 0, se pone 1 porque deben dormir en algún lado)
gen v14_adj = v14_dormit
replace v14_adj = 1 if v14_dormit == 0

* 2. Creación de la variable CONTINUA
gen pers_dorm = tot_pers / v14_adj
replace pers_dorm = 5 if pers_dorm > 5


* --- 12) AYUDA DOMÉSTICA ---
cap drop ayuda_dom_viv
gen ayuda_dom_ind = (p24_parentes==13) if !missing(p24_parentes)
bys i00: egen ayuda_dom_viv = max(ayuda_dom_ind)
drop ayuda_dom_ind
label define binlab 0 "No" 1 "Sí"
label values ayuda_dom_viv binlab
label var ayuda_dom_viv "Ayuda doméstica"
tab ayuda_dom_viv, m


*******************************************************************************
* NORMALIZACIÓN DE VARIABLES GEOGRÁFICAS 
*******************************************************************************
foreach v in imun idep iprov urbrur mun_res_cod i00 {
    capture confirm numeric variable `v'
    if _rc destring `v', replace ignore(" ")
}

save "$out\base_wealth_2024.dta", replace

********************************************************************************
* COLAPSAR A NIVEL HOGAR
********************************************************************************
preserve

collapse (max) piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog techo1_hog techo2_hog techo3_hog techo4_hog pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog baño_exclusivo baño_compartido sin_baño red_exclusivo red_compartido septica_exclusivo septica_compartido pozo_ciego_exclusivo pozo_ciego_compartido superficie_exclusivo superficie_compartido elec1_hog elec2_hog elec3_hog comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog carreta_hog bote_hog cocina_hog prop_casa prop_depto prop_cuarto prop_viv_improvisada prop_viv_local_no_viv pers_dorm ayuda_dom_viv internet codm idep iprov imun urbrur mun_res_cod, by(i00)

compress
save "$out\base_hogar_wealth_2024.dta", replace

********************************************************************************
* 1. DEFINICIÓN DE GLOBALES
********************************************************************************

global X_urb "pers_dorm internet comput_hog telef_hog tv_hog vehic_hog moto_hog bici_hog baño_compartido red_exclusivo red_compartido septica_exclusivo comb_gas_hog agua_red_hog piso_machi_parq piso_mos_cer_hog piso_tierra_hog techo3_hog pared1_hog prop_depto cocina_hog"

global X_rur "pers_dorm internet telef_hog radio_hog tv_hog vehic_hog moto_hog bici_hog carreta_hog sin_baño septica_exclusivo pozo_ciego_excl elec1_hog comb_gas_hog comb_lena_hog comb_solar_hog agua_red_hog  agua_rio_hog piso_mos_cer_hog piso_cemento_hog piso_tierra_hog techo1_hog techo4_hog pared1_hog pared2_hog pared5_hog prop_casa"

********************************************************************************
* 2. ESTIMACIÓN PCA POR ÁREA (Lógica de Rutstein para Países en Desarrollo)
********************************************************************************
* El PCA separado evita que el área rural parezca pobre solo por no tener servicios urbanos.

* PCA Urbano
pca $X_urb if urbrur == 1, corr
predict score_u if e(sample) & urbrur == 1, score

* PCA Rural
pca $X_rur if urbrur == 2, corr
predict score_r if e(sample) & urbrur == 2, score

* Unificación en Índice Compuesto Nacional
gen wi_composite = score_u
replace wi_composite = score_r if urbrur == 2

* Estandarización a Z-Score (Media 0, Desviación 1)
egen wi_z = std(wi_composite)
label var wi_z "Índice de Riqueza Nacional (Z-Score)"

********************************************************************************
* 3. CÁLCULO MUNICIPAL Y QUINTILES
********************************************************************************
* Promedio Municipal de Riqueza (Bienestar Agregado)
bysort codm: egen wi_municipal = mean(wi_z)
label var wi_municipal "Índice de Riqueza Promedio Municipal"

* Quintiles Nacionales (Por Hogar)
xtile q_hogar = wi_z, nq(5)
label define ql 1 "Q1 (Pobreza Extrema)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (Estatus Alto)"
label values q_hogar ql

********************************************************************************
* 4. VISUALIZACIÓN DE RESULTADOS
********************************************************************************

twoway (kdensity wi_z, lcolor(navy) lwidth(thick)) ///
       (kdensity wi_z if urbrur == 1, lcolor(blue) lpattern(dash)) ///
       (kdensity wi_z if urbrur == 2, lcolor(brown) lpattern(dash)), ///
     title("Distribución de Riqueza: Comparativa Urbano vs Rural", size(medium)) ///
     xtitle("Puntaje de Riqueza (z-score)") ///
     ytitle("Densidad") ///
     legend(order(1 "Nacional" 2 "Urbano" 3 "Rural") pos(6) row(1)) ///
     xline(0, lcolor(red) lwidth(vthin) lpattern(dot)) ///
     xlabel(-3(1)4, grid) ylabel(, grid) ///
     graphregion(color(white))
