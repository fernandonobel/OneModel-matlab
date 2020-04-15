ModelClass
=========
ModelClass is a MATLAB class that simplifies working with ODE models. The main idea is to simplify the work of building a ODE model, and therefore reducing the time spent in this process. The main utilities of this class are: (i) doing simulations from symbolic ODEs, (ii) linearize the model at the equilibrium point, (iii) calculate eigenvalues. Using this class has many advantages like having to code less, it is easier to maintain ODE models and all your models will have these utilities.
License: MIT
For more information please contact fersann1@upv.es
## Installation ##
Download this repository into the directory of your choice. Then within MATLAB go to file >> Set path... and add the directory of the repository to the list (if it isn't already). That's it.
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
### Función que evaluas las ODEs
```MATLAB
% TODO:
% m.CreateDerFunction();

```
### Simulación
```MATLAB
m = model();
s = Simulation(m);
t = [0 10];
p = m.parameters();
x0 = m.initialCondition();
opt = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);
[out] = s.simulate(t,x0,p,opt);
s.plotAllStates(out);


```
\resizebox{\textwidth}{!}{\input{./tikz/simulation.tex}}}
### Simulación DAE
```MATLAB
...
s = self.NewState();
s.name = 'x2';
s.eqn = 'd_x2 ==  + k2*x3 - gamma12*x1*x2 - d2*x2 ';
self.AddState(s);
...
```
La clase permite simular sistemas DAE (ode15s y ode23t).
```MATLAB
...
s = self.NewState();
s.name = 'x2';
s.eqn = '0 ==  + k2*x3 - gamma12*x1*x2 - d2*x2 ';
self.AddState(s);
...
```
\resizebox{\textwidth}{!}{\input{./tikz/simulationDAE.tex}}}
### Extender modelos estilo OpenModelica
```MATLAB
classdef AntitheticControllerSaturation < AntitheticController
  methods
    function [self] = AntitheticControllerSaturation()
      s = self.GetState('x3');
      s.eqn = 'd_x3 ==  + k3*x1/(h3+x1) - d3*x3 ';
      s.noNegative = true;
      s.title = 'Process (x3)';
      s.ylabel = 'Protein [nM]';
      self.UpdateState(s);
      
      s = self.NewState();
      s.name = 'x3_ref';
      s.eqn = 'x3_ref = k1/k2';
      s.plot = 'x3';
      self.AddState(s);
      
    end
  ...
```
\resizebox{0.4\textwidth}{!}{\input{./tikz/simulationREF.tex}}}
### Utilidades
% Permite calcular puntos de equilibrio numericos y simbolicos.
% Calcula el jacobiano, puede calcular los eigen values.
% Automatiza el análisis de contractividad.
#### Análisis matemático
Como tenemos un modelo simbólico podemos calcular:
    
- Puntos de equilibrio.
- Linealizar el modelo.
- Calcular eigen values.
- Jacobiano.
- Etc.
```
>> m = AntitheticController();
>> m.jacobian
 
ans =
 
[ - d1 - gamma12*x2,       -gamma12*x1,   0]
[       -gamma12*x2, - d2 - gamma12*x1,  k2]
[                k3,                 0, -d3]
```
#### Automatiza el análisis de contractividad
```
>> m = AntitheticController();
>> m.AssumeBiologic();
>> J = m.jacobian;
>> M = m.Calculate_M_matrix(J);
>> M1 = m.DeriveIMinor(M,2);
>> M2 = m.DeriveIMinor(M1,2);
>> simplify(M2 > 0)
ans =
 
 gamma12*k2*k3*x1 < d3*(d1*d2 + d1*gamma12*x1 + d2*gamma12*x2)
                                                          TRUE
                                                          TRUE
                                                          TRUE
```
## Trabajo futuro
- Hacer un GUI.
- Integrar completamente esta clase con el código de Jose Luis.
- Mejorar el solver del DAE (sólo resuelve DAEs del índice 1).
- Terminar de implementar el modelo multiescala.
