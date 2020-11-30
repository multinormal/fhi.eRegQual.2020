version 16.1

// Fit the model.
frame time {
  mixed time i.arm i.activity $time_adj_vars || clusterid:, vce(cluster observer)
  assert e(converged) == 1
  estimates store time_estimates
}

// Define the time outcomes. TODO: Move to globals?
global time_outcomes him



// Definitions of HIM:
global him_name "HIM"
local him_acts            activity == "Finding files (eRegistry)":activity |
local him_acts `him_acts' activity == "Finding files (paper)":activity     |
local him_acts `him_acts' activity == "Reading files (eRegistry)":activity |
local him_acts `him_acts' activity == "Reading files (paper)":activity     |
local him_acts `him_acts' activity == "Writing files (eRegistry)":activity |
local him_acts `him_acts' activity == "Writing files (paper)":activity     |
local him_acts `him_acts' activity == "Post-consultation HIM":activity     |
local him_acts `him_acts' activity == "Talking (HIM)":activity


// Sample means for HIM.
frame time {
  tempvar mins
  generate `mins' = exp(time)

  // Calculate the number of consultations in each arm.
  levelsof consultation if arm == "Control":arm
  local control_consulations = r(r)
  levelsof consultation if arm == "Intervention":arm
  local intervention_consulations = r(r)

  // Compute sample means and adjusted estimates for each outome.
  foreach outcome of global time_outcomes {
    // Compute the mean number of minutes for the activity in each arm, storing
    // the results in globals.
    total `mins' if arm == "Control":arm & ``outcome'_acts'
    global samp_mean_`outcome'_con = e(b)[1,1] / `control_consulations'
    total `mins' if arm == "Intervention":arm & ``outcome'_acts'
    global samp_mean_`outcome'_int = e(b)[1,1] / `intervention_consulations'
  }

}
