function [dxdt] =  model2OdeFun(t,x,p)
%% MODEL2ODEFUN Function that evaluates the ODEs of model2.
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
% x(4,:) = ref

% der(x1)
dxdt(1,1) = p.k1-p.d1.*x(1,:)-p.gamma12.*x(1,:).*x(2,:);

% der(x2)
dxdt(2,1) = -p.d2.*x(2,:)+p.k3.*x(3,:)-p.gamma12.*x(1,:).*x(2,:);

% der(x3)
dxdt(3,1) = -p.d3.*x(3,:)+p.k3.*x(1,:);

% der(ref)
dxdt(4,1) = p.k3./p.d3;

end