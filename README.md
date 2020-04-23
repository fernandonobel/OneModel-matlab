ModelClass
=========
ModelClass is a MATLAB class which simplifies working with ODE model. The main objetive is to simplify the process of coding and simulating an ODE model, and therefore reducing the time spent in this task. With ModelClass one can program ODE models directly from the symbolic equations and then simulate directly. This class provides also some functionality like OpenModelica (i.e. extendable classes, simulation of DAE models, etc).

Apart from that, ModelClass provides us more classes for different tasks. For example, there is a class for mathematical analysis that can calculate equilibrium points, linearize the model, and calculate eigenvalues from the model defined in ModelClass. On other hand, there is class for contractivity test to check whether a model is contractive or no.

Lastly it is even possible to define ModelClass models from chemical reactions directly and then perform QSSA analysis and simulate.

License: MIT
For more information please contact fersann1@upv.es

## Installation ##

Download this repository into the directory of your choice. Then within MATLAB go to HOME/ENVIROMENT >> Set path and add the directory of the repository and the utils directory to the list (if they aren't already).

## Usage ##

### Definición del modelo

La clase de Matlab es un ``parser" que permite traducir los modelos.
- Reacciones químicas.
- Modelo simbólico.
- Función Matlab que evalúa las derivadas.

### Modelo en reacciones químicas

```
'Reaction', 'kfwd', 'krev'
0 -> x1, k1 = 1.0
x3 -> x3 + x2, k2 = 1.0
x1 -> x1 + x3, k3 = 1.0
x1 + x2 -> 0, gamma12 = 1.0
x1 -> 0, d1 = 1.0
x2 -> 0, d2 = 1.0
x3 -> 0, d3 = 1.0
```

Gracias al código de Jose Luis podemos inicializar la clase con las reacciones.

```MATLAB 

% TODO:
% [Yir,model] = getCSVModel('chemical_reactions_model');
% constructModelClass(model,Yir);

```

Genera el archivo "model.m".

### Modelo de la clase de Matlab autogenerado

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
      s.noNegative = true;
      self.addSymbol(s);

      s = self.newSymbol();
      s.name = 'x3';
      s.eqn = 'd_x3 ==  + k3*x1 - d3*x3 ';
      s.noNegative = true;
      self.addSymbol(s);
      
      s = self.newSymbol();
      s.name = 'ref';
      s.eqn = 'ref ==  k3/d3 ';
      s.noNegative = true;
      self.addSymbol(s);
    end
    
    function [p] = parameters(~)
      p.k1 = 1.0;
      p.k2 = 1.0;
      p.k3 = 1.0;
      p.gamma12 = 1.0;
      p.d1 = 1.0;
      p.d2 = 1.0;
      p.d3 = 1.0;
    end
    
    function [x0] = initialCondition(~)
      x0.x1 = 0.000000;
      x0.x2 = 0.000000;
      x0.x3 = 0.000000;
    end
  end
end
```

### Modelo simbolico

```MATLAB exec ./examples/ex0_readme

m = model();
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

### Función que evaluas las ODEs

```MATLAB

% TODO:
% m.CreateDerFunction();

```


