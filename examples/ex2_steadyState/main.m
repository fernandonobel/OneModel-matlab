% Init the model and the tools for simulating
m = ModelClass.load('model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

% Define intial state, parameters.
x0 = [];
p = [];

% Simulation time span (note that we have set a huge time span).
tspan = [0 100000]; 

% Define the options for the simulator.
opt = odeset('AbsTol', 1e-10, 'RelTol', 1e-10);

% Define the tolerance to determine the steady state.
% Try changing this value to see its effect.
tol = 0.01;

% Set the event for ending the simulation when steady state is reached.
opt = s.optSteadyState(opt,p,tol);

% Simulate the model.
[out] = s.simulate(tspan,x0,p,opt);

% Plot the result and see that the simulation has been stop way before the 
% defined time span.
sp.plotAllStates(out);