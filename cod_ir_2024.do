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

**************
* variaciones * Agua mejorada
**************
 
// De acuerdo a Rusbetein: juntar rios con lagos P07_AGUAPRO==7 
	// esta la variación en 2012, pero no en 2024

cap drop agua_mejorada
gen agua_mejorada=.
replace agua_mejorada=0 if v07_aguapro==1 & inlist(v08_aguadist,1,2) & urbrur==1
replace agua_mejorada=0 if v07_aguapro==2 & urbrur==1
replace agua_mejorada=0 if v07_aguapro==3 & urbrur==1
replace agua_mejorada=0 if v07_aguapro==1 & inlist(v08_aguadist,1,2) & urbrur==2
replace agua_mejorada=0 if v07_aguapro==2 & urbrur==2
replace agua_mejorada=0 if v07_aguapro==3 & urbrur==2
replace agua_mejorada=0 if v07_aguapro==4 & urbrur==2
replace agua_mejorada=0 if v07_aguapro==6 & urbrur==2
replace agua_mejorada=1 if agua_mejorada==.

tab agua_mejorada,m


* --- 5) SANEAMIENTO ---
* 1=Privado, 2=Compartido 
foreach c in 1 2 {
    cap drop sanit`c'_hog
    gen sanit`c'_ind = .
    replace sanit`c'_ind = 1 if v15_servsan==`c'
    replace sanit`c'_ind = 0 if !missing(v15_servsan) & v15_servsan!=`c'
    bys i00: egen sanit`c'_hog = max(sanit`c'_ind)
    drop sanit`c'_ind
    tab sanit`c'_hog, m
}


* --- 6) DESAGÜE --- (OK)
cap drop desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog

gen desag_alcantarillado_ind = .
replace desag_alcantarillado_ind = 1 if v16_desague==1
replace desag_alcantarillado_ind = 0 if !missing(v16_desague) & v16_desague!=1
bys i00: egen desag_alcantarillado_hog = max(desag_alcantarillado_ind)
drop desag_alcantarillado_ind
label var desag_alcantarillado_hog "Desagüe: alcantarillado"
tab desag_alcantarillado_hog, m

gen desag_septica_ind = .
replace desag_septica_ind = 1 if v16_desague==2
replace desag_septica_ind = 0 if !missing(v16_desague) & v16_desague!=2
bys i00: egen desag_septica_hog = max(desag_septica_ind)
drop desag_septica_ind
label var desag_septica_hog "Desagüe: cámara séptica"
tab desag_septica_hog, m

gen desag_pozo_ciego_ind = .
replace desag_pozo_ciego_ind = 1 if v16_desague==3
replace desag_pozo_ciego_ind = 0 if !missing(v16_desague) & v16_desague!=3
bys i00: egen desag_pozo_ciego_hog = max(desag_pozo_ciego_ind)
drop desag_pozo_ciego_ind
label var desag_pozo_ciego_hog "Desagüe: pozo ciego"
tab desag_pozo_ciego_hog, m

gen desag_superficie_ind = .
replace desag_superficie_ind = 1 if inlist(v16_desague,4,5,6)
replace desag_superficie_ind = 0 if !missing(v16_desague) & !inlist(v16_desague,4,5,6)
bys i00: egen desag_superficie_hog = max(desag_superficie_ind)
drop desag_superficie_ind
label var desag_superficie_hog "Desagüe: a la superficie"
tab desag_superficie_hog, m

*******************
* Primera variación: desague desagregado en copartido o no compartido
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

*******************
* Segunda variación: saneamiento mejorado
*******************
cap drop saneamiento_mejorado 
gen saneamiento_mejorado = .
replace saneamiento_mejorado = 0 if inlist(v16_desague,1,6) & urbrur==1
replace saneamiento_mejorado = 0 if inlist(v16_desague,1,2,3,4,6) & urbrur==2
replace saneamiento_mejorado = 1 if saneamiento_mejorado==.
tab saneamiento_mejorado,m 


* --- 7) ELECTRICIDAD ---
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


* --- 8) COMBUSTIBLE ---
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


*Combustible limpio para cocinar:

gen comb_limpio_ind = .
replace comb_limpio_ind = 1 if inlist(v10_combus,1,2,5,6)
replace comb_limpio_ind = 0 if !missing(v10_combus) & !inlist(v10_combus,1,2,5,6)
bys i00: egen comb_limpio_hog = max(comb_limpio_ind)
drop comb_limpio_ind
label var comb_limpio_hog "Combustible limpio para cocinar"
tab comb_limpio_hog, m


* --- 9) BIENES ---
gen radio_ind = .
replace radio_ind = 1 if v19a_radio==1
replace radio_ind = 0 if v19a_radio==2 & v19a_radio==9
bys i00: egen radio_hog = max(radio_ind)
drop radio_ind
label var radio_hog "Tiene radio"
tab radio_hog, m

gen tv_ind = .
replace tv_ind = 1 if v19b_tv==1
replace tv_ind = 0 if v19b_tv==2 & v19b_tv==9
bys i00: egen tv_hog = max(tv_ind)
drop tv_ind
label var tv_hog "Tiene TV"
tab tv_hog, m

gen telef_ind = .
replace telef_ind = 1 if (v19h_telfijo==1 | v19d_celular==1)
replace telef_ind = 0 if (v19h_telfijo==2 & v19d_celular==2 & v19h_telfijo==9 & v19d_celular==9)
bys i00: egen telef_hog = max(telef_ind)
drop telef_ind
label var telef_hog "Tiene teléfono (fijo o celular)"
tab telef_hog, m

gen comput_ind = .
replace comput_ind = 1 if v19c_compu==1
replace comput_ind = 0 if v19c_compu==2 & v19c_compu==9
bys i00: egen comput_hog = max(comput_ind)
drop comput_ind
label var comput_hog "Tiene computadora"
tab comput_hog, m

gen bici_ind = .
replace bici_ind = 1 if v18a_bici==1
replace bici_ind = 0 if v18a_bici==2 & v18a_bici==9
bys i00: egen bici_hog = max(bici_ind)
drop bici_ind
label var bici_hog "Tiene bicicleta"
tab bici_hog, m

gen moto_ind = .
replace moto_ind = 1 if v18b_moto==1
replace moto_ind = 0 if v18b_moto==2 & v18b_moto==9
bys i00: egen moto_hog = max(moto_ind)
drop moto_ind
label var moto_hog "Tiene moto"
tab moto_hog, m

gen vehic_ind = .
replace vehic_ind = 1 if v18c_auto==1
replace vehic_ind = 0 if v18c_auto==2 & v18c_auto==9
bys i00: egen vehic_hog = max(vehic_ind)
drop vehic_ind
label var vehic_hog "Tiene vehículo"
tab vehic_hog, m

gen carreta_ind = .
replace carreta_ind = 1 if v18d_carreta==1
replace carreta_ind = 0 if v18d_carreta==2 & v18d_carreta==9
bys i00: egen carreta_hog = max(carreta_ind)
drop carreta_ind
label var carreta_hog "Tiene carreta"
tab carreta_hog, m

gen bote_ind = .
replace bote_ind = 1 if v18e_bote==1
replace bote_ind = 0 if v18e_bote==2 & v18e_bote==9
bys i00: egen bote_hog = max(bote_ind)
drop bote_ind
label var bote_hog "Tiene bote/canoa"
tab bote_hog, m

gen cocina_ind = .
replace cocina_ind = 1 if v12_cocina==1
replace cocina_ind = 0 if v12_cocina==2
bys i00: egen cocina_hog = max(cocina_ind)
drop cocina_ind
label var cocina_hog "Tiene cuarto cocina"
tab cocina_hog, m


* --- 10) TENENCIA VIVIENDA ---
cap drop vivprop_hog
gen vivprop_ind = .
replace vivprop_ind = 1 if inlist(v17_tenencia,1,2)
replace vivprop_ind = 0 if !missing(v17_tenencia) & !inlist(v17_tenencia,1,2)
bys i00: egen vivprop_hog = max(vivprop_ind)
drop vivprop_ind
label var vivprop_hog "Vivienda propia"
tab vivprop_hog, m

*===================================================================
* Combinación de variables "Tipos de vivienda "con: Vivienda propia* 1 y 2
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

* Combinación de variables "Tipos de vivienda "con: Vivienda alquilada* 4
cap drop alquilada_casa
gen alquilada_casa = 0
replace alquilada_casa = 1 if v17_tenencia == 6 & inlist(v01_tipoviv,1,2)
tab alquilada_casa,m

cap drop alquilada_depto
gen alquilada_depto = 0
replace alquilada_depto = 1 if v17_tenencia == 6 & v01_tipoviv == 2
tab alquilada_depto,m

cap drop alquilada_cuarto
gen alquilada_cuarto = 0
replace alquilada_cuarto = 1 if v17_tenencia == 6 & v01_tipoviv == 3
tab alquilada_cuarto,m

cap drop alquilada_viv_improvisada
gen alquilada_viv_improvisada = 0
replace alquilada_viv_improvisada = 1 if v17_tenencia == 6 & v01_tipoviv == 4
tab alquilada_viv_improvisada,m

cap drop alquilada_viv_local_no_viv
gen alquilada_viv_local_no_viv = 0
replace alquilada_viv_local_no_viv = 1 if v17_tenencia == 6 & v01_tipoviv == 5
tab alquilada_viv_local_no_viv,m

* Combinación de variables "Tipos de vivienda "con: Vivienda en contrato anticrético* 5
cap drop anticr_casa
gen anticr_casa = 0
replace anticr_casa = 1 if v17_tenencia == 7 & inlist(v01_tipoviv,1,2)
tab anticr_casa,m

cap drop anticr_depto
gen anticr_depto = 0
replace anticr_depto = 1 if v17_tenencia == 7 & v01_tipoviv == 2
tab anticr_depto,m

cap drop anticr_cuarto
gen anticr_cuarto = 0
replace anticr_cuarto = 1 if v17_tenencia == 7 & v01_tipoviv == 3
tab anticr_cuarto,m

cap drop anticr_viv_improvisada
gen anticr_viv_improvisada = 0
replace anticr_viv_improvisada = 1 if v17_tenencia == 7 & v01_tipoviv == 4
tab anticr_viv_improvisada,m

cap drop anticr_viv_local_no_viv
gen anticr_viv_local_no_viv = 0
replace anticr_viv_local_no_viv = 1 if v17_tenencia == 7 & v01_tipoviv == 5
tab anticr_viv_local_no_viv,m

* Combinación de variables "Tipos de vivienda "con: Vivienda en contrato anticrético y alquiler* 6
cap drop aya_casa
gen aya_casa = 0
replace aya_casa = 1 if v17_tenencia == 6 & inlist(v01_tipoviv,1,2)
tab aya_casa,m

cap drop aya_depto
gen aya_depto = 0
replace aya_depto = 1 if v17_tenencia == 6 & v01_tipoviv == 2
tab aya_depto,m

cap drop aya_cuarto
gen aya_cuarto = 0
replace aya_cuarto = 1 if v17_tenencia == 6 & v01_tipoviv == 3
tab aya_cuarto,m

cap drop aya_viv_improvisada
gen aya_viv_improvisada = 0
replace aya_viv_improvisada = 1 if v17_tenencia == 6 & v01_tipoviv == 4
tab aya_viv_improvisada,m

cap drop aya_viv_local_no_viv
gen aya_viv_local_no_viv = 0
replace aya_viv_local_no_viv = 1 if v17_tenencia == 6 & v01_tipoviv == 5
tab aya_viv_local_no_viv,m

* Combinación de variables "Tipos de vivienda "con: Cedida por servicios* 7
cap drop ss_casa
gen ss_casa = 0
replace ss_casa = 1 if v17_tenencia == 7 & inlist(v01_tipoviv,1,2)
tab ss_casa,m

cap ss prop_depto
gen ss_depto = 0
replace ss_depto = 1 if v17_tenencia == 7 & v01_tipoviv == 2
tab ss_depto,m

cap drop ss_cuarto
gen ss_cuarto = 0
replace ss_cuarto = 1 if v17_tenencia == 7 & v01_tipoviv == 3
tab ss_cuarto,m

cap drop ss_viv_improvisada
gen ss_viv_improvisada = 0
replace ss_viv_improvisada = 1 if v17_tenencia == 7 & v01_tipoviv == 4
tab ss_viv_improvisada,m

cap drop ss_viv_local_no_viv
gen ss_viv_local_no_viv = 0
replace ss_viv_local_no_viv = 1 if v17_tenencia == 7 & v01_tipoviv == 5
tab ss_viv_local_no_viv,m

* Combinación de variables "Tipos de vivienda ": Prestada por parientes o amigos* 3
cap drop prest_casa
gen prest_casa = 0
replace prest_casa = 1 if v17_tenencia == 3 & inlist(v01_tipoviv,1,2)
tab prest_casa,m

cap drop prest_depto
gen prest_depto = 0
replace prest_depto = 1 if v17_tenencia == 3 & v01_tipoviv == 2
tab prest_depto,m

cap drop prest_cuarto
gen prest_cuarto = 0
replace prest_cuarto = 1 if v17_tenencia == 3 & v01_tipoviv == 3
tab prest_cuarto,m

cap drop prest_viv_improvisada
gen prest_viv_improvisada = 0
replace prest_viv_improvisada = 1 if v17_tenencia == 3 & v01_tipoviv == 4
tab prest_viv_improvisada,m

cap drop prest_viv_local_no_viv
gen prest_viv_local_no_viv = 0
replace prest_viv_local_no_viv = 1 if v17_tenencia == 3 & v01_tipoviv == 5
tab prest_viv_local_no_viv,m




* --- 11) HACINAMIENTO ---
cap drop TOT_PERS pers_dorm_temp hacin_viv

* Total personas en hogar
gen uno = 1
bys i00: egen TOT_PERS = total(uno)
drop uno

* Ratio personas/dormitorio (usando v14_dormit)
gen pers_dorm_temp = .
replace pers_dorm_temp = tot_pers / v14_dormit if v14_dormit > 0

* Dummy (> 2 personas)
gen hacin_ind = 0
replace hacin_ind = 1 if pers_dorm_temp > 2 & !missing(pers_dorm_temp)
replace hacin_ind = 1 if v14_dormit == 0 

bys i00: egen hacin_viv = max(hacin_ind)
drop hacin_ind pers_dorm_temp

label var hacin_viv "Hacinamiento (>2 pers/dorm)"
label define hacinlab 0 "Sin hacinamiento" 1 "Con hacinamiento"
label values hacin_viv hacinlab
tab hacin_viv, m

cap drop pers_dorm

* 1. Ajuste de dormitorios (Paso 4: si es 0, se pone 1 porque deben dormir en algún lado)
gen v14_adj = v14_dormit
replace v14_adj = 1 if v14_dormit == 0

* 2. Creación de la variable CONTINUA (Ratio real sin cortes)
gen pers_dorm = tot_pers / v14_adj

* 3. Tratamiento de Missings: Identificar casos donde falta tot_pers o v14_dormit
* (Se dejan como . para el siguiente paso)
replace pers_dorm = . if missing(tot_pers) | missing(v14_dormit)

* 4. Sustitución por la media (Paso 4 del manual: "Mean substitution for missing values")
summarize pers_dorm
local media_hacin = r(mean)
replace pers_dorm = `media_hacin' if pers_dorm == .

* 5. Etiquetado (Ya no es 0/1, ahora es el número de personas por cuarto)
label var pers_dorm "Ratio continuo de personas por dormitorio (DHS)"

* Limpieza de variables temporales
drop v14_adj

* Verificación
tab pers_dorm, m



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

********************************************************************************
* COLAPSAR A NIVEL HOGAR
********************************************************************************
preserve

collapse (max) ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog carreta_hog bote_hog cocina_hog ///
    vivprop_hog ayuda_dom_viv hacin_viv ///
    idep iprov imun urbrur mun_res_cod ///
    , by(i00)

compress
save "$out\hogar_2024_wealth_base.dta", replace

********************************************************************************
* PCA (ÍNDICE DE RIQUEZA)
********************************************************************************

global wealth_vars ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog carreta_hog bote_hog cocina_hog ///
    vivprop_hog ayuda_dom_viv hacin_viv

*  PCA 
pca $wealth_vars

* Score 
cap drop wealth_score wealth_z w_quintil
predict wealth_score if e(sample), score
egen wealth_z = std(wealth_score)

* Quintiles solo donde exista wealth_z
xtile w_quintil = wealth_z if wealth_z < ., nq(5)

label define q5 1 "Q1 (Más pobre)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (Más rico)", replace
label values w_quintil q5
label var w_quintil "Quintil de Riqueza 2024"

save "$out\hogar_2024_wealth_con_pca.dta", replace


********************************************************************************
* EXPORTAR RESULTADOS 
********************************************************************************

* --- 1. Quintiles Municipales ---
preserve
collapse (mean) mean_wealth=wealth_z (count) hogares=wealth_z, by(mun_res_cod)

xtile quintil_mun_mean = mean_wealth, nq(5)
label values quintil_mun_mean q5
label var quintil_mun_mean "Quintil municipal (promedio wealth)"

save "$out\wealth_municipal_promedio_2024.dta", replace
restore


* --- 2. Duplicados nivel vivienda ---
preserve
keep i00 w_quintil 
duplicates drop  
save "$out\viviendas_unicas_2024.dta", replace
restore 

********************************************************************************
* 1. PREPARACIÓN Y COLAPSO (CRUCIAL: CONTAR MIEMBROS)
********************************************************************************

* Generamos una variable auxiliar para contar personas antes de colapsar
gen uno = 1 

preserve

collapse (max) ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_cemento_hog piso_mos_cer_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_red_hog agua_pileta_hog agua_aguatero_hog agua_pozobomba_hog agua_pozosin_hog agua_rio_hog ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_gas_hog comb_elec_hog comb_solar_hog comb_lena_hog comb_guano_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog carreta_hog bote_hog cocina_hog ///
    vivprop_hog ayuda_dom_viv hacin_viv ///
    (first) idep iprov imun urbrur mun_res_cod ///
    (sum) tot_miembros=uno /// <--- ESTO ES NUEVO: Cuenta personas por hogar (i00)
    , by(i00)

compress
save "$out\hogar_2024_wealth_base.dta", replace

********************************************************************************
* 2. PCA (ÍNDICE DE RIQUEZA)
********************************************************************************

********************************************************************************
* VERSION A — PCA con DESAGÜE DESAGREGADO
********************************************************************************
global X_A_2024 ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_mejorada ///
    sanit1_hog sanit2_hog ///
    desag_alcantarillado_hog desag_septica_hog desag_pozo_ciego_hog desag_superficie_hog ///
    elec1_hog elec2_hog elec3_hog ///
    comb_limpio_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    vivprop_hog ///
    hacin_viv ///
    ayuda_dom_viv

pca $X_A_2024, corr
cap drop wiA24_score wiA24_z qA24_hog qA24_per
predict wiA24_score if e(sample), score
egen wiA24_z = std(wiA24_score)
label var wiA24_z "WI 2024 A (PCA corr, desagüe desagregado, z)"

label define qwl 1 "Q1 (más pobre)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (más rico)", replace

xtile qA24_hog = wiA24_z if wiA24_z < ., nq(5)
label values qA24_hog qwl
label var qA24_hog "Quintil 2024 A (hogares)"

xtile qA24_per = wiA24_z [fw=tot_pers] if wiA24_z < ., nq(5)
label values qA24_per qwl
label var qA24_per "Quintil 2024 A (personas)"

save "$out\wealth_2024_A_desague.dta", replace


********************************************************************************
*  VERSION B — PCA con SANEAMIENTO MEJORADO
********************************************************************************
use "$out\base_hogar_2024_para_pca.dta", clear

global X_B_2024 ///
    piso_tierra_hog piso_tablon_hog piso_machi_parq_hog piso_mos_cer_hog piso_cemento_hog piso_ladrillo_hog ///
    techo1_hog techo2_hog techo3_hog techo4_hog ///
    pared1_hog pared2_hog pared3_hog pared4_hog pared5_hog pared6_hog ///
    agua_mejorada ///
    sanit1_hog sanit2_hog ///
    saneamiento_mejorado ///
    elec1_hog elec2_hog elec3_hog ///
    comb_limpio_hog ///
    radio_hog tv_hog telef_hog comput_hog bici_hog moto_hog vehic_hog cocina_hog carreta_hog bote_hog ///
    vivprop_hog ///
    hacin_viv ///
    ayuda_dom_viv

pca $X_B_2024, corr
cap drop wiB24_score wiB24_z qB24_hog qB24_per
predict wiB24_score if e(sample), score
egen wiB24_z = std(wiB24_score)
label var wiB24_z "WI 2024 B (PCA corr, saneamiento mejorado, z)"

xtile qB24_hog = wiB24_z if wiB24_z < ., nq(5)
label values qB24_hog qwl
label var qB24_hog "Quintil 2024 B (hogares)"

xtile qB24_per = wiB24_z [fw=tot_pers] if wiB24_z < ., nq(5)
label values qB24_per qwl
label var qB24_per "Quintil 2024 B (personas)"

save "$out\wealth_2024_B_desague.dta", replace

********************************************************************************
* BASE FINAL 2024 (A y B en un solo archivo)
********************************************************************************
save "$out\wealth_2024_AB_en_un_archivo.dta", replace


********************************************************************************
* 6) RANKING MUNICIPAL (valor + quintil) — A y B, hogares y personas
********************************************************************************
tempfile munA24_hog munA24_per munB24_hog munB24_per

* --- A: hogares ---
preserve
collapse (mean) wiA24_mun_hog=wiA24_z (count) n_hogares=wiA24_z, by(mun_res_cod)
xtile q_munA24_hog = wiA24_mun_hog, nq(5)
label values q_munA24_hog qwl
save `munA24_hog', replace
save "$out\mun_2024_A_hogares.dta", replace
restore

* --- A: personas (promedio ponderado correcto) ---
preserve
gen double w_wiA24 = wiA24_z * tot_pers
collapse (sum) sum_w_wiA24=w_wiA24 ///
         (sum) poblacion=tot_pers ///
         (count) n_hogares=wiA24_z, by(mun_res_cod)
gen double wiA24_mun_per = sum_w_wiA24 / poblacion
drop sum_w_wiA24
xtile q_munA24_per = wiA24_mun_per, nq(5)
label values q_munA24_per qwl
save `munA24_per', replace
save "$out\mun_2024_A_personas.dta", replace
restore

* --- B: hogares ---
preserve
collapse (mean) wiB24_mun_hog=wiB24_z (count) n_hogares=wiB24_z, by(mun_res_cod)
xtile q_munB24_hog = wiB24_mun_hog, nq(5)
label values q_munB24_hog qwl
save `munB24_hog', replace
save "$out\mun_2024_B_hogares.dta", replace
restore

* --- B: personas (promedio ponderado correcto) ---
preserve
gen double w_wiB24 = wiB24_z * tot_pers
collapse (sum) sum_w_wiB24=w_wiB24 ///
         (sum) poblacion=tot_pers ///
         (count) n_hogares=wiB24_z, by(mun_res_cod)
gen double wiB24_mun_per = sum_w_wiB24 / poblacion
drop sum_w_wiB24
xtile q_munB24_per = wiB24_mun_per, nq(5)
label values q_munB24_per qwl
save `munB24_per', replace
save "$out\mun_2024_B_personas.dta", replace
restore


********************************************************************************
* DISTRIBUCIÓN INTRA-MUNICIPAL (hogares y personas por quintil) — A y B
********************************************************************************
tempfile distA24_hog distA24_per distB24_hog distB24_per

* --- A: hogares ---
preserve
contract mun_res_cod qA24_hog
bys mun_res_cod: egen hogares_mun = total(_freq)
gen share_hog = _freq / hogares_mun
rename _freq hogares_q
order mun_res_cod qA24_hog hogares_q share_hog hogares_mun
save `distA24_hog', replace
restore

* --- A: personas ---
preserve
collapse (sum) personas_q=tot_pers, by(mun_res_cod qA24_per)
bys mun_res_cod: egen personas_mun = total(personas_q)
gen share_per = personas_q / personas_mun
order mun_res_cod qA24_per personas_q share_per personas_mun
save `distA24_per', replace
restore

* --- B: hogares ---
preserve
contract codm qB24_hog
bys codm: egen hogares_mun = total(_freq)
gen share_hog = _freq / hogares_mun
rename _freq hogares_q
order codm qB24_hog hogares_q share_hog hogares_mun
save `distB24_hog', replace
restore

* --- B: personas ---
preserve
collapse (sum) personas_q=tot_pers, by(codm qB24_per)
bys codm: egen personas_mun = total(personas_q)
gen share_per = personas_q / personas_mun
order codm qB24_per personas_q share_per personas_mun
save `distB24_per', replace
restore


********************************************************************************
* Comparación A vs B (2024)
********************************************************************************
use "$out\wealth_2024_AB_en_un_archivo.dta", clear
corr wiA24_z wiB24_z
tab qA24_hog qB24_hog, row col
tab qA24_per qB24_per [fw=tot_pers], row col



