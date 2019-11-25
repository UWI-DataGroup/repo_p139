** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			qeh_injury_prep_2016.do
    //  project:				QEH Injury Dataset. Secondary analysis of available data
    //  analysts:				Ian HAMBLETON
    // 	date last modified	    4-NOV-2019
    //  algorithm task			

HELLO NATASHA ... A SECOND TIME

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
    cap log using "`logpath'\qeh_injury_prep_2016", replace
** HEADER -----------------------------------------------------

** Import dataset received from Dr Babatunde Oredein
** via Dr Natasha Sobers
** Dataset received: Nov-2019

** Partial dataset to speed algorithm building 
** import excel using "`datapath'/version01/1-input/AED Log January 2016-December 2016 TESTING DATASET.xlsx", first
** Full dataset 
import excel using "`datapath'/version01/1-input/AED Log January 2016-December 2016.xlsx", first

drop P_FNUM C D E P_PHONE

** Unique identifier
rename P_SNUM did 
label var did "Participant identifier: daily identifier?"

** YEAR of arrival
gen yoa = year(P_ADATE) 
label var yoa "Year of arrival" 
order yoa , after(did)

** DATE of arrival 
rename P_ADATE doa 
label var doa "Date of arrival"
order doa , after(yoa)

** DAY OF WEEK of arrival
gen dow = dow(doa)
label var dow "Day of week for arrival"
order dow , after(doa)
label define _dow 0 "sun" 1 "mon" 2 "tue" 3 "wed" 4 "thu" 5 "fri" 6 "sat", modify 
label values dow _dow 

** WEEK OF YEAR of arrival 
gen woy = week(doa)
label var woy "Week of year for arrival"
order woy , after(dow)

** Age of patient 
rename P_AGE agey 
replace agey = agey/12 if P_AGETYPE=="Months"
replace agey = agey/52 if P_AGETYPE=="Weeks"
replace agey = agey/365.25 if P_AGETYPE=="Days"
label var agey "Patient age (in years)"
order agey, after(woy)

** Sex of patient 
gen sex = 1 if P_SEX == "F"
replace sex = 2 if P_SEX == "M"
label var sex "Patient sex: 1=female 2=male" 
label define _sex 1 "female" 2 "male", modify 
label values sex _sex 
order sex, after(agey) 

** HOME PARISH of participant 
gen parish = 1 if P_PARISH == "A"
replace parish = 2 if P_PARISH == "X" 
replace parish = 3 if P_PARISH == "G" 
replace parish = 4 if P_PARISH == "M" 
replace parish = 5 if P_PARISH == "S" 
replace parish = 6 if P_PARISH == "J" 
replace parish = 7 if P_PARISH == "O" 
replace parish = 8 if P_PARISH == "L" 
replace parish = 9 if P_PARISH == "E" 
replace parish = 10 if P_PARISH == "P" 
replace parish = 11 if P_PARISH == "T" 
label define _parish 1 "st.andrew" 2 "ch ch" 3 "st.george" 4 "st.michael" 5 "st.james" 6 "st.john" /// 
                     7 "st.joseph" 8 "st.lucy" 9 "st.peter" 10 "st.philip" 11 "st.thomas" 
label values parish _parish 
order parish, after(sex) 
label var parish "Patient parish of residence" 

** Time of day 
ntimeofday P_ATIME, gen(toa) s(h mi) n(hour) parse(:)
split P_ATIME, parse(:) gen(toa_)
gen toa_hr = real(toa_1)
gen toa_min = real(toa_2) 
label var toa "Time of admission as numeric (24-hr clock)" 
label var toa_hr "Hour of admission (24-hr clock)"
label var toa_min "Minute of admission (24-hr clock)"
order toa toa_hr toa_min, after(parish)

** Mode of Admission 
gen amode = 1 if P_AMODE == "EA"
replace amode = 2 if P_AMODE == "GP"
replace amode = 3 if P_AMODE == "PA"
replace amode = 4 if P_AMODE == "PO"
replace amode = 5 if P_AMODE == "PT"
replace amode = 6 if P_AMODE == "QB"
label define _amode 1 "emerg.amb" 2 "unk" 3 "unk" 4 "unk" 5 "private.trans" 6 "unk"  
label values amode _amode 
label var amode "Mode of administration" 
order amode, after(toa_min) 


* ! P_VIS 
* ! Final definition for this
gen visitor = .
replace visitor = 0 if P_VIS == "N"
replace visitor = 1 if P_VIS == "Y"
label define _visitor 0 "no" 1 "yes"
label values visitor _visitor 
label var visitor "Visitor (Y / N)" 
drop P_VIS 
order visitor, after(did) 

* ! P_COMPLNT 
* ! Currently held at end of dataset
label var P_COMPLNT "Patient complaint at presentation"

**  P_ASSCAT 
** Canadian Triage and Assessment Scale
gen ctas = . 
replace ctas = 1 if P_ASSCAT == "1"
replace ctas = 2 if P_ASSCAT == "2"
replace ctas = 3 if P_ASSCAT == "3"
replace ctas = 4 if P_ASSCAT == "4"
replace ctas = 5 if P_ASSCAT == "5"
label define _ctas 1 "non-urgent" 2 "less urgent" 3 "urgent" 4 "emergent" 5 "resuscitation" 
label values ctas _ctas 
label var ctas "Canadian Triage and Assessment Scale (CTAS)"
order ctas, after(amode)

** P_TAREA 
** Treatment area - THREE areas defined 
gen tarea = . 
replace tarea = 1 if P_TAREA == "T"
replace tarea = 2 if P_TAREA == "N"
replace tarea = 3 if P_TAREA == "A"
label define _tarea 1 "Trauma" 2 "Non-trauma" 3 "Asthma bay" 
label values tarea _tarea 
label var tarea "Patient treatment area"
order tarea, after(ctas)

** P_RDIAG - triage time 
** Not clean in received dataset. Have dealt with problems for now
** But something to explore in primary database 
gen hr_temp = substr(P_RDIAG,1,2)
gen min_temp = substr(P_RDIAG,-2,.)
gen tot_hr = real(hr_temp)
gen tot_min = real(min_temp)
gen tot1 = string(tot_hr)
gen tot2 = string(tot_min)
gen tot3 = tot1 + ":" + tot2
ntimeofday tot3, gen(tot) s(h mi) n(hour) parse(:)
label var tot "Time of triage as numeric (24-hr clock)" 
label var tot_hr "Hour of triage (24-hr clock)"
label var tot_min "Minute of triage (24-hr clock)"
order tot tot_hr tot_min , after(tarea)
drop hr_temp min_temp tot1 tot2 tot3

** P_REF 
** Source of referral
encode P_REF, gen(rsource)
#delimit ; 
label define _rsource   15 "none" 
                        30 "winston scott pc"
                        4 "edgar cochrane pc"
                        19 "private doctor"
                        32 "warrens pc" 
                        22 "randall phillips pc" 
                        26 "st jogn pc"
                        6 "fmh clinic"
                        7 "fast track"
                        8 "geriatric hospital" 
                        10 "glebe pc" 
                        11 "horse hill clinic"
                        14 "maurice byer pc"
                        24 "sandy lane medical centre"
                        25 "cruise ship"
                        31 "six roads pc";
#delimit cr                        
label values rsource _rsource
label var rsource "source of referral"
label var P_REF "source of referral"
order rsource P_REF , after(tot_min) 


** PTGROUP
** According to presenting complaint 
* ! Coded specialties - but have not coded them for now
* ! Probably not needed for initial analyses
* ! Ask for categories for completeness?
encode PTGROUP, gen(pgroup) 
label var pgroup "According to presenting complaint"
label var PTGROUP "According to presenting complaint"
order pgroup PTGROUP, after(P_REF) 

** P_SDATE
** Date the patient was seen
** Roughly the same as doa - date of arrival
** Presumably is mostly the same date, but sometimes a day later?? 
rename P_SDATE doc 
label var doc "Date of consultation - Date patient was seen"
order doc, after(PTGROUP) 

** P_EPTIME
** Time the patient was seen 
ntimeofday P_EPTIME, gen(toc) s(h mi) n(hour) parse(:)
split P_EPTIME, parse(:) gen(toc_)
gen toc_hr = real(toc_1)
gen toc_min = real(toc_2) 
label var toc "Time patient seen as numeric (24-hr clock)" 
label var toc_hr "Hour patient seen (24-hr clock)"
label var toc_min "Minute patient seen"
order toc toc_hr toc_min, after(doc)

** P_DOCTOR 
** Attending Doctor 
* ! Is this of interest - need INITIALS defined
rename P_DOCTOR doctor 
label var doctor "Attending doctor" 
order doctor, after(toc_min)

** P_CDATE 
** Consultation request date
rename P_CDATE docon
label var docon "Date of consultation request"
order docon , after(doctor)

** P_CTIME 
** Consultation request time
ntimeofday P_CTIME, gen(tocon) s(h mi) n(hour) parse(:)
split P_CTIME, parse(:) gen(tocon_)
gen tocon_hr = real(tocon_1)
gen tocon_min = real(tocon_2) 
label var tocon "Time of consultation request as numeric (24-hr clock)" 
label var tocon_hr "Hour of consultation request (24-hr clock)"
label var tocon_min "Minute of consultation request"
order tocon tocon_hr tocon_min, after(docon)

** P_CSPEC
** Referral specialty
* ! One or two categories still required 
encode P_CSPEC, gen(rspec) 
replace rspec = . if rspec==1 
#delimit ;
label define _rspec 2 "cardiology"
                    3 "CS"
                    4 "dermatology"
                    5 "ENT"
                    6 "GAST"
                    7 "general surgery"
                    8 "haematology"
                    9 "internal medicine"
                    10 "nephrology"
                    11 "no consultation"
                    12 "neurosurgery"
                    13 "neurology"
                    14 "obs and gynae"
                    15 "OP"
                    16 "orthopaedics"
                    17 "paediatrics"
                    18 "PLAS"
                    19 "PS"
                    20 "psychiatry"
                    21 "radiotherapy"
                    22 "RESrespiratory"
                    23 "urology";
#delimit cr 
label var P_CSPEC "source of referral"
label var rspec "source of referral"
order rspec P_CSPEC, after(tocon_min)  

** P_LAB / P_SOCIAL P_XRAY 
label define _yesno 0 "no" 1 "yes"
gen req_lab = . 
replace req_lab = 0 if P_LAB=="N"
replace req_lab = 1 if P_LAB=="Y"
label values req_lab _yesno
gen req_social = . 
replace req_social = 0 if P_SOCIAL=="N"
replace req_social = 1 if P_SOCIAL=="Y"
label values req_social _yesno
gen req_xray = . 
replace req_xray = 0 if P_XRAY=="N"
replace req_xray = 1 if P_XRAY=="Y"
label values req_xray _yesno
order req_lab req_social req_xray , after(P_CSPEC)
label var req_lab "Laboratory test requested"
label var req_social "Social services requested"
label var req_lab "x-ray requested"

** P_FDIAG 
** Patient final diagnosis text 
* ! Suspect that we may not need this. 
* ! Currently kept at end of dataset
label var P_FDIAG "Patient final diagnosis: text description"

** P_DISPO
** Patient final disposition
* ! Need a few more categories 
encode P_DISPO , gen(disposition)
#delimit ; 
label define _disposition   1 "ward a1"
                            2 "ward a2"
                            3 "ward a3"
                            4 "ward a5"
                            5 "ward a6"
                            6 "ward b1"
                            7 "ward b2"
                            8 "ward b3"
                            9 "ward b4"
                            10 "ward b5"
                            11 "ward b6"
                            12 "ward b7"
                            13 "ward b8"
                            14 "ward c10"
                            15 "ward c12"
                            16 "ward c2"
                            17 "ward c3"
                            18 "ward c4"
                            19 "ward c5"
                            20 "ward c6"
                            21 "ward c7"
                            22 "ward c8"
                            23 "ward c9"
                            24 "AHDU"
                            25 "AICU"
                            26 "labour ward"
                            27 "medical ICU"
                            28 "ANICU"
                            29 "operating theatre"
                            30 "paediatric ICU"
                            31 "ARR"
                            32 "ASICU"
                            33 "discharged"
                            34 "DFC"
                            35 "DH"
                            36 "died"
                            37 "discharged to labour ward"
                            38 "DOA"
                            39 "DPC"
                            40 "DPD"
                            41 "FT"
                            42 "GH"
                            43 "left against med advise"
                            44 "left w/o treatment"
                            45 "OPD"
                            46 "sent to psych hosp"
; 
#delimit cr 
label values disposition _disposition 
label var disposition "Final patient disposition"
label var P_DISPO "Final patient disposition"
order disposition P_DISPO , after(req_xray)

** P_DDATE 
** Discharge date
rename P_DDATE dod
label var dod "Date of discharge"
order dod , after(P_DISPO)

** P_DTIME 
** Discharge time
gen hr_temp = substr(P_DTIME,1,2)
gen min_temp = substr(P_DTIME,-2,.)
gen tod_hr = real(hr_temp)
gen tod_min = real(min_temp)
gen tod1 = string(tod_hr)
gen tod2 = string(tod_min)
gen tod3 = tod1 + ":" + tod2
ntimeofday tod3, gen(tod) s(h mi) n(hour) parse(:)
label var tod "Time of discharge as numeric (24-hr clock)" 
label var tod_hr "Hour of discharge (24-hr clock)"
label var tod_min "Minute of discharge"
order tod tod_hr tod_min , after(dod)
drop hr_temp min_temp tod1 tod2 tod3

** P_RDATE 
** Consultation response date
rename P_RDATE docr
label var docr "Date of consultation response"
order docr , after(tod_min)

** P_RTIME 
** Consultation response time
ntimeofday P_RTIME, gen(tocr) s(h mi) n(hour) parse(:)
split P_RTIME, parse(:) gen(tocr_)
gen tocr_hr = real(tocr_1)
gen tocr_min = real(tocr_2) 
label var tocr "Time of consultation reponse as numeric (24-hr clock)" 
label var tocr_hr "Hour of consultation reponse (24-hr clock)"
label var tocr_min "Minute of consultation reponse"
order tocr tocr_hr tocr_min, after(docr)

* ! DIAG CODES - need definitions 
* ! 1st diagnostic codes - need category definitions - but probably not needed for now. 
* ! 2nd diagnostic code mostly empty - dropped at end of DO file
rename DIAGCODE1 dcode1 
label var dcode1 "Diagnostic code 1" 
rename DIAGCODE2 dcode2 
label var dcode2 "Diagnostic code 2" 

* ! ACODE3 looks to be the main variable used - ICD10-CM
* ! but they ALL have 25% or greater complete
* ! So - multiple codes assigned to individuals.
rename ANATCODE1 acode1 
label var acode1 "Anatomical code 1" 
rename ANATCODE2 acode2 
label var acode2 "Anatomical code 2" 
rename ANATCODE3 acode3 
label var acode3 "Anatomical code 3 - ICD10-CM ?" 
rename ICD icd 
label var icd "ICD - maybe not used?"
order dcode1 dcode2 acode1 acode2 acode3 icd, after(tocr_min)

** VARIABLES UNLIKELY TO BE NEEDED
** P_ROOM       Room assignment (very sparse)
** P_NURSE      Attending nurse (very sparse)
** P_WAIT 
** P_ELOPE 
** P_OVER 
** DIAGCODE2 
drop P_ROOM P_NURSE P_WAIT P_ELOPE P_OVER dcode2

** Save the dataset
drop P_AGETYPE P_SEX P_PARISH P_ATIME P_AMODE P_ASSCAT P_TAREA P_RDIAG P_EPTIME P_CTIME P_DTIME P_RTIME
drop P_LAB P_SOCIAL P_XRAY 
drop toa_* toc_* tocon_* tocr_*
order P_COMPLNT P_FDIAG , last
label data "QEH Injury data: 2016"
save "`datapath'\version01\2-working\qeh_injury_2016", replace 
