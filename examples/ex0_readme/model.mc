% Variables

Variable x1;
Variable x2;
Variable x3;
Variable ref(
  isAlgebraic = true
  );

% Parameters

Parameter k1 = 1;
Parameter k2 = 1;
Parameter k3 = 1;
Parameter d1 = 1;
Parameter d2 = 1;
Parameter d3 = 1;
Parameter gamma12 = 1;

% Equations

d_x1 = k1    - gamma12*x1*x2 - d1*x1;
d_x2 = k3*x3 - gamma12*x1*x2 - d2*x2;
d_x3 = k3*x1 - d3*x3;
ref  = k3/d3;
