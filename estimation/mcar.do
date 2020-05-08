version 16.1

// Test the null hypothesis that the constituent outcomes are jointly MCAR, and
// the null that the constituent outcomes are jointly CDM (a type of MCAR).
// P < 0.05 would reject the hypotheses (i.e., as usual, if P>= 0.05, we cannot
// "conclude" that the data are MCAR or have CDM, merely that we cannot reject
// those hypotheses).
frame original {
  mcartest y1-y5
  global p_mcar = r(p)
  mcartest y1-y5 = i.arm i.strat_var
  global p_cdm  = r(p)
}

