m = ModelClass.load('Model.mc');

s = SimulationClass(m);

[out] = s.simulate();

sp = SimulationPlotClass(m);

figure(1);
clf(1);

sp.plotAllStates(out);
