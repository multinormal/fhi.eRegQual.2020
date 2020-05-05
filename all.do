version 16.1

// Clear everything and set up logging.
clear all
log close _all
log using products/log.smcl, name("eRegQual Birth Outcomes Analysis") replace

// Set up Stata.
do setup/setup

// Set up globals.
do globals/globals

// Import data.
do data/data

// Do estimation.
do estimation/estimation

// Obtain the git revision hash, which is used in the reports.
tempfile git_revision_filename
tempname revision_file
shell git rev-parse --short HEAD > "`git_revision_filename'"
file open `revision_file' using `git_revision_filename', read text
file read `revision_file' line
global git_revision = "`macval(line)'"

