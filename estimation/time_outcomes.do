version 16.1

// Specify the model. Note some of the estimates must be limited to certain
// conditions (e.g. booking visits), which is specified by a global variable.
local model mixed \`y' i.arm $time_adj_vars ${\`y'_pred} || clusterid:, vce(cluster observer)

frame time {
  // Determine the control and intervention levels of the arm variable.
  local con_level = "Control":arm
  local int_level = "Intervention":arm

  foreach y of global time_outcomes {
    // Compute the sample means (recall that data were logged). As in the model,
    // some sample means must be limited to certain conditions.
    mean `y' ${`y'_pred}, over(arm)
    global samp_mean_`y'_con = exp(e(b)["y1", "`y'@`con_level'.arm"])
    global samp_mean_`y'_int = exp(e(b)["y1", "`y'@`int_level'.arm"])

    // Fit the model for each variable of interest, storing the estimates.
    `model'
    assert e(converged) == 1
    estimates store `y'_estimates
  }
}

//// // Define the time outcomes. TODO: Move to globals?
//// global time_outcomes him him_booking him_followup
//// 
//// // Definitions for HIM:
//// global him_name "HIM"
//// local him_acts            activity == "Finding files (eRegistry)":activity |
//// local him_acts `him_acts' activity == "Finding files (paper)":activity     |
//// local him_acts `him_acts' activity == "Reading files (eRegistry)":activity |
//// local him_acts `him_acts' activity == "Reading files (paper)":activity     |
//// local him_acts `him_acts' activity == "Writing files (eRegistry)":activity |
//// local him_acts `him_acts' activity == "Writing files (paper)":activity     |
//// local him_acts `him_acts' activity == "Post-consultation HIM":activity     |
//// local him_acts `him_acts' activity == "Talking (HIM)":activity
//// 
//// // Definitions for HIM (booking visit):
//// global him_booking_name "HIM (booking visit)"
//// local him_booking_acts (`him_acts') & (bookingvisit == "Booking visit":bookingvisit)
//// 
//// // Definitions for HIM (follow-up visit):
//// global him_followup_name "HIM (follow-up visit)"
//// local him_followup_acts (`him_acts') & (bookingvisit == "Non-booking visit":bookingvisit)
//// 
//// // Sample means.
//// frame time {
////   tempvar mins
////   generate `mins' = exp(time)
//// 
////   // Calculate the number of consultations in each arm.
////   levelsof consultation if arm == "Control":arm
////   local control_consultations = r(r)
////   levelsof consultation if arm == "Intervention":arm
////   local intervention_consultations = r(r)
//// 
////   // Compute sample means and adjusted estimates for each outome.
////   foreach outcome of global time_outcomes {
////     // Compute the mean number of minutes for the activity in each arm, storing
////     // the results in globals.
////     total `mins' if arm == "Control":arm & (``outcome'_acts')
////     global samp_mean_`outcome'_con = e(b)[1,1] / `control_consultations'
////     total `mins' if arm == "Intervention":arm & (``outcome'_acts')
////     global samp_mean_`outcome'_int = e(b)[1,1] / `intervention_consultations'
////   }
//// 
////   TODO: Are you using the correct denominator? For example, should we be dividing 
////   by the total number of control consulations, or only those that were booking
////   visits, for example?
//// 
//// }
