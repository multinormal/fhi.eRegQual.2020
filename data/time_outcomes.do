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
  label variable bookingvisit "Visit"
  label define bookingvisit 1 "$booking_lbl" 0 "$nonbooking_lbl"
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
  label variable cluster_size  "Cluster size" // 100s of new enrollments
  
  // Rename the HIM time variable.
  rename himperconsultation him_time
  label variable him_time "HIM"
  global him_time_row_lbl "Any visit"

  // Generate a version of him_time that is limited to booking visits.
  generate him_booking_time = him_time $him_booking_time_pred
  label variable him_booking_time "HIM (booking visit)"
  global him_booking_time_row_lbl "Booking"

  // Generate a version of him_time that is limited to followup visits.
  generate him_fup_time = him_time $him_fup_time_pred
  label variable him_fup_time "HIM (follow-up visit)"
  global him_fup_time_row_lbl "Follow-up"

  // Rename the client care variable.
  rename clientcarewit~n care_time
  label variable care_time "Client care"
  global care_time_row_lbl "Any visit"

  // Generate a version of care_time that is limited to booking visits.
  generate care_booking_time = care_time $care_booking_time_pred
  label variable care_booking_time "Client care (booking visit)"
  global care_booking_time_row_lbl "Booking"

  // Generate a version of care_time that is limited to followup visits.
  generate care_fup_time = care_time $care_fup_time_pred
  label variable care_fup_time "Client care (follow-up visit)"
  global care_fup_time_row_lbl "Follow-up"

  // Rename the total time variable.
  rename consulttime_withreporting total_time
  label variable total_time "Total"
  global total_time_row_lbl "Any visit"

  // Generate a version of total_time that is limited to booking visits.
  generate total_booking_time = total_time $total_booking_time_pred
  label variable total_booking_time "Total (booking visit)"
  global total_booking_time_row_lbl "Booking"

  // Generate a version of total_time that is limited to followup visits.
  generate total_fup_time = total_time $total_fup_time_pred
  label variable total_fup_time "Total (follow-up visit)"
  global total_fup_time_row_lbl "Follow-up"

  // Activties related to health information management (HIM). We sum the time
  // spent using paper and computer because in the control arm it was not
  // possible to use a computer, and in the intervention arm it was also
  // possible to write on paper.
  replace paperfindhim = 0 if missing(paperfindhim)       // Zero time was coded missing.
  replace computerfindhim = 0 if missing(computerfindhim) // Zero time was coded missing.
  generate find_time = paperfindhim + computerfindhim
  label variable find_time "Finding"
  global find_time_row_lbl "Any visit"

  // Generate a version of find_time that is limited to booking visits.
  generate find_booking_time = find_time $find_booking_time_pred
  label variable find_booking_time "Finding (booking visit)"
  global find_booking_time_row_lbl "Booking"

  // Generate a version of find_time that is limited to followup visits.
  generate find_fup_time = find_time $find_fup_time_pred
  label variable find_fup_time "Finding (follow-up visit)"
  global find_fup_time_row_lbl "Follow-up"

  replace paperreadhim = 0 if missing(paperreadhim)       // Zero time was coded missing.
  replace computerreadhim = 0 if missing(computerreadhim) // Zero time was coded missing.
  generate read_time = paperreadhim + computerreadhim
  label variable read_time "Reading"
  global read_time_row_lbl "Any visit"

  // Generate a version of read_time that is limited to booking visits.
  generate read_booking_time = read_time $read_booking_time_pred
  label variable read_booking_time "Reading (booking visit)"
  global read_booking_time_row_lbl "Booking"

  // Generate a version of read_time that is limited to followup visits.
  generate read_fup_time = read_time $read_fup_time_pred
  label variable read_fup_time "Reading (follow-up visit)"
  global read_fup_time_row_lbl "Follow-up"

  // Define the total time spent writing. We sum across both arms because
  // those in the intervention arm (computer) can also write on paper, while
  // those in the control arm do not have access to the computer. Note that
  // the paperwritinghim_1 is actually the sum of writing time and 
  // "afterconsultationhim". It is not necessary to use the corresponding
  // version of computerwritinghim, because that would result in twice the
  // "afterconsultationhim" time being added to the intervention arm.
  replace paperwritinghim_1 = 0 if missing(paperwritinghim_1)   // Zero time was coded missing.
  replace computerwritinghim = 0 if missing(computerwritinghim) // Zero time was coded missing.
  generate write_time = paperwritinghim_1 + computerwritinghim
  label variable write_time "Writing"
  global write_time_row_lbl "Any visit"

  // Generate a version of write_time that is limited to booking visits.
  generate write_booking_time = write_time $write_booking_time_pred
  label variable write_booking_time "Writing (booking visit)"
  global write_booking_time_row_lbl "Booking"

  // Generate a version of write_time that is limited to followup visits.
  generate write_fup_time = write_time $write_fup_time_pred
  label variable write_fup_time "Writing (follow-up visit)"
  global write_fup_time_row_lbl "Follow-up"

  // Observation number corresponds to a consultation.
  generate observation_level = strofreal(observationnumber)
  encode observation_level, generate(consultation)
  label variable consultation "Consultation"

  // Transform times to log scale, preventing missing data due to log(0).
  foreach outcome of global time_outcomes {
    replace `outcome' = log(`outcome' + epsfloat()) if !missing(`outcome')

    // Set time to missing if no time was actually measured.
    replace `outcome' = . if `outcome' < log(0.0001)
  }

  // Drop columns that are not of interest.
  keep consultation arm clusterid observer $time_outcomes $time_adj_var_names

  // Fix a single incorrect observation - this has been verified as correct.
  replace bookingvisit = "$booking_lbl":bookingvisit if missing(bookingvisit)
}
