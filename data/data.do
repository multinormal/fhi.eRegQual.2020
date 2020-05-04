version 16

// Define the path to the data and the signature we expect it to have.
local fname "data/raw/04May2020_eRegQual birth outcomes.dta"
local signature "6367:756(27238):862839612:1580475191"

// Load the data and check its signature is as expected.
use "`fname'", replace
datasignature
assert r(datasignature) == "`signature'"

