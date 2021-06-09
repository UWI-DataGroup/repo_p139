** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			qeh_injury_prep_combine.do
    //  project:				QEH Injury Dataset. Secondary analysis of available data
    //  analysts:				Ian HAMBLETON and Christina Howitt
    // 	date last modified	    22-JAN-2020 (NS)
    //  algorithm task			

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p139"
    ** LOGFILES to unencrypted OneDrive folder
    local logpath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p139"

    ** Close any open log fileand open a new log file
    capture log close
    cap log using "`logpath'\qeh_injury_prep_combine", replace
** HEADER -----------------------------------------------------

use "`datapath'\version01\2-working\qeh_injury_2016_2019", clear 

** Defining type of injury using ICD codes: injury codes are ICD S00-T88 (injury, poisoning and certain other consequences of external causes); and V00-Y99 (external causes of morbidity).
** All other ICD codes will be classified as non-injury. 

** We are differentiating between:
                              ** intentional injury: includes intentional self-harm (ICD X71-X83) and assault (X92-Y08)
                              ** unintentional injury: all other injury codes
                              ** unknown intention: event of undetermined intent (ICD Y21 - Y33)


gen inj_type = .
        order acode1, after(did)
        order acode2, after(acode1)
        order acode3, after(acode2)
        order inj_type, after(acode3)

replace inj_type = 1 if regexm(acode2, "^S") | regexm(acode3, "^S") | regexm(acode2, "^T") | regexm(acode3, "^T") | regexm(acode2, "^V") | regexm(acode3, "^V") | regexm(acode2, "^W") | ///
   regexm(acode3, "W") | regexm(acode2, "X") | regexm(acode3, "X") | regexm(acode2, "^Y") | regexm(acode3, "^Y") 
        sort inj_type acode3 acode2


replace inj_type = 2 if regexm(acode2, "^X7") | regexm(acode3, "^X7") | regexm(acode2, "^X8") | regexm(acode3, "^X8") | regexm(acode2, "^X9") | regexm(acode3, "^X9") | ///
    regexm(acode2, "^Y0") | regexm(acode3, "^Y0")


replace inj_type = 3 if regexm(acode2, "^Y2") | regexm(acode3, "^Y2") | regexm(acode2, "^Y30") | regexm(acode3, "^Y30") | regexm(acode2, "^Y31") | regexm(acode3, "^Y31") | ///
    regexm(acode2, "^Y32") | regexm(acode3, "^Y32") | regexm(acode2, "^Y33") | regexm(acode3, "^Y33") 

label variable inj_type "Injury mechanism"
label define inj_type 1 "Unintentional injury" 2 "Intentional injury" 3 "Unknown intention"
label values inj_type inj_type 



*TABLE OF INJURY TYPE BY YEAR AND SEX
tab inj_type sex if yoa==2016, col

gen inj=0
replace inj=1 if inj_type!=.

gen numinj=1
drop if inj==0
gen tweek = yw(yoa, woy)
	format tweek %tw
collapse yoa woy (sum) numinj, by(tweek)

** Calculate a 5-week rolling average injury total
gen inj3 = (numinj[_n-2] + numinj + numinj[_n+2]) / 5


#delimit ;
	gr twoway
		  /// lw=line width, msize=symbol size, mc=symbol colour, lc=line color
		  /// Colours use RGB system
		  (connect inj3 woy if yoa==2016, lp("-") lw(0.5) msize(0.5) mc("116 196 118") lc("116 196 118"))
		  (connect inj3 woy if yoa==2017, lp("-") lw(0.5) msize(0.5) mc("186 228 179") lc("186 228 179"))
		  (connect inj3 woy if yoa==2018, lp("l") lw(0.5) msize(0.5) mc("0 109 44") lc("0 109 44"))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(7)

			xtitle("Week of the year", margin(t=3) size(3.5))

            ylab(0(50)200, labs(medium) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("Number of injuries admitted per week", margin(r=3) size(3.5))

			legend(size(3) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(0.1) margin(l=2 r=2 t=2 b=2))
            lab(1 "2016")
			lab(2 "2017")
			lab(3 "2018")

            )
        
            ;
#delimit cr