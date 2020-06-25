version 16.1

frame attendance {
  xtlogit y i.arm $adj_vars, vce(cluster clusterid) or
  estimates store attendance_estimates
}