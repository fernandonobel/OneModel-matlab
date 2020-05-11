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
* [General workflow](#general-workflow)
	* [1. Obtaining a ModelClass model](#1-obtaining-a-modelclass-model)
	* [2. Simulate the ModelClass model](#2-simulate-the-modelclass-model)
	* [3. Plot simulation results](#3-plot-simulation-results)
	* [4. Generate an ODE function](#4-generate-an-ode-function)
	* [5. Mathematical analysis](#5-mathematical-analysis)
	* [6. Contractivity test](#6-contractivity-test)
	* [7. Parser of ModelClass models into LaTeX](#7-parser-of-modelclass-models-into-latex)


# General workflow

ModelClass is a class that allows us to define mathematical models in a standard way. Therefore, the first step in the general workflow should be parsing the mathematical model we want to study into the ModelClass framework.

## 1. Obtaining a ModelClass model

There are multiple ways we can choose for obtaining a ModelClass model: (i) the most basic one is to write ourselves a class that extends the ModelClass and then use functions for defining the model, (ii) we can also define our model as chemical reactions and then use the parser of Jose Luis and (iii) we can extend a previous ModelClass model defined and extend it in a OpenModelica style (we can even combine different models into a single one).

It is expected that in the future there be more ways of generating ModelClass models. And this is one of the advantages of using this framework, the model are easier to code than coding ODE function directly and after that we can reuse ModelClass easily.

```MATLAB
classdef model < ModelClass
  methods
    function [self] = model()
      s = self.newSymbol();
      s.name = 'x1';
      s.eqn = 'd_x1 ==  + k1 - gamma12*x1*x2 - d1*x1 ';
      self.addSymbol(s);

      s = self.newSymbol();
      s.name = 'x2';
      s.eqn = 'd_x2 ==  + k2*x3 - gamma12*x1*x2 - d2*x2 ';
      self.addSymbol(s);

      s = self.newSymbol();
      s.name = 'x3';
      s.eqn = 'd_x3 ==  + k3*x1 - d3*x3 ';
      self.addSymbol(s);
      
      s = self.newSymbol();
      s.name = 'ref';
      s.eqn = 'ref ==  k3/d3 ';
      self.addSymbol(s);
    end
  end
end
```

``` MATLAB
% Initialize an object of the model.
m = model();

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
 
    d_x1 == k1 - d1*x1 - gamma12*x1*x2
 d_x2 == k2*x3 - d2*x2 - gamma12*x1*x2
                 d_x3 == k3*x1 - d3*x3
                          ref == k3/d3

```

## 2. Simulate the ModelClass model

Once we have a ModelClass model it is easy to start simulating it. We need to pass a ModelClass object of our model to the SimulationClass. Then we can configure the options for the simulation (e.g. parameters of the model, initial conditions, ODE configuration, which ODE solver to use, time span, ...). And finally we can use the functions for simulating and the SimulationClass will return a struct with the results of the simulation.

``` MATLAB
% Initialize a SimulationClass object with the model data.
s = SimulationClass(m);

% Simulation time span.
tspan = [0 10];

% Parameters of the model.
p.k1 = 1.0;
p.k2 = 1.0;
p.k3 = 1.0;
p.gamma12 = 1.0;
p.d1 = 1.0;
p.d2 = 1.0;
p.d3 = 1.0;

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
```

## 3. Plot simulation results

The SimulatePlotClass simplifies the task of plotting the result of simulations. And if we define plot configuration in our ModelClass, the PlotClass will use that information and we wont need to provide it when plotting.

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

Work in progress.

We could use ModelClass as our main workflow for working with models. However there are situations that we want to obtain a matlab ODE function (i.e. a function that calculates the derivatives of the model form the states). In this case, there is a functionality in the SimulationClass that generates the ODE function automatically for us.

``` MATLAB
% Create an ode function of the model.
s.createOdeFunction();
% Create the driver script for the ode function.
s.createDriverOdeFunction();
```


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

## 5. Mathematical analysis

Work in progress.

## 6. Contractivity test

Work in progress.

## 7. Parser of ModelClass models into LaTeX

Work in progress.


