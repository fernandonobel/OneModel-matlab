%% Init the model and the tools for simulating
m = ModelClass.load('model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

% Simulate.
[out] = s.simulate();

sp.plotAllStates(out);