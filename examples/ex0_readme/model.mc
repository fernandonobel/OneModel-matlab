% Variables

Variable x1;
Variable x2;
Variable x3;
Variable ref(value = k3/d3);

% Parameters

Parameter k1(value = 1.0);
Parameter k2(value = 1.0);
Parameter k3(value = 1.0);
Parameter d1(value = 1.0);
Parameter d2(value = 1.0);
Parameter d3(value = 1.0);
Parameter gamma12(value = 1.0);

% Equations

Equation der_x1 == k1    - gamma12*x1*x2 - d1*x1;
Equation der_x2 == k2*x3 - gamma12*x1*x2 - d2*x2;
Equation der_x3 == k3*x1 - d3*x3;