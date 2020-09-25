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

  //TODO: Some of the data are missing for some outcomes. Should it be set to zero time?

  // Rename and relabel the outcomes.
  rename himperconsultation    him_time
  label variable               him_time         ///
                               "HIM time per consultation (mins)"
  rename consultationtime      consult_time
  label variable               consult_time     ///
                               "Consultation time (mins)"
  rename clientcarewithinconsultation care_time 
  label variable               care_time        ///
                               "Client care time within consultation (mins)"
  rename proceduresclientcare  proc_care_time
  label variable               proc_care_time   ///
                               "Time spent on client care procedures (mins)"
  
  // Rename the outcomes used for the analysis of time spent on activities.
  rename paperfindhim          paper_f_him_time
  rename paperreadhim          paper_r_him_time
  rename paperwritinghim       paper_w_him_time
  rename computerfindhim       comp_f_him_time
  rename computerreadhim       comp_r_him_time
  rename computerwritinghim    comp_w_him_time

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

// Make a version of the time frame that is long, and has "activity" and "time"
// variables, specifying what kind of activity time is being used on.
frame copy time activities 
frame activities {
  // Reshape to long format, creating a temporary activity and a time variable.
  tempvar activity
  reshape long @_time, i(observationnumber) j(`activity') string
  rename _time time
  label variable time "Time used (mins)"

  // Keep only those activities of interest. 
  tempvar to_keep
  generate `to_keep' = 0
  foreach x of global activities {
    replace `to_keep' = `to_keep' | `activity' == "`x'"
  }
  keep if `to_keep'

  // Replace the activities with more useful level names.
  foreach x of global activities {
    replace `activity' = "${`x'_lbl}" if `activity' == "`x'"
  }

  // Encode the activity variable, creating the actual activity variable.
  encode `activity', generate(activity) label(activity_label)

  // Drop columns that are not of interest.
  keep observationnumber arm clusterid observer time activity $time_adj_var_names
}
