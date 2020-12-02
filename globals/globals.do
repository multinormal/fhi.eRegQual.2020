version 16.1

// The number of imputations to perform.
global m_imputations 50 // Very slightly narrower CI if m=100.

// Define the names of the process outcomes.
global process_outcomes ""
global process_outcomes $process_outcomes attendance hypertension diabetes
global process_outcomes $process_outcomes malpresentation anemia fetalgrowth

// Define the main time outcomes.
global him_time_outcomes   him_time   him_booking_time   him_fup_time
global care_time_outcomes  care_time  care_booking_time  care_fup_time
global total_time_outcomes total_time total_booking_time total_fup_time

// Define the minor time outcomes.
global find_time_outcomes find_time
global read_time_outcomes read_time
global write_time_outcomes write_time write_booking_time

// Define all the time outcomes.
global time_outcomes                $him_time_outcomes 
global time_outcomes $time_outcomes $care_time_outcomes 
global time_outcomes $time_outcomes $total_time_outcomes
global time_outcomes $time_outcomes $find_time_outcomes
global time_outcomes $time_outcomes $read_time_outcomes
global time_outcomes $time_outcomes $write_time_outcomes

// Table section titles.
global him_time_outcomes_section   "Health Information Management"
global care_time_outcomes_section  "Client Care"
global total_time_outcomes_section "Total Time§"
global find_time_outcomes_section  "Finding"
global read_time_outcomes_section  "Reading"
global write_time_outcomes_section "Writing"

// Define predicates for the outcomes that need them.
local is_booking     if bookingvisit == "Booking visit":bookingvisit
local is_not_booking if bookingvisit != "Booking visit":bookingvisit
global him_booking_time_pred   `is_booking'
global him_fup_time_pred       `is_not_booking'
global care_booking_time_pred  `is_booking'
global care_fup_time_pred      `is_not_booking'
global total_booking_time_pred `is_booking'
global total_fup_time_pred     `is_not_booking'
global write_booking_time_pred `is_booking'

//global time_outcomes $time_outcomes him_time consult_time care_time

// Define the activities that are of interest.
//// global activities              paper_f_him paper_r_him paper_w_him
//// global activities $activities  comp_f_him  comp_r_him  comp_w_him
//// global activities $activities  after_consult_him
//// global activities $activities  talk_him
//// global activities $activities  proc_care
//// global activities $activities  talk_care
//// global activities $activities  outside_care
//// global activities $activities  misc_consult

// Define value labels for the activities.
// TODO: Are these still used?
global paper_f_him_lbl       "Finding files (paper)"
global paper_r_him_lbl       "Reading files (paper)"
global paper_w_him_lbl       "Writing files (paper)"
global comp_f_him_lbl        "Finding files (eRegistry)"
global comp_r_him_lbl        "Reading files (eRegistry)"
global comp_w_him_lbl        "Writing files (eRegistry)"
global after_consult_him_lbl "Post-consultation HIM"
global talk_him_lbl          "Talking (HIM)"
global proc_care_lbl         "Client care procedures"
global talk_care_lbl         "Talking (client care)"
global outside_care_lbl      "Outside client care"
global misc_consult_lbl      "Miscellaneous"

// The variables to adjust for in the "main" analyses, with their "types". See
// the generated report for an explanation of why these variables are adjusted
// for.
global adj_vars i.strat_var c.cluster_size c.age i.lab_available i.primiparous
global adj_var_names // A global with just the *names* of the adj_vars
foreach x of global adj_vars {
  local x_name = substr("`x'", 3, .) // Remove the i. or c.
  global adj_var_names $adj_var_names `x_name'
}

// The variables to adjust for in the time and motion analyses, with their
// "types". See the generated report for an explanation of why these variables
// are adjusted for. Note that unlike the "main" outcomes, data are not 
// available for age and parity, which were used as constraints in the
// randomization.
global time_adj_vars ""
global time_adj_vars $time_adj_vars i.strat_var c.cluster_size i.lab_available 
global time_adj_vars $time_adj_vars i.bookingvisit
global time_adj_var_names // A global with just the *names* of the time_adj_vars
foreach x of global time_adj_vars {
  local x_name = substr("`x'", 3, .) // Remove the i. or c.
  global time_adj_var_names $time_adj_var_names `x_name'
}

// Define paths to the process outcome files.
global fname_attendance      "data/raw/25June2020_eRegQual process outcomes_attendance.dta"
global fname_hypertension    "data/raw/25June2020_eRegQual process outcomes_hypertension.dta"
global fname_diabetes        "data/raw/25June2020_eRegQual process outcomes_diabetes.dta"
global fname_malpresentation "data/raw/25June2020_eRegQual process outcomes_malpresentation.dta"
global fname_anemia          "data/raw/02July2020_eRegQual process outcomes_anemia.dta"
global fname_fetalgrowth     "data/raw/10August2020_eRegQual process outcomes_fetalgrowth.dta"

// Define paths to the time outcome file.
global fname_time            "data/raw/13Oct20_eRegTime.dta"

// Define data signatures for the process outcome files.
global datasignature_attendance          "6367:39(51496):3578513271:2127801624"
global datasignature_hypertension        "6367:60(68365):3970041110:3735367683"
global datasignature_diabetes            "6367:38(91264):1895688975:3113856828"
global datasignature_malpresentation     "6367:31(88392):1586201653:3483051938"
global datasignature_anemia              "6367:51(74410):3453863737:2485498443"
global datasignature_fetalgrowth         "6367:37(83879):2470058122:813121498"

// Define data signature for the time data.
global datasignature_time                "241:26(73043):3342897650:3191572784"

// Define recoding rules for the arm variables of the process outcomes; the 
// coding of control and intervention vary by outcome. We will adopt the 
// convention that control is coded as 1 and intervention as 2.
global recode_attendance   recode arm (1 = 2) (2 = 1)
global recode_hypertension recode arm (1 = 2) (2 = 1)
foreach x in diabetes malpresentation anemia fetalgrowth {
  global recode_`x' // No recoding necessary
}
