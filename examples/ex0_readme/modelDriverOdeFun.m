%% Driver script for simulating the ODE function modelDriverOdeFun

clear all;
close all;

% Mass matrix for algebraic simulations.
M = [
	1	0	0	0	
	0	1	0	0	
	0	0	1	0	
	0	0	0	0	
];

% Options for the solver.
opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
opt = odeset(opt,'Mass',M);

% Simulation time span.
tspan = [0 10];

% Initial condition.
x0 = [
	 0.0 % x1
	 0.0 % x2
	 0.0 % x3
	 0.0 % ref
];

% Definition of parameters of the model.
p.d1 = 1.0;
p.d2 = 1.0;
p.d3 = 1.0;
p.gamma12 = 1.0;
p.k1 = 1.0;
p.k2 = 1.0;
p.k3 = 1.0;

[t,x] = ode15s(@(t,x) modelOdeFun(t,x,p), tspan, x0, opt);

plot(t,x);
legend('x1','x2','x3','ref');
grid on;
