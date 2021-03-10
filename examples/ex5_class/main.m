%% Stand-alone use of the class.

m = ModelClass.load('./model/proteinClass.mc');

s = SimulationClass(m);
[out] = s.simulate();

sp = SimulationPlotClass(m);
figure();
sp.plotAllStates(out);

%% Use the class defined in other model.

m = ModelClass.load('./model/model.mc');

s = SimulationClass(m);
[out] = s.simulate();

sp = SimulationPlotClass(m);
figure();
sp.plotAllStates(out);
