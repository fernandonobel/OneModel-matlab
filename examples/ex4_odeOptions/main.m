%% Init the model and the tools for simulating
m = ModelClass.load('./model/model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

%% Simulate with default values.
[out] = s.simulate();
sp.plotAllStates(out);

%% Simulate with user defined values.
tspan = 0:10;
p.k = 2;
x0.x = 1;

opt = odeset('AbsTol',1e-1);
[out] = s.simulate(tspan,x0,p,opt);
sp.plotAllStates(out);