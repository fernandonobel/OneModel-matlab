mp = ModelClassParser('Model.mc');

mp.parse();
    

m = Model();

s = SimulationClass(m);

[out] = s.simulate();

sp = SimulationPlotClass(m);

figure(1);
clf(1);

sp.plotAllStates(out);
