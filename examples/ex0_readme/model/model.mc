% Variables

variable x1;
variable x2;
variable x3;
variable ref(value = k3/d3);

% Parameters

parameter k1(value = 1.0);
parameter k2(value = 1.0);
parameter k3(value = 1.0);
parameter d1(value = 1.0);
parameter d2(value = 1.0);
parameter d3(value = 1.0);
parameter gamma12(value = 1.0);

% Equations

equation der_x1 == k1    - gamma12*x1*x2 - d1*x1;
equation der_x2 == k2*x3 - gamma12*x1*x2 - d2*x2;
equation der_x3 == k3*x1 - d3*x3;
