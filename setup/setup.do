version 16.1

// Set the random number generator seed.
set rng  mt64s
set seed 1234
set rngstream 1


// Set up Stata's path to use the "packages" directory for add-on packages.
net set ado "./packages"
sysdir set PERSONAL "./packages"

// Specify formats.
set cformat %9.2f
set pformat %5.2f
set sformat %8.2f

