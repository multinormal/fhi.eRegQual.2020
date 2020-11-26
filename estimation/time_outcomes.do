version 16.1

frame time {
  mixed time i.arm i.activity $time_adj_vars || clusterid:, vce(cluster observer)
  assert e(converged) == 1
  estimates store activity_estimates
}
