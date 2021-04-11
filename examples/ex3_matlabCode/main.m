%% Init the model and the tools for simulating
m = OneModel.load('./model/model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

% Define intial state, parameters.
x0 = [];
p = [];

% Define the options for the simulator.
opt = odeset('AbsTol', 1e-3, 'RelTol', 1e-6);

% Simulation time span.
tspan = [0 10]; 

% Simulate.
[out] = s.simulate(tspan,x0,p,opt);

sp.plotAllStates(out);
