/****************************************************************************************
CENSO 2012 — DUMMIES PARA DHS WEALTH INDEX + PCA + QUINTILES
****************************************************************************************/

********************************************************************************
* CONFIGURACIÓN DE RUTAS
********************************************************************************
clear all
set more off
version 17.0

global path "C:\Users\Paolo\Desktop\DHS_WI"
global in   "$path"
global out  "$path\_out"
global code "$path\_code"
global tbl  "$path\_tbl"

cap mkdir "$out"
cap mkdir "$code"
cap mkdir "$tbl"

********************************************************************************
* IMPORTAR BASES PRINCIPALES
********************************************************************************

capture confirm file "$in\persona.dta"
if _rc==0 {
    use "$in\persona.dta", clear
    compress
    save "$out\persona_2012.dta", replace
}
else exit

capture confirm file "$in\vivienda.dta"
if _rc==0 {
    use "$in\vivienda.dta", clear
    compress
    save "$out\vivienda_2012.dta", replace
}
else exit

********************************************************************************
* UNIÓN PERSONA (m:1) VIVIENDA (1:1)
********************************************************************************
use "$out\persona_2012.dta", clear
confirm variable I_BC_VIV

merge m:1 I_BC_VIV using "$out\vivienda_2012.dta"
keep if _merge==3
drop _merge

********************************************************************************
* FILTRAR VIVIENDAS PARTICULARES
********************************************************************************
capture confirm variable P01_TIPOVIV
if _rc==0 {
    keep if inrange(P01_TIPOVIV,1,5)
}

compress
save "$out\censo_2012_unido.dta", replace

********************************************************************************
* ========================
* DUMMIES DHS WEALTH INDEX
* ========================
********************************************************************************
*===================================================================
* Combinación de variables "Tipos de vivienda "con: Vivienda propia*
*====================================================================
cap drop prop_casa
gen prop_casa = 0
replace prop_casa = 1 if P19_TENENCIA == 1 & P01_TIPOVIV == 1
tab prop_casa,m

cap drop prop_depto
gen prop_depto = 0
replace prop_depto = 1 if P19_TENENCIA == 1 & P01_TIPOVIV == 2
tab prop_depto,m

cap drop prop_cuarto
gen prop_cuarto = 0
replace prop_cuarto = 1 if P19_TENENCIA == 1 & P01_TIPOVIV == 3
tab prop_cuarto,m

cap drop prop_viv_improvisada
gen prop_viv_improvisada = 0
replace prop_viv_improvisada = 1 if P19_TENENCIA == 1 & P01_TIPOVIV == 4
tab prop_viv_improvisada,m

cap drop prop_viv_local_no_viv
gen prop_viv_local_no_viv = 0
replace prop_viv_local_no_viv = 1 if P19_TENENCIA == 1 & P01_TIPOVIV == 5
tab prop_viv_local_no_viv,m


*========================================================
* 1) PISO: P06_PISOS (OK)
*========================================================

* Tierra (1)
cap drop piso_tierra_hog
gen piso_tierra_ind = .
replace piso_tierra_ind = 1 if P06_PISOS==1
replace piso_tierra_ind = 0 if !missing(P06_PISOS) & P06_PISOS!=1
bys I_BC_VIV: egen piso_tierra_hog = max(piso_tierra_ind)
drop piso_tierra_ind
label var piso_tierra_hog "Piso: Tierra (dummy)"
tab piso_tierra_hog, m

* Tablón (2)
cap drop piso_tablon_hog
gen piso_tablon_ind = .
replace piso_tablon_ind = 1 if P06_PISOS==2
replace piso_tablon_ind = 0 if !missing(P06_PISOS) & P06_PISOS!=2
bys I_BC_VIV: egen piso_tablon_hog = max(piso_tablon_ind)
drop piso_tablon_ind
label var piso_tablon_hog "Piso: Tablón de madera (dummy)"
tab piso_tablon_hog, m

* Machimbre/Parquet (3-4)
cap drop piso_machi_parq_hog
gen piso_machi_parq_ind = .
replace piso_machi_parq_ind = 1 if inlist(P06_PISOS,3,4)
replace piso_machi_parq_ind = 0 if !missing(P06_PISOS) & !inlist(P06_PISOS,3,4)
bys I_BC_VIV: egen piso_machi_parq_hog = max(piso_machi_parq_ind)
drop piso_machi_parq_ind
label var piso_machi_parq_hog "Piso: Machimbre/Parquet (dummy)"
tab piso_machi_parq_hog, m

* Mosaico/Baldosa/Cerámica (5-7)
cap drop piso_mos_cer_hog
gen piso_mos_cer_ind = .
replace piso_mos_cer_ind = 1 if inlist(P06_PISOS,5,7)
replace piso_mos_cer_ind = 0 if !missing(P06_PISOS) & !inlist(P06_PISOS,5,7)
bys I_BC_VIV: egen piso_mos_cer_hog = max(piso_mos_cer_ind)
drop piso_mos_cer_ind
label var piso_mos_cer_hog "Piso: Mosaico/Baldosa/Cerámica (dummy)"
tab piso_mos_cer_hog, m

* Cemento (6) 
cap drop piso_cemento_hog
gen piso_cemento_ind = .
replace piso_cemento_ind = 1 if P06_PISOS==6
replace piso_cemento_ind = 0 if !missing(P06_PISOS) & P06_PISOS!=6
bys I_BC_VIV: egen piso_cemento_hog = max(piso_cemento_ind)
drop piso_cemento_ind
label var piso_cemento_hog "Piso: Cemento (dummy)"
tab piso_cemento_hog, m

* Ladrillo (8)
cap drop piso_ladrillo_hog
gen piso_ladrillo_ind = .
replace piso_ladrillo_ind = 1 if P06_PISOS==8
replace piso_ladrillo_ind = 0 if !missing(P06_PISOS) & P06_PISOS!=8
bys I_BC_VIV: egen piso_ladrillo_hog = max(piso_ladrillo_ind)
drop piso_ladrillo_ind
label var piso_ladrillo_hog "Piso: Ladrillo (dummy)"
tab piso_ladrillo_hog, m


*========================================================
* 2) TECHO: P05_TECHO (OK)
*========================================================
cap label drop lbl_techo2012
label define lbl_techo2012 ///
    1 "Calamina o plancha metálica" ///
    2 "Teja (cemento/arcilla/fibrocemento)" ///
    3 "Losa de hormigón armado" ///
    4 "Paja/palma/caña/barro", replace
label values P05_TECHO lbl_techo2012

foreach c in 1 2 3 4 {
    cap drop techo`c'_hog
    gen techo`c'_ind = .
    replace techo`c'_ind = 1 if P05_TECHO==`c'
    replace techo`c'_ind = 0 if !missing(P05_TECHO) & P05_TECHO!=`c'
    bys I_BC_VIV: egen techo`c'_hog = max(techo`c'_ind)
    drop techo`c'_ind
    tab techo`c'_hog, m
}

label var techo1_hog "Techo: Calamina/plancha metálica (dummy)"
label var techo2_hog "Techo: Teja (dummy)"
label var techo3_hog "Techo: Losa de hormigón armado (dummy)"
label var techo4_hog "Techo: Paja/palma/caña/barro (dummy)"


*========================================================
* 3) PARED: P03_PARED (OK)
*========================================================
cap label drop lbl_pared2012
label define lbl_pared2012 ///
    1 "Ladrillo/bloque/hormigón" ///
    2 "Adobe/tapial" ///
    3 "Tabique/quinche" ///
    4 "Piedra" ///
    5 "Madera" ///
    6 "Caña/palma/tronco", replace
label values P03_PARED lbl_pared2012

foreach c in 1 2 3 4 5 6 {
    cap drop pared`c'_hog
    gen pared`c'_ind = .
    replace pared`c'_ind = 1 if P03_PARED==`c'
    replace pared`c'_ind = 0 if !missing(P03_PARED) & P03_PARED!=`c'
    bys I_BC_VIV: egen pared`c'_hog = max(pared`c'_ind)
    drop pared`c'_ind
    tab pared`c'_hog, m
}

label var pared1_hog "Pared: Ladrillo/bloque/hormigón (dummy)"
label var pared2_hog "Pared: Adobe/tapial (dummy)"
label var pared3_hog "Pared: Tabique/quinche (dummy)"
label var pared4_hog "Pared: Piedra (dummy)"
label var pared5_hog "Pared: Madera (dummy)"
label var pared6_hog "Pared: Caña/palma/tronco (dummy)"


*========================================================
* 4) AGUA: P07_AGUAPRO (OK)
*========================================================
foreach s in red pileta aguatero pozobomba pozosin rio {
    cap drop agua_`s'_hog
}

gen agua_red_ind = .
replace agua_red_ind = 1 if P07_AGUAPRO==1
replace agua_red_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=1
bys I_BC_VIV: egen agua_red_hog = max(agua_red_ind)
drop agua_red_ind
label var agua_red_hog "Agua: Cañería de red (dummy)"
tab agua_red_hog, m

gen agua_pileta_ind = .
replace agua_pileta_ind = 1 if P07_AGUAPRO==2
replace agua_pileta_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=2
bys I_BC_VIV: egen agua_pileta_hog = max(agua_pileta_ind)
drop agua_pileta_ind
label var agua_pileta_hog "Agua: Pileta pública (dummy)"
tab agua_pileta_hog, m

gen agua_aguatero_ind = .
replace agua_aguatero_ind = 1 if P07_AGUAPRO==3
replace agua_aguatero_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=3
bys I_BC_VIV: egen agua_aguatero_hog = max(agua_aguatero_ind)
drop agua_aguatero_ind
label var agua_aguatero_hog "Agua: Carro repartidor/aguatero (dummy)"
tab agua_aguatero_hog, m

gen agua_pozobomba_ind = .
replace agua_pozobomba_ind = 1 if P07_AGUAPRO==4
replace agua_pozobomba_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=4
bys I_BC_VIV: egen agua_pozobomba_hog = max(agua_pozobomba_ind)
drop agua_pozobomba_ind
label var agua_pozobomba_hog "Agua: Pozo con bomba (dummy)"
tab agua_pozobomba_hog, m

gen agua_pozosin_ind = .
replace agua_pozosin_ind = 1 if P07_AGUAPRO==5
replace agua_pozosin_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=5
bys I_BC_VIV: egen agua_pozosin_hog = max(agua_pozosin_ind)
drop agua_pozosin_ind
label var agua_pozosin_hog "Agua: Pozo sin bomba/no protegido (dummy)"
tab agua_pozosin_hog, m

gen agua_rio_lago_ind = .
replace agua_rio_lago_ind = 1 if inlist(P07_AGUAPRO,6,7)
replace agua_rio_lago_ind = 0 if !missing(P07_AGUAPRO) & !inlist(P07_AGUAPRO,6,7)
bys I_BC_VIV: egen agua_rio_lago_hog = max(agua_rio_lago_ind)
drop agua_rio_lago_ind
label var agua_rio_lago_hog "Agua: Río/vertiente/acequia/lago (dummy)"
tab agua_rio_lago_hog, m


*******************
* 5) Desague desagregado en copartido o no compartido
*******************
tab P10_DESAGUE,m	// con missings (26,71 %) ya que los individuos no cuentan con servicio sanitario, baño o letrina 
tab P09_SERVSANIT,m

gen baño_exclusivo = P09_SERVSANIT == 1 if !missing(P09_SERVSANIT)
gen baño_compartido = P09_SERVSANIT == 2 if !missing(P09_SERVSANIT)
gen sin_baño = P09_SERVSANIT == 3 if !missing(P09_SERVSANIT)

 
 * Red de alcantarillado
cap drop red_exclusivo
gen red_exclusivo = P10_DESAGUE == 1 & baño_exclusivo==1
tab red_exclusivo,m

cap drop red_compartido
gen red_compartido = P10_DESAGUE == 1 & baño_compartido==1
tab red_compartido,m

* Cámara séptica
cap drop septica_exclusivo
gen septica_exclusivo = P10_DESAGUE == 2 & baño_exclusivo==1
tab septica_exclusivo,m

cap drop septica_compartido
gen septica_compartido = P10_DESAGUE == 2 & baño_compartido==1
tab septica_compartido,m

* Pozo ciego 
cap drop pozo_ciego_exclusivo
gen pozo_ciego_exclusivo = P10_DESAGUE == 3 & baño_exclusivo==1
tab pozo_ciego_exclusivo,m

cap drop  pozo_ciego_compartido
gen pozo_ciego_compartido = P10_DESAGUE == 3 & baño_compartido==1
tab pozo_ciego_compartido,m

* Superficie 
cap drop superficie_exclusivo
gen superficie_exclusivo = inlist(P10_DESAGUE,4,5,6) & baño_exclusivo==1
tab superficie_exclusivo,m

cap drop superficie_compartido
gen superficie_compartido = inlist(P10_DESAGUE,4,5,6) & baño_compartido==1
tab superficie_compartido,m


*========================================================
* 6) ELECTRICIDAD: P11_ENERGIA 
*========================================================
foreach c in 1 2 3 {
    cap drop elec`c'_hog
    gen elec`c'_ind = .
    replace elec`c'_ind = 1 if P11_ENERGIA==`c'
    replace elec`c'_ind = 0 if !missing(P11_ENERGIA) & P11_ENERGIA!=`c'
    bys I_BC_VIV: egen elec`c'_hog = max(elec`c'_ind)
    drop elec`c'_ind
    tab elec`c'_hog, m
}
label var elec1_hog "Electricidad: servicio público (dummy)"
label var elec2_hog "Electricidad: generador/motor (dummy)"
label var elec3_hog "Electricidad: panel solar (dummy)"


*========================================================
* 7) COMBUSTIBLE: P12_COMBUS
*========================================================
cap drop comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog comb_nococina_hog

gen comb_gas_ind = .
replace comb_gas_ind = 1 if inlist(P12_COMBUS,1,2)
replace comb_gas_ind = 0 if !missing(P12_COMBUS) & !inlist(P12_COMBUS,1,2)
bys I_BC_VIV: egen comb_gas_hog = max(comb_gas_ind)
drop comb_gas_ind
label var comb_gas_hog "Combustible: gas (dummy)"
tab comb_gas_hog, m

gen comb_elec_ind = .
replace comb_elec_ind = 1 if P12_COMBUS==5
replace comb_elec_ind = 0 if !missing(P12_COMBUS) & P12_COMBUS!=5
bys I_BC_VIV: egen comb_elec_hog = max(comb_elec_ind)
drop comb_elec_ind
label var comb_elec_hog "Combustible: electricidad (dummy)"
tab comb_elec_hog, m

gen comb_solar_ind = .
replace comb_solar_ind = 1 if P12_COMBUS==6
replace comb_solar_ind = 0 if !missing(P12_COMBUS) & P12_COMBUS!=6
bys I_BC_VIV: egen comb_solar_hog = max(comb_solar_ind)
drop comb_solar_ind
label var comb_solar_hog "Combustible: solar (dummy)"
tab comb_solar_hog, m

gen comb_lena_ind = .
replace comb_lena_ind = 1 if P12_COMBUS==3
replace comb_lena_ind = 0 if !missing(P12_COMBUS) & P12_COMBUS!=3
bys I_BC_VIV: egen comb_lena_hog = max(comb_lena_ind)
drop comb_lena_ind
label var comb_lena_hog "Combustible: leña (dummy)"
tab comb_lena_hog, m

gen comb_guano_ind = .
replace comb_guano_ind = 1 if P12_COMBUS==4
replace comb_guano_ind = 0 if !missing(P12_COMBUS) & P12_COMBUS!=4
bys I_BC_VIV: egen comb_guano_hog = max(comb_guano_ind)
drop comb_guano_ind
label var comb_guano_hog "Combustible: guano/bosta/taquia (dummy)"
tab comb_guano_hog, m

*========================================================
* 8) BIENES 
*========================================================
cap drop radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog

gen radio_ind = .
replace radio_ind = 1 if P17A_RADIO==1
replace radio_ind = 0 if P17A_RADIO==2
bys I_BC_VIV: egen radio_hog = max(radio_ind)
drop radio_ind
label var radio_hog "Tiene radio (dummy)"
tab radio_hog, m

gen tv_ind = .
replace tv_ind = 1 if P17B_TV==1
replace tv_ind = 0 if P17B_TV==2
bys I_BC_VIV: egen tv_hog = max(tv_ind)
drop tv_ind
label var tv_hog "Tiene televisor (dummy)"
tab tv_hog, m

gen telef_ind = .
replace telef_ind = 1 if P17E_TELEF==1
replace telef_ind = 0 if P17E_TELEF==2
bys I_BC_VIV: egen telef_hog = max(telef_ind)
drop telef_ind
label var telef_hog "Tiene teléfono (dummy)"
tab telef_hog, m

gen comput_ind = .
replace comput_ind = 1 if P17C_COMPUT==1
replace comput_ind = 0 if P17C_COMPUT==2
bys I_BC_VIV: egen comput_hog = max(comput_ind)
drop comput_ind
label var comput_hog "Tiene computadora (dummy)"
tab comput_hog, m

gen bici_ind = .
replace bici_ind = 1 if P18B_BICIC==1
replace bici_ind = 0 if P18B_BICIC==2
bys I_BC_VIV: egen bici_hog = max(bici_ind)
drop bici_ind
label var bici_hog "Tiene bicicleta (dummy)"
tab bici_hog, m

gen moto_ind = .
replace moto_ind = 1 if P18C_MOTO==1
replace moto_ind = 0 if P18C_MOTO==2
bys I_BC_VIV: egen moto_hog = max(moto_ind)
drop moto_ind
label var moto_hog "Tiene motocicleta (dummy)"
tab moto_hog, m

gen vehic_ind = .
replace vehic_ind = 1 if P18A_VEHIC==1
replace vehic_ind = 0 if P18A_VEHIC==2
bys I_BC_VIV: egen vehic_hog = max(vehic_ind)
drop vehic_ind
label var vehic_hog "Tiene vehículo automotor (dummy)"
tab vehic_hog, m

gen carreta_ind = .
replace carreta_ind = 1 if P18D_CARRETA==1
replace carreta_ind = 0 if P18D_CARRETA==2
bys I_BC_VIV: egen carreta_hog = max(carreta_ind)
drop carreta_ind
label var carreta_hog "Tiene carreta/carretón (dummy)"
tab carreta_hog, m

gen bote_ind = .
replace bote_ind = 1 if P18E_BOTE==1
replace bote_ind = 0 if P18E_BOTE==2
bys I_BC_VIV: egen bote_hog = max(bote_ind)
drop bote_ind
label var bote_hog "Tiene bote/balsa/canoa (dummy)"
tab bote_hog, m


*========================================================
* 10) Cuarto para cocinar
*========================================================

gen cocina_ind = .
replace cocina_ind = 1 if P13_COCINA==1
replace cocina_ind = 0 if P13_COCINA==2
bys I_BC_VIV: egen cocina_hog = max(cocina_ind)
drop cocina_ind
label var cocina_hog "Tiene cuarto solo para cocinar (dummy)"
tab cocina_hog, m


*==================================================================
* 11) Personas por dormitorio
*==================================================================
cap drop pers_dorm_temp hacin_viv

* 1. Ajuste de dormitorios (Paso 1: si es 0, se pone 1 porque deben dormir en algún lado)
gen p15_adj = P15_DORMIT
replace p15_adj = 1 if P15_DORMIT == 0

* Calculo 
gen pers_dorm = TOTPERS_VIV / p15_adj 
replace pers_dorm = 5 if pers_dorm > 5


*========================================================
* 12) AYUDA DOMÉSTICA
*========================================================
cap drop ayuda_dom_viv
gen ayuda_dom_ind = (P23_PARENTES==9) if !missing(P23_PARENTES)
bys I_BC_VIV: egen ayuda_dom_viv = max(ayuda_dom_ind)
drop ayuda_dom_ind
cap label drop binlab
label define binlab 0 "No" 1 "Sí"
label values ayuda_dom_viv binlab
label var ayuda_dom_viv "Vivienda con ayuda doméstica (dummy)"
tab ayuda_dom_viv, m

*========================================================
* 13) BASURA  P16_BASURA          (sin missings)
*========================================================
cap drop recol_basura
gen recol_basura = (P16_BASURA==1 | P16_BASURA==2) if !missing(P16_BASURA)
label var recol_basura "Vivienda con ayuda doméstica (dummy)"
tab recol_basura, m

cap drop norecol_basura
gen norecol_basura = inlist(P16_BASURA,3,4,5,6,7) if !missing(P16_BASURA)
label var norecol_basura "Vivienda con ayuda doméstica (dummy)"
tab norecol_basura, m

*========================================================
* 14) REVOQUE EN PARED INTERIOR: P04_REVOQ (sin missings)
*========================================================
cap drop revoque_hog
gen revoque_ind = .
replace revoque_ind = 1 if P04_REVOQ==1
replace revoque_ind = 0 if !missing(P04_REVOQ) & P04_REVOQ!=1
bys I_BC_VIV: egen revoque_hog = max(revoque_ind)
drop revoque_ind
label var revoque_hog "Revoque:  (dummy)"
tab revoque_hog, m

*========================================================
* 15) Internet
*========================================================
cap drop internet
gen internet = 0
replace internet = 1 if P17D_INTERNET == 1
tab internet, m

*******************************************************************************
* NORMALIZACIÓN DE VARIABLES GEOGRÁFICAS 
*******************************************************************************

capture confirm numeric variable MUN
if _rc destring MUN, replace ignore(" ")

capture confirm numeric variable I02_DEPTO
if _rc destring I02_DEPTO, replace ignore(" ")

capture confirm numeric variable I03_PROV
if _rc destring I03_PROV, replace ignore(" ")

capture confirm numeric variable URBRUR_P
if _rc destring URBRUR_P, replace ignore(" ")

capture confirm numeric variable I00_FOLIO 
if _rc destring I00_FOLIO, replace ignore(" ")

capture confirm numeric variable I_BC_VIV
if _rc destring I_BC_VIV, replace ignore(" ")

save "$out\base_wealth_2012.dta", replace


********************************************************************************
* COLAPSAR A NIVEL HOGAR
********************************************************************************
preserve
collapse (max) prop_casa prop_depto prop_cuarto prop_viv_improvisada prop_viv_local_no_viv piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog techo1_hog techo2_hog techo3_hog techo4_hog pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_lago_hog baño_exclusivo baño_compartido sin_baño red_exclusivo red_compartido septica_exclusivo septica_compartido pozo_ciego_exclusivo pozo_ciego_compartido superficie_exclusivo superficie_compartido elec1_hog elec2_hog elec3_hog comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog carreta_hog bote_hog cocina_hog pers_dorm ayuda_dom_viv recol_basura norecol_basura revoque_hog internet I02_DEPTO I03_PROV MUN URBRUR URBRUR_P, by(I_BC_VIV)

compress
save "$out\base_hogar_wealth_2012.dta", replace

********************************************************************************
* 1. DEFINICIÓN DE GLOBALES
********************************************************************************

global X_urb "pers_dorm internet comput_hog telef_hog tv_hog vehic_hog moto_hog bici_hog red_exclusivo septica_exclusivo sin_baño comb_gas_hog agua_red_hog piso_machi_parq piso_mos_cer_hog piso_tierra_hog techo3_hog techo2_hog pared1_hog cocina_hog"

global X_rur "pers_dorm internet telef_hog radio_hog tv_hog vehic_hog moto_hog bici_hog carreta_hog sin_baño baño_exclusivo pozo_ciego_excl elec1_hog comb_gas_hog comb_elec_hog comb_solar_hog agua_red_hog agua_rio_hog piso_cemento_hog piso_tierra_hog techo1_hog techo4_hog pared1_hog pared2_hog pared5_hog"

********************************************************************************
* 2. ESTIMACIÓN PCA POR ÁREA (Lógica de Rutstein para Países en Desarrollo)
********************************************************************************
* El PCA separado evita que el área rural parezca pobre solo por no tener servicios urbanos.

* PCA Urbano
pca $X_urb if URBRUR == 1, corr
predict score_u if e(sample) & URBRUR == 1, score

* PCA Rural
pca $X_rur if URBRUR == 2, corr
predict score_r if e(sample) & URBRUR == 2, score

* Unificación en Índice Compuesto Nacional
gen wi_composite = score_u
replace wi_composite = score_r if URBRUR == 2

* Estandarización a Z-Score (Media 0, Desviación 1)
egen wi_z = std(wi_composite)
label var wi_z "Índice de Riqueza Nacional (Z-Score)"

********************************************************************************
* 3. CÁLCULO MUNICIPAL Y QUINTILES
********************************************************************************
* Promedio Municipal de Riqueza (Bienestar Agregado)
bysort MUN: egen wi_municipal = mean(wi_z)
label var wi_municipal "Índice de Riqueza Promedio Municipal"

* Quintiles Nacionales (Por Hogar)
xtile q_hogar = wi_z, nq(5)
label define ql 1 "Q1 (Pobreza Extrema)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (Estatus Alto)"
label values q_hogar ql

********************************************************************************
* 4. VISUALIZACIÓN DE RESULTADOS
********************************************************************************

twoway (kdensity wi_z, lcolor(navy) lwidth(thick)) ///
       (kdensity wi_z if URBRUR == 1, lcolor(blue) lpattern(dash)) ///
       (kdensity wi_z if URBRUR == 2, lcolor(brown) lpattern(dash)), ///
     title("Distribución de Riqueza: Comparativa Urbano vs Rural", size(medium)) ///
     xtitle("Puntaje de Riqueza (z-score)") ///
     ytitle("Densidad") ///
     legend(order(1 "Nacional" 2 "Urbano" 3 "Rural") pos(6) row(1)) ///
     xline(0, lcolor(red) lwidth(vthin) lpattern(dot)) ///
     xlabel(-3(1)4, grid) ylabel(, grid) ///
     graphregion(color(white))
