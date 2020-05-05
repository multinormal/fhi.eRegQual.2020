version 16.1

// Do a very basic analysis that ignores all issue such as missing data.
melogit y arm i.strat_var || clusterid:, or

