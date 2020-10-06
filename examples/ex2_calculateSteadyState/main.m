% Init the model and the tools for simulating
m = ModelClass.load('model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

% Define intial state, parameters.
x0 = [];
p = [];

% Simulation time span (note that we have set a huge time span).
tspan = [0 10]; 

% Define the options for the simulator.
opt = odeset('AbsTol', 1e-10, 'RelTol', 1e-10);

% Simulate the model.
[out] = s.simulate(tspan,x0,p,opt);

% Calculate the steady state.
[out_ss] = s.steadyState(x0,p);

% Plot the result and see that the simulation has been stop way before the 
% defined time span.
sp.plotAllStates(out);
plot(out.t(end),out_ss,'o');