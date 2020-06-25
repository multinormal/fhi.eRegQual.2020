version 16.1

// The number of imputations to perform.
global m_imputations 50 // Very slightly narrower CI if m=100.

// Labels for binary variables with levels yes and no.
label define yes_no_label 1 Yes 0 No

// The variables to adjust for, with their "typed". See the generated report for
// an explanation of why these variables are adjusted for.
global adj_vars i.strat_var i.lab_available c.cluster_size i.age_over_40 ///
                i.primiparous
global adj_var_names // A global with just the *names* of the adj_vars
foreach x of global adj_vars {
  local x_name = substr("`x'", 3, .) // Remove the i. or c.
  global adj_var_names $adj_var_names `x_name'
}
