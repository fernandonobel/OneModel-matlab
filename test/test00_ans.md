``` MATLAB%% 1. Model definition

m = model();

m.vars
m.eqns
%% 2. Simulation

s = SimulationClass(m);

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

% sp = SimulationPlotClass(m);

% sp.plotAllStates(out);

%% 4. Function that evaluates the ODEs
% TODO:
% m.CreateDerFunction();
```

```
ans =
 
  x1
  x2
  x3
 ref
 
 
ans =
 
    d_x1 == k1 - d1*x1 - gamma12*x1*x2
 d_x2 == k2*x3 - d2*x2 - gamma12*x1*x2
                 d_x3 == k3*x1 - d3*x3
                          ref == k3/d3
 

out = 

  struct with fields:

      t: [154x1 double]
     x1: [154x1 double]
     x2: [154x1 double]
     x3: [154x1 double]
    ref: [154x1 double]
```
