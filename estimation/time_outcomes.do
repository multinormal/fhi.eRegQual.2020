version 16.1

// Fit the model.
frame time {
  mixed time i.arm i.activity $time_adj_vars || clusterid:, vce(cluster observer)
  assert e(converged) == 1
  estimates store time_estimates
}

// Sample means for HIM.
frame time {
  tempvar mins
  generate `mins' = exp(time)

  // Calculate the number of consultations in each arm.
  levelsof consultation if arm == "Control":arm
  local control_consulations = r(r)
  levelsof consultation if arm == "Intervention":arm
  local intervention_consulations = r(r)

  // Create an indicator for whether activity is one of the HIM time activities.
  tempvar include
  generate `include' = activity == "Finding files (eRegistry)":activity |    ///
                       activity == "Finding files (paper)":activity     |    ///
                       activity == "Reading files (eRegistry)":activity |    ///
                       activity == "Reading files (paper)":activity     |    ///
                       activity == "Writing files (eRegistry)":activity |    ///
                       activity == "Writing files (paper)":activity     |    ///
                       activity == "Post-consultation HIM":activity     |    ///
                       activity == "Talking (HIM)":activity
  total `mins' if arm == "Control":arm & `include'
  local mean_him_control = e(b)[1,1] / `control_consulations'
  total `mins' if arm == "Intervention":arm & `include'
  local mean_him_intervention = e(b)[1,1] / `intervention_consulations'

  display "C: `mean_him_control', I: `mean_him_intervention'"

}
