version 16.1

frame attendance {
  xtlogit y i.arm, vce(cluster clusterid) or
  estimates store attendance_estimates
}