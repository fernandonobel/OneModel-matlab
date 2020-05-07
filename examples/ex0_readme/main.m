%% 1. Model definition.

% Initialize an object of the model.
m = model();

% Display variables and equations of the model.
m.vars
m.eqns
%% 2. Simulation.

% Initialize a SimulationClass object with the model data.
s = SimulationClass(m);

% Simulation time span.
tspan = [0 10];

% Parameters of the model.
p.k1 = 1.0;
p.k2 = 1.0;
p.k3 = 1.0;
p.gamma12 = 1.0;
p.d1 = 1.0;
p.d2 = 1.0;
p.d3 = 1.0;

% Intial conditions of the model.
x0.x1 = 0.000000;
x0.x2 = 0.000000;
x0.x3 = 0.000000;

% Options for the solver.
opt = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

% Simulate the model.
[out] = s.simulate(tspan,x0,p,opt);

% Result of the simulation.
out
%% 3. Plot simulation result.

% Initialize a SimulationPlotClass object with the model data.
sp = SimulationPlotClass(m);

% Plot the result of the simulation.
sp.plotAllStates(out);

%% 4. Function that evaluates the ODEs.

% Create an ode function of the model.
s.createOdeFunction();

%% 5. Simulate with the ode function.

% Options for the solver.
opt = odeset('AbsTol',1e-8,'RelTol',1e-8);

% In DAE simualtions, the mass matrix is needed.
opt = odeset(opt,'Mass',s.massMatrix);

% Simulation time span.
tspan = [0 10]; 

% Initial condition for the model.
x0 = [0 0 0 0];

% Simulate using the ode15s and using previous defined parameters.
[t,x] = ode15s(@(t,x) modelOdeFun(t,x,p), tspan, x0, opt);

% Final value of the states.
x(end,:)

%% 6. Plot simulation result of the ode function.

% Plot the simulation result  on top of the previous one. 
subplot(2,2,1);
plot(t,x(:,1));

subplot(2,2,2);
plot(t,x(:,2));

subplot(2,2,3);
plot(t,x(:,3));

subplot(2,2,4);
plot(t,x(:,4));