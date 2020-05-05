version 16.1

// Set up the imputation and the roles of the variables.
mi set mlong
mi register passive $passives
mi register imputed $imputed_conts $imputed_dichs $imputed_mults
mi register regular $regulars


mi impute chained (regress) $imputed_conts  ///
                  (logit)   $imputed_dichs  ///
                  (mlogit)  $imputed_mults, ///
                  add(5) augment

// TODO: The above runs, but the predictors used in each imputation are not the
// same, possibly due to collinearity. Run "help mi_omit_note" to learn what to
// do.


// Do a very basic analysis that ignores all issue such as missing data.
//melogit y arm i.strat_var || clusterid:, or

// TODO: Note that if we replace arm with i.arm, the model does not fit but gives
// identical or very similar estimates. I.e., there is a problem that gets
// introduced when we convert arm into an indicator. The estimates for the two
// approaches are identical except for the constant term, whose CI is slightly
// wider under the arm (rather than i.arm) approach. The interpretation of the
// arm coefficient is that it is the OR for a unit increase in "arm", i.e.,
// it corresponds to the arm=2 (the D condition). So, perhaps rename the
// variable to be something like "treat_D".

