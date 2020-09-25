version 16.1

frame time {
  foreach y of global time_outcomes {
      mixed `y' i.arm $time_adj_vars || clusterid:
      assert e(converged) == 1
      estimates store `y'_estimates
  }
}

// TODO: Move the following to its own do file?
frame activities {
  // We have observations clustered within consultation, clustered within
  // clinic.
  mixed time i.arm i.activity $time_adj_vars || clusterid: || consultation:
  estimates store activity_estimates
}
