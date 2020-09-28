version 16.1

frame activities {
  // We have observations clustered within consultation, clustered within
  // clinic. Note that it is necessary to include arm because while the
  // control arm could not use a computer, the intervention arm could use
  // both the computer and paper files.
  mixed time i.arm i.activity $time_adj_vars || clusterid: || consultation:
  estimates store activity_estimates
}
