version 16.1

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/04May2020_eRegQual birth outcomes.dta"
local signature "6367:756(27238):862839612:1580475191"

frame create original
frame original {
  // Load the data and check its signature is as expected.
  use "`fname'", replace
  datasignature
  assert r(datasignature) == "`signature'"

  // Globals that specify the imputed and regular variables.
  global imputeds
  global regulars

  // Convert the arm variable from string to integer.
  encode prettyExposure, generate(arm)
  label variable arm Arm
  fvset base 1 arm
  global regulars $regulars arm

  // Convert the stratification variable from string to integer.
  encode bookorgdistricthashed, generate(strat_var)
  label variable strat_var District
  fvset base 1 strat_var
  global regulars $regulars strat_var

  // Rename and label the cluster identifier variable.
  rename str_TRIAL_1_Cluster clusterid
  label variable clusterid Cluster
  global regulars $regulars clusterid

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

  // Apply labels to the outcomes.
  label define yes_no_label 0 "No" 1 "Yes"
  label values y* yes_no_label

  // Age.
  replace age = . if age <= 1 // Correct some mis-coded values of the age variable.
  label variable age "Age (years)"
  global imputeds $imputeds age

  // BMI.
  rename bookbmi bmi
  replace bmi = . if bmi < 15 | bmi > 48 // Same policy as for categorical version.
  label variable bmi "Body mass index"
  global imputeds $imputeds bmi

  // Education.
  label variable education "Education (years)"
  global imputeds $imputeds education

  // Income.
  generate log_income = log(avgincome) // Log to approximately normalize.
  label variable log_income "Monthly household income (ILS; log scale)"
  global imputeds $imputeds log_income

  // Lab availability.
  label variable lab_available "Lab available"
  label define lab_available_label 1 "Lab" 0 "No lab"
  label values lab_available lab_available_label
  global regulars $regulars lab_available
  
  // Generate an indicator for whether each woman is primiparous.
  rename bookprimi primiparous
  label variable primiparous   "Parity"
  label define primiparous_label 1 "Primiparous" 0 "Multiparous"
  label values primiparous primiparous_label
  global imputeds $imputeds primiparous
  
  // Compute the cluster size from the trial data. We use the trial data for
  // simplicity and have verified that these agree with the "baseline" data on
  // trial size. We divide by 100 because cluster sizes range from about 10 to
  // about 220, and we want to get regression coefficients that are non-null
  // within two decimal places!
  by clusterid, sort: generate cluster_size = _N / 100
  global regulars $regulars cluster_size

  // Ultrasound available.
  label variable us_available "US available"
  global regulars $regulars us_available

  // Keep only the variables of interest.
  keep y* $imputeds $regulars TrialOne_adverse_pregoutc

  // Verify that all of the regular variables are complete, and that each of the
  // variables to be imputed contain missing values.
  foreach x of global regulars {
    misstable summarize `x'
    assert r(N_lt_dot) == .
  }
  foreach x of varlist y1-y5 $imputeds {
    misstable summarize `x'
    assert r(N_lt_dot) < _N
  }
}
