version 16.1

// Load the data and check its signature is as expected.
frame create time
frame time {
  // Import the data and verify its signature.
  use "${fname_time}", replace
  datasignature
  assert r(datasignature) == "${datasignature_time}"

  // Encode/rename the arm variable. We recode here, and note that it is not
  // possible to blind the analyst because use of the intervention in one arm
  // and non-use in the other makes treatment assignment obvious.
  replace exposure = "Control"      if exposure == "A"
  replace exposure = "Intervention" if exposure == "B"
  encode exposure, generate(arm)
  label variable arm Arm

  // Encode/rename booking visit variable.
  label variable bookingvisit "Booking visit"
  label define bookingvisit 1 "Booking visit" 0 "Non-booking visit"
  label values bookingvisit bookingvisit

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
  
  // Rename the outcomes used for the analysis of time spent on activities:
  // Activties related to health information management (HIM):
  rename paperfindhim          paper_f_him_time // Finding
  rename paperreadhim          paper_r_him_time // Reading
  rename paperwritinghim       paper_w_him_time // Writing
  rename computerfindhim       comp_f_him_time  // Finding
  rename computerreadhim       comp_r_him_time  // Reading
  rename computerwritinghim    comp_w_him_time  // Writing
  rename afterconsultationhim  after_consult_him_time
  rename talkinghim            talk_him_time
  // Activities related to client care.
  rename proceduresclientcare  proc_care_time
  rename talkingclientcare     talk_care_time
  rename outsideclientcare     outside_care_time
  // Other activities. 
  rename miscellaneouswithinconsultatio misc_consult_time

  // Observation number corresponds to a consultation.
  generate observation_level = strofreal(observationnumber)
  encode observation_level, generate(consultation)
  label variable consultation "Consultation"

  // Reshape to long format, creating a temporary activity and a time variable.
  tempvar activity
  reshape long @_time, i(consultation) j(`activity') string
  rename _time time

  // Transform times to log scale, preventing missing data due to log(0).
  replace time = log(time + epsfloat()) if !missing(time)
  label variable time "Time used (log mins)"

  // Measurements of zero time were coded as missing; i.e. did not happen.
  drop if missing(time)

  // Keep only those activities of interest. 
  generate to_keep = 0
  foreach x of global activities {
    replace to_keep = to_keep | `activity' == "`x'"
  }
  keep if to_keep

  // Replace the activities with more useful level names.
  foreach x of global activities {
    replace `activity' = "${`x'_lbl}" if `activity' == "`x'"
  }

  // Encode the activity variable, creating the actual activity variable.
  encode `activity', generate(activity) label(activity)

  // Drop columns that are not of interest.
  keep consultation arm clusterid observer time activity $time_adj_var_names

  // Fix a single incorrect observation - this has been verified as correct.
  replace bookingvisit = "Booking visit":bookingvisit if missing(bookingvisit)

  // Verify that no data are missing.
  misstable summarize
  assert r(N_lt_dot) == .
}
