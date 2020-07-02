version 16.1

// Record the maximum percentage of data missing for age for process outcomes.
global max_miss_age_pc 0

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
    // within two decimal places! Note that cluster size computation must be
    // done before the data set is reshaped to long format, or we will count
    // one enrollment per visit rather than pregnancy.
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
    
    // Generate an indicator for whether each woman is primiparous.
    rename bookprimi primiparous

    // Age.
    replace age = . if age <= 1 // Correct some mis-coded values of the age variable.
    label variable age "Age (years)"

    // Keep only the variables of interest.
    keep y arm pregnancy visit clusterid $adj_var_names

    // Label the variables
    label variable y             "Successful `outcome'"
    label variable arm           "Study arm"
    label variable pregnancy     "Pregnancy"
    label variable clusterid     "Cluster"
    label variable strat_var     "District"
    label variable lab_available "Lab availability"
    label variable cluster_size  "Cluster size" // 100s of new enrollments
    label variable age           "Age (years)"
    label variable primiparous   "Parity"       // Indicator of primiparity.

    // Label values.
    label define lab_available_label 1 "Lab" 0 "No lab"
    label values lab_available lab_available_label
    label define primiparous_label 1 "Primiparous" 0 "Multiparous"
    label values primiparous primiparous_label

    // There should only be missing data for the age variable.
    describe, short varlist
    local vars = r(varlist)
    local vars = ustrtrim(usubinstr("`vars'", "age", "", .))
    foreach x of local vars {
      misstable summarize `x'
      assert r(N_lt_dot) == .
    }

    // The age variable should contain no more than 1.257% missing data.
    misstable summarize age
    local miss_age_pc = 100 * (r(N_eq_dot) / (r(N_eq_dot) + r(N_lt_dot)))
    if `miss_age_pc' > $max_miss_age_pc global max_miss_age_pc = `miss_age_pc'
    drop if missing(age)
    assert r(N_drop) <= 300 // Ensure we did only drop a little data!

    // For most of the process outcomes, we have multiple visits within
    // pregnancy; we model the cluster-randomized design in the estimation.
    // For malpresentation, there is only one visit and so cluster can be the
    // panel variable. Note that the xtlogit-based analysis with cluster as the
    // panel variable gives identical point estimates and confidence intervals
    // as a melogit-based analysis with cluster as the random effect.
    if "`outcome'" != "malpresentation" xtset pregnancy visit
    if "`outcome'" == "malpresentation" xtset clusterid
  }
}
