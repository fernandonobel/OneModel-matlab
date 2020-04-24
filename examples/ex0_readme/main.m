%% 1. Model definition

m = model();

m.vars
m.eqns
%% 2. Simulation

s = Simulation(m);

t = [0 10];

p.k1 = 1.0;
p.k2 = 1.0;
p.k3 = 1.0;
p.gamma12 = 1.0;
p.d1 = 1.0;
p.d2 = 1.0;
p.d3 = 1.0;

x0.x1 = 0.000000;
x0.x2 = 0.000000;
x0.x3 = 0.000000;

opt = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

[out] = s.simulate(t,x0,p,opt);

out
%% 3. Plot simulation results

s.plotAllStates(out);
print('simulationPlot','-dpng')

%% 4. Function that evaluates the ODEs
% TODO:
% m.CreateDerFunction();
