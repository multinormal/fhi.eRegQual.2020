version 16.1

// The number of imputations to perform.
global m_imputations 50 // Very slightly narrower CI if m=100.

// Define the names of the process outcomes.
global process_outcomes ""
global process_outcomes $process_outcomes attendance hypertension diabetes
global process_outcomes $process_outcomes malpresentation anemia fetalgrowth

// The variables to adjust for, with their "types". See the generated report for
// an explanation of why these variables are adjusted for.
global adj_vars i.strat_var c.cluster_size c.age i.lab_available i.primiparous
global adj_var_names // A global with just the *names* of the adj_vars
foreach x of global adj_vars {
  local x_name = substr("`x'", 3, .) // Remove the i. or c.
  global adj_var_names $adj_var_names `x_name'
}

// Define paths to the process outcome files.
global fname_attendance      "data/raw/25June2020_eRegQual process outcomes_attendance.dta"
global fname_hypertension    "data/raw/25June2020_eRegQual process outcomes_hypertension.dta"
global fname_diabetes        "data/raw/25June2020_eRegQual process outcomes_diabetes.dta"
global fname_malpresentation "data/raw/25June2020_eRegQual process outcomes_malpresentation.dta"
global fname_anemia          "data/raw/02July2020_eRegQual process outcomes_anemia.dta"
global fname_fetalgrowth     "data/raw/02July2020_eRegQual process outcomes_fetalgrowth.dta"

// Define data signatures for the process outcome files.
global datasignature_attendance          "6367:39(51496):3578513271:2127801624"
global datasignature_hypertension        "6367:60(68365):3970041110:3735367683"
global datasignature_diabetes            "6367:38(91264):1895688975:3113856828"
global datasignature_malpresentation     "6367:31(88392):1586201653:3483051938"
global datasignature_anemia              "6367:51(74410):3453863737:2485498443"
global datasignature_fetalgrowth        "6367:142(76473):3264358426:1819903352"
