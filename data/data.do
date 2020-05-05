version 16.1

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/04May2020_eRegQual birth outcomes.dta"
local signature "6367:756(27238):862839612:1580475191"

// Load the data and check its signature is as expected.
use "`fname'", replace
datasignature
assert r(datasignature) == "`signature'"

// Convert the arm variable from string to integer.
encode prettyExposure, generate(arm)
label variable arm Arm
local variables `variables' arm

// Convert the stratification variable from string to integer.
encode bookorgdistricthashed, generate(strat_var)
label variable strat_var District
local variables `variables' strat_var

// Rename and label the cluster identifier variable.
rename str_TRIAL_1_Cluster clusterid
label variable clusterid Cluster
local variables `variables' clusterid

// Rename the components of the composite outcome.
rename anemia_at_birth              y1
label variable                      y1 "Anemia at birth"
rename severehypertension_at_birth  y2
label variable                      y2 "Severe hypertension at birth"
rename sga_undetected_at_birth      y3
label variable                      y3 "SGA undetected at birth"
rename malpres_undetected           y4
label variable                      y4 "Malpresentation undetected at birth"
rename lga                          y5
label variable                      y5 "Large for gestational age"

// The composite outcome is defined as follows. If:
// * All of the outcomes are false -> composite outcome is false;
// * At least one of the outcomes is true -> composite outcome is true;
// * One or more of the outcomes are missing and all others are false
//   -> composite outcome is missing.
tempvar all_false
generate `all_false' = (y1 == 0) & (y2 == 0) & (y3 == 0) & (y4 == 0) & (y5 == 0)

tempvar one_true
generate `one_true'  = (y1 == 1) | (y2 == 1) | (y3 == 1) | (y4 == 1) | (y5 == 1)

generate y = .
replace  y = 0 if `all_false'
replace  y = 1 if `one_true'
label variable y "Adverse pregnancy outcome"

local variables `variables' y*

// Verify that we can correctly recompute the composite outcome.
count if y == TrialOne_adverse_pregoutc
assert r(N) == _N

keep `variables'

