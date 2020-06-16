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

  // Reshape to long format. Note that the column uniqueid is not actually
  // unique but identifies women, who can have multiple pregnancies (not
  // twins in this data set). Rows in the wide data frame are pregnancies, so
  // we simply generate a unique pregnancy number for them.
  generate pregnancy = _n
  local stubs opportunity_attendance_ success_attendance_
  reshape long `stubs', i(pregnancy) j(visit)

  // We are interested in relative probability of success.
  local success_label_name = "`: value label success_attendance_'"
  generate y = success_attendance_ == "SUCCESSFUL":`success_label_name'

  encode prettyExposure, generate(arm)
  rename str_TRIAL_1_Cluster clusterid

  xtset pregnancy visit

  // TODO: Move this estimation command elsewhere.
  xtlogit y i.arm, vce(cluster clusterid) or


  // NOTE: The abive will not work because uniqueid is not unique! The
  // unit of observation is pregnancy, so just create a 1, 2, 3, ... column.  

  // TODO: Think about other variable that are important to keep/use.

  // TODO: Look at xtgee for the regression

  // TODO: If you generate an OR for this analysis, switch the birth outcomes
  // to OR, too.

  // TODO: Probably report OR and assumed and corresponding risks.
}
