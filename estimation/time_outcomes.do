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
    tempvar x
    generate `x' = exp(`y') // Un-log the time data for this outcome.
    mean `x' ${`y'_pred}, over(arm)
    global samp_mean_`y'_con = e(b)["y1", "`x'@`con_level'.arm"]
    global samp_mean_`y'_int = e(b)["y1", "`x'@`int_level'.arm"]

    // Fit the model for each variable of interest, storing the estimates.
    `model'
    assert e(converged) == 1
    estimates store `y'
  }
}
