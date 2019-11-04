** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			qeh_injury_001.do
    //  project:				QEH Injury Dataset. Secondary analysis of available data
    //  analysts:				Ian HAMBLETON
    // 	date last modified	    4-NOV-2019
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
    cap log using "`logpath'\qeh_injury_001", replace
** HEADER -----------------------------------------------------

** Import dataset received from Dr Babatunde Oredein
** via Dr Natasha Sobers
** Dataset received: Nov-2019
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

** Time of day 
ntimeofday P_ATIME, gen(toa) s(h mi) n(hour) parse(:)
split P_ATIME, parse(:) gen(toa_)
rename toa_1 toa_hr
rename toa_2 toa_min 
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
order amode, after(toa_min) 


** Unknown variables for now 
label var P_VIS "P_VIS" 

** Save the dataset
drop P_AGETYPE P_SEX P_PARISH P_ATIME P_AMODE
label data "QEH Injury data: 2016"
** save "`datapath'\version01\2-working\qeh_injury_2016", replace 
