% Variables

Variable x1;
Variable x2;
Variable x3;
Variable ref(isAlgebraic=true);

% Parameters

Parameter k1;
Parameter k2;
Parameter k3;
Parameter d1;
Parameter d2;
Parameter d3;
Parameter gamma12;

% Equations

Equation d_x1 == k1    - gamma12*x1*x2 - d1*x1;
Equation d_x2 == k2*x3 - gamma12*x1*x2 - d2*x2;
Equation d_x3 == k3*x1 - d3*x3;
Equation ref  == k3/d3;
