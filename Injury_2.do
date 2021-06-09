* HEADER -----------------------------------------------------
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

** We are differentiating injury type using location:
                              ** 1: Head and Neck: (codes S00 - S19)
                              ** 2: Chest and Abdomen (codes S20 - S39)
                              ** 3: Upper limb (codes S40 - S69)
							  ** 4: Lower limb (codes S70 - S99)
							  ** 5: Multiple regions (code T07)
                              ** 6: Unspecified (code T14)
***Code below here to be completed with appropriate categories
**Need five anatomic categories							  

gen inj_site = .
        order acode1, after(did)
        order acode2, after(acode1)
        order acode3, after(acode2)
        order inj_site, after(acode3)

replace inj_site = 1 if regexm(acode2, "^S0" ) | regexm(acode3, "^S0") | regexm(acode2, "^S1") | regexm(acode3, "^S1") 
        


replace inj_site = 2 if regexm(acode2, "^S2") | regexm(acode3, "^S2") | regexm(acode2, "^S3") | regexm(acode3, "^S3") 


replace inj_site = 3 if regexm(acode2, "^S4") | regexm(acode3, "^S4") | regexm(acode2, "^S5") | regexm(acode3, "^S5") | regexm(acode2, "^S6") | regexm(acode3, "^S6")  
    
replace inj_site = 4 if regexm(acode2, "^S7") | regexm(acode3, "^S7") | regexm(acode2, "^S8") | regexm(acode3, "^S8") | regexm(acode2, "^S9") | regexm(acode3, "^S9")  

replace inj_site = 5 if regexm(acode2, "^T07") | regexm(acode3, "^T07") 

replace inj_site = 6 if regexm(acode2, "^T14") | regexm(acode3, "^T14") 

sort inj_site acode3 acode2

label variable inj_site "Injury site"
label define inj_site 1 "Head and neck" 2 "Chest and Abdomen" 3 "Upper limb"  4 "Lower limb" 5 "Multiple regions" 6 "Unspecified region"
label values inj_site inj_site 


**TABLE OF INJURY TYPE BY YEAR AND SEX
tab inj_site sex if yoa==2016, col
tab inj_site sex if yoa==2017, col
tab inj_site sex if yoa==2018, col



**********************************************************************************************************************************************************************************
*   Next we look at burns separately. We first look at all burns, then differentiate between site of burn (external body; eye and internal organs; multiple sites)
********************************************************************************************************************************************************************************** 

gen burn=0
replace burn = 1 if regexm(acode2, "^T2") | regexm(acode3, "^T2") | regexm(acode2, "^T30") | regexm(acode3, "^T30") | regexm(acode2, "^T31") | regexm(acode3, "^T31") | regexm(acode2, "^T32") | regexm(acode3, "^T32")

gen burn_site = .

replace burn_site=1 if regexm(acode2, "^T20") | regexm(acode3, "^T20") | regexm(acode2, "^T21") | regexm(acode3, "^T21") | regexm(acode2, "^T22") | regexm(acode3, "^T22")  ///
    | regexm(acode2, "^T23") | regexm(acode3, "^T23") | regexm(acode2, "^T24") | regexm(acode3, "^T24") | regexm(acode2, "^T25") | regexm(acode3, "^T25")

replace burn_site=2 if regexm(acode2, "^T26") | regexm(acode3, "^T26") | regexm(acode2, "^T27") | regexm(acode3, "^T27") | regexm(acode2, "^T28") | regexm(acode3, "^T28")  

replace burn_site=3 if regexm(acode2, "^T29") | regexm(acode3, "^T29") | regexm(acode2, "^T30") | regexm(acode3, "^T30") | regexm(acode2, "^T31") | regexm(acode3, "^T31") | regexm(acode2, "^T32") | regexm(acode3, "^T32")  

label define burn_site 1 "external" 2 "eye and internal organs" 3  "multiple region"
label values burn_site burn_site 

order burn, after(inj_site)
order burn_site, after(burn)

**TABLE OF BURN TYPE BY YEAR AND SEX
tab burn sex if yoa==2016, col
tab burn sex if yoa==2017, col
tab burn sex if yoa==2018, col

tab burn_site sex if yoa==2016, col
tab burn_site sex if yoa==2017, col
tab burn_site sex if yoa==2018, col