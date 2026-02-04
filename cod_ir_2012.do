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

gen agua_rio_ind = .
replace agua_rio_ind = 1 if P07_AGUAPRO==6
replace agua_rio_ind = 0 if !missing(P07_AGUAPRO) & P07_AGUAPRO!=6
bys I_BC_VIV: egen agua_rio_hog = max(agua_rio_ind)
drop agua_rio_ind
label var agua_rio_hog "Agua: Río/vertiente/acequia (dummy)"
tab agua_rio_hog, m

gen agua_rio_lago_ind = .
replace agua_rio_lago_ind = 1 if inlist(P07_AGUAPRO,6,7)
replace agua_rio_lago_ind = 0 if !missing(P07_AGUAPRO) & !inlist(P07_AGUAPRO,6,7)
bys I_BC_VIV: egen agua_rio_lago_hog = max(agua_rio_lago_ind)
drop agua_rio_lago_ind
label var agua_rio_lago_hog "Agua: Río/vertiente/acequia/lago (dummy)"
tab agua_rio_lago_hog, m

**************
* Primera variación: Agua mejorada 
**************

* Agua mejorada
cap drop agua_mejorada
gen agua_mejorada = .
replace agua_mejorada = 0 if inlist(P07,3,4,5,6,7) & URBRUR==1
replace agua_mejorada = 0 if inlist(P07,3,5,6,7) & URBRUR==2
replace agua_mejorada = 1 if inlist(P07,1,2) & URBRUR==1
replace agua_mejorada = 1 if inlist(P07,1,2,4) & URBRUR==2
tab agua_mejorada,m


*========================================================
* 5) SANEAMIENTO: P09_SERVSANIT (OK)
*========================================================
foreach c in 1 2 {
    cap drop sanit`c'_hog
    gen sanit`c'_ind = .
    replace sanit`c'_ind = 1 if P09_SERVSANIT==`c'
    replace sanit`c'_ind = 0 if !missing(P09_SERVSANIT) & P09_SERVSANIT!=`c'
    bys I_BC_VIV: egen sanit`c'_hog = max(sanit`c'_ind)
    drop sanit`c'_ind
    tab sanit`c'_hog, m
}
label var sanit1_hog "Sanitario: Sí, privado (dummy)"
label var sanit2_hog "Sanitario: Sí, compartido (dummy)"



*========================================================
* 6) DESAGÜE: P10_DESAGUE (OK)
*========================================================
cap drop desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog

gen desag_alcantarillado_ind = .
replace desag_alcantarillado_ind = 1 if P10_DESAGUE==1
replace desag_alcantarillado_ind = 0 if !missing(P10_DESAGUE) & P10_DESAGUE!=1
bys I_BC_VIV: egen desag_alcantarillado_hog = max(desag_alcantarillado_ind)
drop desag_alcantarillado_ind
label var desag_alcantarillado_hog "Desagüe: alcantarillado (dummy)"
tab desag_alcantarillado_hog, m

gen desag_septica_ind = .
replace desag_septica_ind = 1 if P10_DESAGUE==2
replace desag_septica_ind = 0 if !missing(P10_DESAGUE) & P10_DESAGUE!=2
bys I_BC_VIV: egen desag_septica_hog = max(desag_septica_ind)
drop desag_septica_ind
label var desag_septica_hog "Desagüe: cámara séptica (dummy)"
tab desag_septica_hog, m

gen desag_pozo_ciego_ind = .
replace desag_pozo_ciego_ind = 1 if P10_DESAGUE==3
replace desag_pozo_ciego_ind = 0 if !missing(P10_DESAGUE) & P10_DESAGUE!=3
bys I_BC_VIV: egen desag_pozo_ciego_hog = max(desag_pozo_ciego_ind)
drop desag_pozo_ciego_ind
label var desag_pozo_ciego_hog "Desagüe: pozo ciego (dummy)"
tab desag_pozo_ciego_hog, m

gen desag_superficie_ind = .
replace desag_superficie_ind = 1 if inlist(P10_DESAGUE,4,5,6)
replace desag_superficie_ind = 0 if !missing(P10_DESAGUE) & !inlist(P10_DESAGUE,4,5,6)
bys I_BC_VIV: egen desag_superficie_hog = max(desag_superficie_ind)
drop desag_superficie_ind
label var desag_superficie_hog "Desagüe: a la superficie (4-6) (dummy)"
tab desag_superficie_hog, m


*******************
* Primera variación: desague desagregado en copartido o no compartido
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


*******************
* Segunda variación: saneamiento mejorado
*******************

cap drop saneamiento_mejorado 
gen saneamiento_mejorado = .
replace saneamiento_mejorado = 1 if saneamiento==.
replace saneamiento_mejorado = 1 if inlist(P10_DESAGUE,2,3,4,5,6) & URBRUR==1
replace saneamiento_mejorado = 1 if inlist(P10_DESAGUE,4,5,6) & URBRUR==2
replace saneamiento_mejorado = 0 if inlist(P10_DESAGUE,1) & URBRUR==1
replace saneamiento_mejorado = 0 if inlist(P10_DESAGUE,1,2,3) & URBRUR==2
tab saneamiento_mejorado,m


*========================================================
* 7) ELECTRICIDAD: P11_ENERGIA 
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
* 8) COMBUSTIBLE: P12_COMBUS
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


*Combustible limpio para cocinar:

gen comb_limpio_ind = .
replace comb_limpio_ind = 1 if inlist(P12_COMBUS,1,2,3,4)
replace comb_limpio_ind = 0 if !missing(P12_COMBUS) & !inlist(P12_COMBUS,1,2,3,4)
bys I_BC_VIV: egen comb_limpio_hog = max(comb_limpio_ind)
drop comb_limpio_ind
label var comb_limpio_hog "Combustible limpio para cocinar (dummy)"
tab comb_limpio_hog, m



*========================================================
* 9) BIENES 
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

gen cocina_ind = .
replace cocina_ind = 1 if P13_COCINA==1
replace cocina_ind = 0 if P13_COCINA==2
bys I_BC_VIV: egen cocina_hog = max(cocina_ind)
drop cocina_ind
label var cocina_hog "Tiene cuarto solo para cocinar (dummy)"
tab cocina_hog, m

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
* 10) TENENCIA VIVIENDA: P19_TENENCIA (binaria "propia")
*========================================================
cap drop vivprop_hog
gen vivprop_ind = .
replace vivprop_ind = 1 if P19_TENENCIA==1
replace vivprop_ind = 0 if !missing(P19_TENENCIA) & P19_TENENCIA!=1
bys I_BC_VIV: egen vivprop_hog = max(vivprop_ind)
drop vivprop_ind
label var vivprop_hog "Vivienda propia (dummy: código 1)"
tab vivprop_hog, m


*==================================================================
* 11) HACINAMIENTO BINARIO: Dummy (1=Con hacinamiento, 0=Sin)
*==================================================================
cap drop pers_dorm_temp hacin_viv

* 1. Ajuste de dormitorios (Paso 4: si es 0, se pone 1 porque deben dormir en algún lado)
gen p15_adj = P15_DORMIT
replace p15_adj = 1 if P15_DORMIT == 0

* Calculo temporal
gen pers_dorm_temp = TOTPERS_VIV / p15_adj 

* Dummy: 1=Medio/Alto (hacinamiento), 0=Sin
gen hacin_ind = .
replace hacin_ind = 0 if pers_dorm_temp <= 2 & p15_adj > 0
replace hacin_ind = 1 if pers_dorm_temp > 2 & p15_adj > 0

bys I_BC_VIV: egen hacin_viv = max(hacin_ind)
drop hacin_ind pers_dorm_temp

label var hacin_viv "Vivienda con hacinamiento (1=Sí:Medio/Alto, 0=Bajo)"
label define binlab 0 "Sin" 1 "Con hacinamiento"
label values hacin_viv binlab
tab hacin_viv, m

* 2. Creación de la variable CONTINUA (Ratio real sin cortes)
gen pers_dorm = TOTPERS_VIV / p15_adj

replace pers_dorm = 10 if pers_dorm > 10

* 3. Tratamiento de Missings: Identificar casos donde falta tot_pers o v14_dormit
* (Se dejan como . para el siguiente paso)
replace pers_dorm = . if missing(TOTPERS_VIV) | missing(P15_DORMIT)

* 4. Sustitución por la media (Paso 4 del manual: "Mean substitution for missing values")
summarize pers_dorm
local media_hacin = r(mean)
replace pers_dorm = `media_hacin' if pers_dorm == .

* 5. Etiquetado (Ya no es 0/1, ahora es el número de personas por cuarto)
label var pers_dorm "Ratio continuo de personas por dormitorio (DHS)"

* Limpieza de variables temporales
drop p15_adj

* Verificación
tab pers_dorm, m


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


********************************************************************************
* COLAPSAR A NIVEL HOGAR
********************************************************************************
preserve
collapse (max) ///
    jefe_hogar discapacitado_v ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    vivprop_hog ///
    hacin_viv ///
    ayuda_dom_viv ///
    I02_DEPTO I03_PROV MUN URBRUR URBRUR_P ///
    , by(I_BC_VIV)

compress
save "$out\base_hogar_wealth_2012.dta", replace

********************************************************************************
* PCA (WEALTH INDEX) — NIVEL HOGAR
********************************************************************************

global X_wealth ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    vivprop_hog ///
    hacin_viv ///
    ayuda_dom_viv

*misstable summarize $X_wealth

* PCA con matriz de correlaciones
pca $X_wealth, corr

* Score del primer componente 
cap drop wealth_hog wealth_hog_z
predict wealth_hog if e(sample), score
egen wealth_hog_z = std(wealth_hog)
label var wealth_hog_z "Índice de riqueza (PCA comp1, z-score)"

* Quintiles 
cap drop q_wealth
xtile q_wealth = wealth_hog_z if wealth_hog_z < ., nq(5)

label define qwl 1 "Q1 (más pobre)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (más rico)", replace
label values q_wealth qwl
label var q_wealth "Quintil de riqueza (hogar, nacional)"

save "$out\base_hogar_wealth_2012_con_pca.dta", replace

********************************************************************************
* EXPORTAR RESULTADOS
********************************************************************************

* --- 1. Quintiles Municipales ---
preserve
collapse (mean) mean_wealth=wealth_hog_z (count) hogares=wealth_hog_z, by(MUN)

xtile quintil_mun_mean = mean_wealth, nq(5)
label values quintil_mun_mean qwl
label var quintil_mun_mean "Quintil municipal (según promedio municipal de riqueza)"

save "$out\quintil_municipal_mean_2012.dta", replace
restore


* --- 2. Duplicados nivel vivienda ---
preserve

keep I_BC_VIV q_wealth 
duplicates drop  
save "$out\viviendas_unicas_2012.dta", replace

restore 



********************************************************************************
* COLAPSO A NIVEL HOGAR
********************************************************************************
preserve

collapse (max) ///
    jefe_hogar discapacitado_v ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    vivprop_hog ///
    hacin_viv ///
    ayuda_dom_viv ///
    (first) I02_DEPTO I03_PROV MUN TOTPERS_VIV /// 
    , by(I_BC_VIV)

compress
save "$out\base_hogar_censo_preparada.dta", replace

********************************************************************************
* CÁLCULO DEL PCA (ÍNDICE DE RIQUEZA)
********************************************************************************
********************************************************************************
* VERSION A — PCA con DESAGÜE DESAGREGADO (DHS-like)
********************************************************************************
global X_A ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_mejorada ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_limpio_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    hacin_viv ///
    ayuda_dom_viv

pca $X_A, corr
cap drop wi_A_score wi_A_z
predict wi_A_score if e(sample), score
egen wi_A_z = std(wi_A_score)
label var wi_A_z "WI A (PCA corr, desagüe desagregado, z)"

* Quintiles A (hogares y personas)
label define qwl 1 "Q1 (más pobre)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (más rico)", replace

cap drop qA_hog qA_per
xtile qA_hog = wi_A_z if wi_A_z < ., nq(5)
label values qA_hog qwl
label var qA_hog "Quintil A (hogares)"

xtile qA_per = wi_A_z [fw=TOTPERS_VIV] if wi_A_z < ., nq(5)
label values qA_per qwl
label var qA_per "Quintil A (personas)"

save "$out\wealth_2012_A_desague.dta", replace


********************************************************************************
* 3) VERSION B — PCA con SANEAMIENTO MEJORADO (sensibilidad)
********************************************************************************
global X_B ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_mejorada ///
    sanit1_hog sanit2_hog ///
    saneamiento_mejorado ///
    elec1_hog elec2_hog elec3_hog ///
    comb_limpio_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    hacin_viv ///
    ayuda_dom_viv

pca $X_B, corr
cap drop wi_B_score wi_B_z
predict wi_B_score if e(sample), score
egen wi_B_z = std(wi_B_score)
label var wi_B_z "WI B (PCA corr, saneamiento mejorado, z)"

* Quintiles B (hogares y personas)
cap drop qB_hog qB_per
xtile qB_hog = wi_B_z if wi_B_z < ., nq(5)
label values qB_hog qwl
label var qB_hog "Quintil B (hogares)"

xtile qB_per = wi_B_z [fw=TOTPERS_VIV] if wi_B_z < ., nq(5)
label values qB_per qwl
label var qB_per "Quintil B (personas)"

save "$out\wealth_2012_B_sanemejorado.dta", replace


********************************************************************************
* 4) RESÚMENES MUNICIPALES (A y B) — hogares y personas
********************************************************************************

tempfile munA_hog munA_per munB_hog munB_per

* ===== A: DESAGÜE DESAGREGADO =====
preserve
collapse (mean) wiA_mun_hog=wi_A_z (count) n_hogares=wi_A_z, by(MUN)
xtile q_munA_hog = wiA_mun_hog, nq(5)
label values q_munA_hog qwl
save `munA_hog', replace
save "$out\mun_2012_A_hogares.dta", replace
restore

preserve
collapse (mean) wiA_mun_per=wi_A_z [fw=TOTPERS_VIV] ///
         (sum) poblacion=TOTPERS_VIV ///
         (count) n_hogares=wi_A_z, by(MUN)
xtile q_munA_per = wiA_mun_per, nq(5)
label values q_munA_per qwl
save `munA_per', replace
save "$out\mun_2012_A_personas.dta", replace
restore

* ===== B: SANEAMIENTO MEJORADO =====
preserve
collapse (mean) wiB_mun_hog=wi_B_z (count) n_hogares=wi_B_z, by(MUN)
xtile q_munB_hog = wiB_mun_hog, nq(5)
label values q_munB_hog qwl
save `munB_hog', replace
save "$out\mun_2012_B_hogares.dta", replace
restore

preserve
collapse (mean) wiB_mun_per=wi_B_z [fw=TOTPERS_VIV] ///
         (sum) poblacion=TOTPERS_VIV ///
         (count) n_hogares=wi_B_z, by(MUN)
xtile q_munB_per = wiB_mun_per, nq(5)
label values q_munB_per qwl
save `munB_per', replace
save "$out\mun_2012_B_personas.dta", replace
restore


********************************************************************************
* 5) Medir cuánto cambia A vs B
********************************************************************************
* Correlación entre scores
corr wi_A_z wi_B_z

* Matriz de cambio de quintil (hogares)
tab qA_hog qB_hog, row col

* Matriz de cambio de quintil (personas)
tab qA_per qB_per [fw=TOTPERS_VIV], row col

save "$out\wealth_2012_AB_en_un_archivo.dta", replace















