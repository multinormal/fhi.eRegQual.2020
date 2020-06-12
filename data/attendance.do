version 16.1

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/10June2020_eRegQual process outcomes_attendance.dta"
local signature "6367:38(71787):750205262:160982189"

frame create attendance
frame attendance {
  // Load the data and check its signature is as expected.
  use "`fname'", replace
  datasignature
  assert r(datasignature) == "`signature'"
}
