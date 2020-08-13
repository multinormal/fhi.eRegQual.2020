version 16.1

// Clear everything and set up logging.
clear all
log close _all
log using products/log.smcl, name("eRegQual Analysis") replace

// Set up Stata.
do setup/setup

// Set up globals.
do globals/globals

// Import the process outcome data.
do data/process_outcomes

// Import birth outcome data and perform imputation.
do data/birth_outcomes
do data/impute

// Do estimation.
do estimation/missing          // Calculate percentage of data missing.
do estimation/mcar             // Test the MCAR hypothesis.
do estimation/birth_outcomes   // Analyze the birth outcome data.
do estimation/process_outcomes // Analyze process outcome data.
do estimation/margins          // Compute marginal probabilities.

// Make figures
do figures/imputation
do figures/margins

// Obtain the git revision hash, which is used in the reports.
tempfile git_revision_filename
tempname revision_file
shell git rev-parse --short HEAD > "`git_revision_filename'"
file open `revision_file' using `git_revision_filename', read text
file read `revision_file' line
global git_revision = "`macval(line)'"

// Make the report
do reports/report products/report.docx
