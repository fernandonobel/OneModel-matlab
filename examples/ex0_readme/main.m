%% 1. Model definition from chemical reactions

% TODO:
% [Yir,model] = getCSVModel('chemical_reactions_model');
% constructModelClass(model,Yir);

%% 2. Simbolic model

m = model();
m.vars
m.eqns

%% 3. Function that evaluates the ODEs

% TODO:
% m.CreateDerFunction();

%% 4. Simulation

m = model();

s = Simulation(m);

t = [0 10];
p = m.parameters();
x0 = m.initialCondition();
opt = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

[out] = s.simulate(t,x0,p,opt);

s.plotAllStates(out);



