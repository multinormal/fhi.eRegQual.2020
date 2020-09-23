version 16.1

// Load the data and check its signature is as expected.
frame create time
frame time {
  // Import the data and verify its signature.
  use "${fname_time}", replace
  datasignature
  assert r(datasignature) == "${datasignature_time}"

  // Encode/rename arm variable.
  encode exposure, generate(arm)
  label variable arm Arm

  // Encode/rename booking visit variable.
  label variable bookingvisit "Booking visit"
  label define bookingvisit_label 1 "Booking visit" 0 "Non-booking visit"
  label values bookingvisit bookingvisit_label

  // Rename observer variable.
  rename observercode observer

  // Rename cluster identifier variables.
  rename clinicnumber clusterid
  label variable clusterid Cluster

  // Rename the district variable, which was used in stratification.
  rename district strat_var

  // Lab availability.
  label variable lab_available "Lab available"
  label define lab_available_label 1 "Lab" 0 "No lab"
  label values lab_available lab_available_label

  // Compute the cluster size from the trial data. We use the trial data for
  // simplicity and have verified that these agree with the "baseline" data on
  // trial size. We divide by 100 because cluster sizes range from about 10 to
  // about 220, and we want to get regression coefficients that are non-null
  // within two decimal places! Note that cluster size computation must be
  // done before the data set is reshaped to long format, or we will count
  // one enrollment per visit rather than pregnancy.
  by clusterid, sort: generate cluster_size = _N / 100

  // Rename the outcomes.
  rename himperconsultation    him_time
  label variable               him_time "HIM time per consultation (mins)"

  // Transform times to the log scale.
  foreach y of varlist $time_outcomes {
    replace `y' = log(`y' + epsfloat()) // Prevent missing data due to log(0).
  }

  // Keep only the variables of interest.
  //// TODO: REINSTATE
  //// keep $time_outcomes arm clusterid observer $time_adj_var_names

  // Verify that no data are missing.
  //// TODO: REINSTATE
  //// misstable summarize
  //// assert r(N_lt_dot) == .
}
