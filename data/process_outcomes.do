version 16.1

foreach outcome of global process_outcomes {
  frame create `outcome'
  frame `outcome' {
    // Load the data and check its signature is as expected.
    use "${fname_`outcome'}", replace
    datasignature
    assert r(datasignature) == "${datasignature_`outcome'}"

    // Encode/rename arm and cluster identifier variables.
    encode prettyExposure, generate(arm)
    rename str_TRIAL_1_Cluster clusterid

    // Compute the cluster size from the trial data. We use the trial data for
    // simplicity and have verified that these agree with the "baseline" data on
    // trial size. We divide by 100 because cluster sizes range from about 10 to
    // about 220, and we want to get regression coefficients that are non-null
    // within two decimal places!
    by clusterid, sort: generate cluster_size = _N / 100

    // Reshape to long format. Note that the uniqueid variable is not actually
    // unique but identifies women, who can have multiple pregnancies (but not
    // twins in this data set). Rows in the wide data frame are pregnancies, so
    // we simply generate a unique pregnancy number for each row. We generate a 
    // visit variable, as each woman (pregnancy) may attend clinic multiple times. 
    generate pregnancy = _n
    local stubs opportunity_`outcome'_ success_`outcome'_
    reshape long `stubs', i(pregnancy) j(visit)

    // While the outcome variable is a factor with three levels, we are only 
    // interested in the relative odds of success. The other levels are 
    // "NOT SUCCESSFUL" and "NOT APPLICABLE". Not applicable is not of 
    // scientific interest here.
    local success_label_name = "`: value label success_`outcome'_'"
    drop if      success_`outcome'_ == "NOT APPLICABLE":`success_label_name'
    generate y = success_`outcome'_ == "SUCCESSFUL":`success_label_name'

    // Convert the stratification variable from string to integer.
    encode bookorgdistricthashed, generate(strat_var)

    // Generate an indicator for whether each woman is aged > 40 years.
    generate age_over_40 = age > 40
    label values age_over_40 yes_no_label
    
    // Generate an indicator for whether each woman is primiparous.
    rename bookprimi primiparous
    label values primiparous yes_no_label

    // Keep only the variables of interest.
    keep y arm pregnancy visit clusterid $adj_var_names

    // Label the variables
    label variable y             "Successful `outcome'"
    label variable arm           "Study arm"
    label variable pregnancy     "Pregnancy"
    label variable clusterid     "Cluster"
    label variable strat_var     "District"
    label variable lab_available "Lab available"
    label variable cluster_size  "Cluster size (100s of new enrollments)"
    label variable age_over_40   "Age > 40 years"
    label variable primiparous   "Primiparous"

    // There should be no missing data.
    misstable summarize, all
    assert r(N_lt_dot) == _N

    // For most of the process outcomes, we have multiple visits within
    // pregnancy; we model the cluster-randomized design in the estimation.
    // For malpresentation, there is only one visit and so cluster can be the
    // panel variable.
    if "`outcome'" != "malpresentation" xtset pregnancy visit
    if "`outcome'" == "malpresentation" xtset clusterid

    // TODO: If you generate an OR for this analysis, switch the birth outcomes
    // to OR, too. Make sure you update the report text if you change the link.

    // TODO: Probably report OR and assumed and corresponding risks.
  }
}
