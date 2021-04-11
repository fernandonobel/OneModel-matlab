%% Stand-alone use of the class.

m = OneModel.load('./model/proteinClass.mc');

s = SimulationClass(m);
[out] = s.simulate();

sp = SimulationPlotClass(m);
figure();
sp.plotAllStates(out);

%% Use the class defined in other model.

m = OneModel.load('./model/model.mc');

s = SimulationClass(m);
[out] = s.simulate();

sp = SimulationPlotClass(m);
figure();
sp.plotAllStates(out);
