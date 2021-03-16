%% Driver script for simulating the ODE function modelDriverOdeFun
% This script was autogenerated with ModelClass v0.5.0 ce4b9ed   -   Fernando Nóbel (fersann1@upv.es).

clear all;
close all;

% Mass matrix for algebraic simulations.
M = [
	1	0	0	
	0	1	0	
	0	0	1	
];

% Options for the solver.
opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
opt = odeset(opt,'Mass',M);

% Simulation time span.
tspan = [0 10];

% Default initial condition value.
x0 = [
	 0.000000e+00 % x1
	 0.000000e+00 % x2
	 0.000000e+00 % x3
];

% Default parameters value.
p.k1 = 1.000000e+00;
p.k2 = 1.000000e+00;
p.k3 = 1.000000e+00;
p.d1 = 1.000000e+00;
p.d2 = 1.000000e+00;
p.d3 = 1.000000e+00;
p.gamma12 = 1.000000e+00;

[t,x] = ode15s(@(t,x) modelOdeFun(t,x,p), tspan, x0, opt);

plot(t,x);
legend('x1','x2','x3');
grid on;
