ModelClass
=========
ModelClass is a MATLAB class which simplifies working with ODE model. The main objetive is to simplify the process of coding and simulating an ODE model, and therefore reducing the time spent in this task. With ModelClass one can program ODE models from the symbolic equations and then simulate directly. This class provides also some functionality like OpenModelica (i.e. extendable classes, simulation of DAE models, etc).

Apart from that, ModelClass provides us more classes for different tasks. For example, there is a class for mathematical analysis that can calculate equilibrium points, linearize the model, and calculate eigenvalues from the model defined in ModelClass. On other hand, there is class for a contractivity test to check whether a model is contractive or no.

Lastly it is even possible to define ModelClass models from chemical reactions directly and then perform QSSA analysis and simulate.

For more information please contact fersann1@upv.es

# Installation

Download this repository into the directory of your choice. Then within MATLAB go to HOME/ENVIROMENT >> Set path and add the directory of the repository and the utils directory to the list (if they aren't already).

# Table of contents

* [Installation](#installation)
* [Table of contents](#table-of-contents)
* [Documentation](#documentation)
* [General workflow](#general-workflow)
	* [1. Obtaining a ModelClass model](#1-obtaining-a-modelclass-model)
	* [2. Simulate the ModelClass model](#2-simulate-the-modelclass-model)
	* [3. Plot simulation results](#3-plot-simulation-results)
	* [4. Generate an ODE function](#4-generate-an-ode-function)
	* [5. Mathematical analysis](#5-mathematical-analysis)
	* [6. Contractivity test](#6-contractivity-test)
	* [7. Parser of ModelClass models into LaTeX](#7-parser-of-modelclass-models-into-latex)


# Documentation

ModelClass has a documentation placed in the following [link](doc/README.md).

# General workflow

ModelClass is a class that allows us to define mathematical models in a standard way. Therefore, the first step in the general workflow should be parsing the mathematical model we want to study into the ModelClass framework. The examples of code given in the following subsections can be found in the ./examples/ex0_readme folder.

## 1. Obtaining a ModelClass model

There are multiple ways we can choose for obtaining a ModelClass model: (i) the most basic one is to write ourselves a class that extends the ModelClass and then use functions for defining the model, (ii) we can also define our model as chemical reactions and then use the parser of Jose Luis and (iii) we can extend a previous ModelClass model defined and extend it in a OpenModelica style (we can even combine different models into a single one).

It is expected that in the future there be more ways of generating ModelClass models. And this is one of the advantages of using this framework, the model are easier to code than coding ODE function directly and after that we can reuse ModelClass easily.

A ModelClass model will look something like this (./examples/ex0_readme/model.mc):

```MATLAB
% Variables

Variable x1;
Variable x2;
Variable x3;
Variable ref(value = k3/d3);

% Parameters

Parameter k1(value = 1.0);
Parameter k2(value = 1.0);
Parameter k3(value = 1.0);
Parameter d1(value = 1.0);
Parameter d2(value = 1.0);
Parameter d3(value = 1.0);
Parameter gamma12(value = 1.0);

% Equations

Equation der_x1 == k1    - gamma12*x1*x2 - d1*x1;
Equation der_x2 == k2*x3 - gamma12*x1*x2 - d2*x2;
Equation der_x3 == k3*x1 - d3*x3;
```

and the models are initialized with the following method:

```MATLAB

% Initialize an object of the model.
m = loadModelClass('model');

% Display variables and equations of the model.
m.vars
m.eqns
```

```
ans =
 
  x1
  x2
  x3
 ref
 
 
ans =
 
    der_x1 == k1 - d1*x1 - gamma12*x1*x2
 der_x2 == k2*x3 - d2*x2 - gamma12*x1*x2
                 der_x3 == k3*x1 - d3*x3
                            ref == k3/d3

```

## 2. Simulate the ModelClass model

Once we have a ModelClass model it is easy to start simulating it. We need to pass a ModelClass object of our model to the SimulationClass. Then we can configure the options for the simulation (e.g. parameters of the model, initial conditions, ODE configuration, which ODE solver to use, time span, ...). And finally we can use the functions for simulating and the SimulationClass will return a struct with the results of the simulation.

```MATLAB

% Initialize a SimulationClass object with the model data.
s = SimulationClass(m);

% Simulation time span.
tspan = [0 10];

% Parameters of the model.
p = []; % They are already defined in "model.mc"

% Intial conditions of the model.
x0.x1 = 0.000000;
x0.x2 = 0.000000;
x0.x3 = 0.000000;

% Options for the solver.
opt = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

% Simulate the model.
[out] = s.simulate(tspan,x0,p,opt);

% Result of the simulation.
out
```

```
out = 

  struct with fields:

          t: [154x1 double]
         x1: [154x1 double]
         x2: [154x1 double]
         x3: [154x1 double]
        ref: [154x1 double]
         k1: [154x1 double]
         k2: [154x1 double]
         k3: [154x1 double]
         d1: [154x1 double]
         d2: [154x1 double]
         d3: [154x1 double]
    gamma12: [154x1 double]
```

## 3. Plot simulation results

The SimulatePlotClass simplifies the task of plotting the result of simulations. And if we define plot configuration in our ModelClass, the PlotClass will use that information. This way do not need to provide it when plotting.

```MATLAB

% Initialize a SimulationPlotClass object with the model data.
sp = SimulationPlotClass(m);

% Plot the result of the simulation.
sp.plotAllStates(out);
```

<p align="center">
  <img width="850" src="./examples/ex0_readme/simulationPlot.png">
</p>

## 4. Generate an ODE function

We could use ModelClass as our main workflow for working with models. However there are situations where we want to obtain a matlab ODE function (i.e. a function that calculates the derivatives of the model form the states). In this case, there is a functionality in the SimulationClass that generates the ODE function automatically for us. Also it can generate a driver script that simulates using the generated ODE function (this script could be used as a start template for using the ODE function).

With the following code you can generate the ODE function and the driver script:

```MATLAB

% Create an ode function of the model.
s.createOdeFunction();
% Create the driver script for the ode function.
s.createDriverOdeFunction();

```


, the contents of the generated ODE funtion (./examples/ex0_readme/modelOdeFun.m) are:

```MATLAB
function [dxdt] =  modelOdeFun(t,x,p)
%% MODELODEFUN Function that evaluates the ODEs of model.
% This function was autogenerated by the SimulationClass.
%
% param: t Current time in the simulation.
%      : x Vector with states values.
%      : p Struct with the parameters.
%
% return: dxdt Vector with derivatives values.

% States
% x(1,:) = x1
% x(2,:) = x2
% x(3,:) = x3
% x(4,:) = ref	 % (Algebraic state)

% der(x1)
dxdt(1,1) = p.k1-p.d1.*x(1,:)-p.gamma12.*x(1,:).*x(2,:);

% der(x2)
dxdt(2,1) = -p.d2.*x(2,:)+p.k2.*x(3,:)-p.gamma12.*x(1,:).*x(2,:);

% der(x3)
dxdt(3,1) = -p.d3.*x(3,:)+p.k3.*x(1,:);

% der(ref) (Algebraic state)
dxdt(4,1) = -x(4,:)+p.k3./p.d3;

end
```

and the content of the generated driver script (./examples/ex0_readme/modelDriverOdeFun.m) are:

```MATLAB
%% Driver script for simulating the ODE function modelDriverOdeFun

clear all;
close all;

% Mass matrix for algebraic simulations.
M = [
	1	0	0	0	
	0	1	0	0	
	0	0	1	0	
	0	0	0	0	
];

% Options for the solver.
opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
opt = odeset(opt,'Mass',M);

% Simulation time span.
tspan = [0 10];

% Initial condition.
x0 = [
	 0.0 % x1
	 0.0 % x2
	 0.0 % x3
	 0.0 % ref
];

% Definition of parameters of the model.
p.k1 = 1.0;
p.k2 = 1.0;
p.k3 = 1.0;
p.d1 = 1.0;
p.d2 = 1.0;
p.d3 = 1.0;
p.gamma12 = 1.0;

[t,x] = ode15s(@(t,x) modelOdeFun(t,x,p), tspan, x0, opt);

plot(t,x);
legend('x1','x2','x3','ref');
grid on;
```

Finally, we can simulate by executing the driver script.

## 5. Mathematical analysis

Work in progress.

## 6. Contractivity test

Work in progress.

## 7. Parser of ModelClass models into LaTeX

Work in progress.


