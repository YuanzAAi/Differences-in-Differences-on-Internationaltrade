cd "C:\Users\86159\Desktop\Junior"
capture log close
log using internetionalTrade, replace
set more off
use data.dta, clear
*描述性统计，并输出到word中
wmtsum using sum.rtf,replace //输出到word
xtset id year
gen lngdp = ln(gdp)
xtreg mirate open edu lngdp,fe vce(cluster province)
est store m1
reghdfe mirate open edu lngdp,absorb(year) vce(cluster province)
est store m2
reghdfe mirate open edu lngdp,absorb(province) vce(cluster province)
est store m3
reghdfe mirate open edu lngdp,absorb(year province) vce(cluster province)
est store m4
estfe m1 m2 m3 m4,labels(year "Year FE" province "Province FE")
wmtreg m1 m2 m3 m4 using Trade.rtf, replace  t(%9.2f) scalars(r2 F N) indicate(`r(indicate_fe)')  title(FE)
*一带一路
gen fightime = (year >=2014)&!missing(year) 
gen affected = 0
replace affected = 1 if (id == 1 | id == 4 | id == 7 | id == 5 | id == 10 | id == 12 | id == 15 | id == 17 | id == 19 | id == 20 | id == 24 | id == 27)
gen did = fightime*affected
xi:xtreg mirate did i.province i.year , vce(cluster province)
est sto d1
xi:xtreg mirate did i.province i.year  edu lngdp , vce(cluster province)
est sto d11
gen Dyear = year - 2014
gen Before3 = (Dyear == -3 & affected == 1)
gen Before2 = (Dyear == -2 & affected == 1)
gen Before1 = (Dyear == -1 & affected == 1)
gen Current = (Dyear == 0 & affected == 1)
gen After1 = (Dyear == 1 & affected == 1)
gen After2 = (Dyear == 2 & affected == 1)
gen After3 = (Dyear == 3 & affected == 1)
reghdfe mirate fightime affected Before3 Before2 Before1 Current After1 After2 After3,absorb(year ) vce(cluster province)
est sto CT2014
coefplot CT2014,keep(Before3 Before2 Before1 Current After1 After2 After3) vertical recast(connect) yline(0)
graph export "C:\Users\86159\Desktop/CT2014.png", replace
*2008年金融危机
replace fightime = (year >=2008)&!missing(year) 
replace did = fightime*affected
xi:xtreg mirate did  i.province i.year , vce(cluster province)
est sto d2
xi:xtreg mirate did  edu lngdp  i.province i.year, vce(cluster province)
est sto d21
replace Dyear = year - 2008
replace Before3 = (Dyear == -3 & affected == 1)
replace Before2 = (Dyear == -2 & affected == 1)
replace Before1 = (Dyear == -1 & affected == 1)
replace Current = (Dyear == 0 & affected == 1)
replace After1 = (Dyear == 1 & affected == 1)
replace After2 = (Dyear == 2 & affected == 1)
replace After3 = (Dyear == 3 & affected == 1)
reghdfe mirate fightime affected Before3 Before2 Before1 Current After1 After2 After3,absorb(year province) vce(cluster province)
est sto CT2008
coefplot CT2008,keep(Before3 Before2 Before1 Current After1 After2 After3) vertical recast(connect) yline(0)
graph export "C:\Users\86159\Desktop/CT2008.png", replace
*2001年加入WTO
replace fightime = (year >=2002)&!missing(year) 
replace did = fightime*affected
xi:xtreg mirate did i.province i.year, vce(cluster province)
est sto d3
xi:xtreg mirate did  edu lngdp  i.province i.year, vce(cluster province)
est sto d31
wmtreg d3 d31 d1 d11 d2 d21 using Trade.rtf, append  keep(did  edu lngdp) t(%9.2f) scalars(r2 F N) indicate("Year FE = *Iyear* " "Province FE = *Iprovince*") title(DID) mgroups(2002 2014 2008 2 2 2)
gen mfmrate = mmale/mfemale
gen open_mfmrate = open*mfmrate
gen mirate_m = mmale/pmale
gen mirate_fe = mfemale/pfemale
reghdfe mirate mfmrate  open_mfmrate open edu lngdp,absorb(year province) vce(cluster province)
est store k1
reghdfe mirate_m open edu lngdp,absorb(year province) vce(cluster province)
est store k2
reghdfe mirate_fe open edu lngdp,absorb(year province) vce(cluster province)
est store k3
estfe k1 k2 k3 ,labels(year "Year FE" province "Province FE")
wmtreg k1 k2 k3  using Trade.rtf, append  t(%9.2f) scalars(r2 F N) indicate(`r(indicate_fe)') title(Heterogeneity) mgroups(m/fe m fe 1 1 1)
log close
exit