** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			qeh_injury_prep_combine.do
    //  project:				QEH Injury Dataset. Secondary analysis of available data
    //  analysts:				Ian HAMBLETON
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

use "`datapath'\version01\2-working\qeh_injury_2016", clear
append using "`datapath'\version01\2-working\qeh_injury_2017"
append using "`datapath'\version01\2-working\qeh_injury_2018"
append using "`datapath'\version01\2-working\qeh_injury_2019"

label data "QEH Injury data: 2016 to 2019"
save "`datapath'\version01\2-working\qeh_injury_2016_2019", replace 
