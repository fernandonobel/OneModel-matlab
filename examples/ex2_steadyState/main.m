%% Init the model and the tools for simulating
m = OneModel.load('./model/model.mc');
s = SimulationClass(m);
sp = SimulationPlotClass(m);

% Define intial state, parameters.
x0 = [];
p = [];

% Define the options for the simulator.
opt = odeset('AbsTol', 1e-3, 'RelTol', 1e-6);

%% Simulate normally the model.
% This way, we need to define a long enough time span to reach the steady
% state.

% Simulation time span.
tspan = [0 10]; 

% Simulate.
[out_1] = s.simulate(tspan,x0,p,opt);

%% Simulate until steady state is reached.
% We are going to define an event to stop the simulation when the steady
% state is reached.

% We do not need to worry about simulation time span, as it will stop due
% to the event.
tspan = [0 +inf]; 

% Define the tolerance to determine the steady state.
% Try changing this value to see its effect.
tol = 1e-2;

% Set the event for ending the simulation when steady state is reached.
opt = s.optSteadyState(opt,p,tol);

% Simulate.
[out_2] = s.simulate(tspan,x0,p,opt);

%% Calculate the steady state.
% We can use this method to calculate the steady state directly.

% Get the steady state.
[out_3] = s.simulateSteadyState(x0,p);

%% Plot the result and see that the simulation has been stop way before the 
% defined time span.
figure(1);
clf(1);

hold on;
grid on;
plot(out_1.t,out_1.x);
plot(out_2.t,out_2.x,'--','LineWidth',1.5);
plot(out_1.t(end),out_3.x,'o','LineWidth',2);
legend('simulate','optSteadyState','simulateSteadyState','Location','SouthEast');
