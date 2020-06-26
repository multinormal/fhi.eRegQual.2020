version 16.1

frame attendance {
  xtlogit y i.arm $adj_vars, vce(cluster clusterid) or
  estimates store attendance_estimates

  // TODO: As an alternative to the "spider plots" proposed in the protocol to
  // study the association between outcomes and variables such as cluster size,
  // we could make margin plots, along the following lines:
  // estimates restore attendance_estimates
  // frame change attendance // Make sure we have the correct frame.
  // margins i.arm, at(cluster_size = (2(1)7))
  //   // Compute margins for each level of arm, at values of cluster size from
  //   // 2 to 7.
  // marginsplot
  // margins i.arm#i.age_over_40 // This is the syntax for a factor variable.
}