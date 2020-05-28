% I would like to represent the reference of the baseModel.mc dynamically.

% First, extend the functionality defined in baseModel.mc.
extends ./baseModel.mc;

% Then, add a variable for the reference.
Variable ref(isAlgebraic=true);

% And add the equation to calculate the reference value.
Equation ref  == k3/d3;
