version 16.1

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/12June2020_eRegQual process outcomes_attendance.dta"
local signature "6367:38(71787):4163979373:2535885136"

frame create attendance
frame attendance {
  // Load the data and check its signature is as expected.
  use "`fname'", replace
  datasignature
  assert r(datasignature) == "`signature'"

  // Reshape to long format. Note that the uniqueid variable is not actually
  // unique but identifies women, who can have multiple pregnancies (but not
  // twins in this data set). Rows in the wide data frame are pregnancies, so
  // we simply generate a unique pregnancy number for each row. We generate a 
  // visit variable, as each woman (pregnancy) may attend clinic multiple times. 
  generate pregnancy = _n
  local stubs opportunity_attendance_ success_attendance_
  reshape long `stubs', i(pregnancy) j(visit)

  // The outcome is successful attendance. While the success_attendance_
  // variable is a factor with three levels, we are only interested in the
  // relative odds of success. The other levels are "NOT SUCCESSFUL" and
  // "NOT APPLICABLE". Not applicable is not of scientific interest here.
  local success_label_name = "`: value label success_attendance_'"
  generate y = success_attendance_ == "SUCCESSFUL":`success_label_name'

  // Encode/rename arm and cluster identifier variables.
  encode prettyExposure, generate(arm)
  rename str_TRIAL_1_Cluster clusterid

  // Convert the stratification variable from string to integer.
  encode bookorgdistricthashed, generate(strat_var)
  label variable strat_var District

  // Keep only the variables of interest.
  keep y arm pregnancy visit clusterid strat_var

  // Label the variables
  label variable y         "Successful attendance"
  label variable arm       "Study arm"
  label variable pregnancy "Pregnancy"
  label variable clusterid "Cluster"

  // There should be no missing data.
  misstable summarize, all
  assert r(N_lt_dot) == _N

  // Set pregnancy as the panel variable and visit at the time variable.
  xtset pregnancy visit

  // TODO: Think about other variable that are important to keep/use.

  // TODO: If you generate an OR for this analysis, switch the birth outcomes
  // to OR, too. Make sure you update the report text if you change the link.

  // TODO: Probably report OR and assumed and corresponding risks.

}
