SimOptions AbsTol = 1e-3;
SimOptions RelTol = 1e-9;
SimOptions TimeSpan  = [0 10];

Variable x(start = 0);
Parameter k(value = 1);

Equation der_x == k - x;
