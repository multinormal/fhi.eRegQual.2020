version 16.1

// Clear everything and set up logging.
clear all
log close _all
log using products/log.smcl, name("eRegQual Analysis") replace

// Set up Stata.
do setup/setup

// Set up globals.
do globals/globals

// Import birth outcome data and perform imputation.
// TODO: Reinstate
do data/birth_outcomes
// do data/impute

// Import the process outcome data.
do data/attendance

// TODO: Reinstate
// // Do estimation.
// do estimation/missing          // Calculate percentage of data missing.
// do estimation/mcar             // Test the MCAR hypothesis.
// do estimation/birth_outcomes   // Analyze the birth outcome data.
do estimation/attendance          // Analyze the attendance data.

// TODO: Reinstate
// // Make figures
// do figures/figures

// TODO: Make Spider diagram for each process outcome
// (see https://folkehelse.sharepoint.com/:i:/r/sites/1461/Restricted%20Documents/4.Research/Analysis,%20Sample%20Size,%20Randomizatio/eRegQual/radar_chart_eRegQual.png?csf=1&web=1&e=JeKbbU)



// Obtain the git revision hash, which is used in the reports.
tempfile git_revision_filename
tempname revision_file
shell git rev-parse --short HEAD > "`git_revision_filename'"
file open `revision_file' using `git_revision_filename', read text
file read `revision_file' line
global git_revision = "`macval(line)'"

// Make the report
do reports/report products/report.docx
