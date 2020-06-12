version 16.1

// Clear everything and set up logging.
clear all
log close _all
log using products/log.smcl, name("eRegQual Analysis") replace

// Set up Stata.
do setup/setup

// Set up globals.
do globals/globals

// TODO: Reinstate
// // Import birth outcome data and perform imputation.
// do data/birth_outcomes
// do data/impute

// Import the process outcome data.
do data/attendance

// TODO: Reinstate
// // Do estimation.
// do estimation/missing
// do estimation/estimation
// do estimation/mcar

// TODO: Reinstate
// // Make figures
// do figures/figures

// Obtain the git revision hash, which is used in the reports.
tempfile git_revision_filename
tempname revision_file
shell git rev-parse --short HEAD > "`git_revision_filename'"
file open `revision_file' using `git_revision_filename', read text
file read `revision_file' line
global git_revision = "`macval(line)'"

// Make the reports
// TODO: Reinstate this
// do reports/report products/report.docx

