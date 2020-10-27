SimOptions AbsTol = 1e-9;
SimOptions RelTol = 1e-9;
SimOptions TimeSpan  = [0 10];

Variable x(
  start = 0
  );

Equation der_x == 1 - x;
