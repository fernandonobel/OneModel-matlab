% I would like to represent the reference of the baseModel.mc dynamically.

% First, extend the functionality defined in baseModel.mc.
import ./model/baseModel.mc;

% Then, add a variable for the reference.
variable ref;

% And add the equation to calculate the reference value.
equation ref == k3/d3;
