% SimOptions.Solver = @ode45;
SimOptions.AbsTol = 1e-3;
SimOptions.RelTol = 1e-6;
SimOptions.TimeSpan  = [0 10];

Variable x(
  start = 0
  );

Equation der_x == 1 - x;
