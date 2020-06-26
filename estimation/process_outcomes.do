version 16.1

foreach outcome of global process_outcomes {
  frame `outcome' {
    if "`outcome'" != "malpresentation" {
      xtlogit y i.arm $adj_vars, vce(cluster clusterid) or
    }
    else {
      melogit y i.arm $adj_vars || clusterid:, or
    }

    estimates store `outcome'_estimates

    // TODO: As an alternative to the "spider plots" proposed in the protocol to
    // study the association between outcomes and variables such as cluster size,
    // we could make margin plots, along the following lines:
    // estimates restore `outcome'_estimates
    // frame change `outcome' // Make sure we have the correct frame.
    // margins i.arm, at(cluster_size = (2(1)7))
    //   // Compute margins for each level of arm, at values of cluster size from
    //   // 2 to 7.
    // marginsplot
    // margins i.arm#i.age_over_40 // This is the syntax for a factor variable.
  }
}
