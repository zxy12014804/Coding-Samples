
* ----------------------------------------
* ########################################
* 
* CODING SAMPLE: GOVERNMENT RESPONSE AND LEARNING DURING A PANDEMIC
* 
* 09/2022
* Script by Xiaoyang Zhang
*
* Introduction: An excerpt from the script I wrote for my undergraduate thesis
* 
* ########################################
* ----------------------------------------

clear all
cap log close
set more off

* ----------------------------------------
* ########################################
* PREPARATIONS
* ########################################
* ----------------------------------------

* ----------------------------------------
* Path and data import setup
* ----------------------------------------

global datadir ... // Put data path here
cd "${datadir}"

// Import foreign cases data
import delimited "foreign_cases/df_concat.csv", colr(2) clear
duplicates drop regionname year month day, force

// Merge with all cases data
merge 1:1 regionname year month day using "oxcgrt_china.dta"
drop if _merge == 1
drop _merge
order fcases, after(newcases)
replace fcases = 0 if fcases == .
drop if regionname == ""

gen date_code = mdy(month, day, year), after(day)
gen date = date_code, after(date_code)
format date %td

encode regionname, generate(region_code)
order region_code, after(regionname)

sort region_code date_code

* ----------------------------------------
* Main variable construction
* ----------------------------------------

// New domestic cases
gen newcases_dom = newcases - fcases, after(fcases)

// Graph of daily new cases
preserve
collapse (sum) newcases_dom, by(date)
twoway (line newcases_dom date, sort pstyle(p3)), ///
	xtitle("Date") ///
	ytitle("Total # of new cases") ///
	scheme(s1color)
restore

// Logged stringency index
gen ln_SI = ln(1+stringencyindex), after(stringencyindex)

// Define outbreak
gen outbreak = ( ///
				(newcases_dom[_n-14] ~= 0 & regionname[_n-14] == regionname) | ///
				(newcases_dom[_n-13] ~= 0 & regionname[_n-13] == regionname) | ///
				(newcases_dom[_n-12] ~= 0 & regionname[_n-12] == regionname) | ///
				(newcases_dom[_n-11] ~= 0 & regionname[_n-11] == regionname) | ///
				(newcases_dom[_n-10] ~= 0 & regionname[_n-10] == regionname) | ///
				(newcases_dom[_n-9] ~= 0 & regionname[_n-9] == regionname) | ///
				(newcases_dom[_n-8] ~= 0 & regionname[_n-8] == regionname) | ///
				(newcases_dom[_n-7] ~= 0 & regionname[_n-7] == regionname) | ///
				(newcases_dom[_n-6] ~= 0 & regionname[_n-6] == regionname) | ///
				(newcases_dom[_n-5] ~= 0 & regionname[_n-5] == regionname) | ///
				(newcases_dom[_n-4] ~= 0 & regionname[_n-4] == regionname) | ///
				(newcases_dom[_n-3] ~= 0 & regionname[_n-3] == regionname) | ///
				(newcases_dom[_n-2] ~= 0 & regionname[_n-2] == regionname) | ///
				(newcases_dom[_n-1] ~= 0 & regionname[_n-1] == regionname) | ///
				newcases_dom ~= 0)
replace outbreak = 0 if newcases_dom == .

// Population for provinces
gen population = 0, after(stringencyindex) // 万人单位
replace population = 2189.31 if regionname == "Beijing"
replace population = 2487.09 if regionname == "Shanghai"
replace population = 8474.80 if regionname == "Jiangsu"
replace population = 4154.01 if regionname == "Fujian"
replace population = 1386.60 if regionname == "Tianjin"
replace population = 6456.76 if regionname == "Zhejiang"
replace population = 12601.25 if regionname == "Guangdong"
replace population = 3205.42 if regionname == "Chongqing"
replace population = 5775.26 if regionname == "Hubei"
replace population = 2404.92 if regionname == "Inner Mongolia"
replace population = 10152.75 if regionname == "Shandong"
replace population = 3952.90 if regionname == "Shaanxi"
replace population = 6102.72 if regionname == "Anhui"
replace population = 6644.49 if regionname == "Hunan"
replace population = 4259.14 if regionname == "Liaoning"
replace population = 8367.49 if regionname == "Sichuan"
replace population = 4518.86 if regionname == "Jiangxi"
replace population = 9936.55 if regionname == "Henan"
replace population = 1008.12 if regionname == "Hainan"
replace population = 720.27 if regionname == "Ningxia"
replace population = 2585.23 if regionname == "Xinjiang"
replace population = 364.81 if regionname == "Tibet"
replace population = 4720.93 if regionname == "Yunnan"
replace population = 2407.35 if regionname == "Jilin"
replace population = 592.40 if regionname == "Qinghai"
replace population = 3491.56 if regionname == "Shanxi"
replace population = 7461.02 if regionname == "Hebei"
replace population = 3856.21 if regionname == "Guizhou"
replace population = 5012.68 if regionname == "Guangxi"
replace population = 3185.01 if regionname == "Heilongjiang"
replace population = 2501.98 if regionname == "Gansu"

// GDP per capita for provincees
gen gdppc = 0, after(population) // 单位元
replace gdppc = 164904 if regionname == "Beijing"
replace gdppc = 155606 if regionname == "Shanghai"
replace gdppc = 121205 if regionname == "Jiangsu"
replace gdppc = 105690 if regionname == "Fujian"
replace gdppc = 101570 if regionname == "Tianjin"
replace gdppc = 100070 if regionname == "Zhejiang"
replace gdppc = 87897 if regionname == "Guangdong"
replace gdppc = 78002 if regionname == "Chongqing"
replace gdppc = 75223 if regionname == "Hubei"
replace gdppc = 72185 if regionname == "Inner Mongolia"
replace gdppc = 72029 if regionname == "Shandong"
replace gdppc = 66235 if regionname == "Shaanxi"
replace gdppc = 63383 if regionname == "Anhui"
replace gdppc = 62881 if regionname == "Hunan"
replace gdppc = 58967 if regionname == "Liaoning"
replace gdppc = 58081 if regionname == "Sichuan"
replace gdppc = 56854 if regionname == "Jiangxi"
replace gdppc = 55348 if regionname == "Henan"
replace gdppc = 54878 if regionname == "Hainan"
replace gdppc = 54432 if regionname == "Ningxia"
replace gdppc = 53371 if regionname == "Xinjiang"
replace gdppc = 52157 if regionname == "Tibet"
replace gdppc = 51943 if regionname == "Yunnan"
replace gdppc = 51141 if regionname == "Jilin"
replace gdppc = 50742 if regionname == "Qinghai"
replace gdppc = 50556 if regionname == "Shanxi"
replace gdppc = 48528 if regionname == "Hebei"
replace gdppc = 46228 if regionname == "Guizhou"
replace gdppc = 44201 if regionname == "Guangxi"
replace gdppc = 43009 if regionname == "Heilongjiang"
replace gdppc = 36038 if regionname == "Gansu"

// Define first outbreak for each province
egen outbreak_first = min(cond(outbreak == 1, date_code, .)), by(region_code)
order outbreak_first, after(outbreak)
replace outbreak_first = 0 if outbreak == 0
replace outbreak_first = 0 if date_code ~= outbreak_first
replace outbreak_first = 1 if outbreak_first > 0
replace outbreak_first = 1 if outbreak == 1 & outbreak_first[_n-1] == 1

drop if outbreak_first == 1
drop outbreak_first

egen outbreak_first = min(cond(outbreak == 1, date_code, .)), by(region_code)
order outbreak_first, after(outbreak)
replace outbreak_first = 0 if outbreak == 0
replace outbreak_first = 0 if date_code ~= outbreak_first
replace outbreak_first = 1 if outbreak_first > 0
replace outbreak_first = 1 if outbreak == 1 & outbreak_first[_n-1] == 1
replace outbreak_first = 1 if outbreak_first == 0 & outbreak_first[_n+7] == 1 & regionname[_n+7] == regionname


// Event study variable
gen D_covid = ., after(outbreak_first)
forval i = -7/14 {
	replace D_covid = `i' if outbreak[_n-`i'-1] == 0 & outbreak[_n-`i'] == 1 & regionname[_n-`i'-1] == regionname
}
forval i = 0/14 {
	replace D_covid = `i' if regionname[_n-`i'-1] ~= regionname[_n-`i'] & outbreak_first[_n-`i'] == 1
}
replace D_covid = D_covid + 8

// Second outbreak variable
gen outbreak_2 = date_code if D_covid < D_covid[_n-1], after(outbreak_first)
replace outbreak_2 = outbreak_2[_n-1] if D_covid == D_covid[_n-1] + 1
tostring outbreak_2, replace
replace outbreak_2 = "" if outbreak_2 == "."

gen op_code = "", after(outbreak_2)
forval i = 1/31 {
	replace op_code = "`i'_" + outbreak_2 if region_code == `i'
}
drop outbreak_2


* ----------------------------------------
* ########################################
* DESCRIPTIVE ANALYSIS
* ########################################
* ----------------------------------------

cd "tables&figures"

* ----------------------------------------
* Summary stats tables
* ----------------------------------------

foreach var of varlist stringencyindex population gdppc outbreak {
	bysort regionname: ///
		asdoc su `var', ///
		dec(3) ///
		save(sum_stats_`var'.doc), replace
}

bysort regionname: asdoc su stringencyindex if D_covid ~= ., ///
	dec(3) ///
	save(sum_stats_SI_post.doc), replace

// Define outbreak order
drop if D_covid == .
drop outbreak_order

gen outbreak_order = 1, after(outbreak_first)
replace outbreak_order = outbreak_order[_n-1] + (region_code == region_code[_n-1] & D_covid ~= D_covid[_n-1] + 1) if (regionname ~= "Anhui" | date_code ~= 22042) & regionname == regionname[_n-1]


* ----------------------------------------
* Descriptive graphs
* ----------------------------------------

gen monthly = ym(year, month), after(date_code)
format monthly %tm

// Start date of all outbreaks
preserve
gen outbreak_count = (D_covid == 8)
collapse (sum) outbreak_count, by(monthly)
twoway (bar outbreak_count monthly, pstyle(p3)), ///
	xtitle("Date") ///
	ytitle("# of outbreaks (excluding first outbreak in each province)") ///
	scheme(s1color)
restore

// Time distribution of first outbreak across provinces
preserve
gen outbreak_count = (D_covid == 8 & outbreak_first == 1)
collapse (sum) outbreak_count, by(monthly)
twoway (bar outbreak_count monthly, pstyle(3)), ///
	xtitle("Date") ///
	ytitle("# of outbreaks (excluding first outbreak in each province)") ///
	scheme(s1color)
restore

// Distribution of # of new cases on first day of outbreak
hist newcases_dom if D_covid == 8, ///
	frac width(1) pstyle(p3) ///
	xtitle("# of new cases") ///
	ytitle("Fraction of observations") ///
	scheme(s1color)

// Distribution of duration of outbreaks
preserve
gen outbreak_2 = date_code if outbreak == 1 & outbreak[_n-1] == 0, after(outbreak_first)
replace outbreak_2 = outbreak_2[_n-1] if outbreak == 1 & outbreak[_n-1] == 1
tostring outbreak_2, replace
replace outbreak_2 = "" if outbreak_2 == "."

gen outbreak_code = "", after(outbreak_2)
forval i = 1/31 {
	replace outbreak_code = "`i'_" + outbreak_2 if region_code == `i' & outbreak == 1
}
drop outbreak_2

gen duration = 1 if outbreak == 1
drop if outbreak == 0
collapse (mean) region_code (sum) duration, by(outbreak_code)
hist duration, ///
	frac width(10) pstyle(p3) ///
	scheme(s1color)
restore

// Max # of new cases for each outbreak
preserve
gen outbreak_2 = date_code if outbreak == 1 & outbreak[_n-1] == 0, after(outbreak_first)
replace outbreak_2 = outbreak_2[_n-1] if outbreak == 1 & outbreak[_n-1] == 1
tostring outbreak_2, replace
replace outbreak_2 = "" if outbreak_2 == "."

gen outbreak_code = "", after(outbreak_2)
forval i = 1/31 {
	replace outbreak_code = "`i'_" + outbreak_2 if region_code == `i' & outbreak == 1
}
drop outbreak_2

gen duration = 1 if outbreak == 1
drop if outbreak == 0
collapse (mean) region_code (max) newcases_dom, by(outbreak_code)
hist newcases_dom, ///
	frac width(5) pstyle(p3) ///
	xlabel(0(20)120) ///
	xtitle("Maximum # of new cases") ///
	ytitle("Fraction of observations") ///
	scheme(s1color)
restore

// National COVID trend
preserve
collapse (sum) newcases_dom, by(date)
twoway (line newcases_dom date, sort pstyle(p3)), ///
	xtitle("Date") ///
	ytitle("Total # of new cases") ///
	scheme(s1color)
restore


* ----------------------------------------
* ########################################
* ECONOMETRIC STRATEGIES
* ########################################
* ----------------------------------------

* ----------------------------------------
* Government response: 2*2 DID & event study
* ----------------------------------------

cd "tables&figures"

// DID
gen D_post = (D_covid >= 8), after(D_covid)

qui reghdfe ln_SI D_post if D_covid ~= ., absorb(region_code) vce(cluster region_code) // 无control，只有region FE
outreg2 using "part1_DID.xls", replace
qui reghdfe ln_SI D_post if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code) // 无control，有两个FE
outreg2 using "part1_DID.xls", append
qui reghdfe ln_SI D_post newcases_dom if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code) // 都加上
outreg2 using "part1_DID.xls", append

// Event study
qui reghdfe ln_SI ib7.D_covid newcases_dom if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code)

coefplot, omitted ///
	drop(0.D_covid newcases_dom _cons) ///
	baselevels ///
	vertical yline(0, lcolor(cranberry) lwidth(thin)) ///
	xline(7, lcolor(cranberry) lwidth(thin)) ///
	msize(vsmall) ///
	coeflabels( ///
	1.D_covid = "-7" ///
	2.D_covid = "-6" ///
	3.D_covid = "-5" ///
	4.D_covid = "-4" ///
	5.D_covid = "-3" ///
	6.D_covid = "-2" ///
	7.D_covid = "-1" ///
	8.D_covid = "0" ///
	9.D_covid = "1" ///
	10.D_covid = "2" ///
	11.D_covid = "3" ///
	12.D_covid = "4" ///
	13.D_covid = "5" ///
	14.D_covid = "6" ///
	15.D_covid = "7" ///
	16.D_covid = "8" ///
	17.D_covid = "9" ///
	18.D_covid = "10" ///
	19.D_covid = "11" ///
	20.D_covid = "12" ///
	21.D_covid = "13" ///
	22.D_covid = "14" ///
	) ///
	xtitle("Days from outbreak") ///
	ytitle("Percentage change in SI") ///
	levels(95) ///
	scheme(s1color) ///
	pstyle(p3) ///
	ciopts(recast(rcap) msize(small))


* ----------------------------------------
* Stringency learning: 2*2 DID and event study
* ----------------------------------------

cd "tables&figures"

gen order_early = (outbreak_order <= 1), after(outbreak_order)
gen D_covid_early = D_covid * order_early, after(D_covid)
gen D_covid_later = D_covid * (1 - order_early), after(D_covid_early)

// DID
gen D_post_first = D_post * order_early, after(D_post)

qui reghdfe ln_SI D_post_first D_post if D_covid ~= ., absorb(region_code) vce(cluster region_code)
outreg2 using "part1_first.xls", replace
qui reghdfe ln_SI D_post_first D_post if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code)
outreg2 using "part1_first.xls", append
qui reghdfe ln_SI D_post_first D_post newcases_dom if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code)
est store p_baseline
outreg2 using "part1_first.xls", append

// Robustness: dropping provinces
forval i = 1/31 {
	preserve
	gen D_post_first_`i' = D_post_first, after(D_post_first)
	qui reghdfe ln_SI D_post_first_`i' D_post newcases_dom if D_covid ~= . & region_code ~= `i', absorb(region_code date_code) vce(cluster region_code)
	est store p_`i'
	restore
}

coefplot ///
	(p_baseline) ///
	(p_1) ///
	(p_2) ///
	(p_3) ///
	(p_4) ///
	(p_5) ///
	(p_6) ///
	(p_7) ///
	(p_8) ///
	(p_9) ///
	(p_10) ///
	(p_11) ///
	(p_12) ///
	(p_13) ///
	(p_14) ///
	(p_15) ///
	(p_16) ///
	(p_17) ///
	(p_18) ///
	(p_19) ///
	(p_20) ///
	(p_21) ///
	(p_22) ///
	(p_23) ///
	(p_24) ///
	(p_25) ///
	(p_26) ///
	(p_27) ///
	(p_29) ///
	(p_30) ///
	(p_31), ///
	pstyle(p3) ///
	drop(D_post newcases_dom _cons) ///
	baselevels vertical yline(0, lwidth(vthin)) ///
	msize(vsmall) ///
	coeflabels( ///
	D_post_first = "National" ///
	D_post_first_1 = "Anhui" ///
	D_post_first_2 = "Beijing" ///
	D_post_first_3 = "Chongqing" ///
	D_post_first_4 = "Fujian" ///
	D_post_first_5 = "Gansu" ///
	D_post_first_6 = "Guangdong" ///
	D_post_first_7 = "Guangxi" ///
	D_post_first_8 = "Guizhou" ///
	D_post_first_9 = "Hainan" ///
	D_post_first_10 = "Hebei" ///
	D_post_first_11 = "Heilongjiang" ///
	D_post_first_12 = "Henan" ///
	D_post_first_13 = "Hubei" ///
	D_post_first_14 = "Hunan" ///
	D_post_first_15 = "Neimenggu" ///
	D_post_first_16 = "Jiangsu" ///
	D_post_first_17 = "Jiangxi" ///
	D_post_first_18 = "Jilin" ///
	D_post_first_19 = "Liaoning" ///
	D_post_first_20 = "Ningxia" ///
	D_post_first_21 = "Qinghai" ///
	D_post_first_22 = "Shaanxi" ///
	D_post_first_23 = "Shandong" ///
	D_post_first_24 = "Shanghai" ///
	D_post_first_25 = "Shanxi" ///
	D_post_first_26 = "Sichuan" ///
	D_post_first_27 = "Tianjin" ///
	D_post_first_29 = "Xinjiang" ///
	D_post_first_30 = "Yunnan" ///
	D_post_first_31 = "Zhejiang", ///
	angle(vertical)) ///
	xtitle("Province") ///
	ytitle("Coefficient") ///
	legend(off) ///
	levels(95) ///
	scheme(s1color) ///
	ciopts(recast(rcap) msize(small))

// Event study
preserve
gen D_covid_test = D_covid_early, after(D_covid_early)
qui reghdfe ln_SI ib7.D_covid_test ib7.D_covid_later newcases_dom if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code)
est store fearly
restore

preserve
gen D_covid_test = D_covid_later, after(D_covid_later)
qui reghdfe ln_SI ib7.D_covid_early ib7.D_covid_test newcases_dom if D_covid ~= ., absorb(region_code date_code) vce(cluster region_code)
est store flater
restore

coefplot (fearly, label(The first outbreak) pstyle(p1)) (flater, label(Subsequent outbreaks) pstyle(p2)), ///
	omitted ///
	keep( ///
	1.D_covid_test 2.D_covid_test 3.D_covid_test ///
	4.D_covid_test 5.D_covid_test 6.D_covid_test 7.D_covid_test ///
	8.D_covid_test 9.D_covid_test 10.D_covid_test 11.D_covid_test ///
	12.D_covid_test 13.D_covid_test 14.D_covid_test 15.D_covid_test ///
	16.D_covid_test 17.D_covid_test 18.D_covid_test 19.D_covid_test ///
	20.D_covid_test 21.D_covid_test 22.D_covid_test ///
	) ///
	baselevels ///
	vertical yline(0, lwidth(vthin)) ///
	xline(7, lcolor(cranberry) lwidth(thin)) ///
	msize(vsmall) ///
	coeflabels( ///
	1.D_covid_test = "-7" ///
	2.D_covid_test = "-6" ///
	3.D_covid_test = "-5" ///
	4.D_covid_test = "-4" ///
	5.D_covid_test = "-3" ///
	6.D_covid_test = "-2" ///
	7.D_covid_test = "-1" ///
	8.D_covid_test = "0" ///
	9.D_covid_test = "1" ///
	10.D_covid_test = "2" ///
	11.D_covid_test = "3" ///
	12.D_covid_test = "4" ///
	13.D_covid_test = "5" ///
	14.D_covid_test = "6" ///
	15.D_covid_test = "7" ///
	16.D_covid_test = "8" ///
	17.D_covid_test = "9" ///
	18.D_covid_test = "10" ///
	19.D_covid_test = "11" ///
	20.D_covid_test = "12" ///
	21.D_covid_test = "13" ///
	22.D_covid_test = "14" ///
	) ///
	xtitle("Days from outbreak") ///
	ytitle("Percentage change in SI") ///
	legend(ring(0) bplacement(nwest) col(1)) ///
	levels(95) ///
	scheme(s1color) ///
	ciopts(recast(rcap rcap) msize(small medium))

// Difference between first and subsequent outbreaks
qui reghdfe ln_SI ib7.D_covid_early ib7.D_covid newcases_dom, absorb(outbreak_order region_code date_code) vce(cluster region_code)

coefplot, omitted ///
	drop(0.D_covid_early *.D_covid newcases_dom _cons) ///
	baselevels ///
	vertical yline(0, lcolor(cranberry) lwidth(thin)) ///
	xline(7, lcolor(cranberry) lwidth(thin)) ///
	msize(vsmall) ///
	coeflabels( ///
	1.D_covid_early = "-7" ///
	2.D_covid_early = "-6" ///
	3.D_covid_early = "-5" ///
	4.D_covid_early = "-4" ///
	5.D_covid_early = "-3" ///
	6.D_covid_early = "-2" ///
	7.D_covid_early = "-1" ///
	8.D_covid_early = "0" ///
	9.D_covid_early = "1" ///
	10.D_covid_early = "2" ///
	11.D_covid_early = "3" ///
	12.D_covid_early = "4" ///
	13.D_covid_early = "5" ///
	14.D_covid_early = "6" ///
	15.D_covid_early = "7" ///
	16.D_covid_early = "8" ///
	17.D_covid_early = "9" ///
	18.D_covid_early = "10" ///
	19.D_covid_early = "11" ///
	20.D_covid_early = "12" ///
	21.D_covid_early = "13" ///
	22.D_covid_early = "14" ///
	) ///
	xtitle("Days from outbreak") ///
	ytitle("Difference in SI increase (first - subsequent)") ///
	levels(95 90) ///
	scheme(s1color) ///
	pstyle(p3) ///
	ciopts(recast(rcap rcap) msize(small medium))


// GDP per capita heterogeneity
qui reghdfe ln_SI ib7.D_covid_early ib7.D_covid newcases_dom if gdppc >= 58000, absorb(region_code date_code) vce(cluster region_code)
est store fhigh
qui reghdfe ln_SI ib7.D_covid_early ib7.D_covid newcases_dom if gdppc < 58000, absorb(region_code date_code) vce(cluster region_code)
est store flow

coefplot (fhigh, label(Above-median GDP per capita) pstyle(p1)) (flow, label(Below-median GDP per capita) pstyle(p7)), ///
	omitted ///
	drop(0.D_covid_early *.D_covid newcases_dom _cons) ///
	baselevels ///
	vertical yline(0, lwidth(vthin)) ///
	xline(7, lcolor(cranberry) lwidth(thin)) ///
	msize(vsmall) ///
	coeflabels( ///
	1.D_covid_early = "-7" ///
	2.D_covid_early = "-6" ///
	3.D_covid_early = "-5" ///
	4.D_covid_early = "-4" ///
	5.D_covid_early = "-3" ///
	6.D_covid_early = "-2" ///
	7.D_covid_early = "-1" ///
	8.D_covid_early = "0" ///
	9.D_covid_early = "1" ///
	10.D_covid_early = "2" ///
	11.D_covid_early = "3" ///
	12.D_covid_early = "4" ///
	13.D_covid_early = "5" ///
	14.D_covid_early = "6" ///
	15.D_covid_early = "7" ///
	16.D_covid_early = "8" ///
	17.D_covid_early = "9" ///
	18.D_covid_early = "10" ///
	19.D_covid_early = "11" ///
	20.D_covid_early = "12" ///
	21.D_covid_early = "13" ///
	22.D_covid_early = "14" ///
	) ///
	xtitle("Days from outbreak") ///
	ytitle("Difference in SI increase (first - subsequent)") ///
	legend(ring(0) bplacement(nwest) col(1)) ///
	levels(95 90) ///
	scheme(s1color) ///
	ciopts(recast(rcap rcap) msize(small medium))

// Supplementary descriptive evidence on heterogeneity
twoway (scatter ln_SI date if gdppc >= 58000 & date_code >=21950, msize(tiny)) ///
	   (scatter ln_SI date if gdppc < 58000 & date_code >=21950, msize(tiny))

twoway (scatter ln_SI date if gdppc >= 58000 & date_code >=21950, msize(tiny) mcolor(%3) pstyle(p1)) ///
	   (scatter ln_SI date if gdppc < 58000 & date_code >=21950, msize(tiny) mcolor(%3) pstyle(p2)) ///
	   (lfitci ln_SI date if gdppc >= 58000 & date_code >=21950, lwidth(medium) acolor(%30) pstyle(p1)) ///
	   (lfitci ln_SI date if gdppc < 58000 & date_code >=21950, lwidth(medium) acolor(%30) pstyle(p2)), ///
	   legend(order(4 "Above-median GDP per capita" 6 "Below-median GDP per capita") ring(0) bplacement(nwest) col(1)) ///
	   yscale(range(3.25(0.25)4.75)) ///
	   xtitle("Date") ///
	   ytitle("log(SI)") ///
	   scheme(s1color)

