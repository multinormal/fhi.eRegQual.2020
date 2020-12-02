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
  
  // Rename the HIM time variable.
  rename himperconsultation him_time
  label variable him_time "HIM time (any visit)"
  global him_time_row_lbl "Any visit"

  // Generate a version of him_time that is limited to booking visits.
  generate him_booking_time = him_time $him_booking_time_pred
  label variable him_booking_time "HIM time (booking visit)"
  global him_booking_time_row_lbl "Booking"

  // Generate a version of him_time that is limited to followup visits.
  generate him_fup_time = him_time $him_fup_time_pred
  label variable him_fup_time "HIM time (follow-up visit)"
  global him_fup_time_row_lbl "Follow-up"

  // Rename the client care variable.
  rename clientcarewit~n care_time
  label variable care_time "Client care time (any visit)"
  global care_time_row_lbl "Any visit"

  // Generate a version of care_time that is limited to booking visits.
  generate care_booking_time = care_time $care_booking_time_pred
  label variable care_booking_time "Client care time (booking visit)"
  global care_booking_time_row_lbl "Booking"

  // Generate a version of care_time that is limited to followup visits.
  generate care_fup_time = care_time $care_fup_time_pred
  label variable care_fup_time "Client care time (follow-up visit)"
  global care_fup_time_row_lbl "Follow-up"

  // Rename the total time variable.
  rename consulttime_withreporting total_time
  label variable total_time "Total time (any visit)"
  global total_time_row_lbl "Any visit"

  // Generate a version of total_time that is limited to booking visits.
  generate total_booking_time = total_time $total_booking_time_pred
  label variable total_booking_time "Total time (booking visit)"
  global total_booking_time_row_lbl "Booking"

  // Generate a version of total_time that is limited to followup visits.
  generate total_fup_time = total_time $total_fup_time_pred
  label variable total_fup_time "Total time (follow-up visit)"
  global total_fup_time_row_lbl "Follow-up"

  //// TODO: For each outcome: create a variable for it here and label it. Then
  //// add it to time_outcomes in globals.do. If we need to limit the outcome to
  //// booking visits, for example, also create a predicate in globals.do that is
  //// named using the naming scheme there. The table of results dhould then just
  //// update itself automatically.

  //// // Activties related to health information management (HIM):
  //// rename paperfindhim          paper_f_him_time // Finding
  //// rename paperreadhim          paper_r_him_time // Reading
  //// rename paperwritinghim       paper_w_him_time // Writing
  //// rename computerfindhim       comp_f_him_time  // Finding
  //// rename computerreadhim       comp_r_him_time  // Reading
  //// rename computerwritinghim    comp_w_him_time  // Writing
  //// rename afterconsultationhim  after_consult_him_time
  //// rename talkinghim            talk_him_time
  //// // Activities related to client care.
  //// rename proceduresclientcare  proc_care_time
  //// rename talkingclientcare     talk_care_time
  //// rename outsideclientcare     outside_care_time
  //// // Other activities. 
  //// rename miscellaneouswithinconsultatio misc_consult_time

  // Observation number corresponds to a consultation.
  generate observation_level = strofreal(observationnumber)
  encode observation_level, generate(consultation)
  label variable consultation "Consultation"

  // Transform times to log scale, preventing missing data due to log(0).
  foreach outcome of global time_outcomes {
    replace `outcome' = log(`outcome' + epsfloat()) if !missing(`outcome')
  }

  // Drop columns that are not of interest.
  keep consultation arm clusterid observer $time_outcomes $time_adj_var_names

  // Fix a single incorrect observation - this has been verified as correct.
  replace bookingvisit = "Booking visit":bookingvisit if missing(bookingvisit)
}
