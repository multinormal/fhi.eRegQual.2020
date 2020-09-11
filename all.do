version 16.1

// Clear everything and set up logging.
clear all
log close _all
log using products/log.smcl, name("eRegQual Analysis") replace

// Set up Stata.
do setup/setup

// Set up globals.
do globals/globals

// Import the data.
do data/process_outcomes
do data/birth_outcomes
do data/time_outcomes

// Perform imputation.
// TODO: REINSTATE do data/impute

// Do estimation.
// TODO: REINSTATE do estimation/missing          // Calculate percentage of data missing.
do estimation/mcar             // Test the MCAR hypothesis.
// TODO: REINSTATE do estimation/birth_outcomes   // Analyze the birth outcome data.
// TODO: REINSTATE do estimation/process_outcomes // Analyze process outcome data.
// TODO: REINSTATE do estimation/margins          // Compute marginal probabilities.
do estimation/time_outcomes                       // Analyze time and motion data.

// Make figures
// TODO: REINSTATE do figures/imputation
// TODO: REINSTATE do figures/margins

// Obtain the git revision hash, which is used in the reports.
tempfile git_revision_filename
tempname revision_file
shell git rev-parse --short HEAD > "`git_revision_filename'"
file open `revision_file' using `git_revision_filename', read text
file read `revision_file' line
global git_revision = "`macval(line)'"

// Make the report
// TODO: REINSTATE do reports/report products/report.docx
