version 16.1

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/04May2020_eRegQual birth outcomes.dta"
local signature "6367:756(27238):862839612:1580475191"

// Load the data and check its signature is as expected.
use "`fname'", replace
datasignature
assert r(datasignature) == "`signature'"

// Convert the arm variable from string to integer.
encode prettyExposure, generate(arm) label(Arm)
drop prettyExposure

// Convert the stratification variable from string to integer.
encode bookorgdistricthashed, generate(strat_var) label(District)
drop bookorgdistricthashed

// Rename and label the cluster identifier variable.
rename str_TRIAL_1_Cluster clusterid
label variable clusterid Cluster

// The following is temporary. We re-compute the composite outcome and verify
// that we have done so correctly.

// The composite outcome is defined as follows. If:
// * All of the outcomes are false -> composite outcome is false;
// * At least one of the outcomes is true -> composite outcome is true;
// * One or more of the outcomes are missing and all others are false
//   -> composite outcome is missing.

local y1 anemia_at_birth             
local y2 severehypertension_at_birth 
local y3 sga_undetected_at_birth              
local y4 malpres_undetected          
local y5 lga

tempvar all_false
generate `all_false' = (`y1'==0) & (`y2'==0) & (`y3'==0) & (`y4'==0) & (`y5'==0)

tempvar one_true
generate `one_true'  = (`y1'==1) | (`y2'==1) | (`y3'==1) | (`y4'==1) | (`y5'==1)

generate y = .
replace  y = 0 if `all_false'
replace  y = 1 if `one_true'

// Verify that we can correctly recompute the composite outcome.
count if y == TrialOne_adverse_pregoutc
assert r(N) == _N


// NOTE: The above correctly defines the outcome, but it is called
// TrialOne_adverse_pregoutc, not the name specified in the Excel file. Mahima
// sent a new version of that file.
