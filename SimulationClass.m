classdef SimulationClass < handle
  %% SIMULATIONCLASS This class simulates ModelClass models.
  %

  properties
    % ModelClass object to simulate.
    model
  end % properties

  properties 
    % DAE model.
    daeModel                       
    % Albegraic model.
    algebraicModel
    % Substitution vars model.
    subsModel
    % Mass matrix for DAE.
    massMatrix                         
    % Function that evaluates fast the DAE model.
    fncDaeModel                     
    % Function that evaluates fast the algebraic model.
    fncAlgebraicModel                     
    % Function that evaluates fast the substitution vars model.
    fncSubsModel
  end % properties (Dependent)

  %% Contructors.
  methods 
    function [obj] =  SimulationClass(model)
      %% SIMULATION  Constructor of Simulation class.
      %
      % param: model ModelClass object to simulate.
      %
      % return: obj SimulationClass object.

      obj.model = model;

    end % Simulation
  end % methods

  %% Simulation methods.
  methods
    function [out] =  simulate(obj,varargin)
      %% SIMULATE Simulate the symbolic model.
      %
      % simulate(obj) Simulate the symbolic model using the default values
      % defined in the ModelClass object.
      %
      % simulate(obj,tspan,x0,p,opt) Simulate the symbolic model using the user
      % defined parameters for the simulation. Is any of the arguments is [],
      % the default value will be used.
      %
      % param: tspan [tStart, tEnd] Time interval for the simulation.
      %      : x0 [real] Initial conditions.
      %      : p real. Parameters.
      %      : opt Options for the ode.
      %
      % return: out real. Struct with the result of the simulation.

      if nargin == 1
        tspan = [];
        x0 = [];
        p = [];
        opt = [];
      else
        tspan = varargin{1};
        x0 = varargin{2};
        p = varargin{3};
        opt = varargin{4};
      end

      if isempty(tspan)
        % Use the default value.
        tspan = obj.model.simOptions.TimeSpan;
      end

      if isempty(opt)
        % Use the default value.
        opt = obj.model.simOptions.opts;
      else
        % Override the default value with the new one.
        opt = odeset(obj.model.simOptions.opts,opt);
      end

      aux = obj.model.isReduced;
      obj.model.isReduced = true;

      % Simulate
      [t,x,p] = obj.simulateTX(tspan,x0,p,opt);

      obj.model.isReduced = false;
      % Return sim results in a struct.
      out.t = t;

      % SimulateTX changes the normal order of the states.
      indexSwap = 1:length(obj.model.varsName);
      indexSwap = [indexSwap(~obj.model.isSubs) indexSwap(obj.model.isSubs)];

      for i = 1:length(obj.model.varsName)
        out.(obj.model.varsName{indexSwap(i)}) = x(:,i);
      end

      % Add the parameter value to the out.
      if isempty(p)
          fn = [];
      else
        fn = fieldnames(p);
      end

      for i = 1:length(fn)
        out.(fn{i}) = p.(fn{i})*ones(size(t));
      end

      obj.model.isReduced = aux;

    end % simulate

    function [out] =  simulateContinue(obj,tadd,out,p,opt)
      %% SIMULATECONTINUE Continue simulating an exisiting simulation result.
      %
      % param: tadd real Additional time to simulate.
      %      : out real. Output of a previous simulation.
      %      : p real. Parameters.
      %      : opt Options for the ode.
      %
      % return: out real. Struct with the result of the simulation.

      aux = obj.model.isReduced;
      obj.model.isReduced = true;

      x0 = [];
      for i = 1:obj.model.varsNum
        x0.(obj.model.varsName{i}) = out.(obj.model.varsName{i})(end);
      end
      tspan = [out.t(end) out.t(end)+tadd];

      % Simulate
      [out_new] = obj.simulate(tspan,x0,p,opt);

      % Concat new out to previous out
      out = concatStruct(out, out_new);

      obj.model.isReduced = aux;

    end % simulateContinue

    function [t,x,p] =  simulateTX(obj,tspan,x0,p,opt)
      %% SIMULATETX 
      %
      % param: tspan [tStart, tEnd] Time interval for the simulation.
      %      : x0 [real] Initial conditions.
      %      : p real. Parameters.
      %      : opt Options for the ode.
      %
      % return: t [real] Time of the simulation.
      %       : x [[reall]] States of the simulaton.

      % Simulate the model and return [t,x]
      if nargin < 5
        opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
      end

      opt = odeset(opt,'Mass',obj.massMatrix);

      % Combine the user initial conditions with the defaults of the model.
      x0 = obj.combineInitialCondition(x0);
      
      % Check format of x0
      if isstruct(x0)
        x0 = obj.stateArrayFromNamedStruct(x0);
      end

      % Combine the user parameters with the defaults of the model.
      p = obj.combineParam(p);

      % Check if the initial conditions match the number of states.
      if length(x0) ~= obj.model.varsNum
        error('The number of initial conditions do not match with the number of states');
      end

      % Simulate
      % TODO: Make optional the noNegativeWrapper because it is slow.
      % [t,x] = ode15s(@(t,x) obj.noNegativeWrapper(t,x,p,obj.fncDaeModel),tspan,x0,opt);
      [t,x] = ode15s(@(t,x) obj.fncDaeModel(t,x,p),tspan,x0,opt);

      % Calculate the susbtitution variables.
      obj.model.isReduced = false;
      totalVars = obj.model.varsNum;
      obj.model.isReduced = true;
      
      xSubs = zeros(length(t),totalVars-obj.model.varsNum);
      
      for i = 1:length(t)
        xSubs(i,:) = obj.fncSubsModel(t(i),x(i,:)',p);
      end
      
      x = [x xSubs];

    end % simulateTX

    function [out, out_tx] = simulateSteadyState(obj,x0,p,tol,mTime,opt)
      %% STEADYSTATE Simulates until the steady state is reached.
      %
      % param: x0 real. Struct with the intial condition.
      %        p  real. Struct with the parameters values.
      %        tol real Tolerance for determining steady state.
      %        mTime real Maximum simulation time in seconds.
      %        opt Options for the fsolve.
      %
      % return: out Steady state values.
      %         out_tx Output of the simulation.
      
      if nargin < 4
        tol = [];
      end
      
      if nargin < 5
        mTime = 10;
      end

      if nargin < 6
        opt = [];
      end

      sTime = tic;

      % Set the event for ending the simulation when steady state is reached.
      opt = obj.optSteadyState(opt,p,tol,sTime,mTime);

      % Run the simulation endlessly.
      out = obj.simulate([0 +inf],x0,p,opt);

      % Save the simulation temporal evolution.
      out_tx = out;
      
      % Return only the last value of the simulation;
      fn = fieldnames(out);
      for i = 1:length(fn)
          out.(fn{i}) = out.(fn{i})(end);
      end 

    end % steadyState
    
    function [value,isterminal,direction] =  eventSteadyState(obj,t,x,p,tol,sTime,mTime)
      %% EVALUATEDERIVATIVE This function is an Event for ode that will stop the
      % simulation when the steady state is reached.
      %
      % If the simulation last more than mTime, stop the simulation. This avoids
      % endless simulations.
      %
      % param: t real Time for the evaluation.
      %      : x [real] State vector.
      %      : p real. Parameters.
      %      : tol rel Tolerance for determining the steady state.
      %      : sTime Start time returned with tic().
      %      : mTime real Maximum simulation time in seconds.
      %
      % return: [value,isteminal,direction] Return data need for an Event.

      if nargin < 6
        sTime = -1;
      end

      if nargin < 7
        mTime = 10;
      end

      if sTime ~= -1
        if toc(sTime) > mTime
          error('The simulation for finding the steady state takes more time to compute that the maximum time limit which is set to %s seconds.',num2str(mTime));
        end
      end
      % Evaluate the derivatives.
      dxdt = obj.fncDaeModel(t,x,p);

      dxdt = sum(abs(dxdt));

      if dxdt < tol
        value = 0; % Stop the simulation.
      else
        value = 1; % Keep on with simulation.
      end

      isterminal = 1; % Stop the integration
      direction = 0; % Negative direction only

    end % eventSteadyState

    function [opt] = optSteadyState(obj,opt,p,tol,sTime,mTime)
      %% OPTSTEADYSTATE Set the event for simulating until steady state is
      % reached
      %
      % param: opt Options for the ODE function.
      %      : p real. Struct with the parameters of the model.
      %      : tol real Tolerance for determining the steady state.
      %      : sTime Start time returned with tic().
      %      : mTime real Maximum simulation time in seconds.
      %
      % return: opt Options with the event for steady state.

      if ~exist('tol','var') || isempty(tol)
        tol = 1e-6;
      end

      if nargin < 5
        sTime = -1;
      end

      if nargin < 6
        mTime = 1;
      end
  
      % Combine the user parameters with the defaults of the model.
      p = obj.combineParam(p);
      
      opt = odeset(opt,'Events',@(t,y) obj.eventSteadyState(t,y,p,tol,sTime,mTime));

    end % State

    function [out] = combineInitialCondition(obj,x0)
      %% COMBINEINITIALCONDITION Combines the value of the initial conditions
      % defined in the model with the x0 defined for the simulation.
      %
      % Variables defined in ModelClass have a start property, this value is
      % used as a default value if the user does not provide a value for that
      % Variable in the x0 struct passed to the simulation.
      %
      % param: x0 Initial condition introduced by the user.
      %
      % return: out

      out = [];

      varsName = obj.model.varsName;
      varsStart = obj.model.varsStart;

      for i = 1:obj.model.varsNum
        out.(varsName{i}) = varsStart(i);
      end
      
      if isempty(x0)
        f = [];
      else
        f = fieldnames(x0);
      end

      for i = 1:length(f)
          out.(f{i}) = x0.(f{i});  
      end
      
    end % combineInitialCondition

    function [out] = combineParam(obj,p)
      %% COMBINEPARAM Combines the value of the parameters defined in the model
      % with the parameters p defined for the simulation.
      %
      % Parameters defined in ModelClass have a value property, this value is
      % used as a default value if the user does not provide a value for that
      % Parameter in the p struct passed to the simulation.
      %
      % param: p Parameters introduced by the user.
      %
      % return: out Paramters including the default values if needed.

      out = [];
     
      paramsName = obj.model.paramsName;
      paramsValue = obj.model.paramsValue;

      for i = 1:length(paramsName)
        out.(paramsName{i}) = paramsValue(i);
      end

      if isempty(p)
        f = [];
      else
        f = fieldnames(p);
      end
      
      for i = 1:length(f)
          out.(f{i}) = p.(f{i});
      end

    end % combineParam

    function [out] =  stateArrayFromNamedStruct(obj,x0)
      %% STATEARRAYFROMNAMEDSTRUCT Return a intial conditon vector from a struct.
      %
      % param: x0 real. Initial condition struct.
      %
      % return: out Initial condition array.

      out = zeros(1,obj.model.varsNum);
      for i = 1:obj.model.varsNum
        try
          out(i) = x0.(obj.model.varsName{i});
        catch
          error('initial condition was not defined.');
        end
      end

    end % stateArrayFromNamedStruct

    function [out] =  noNegativeWrapper(obj,t,x,p,func)
      %% NONEGATIVEWRAPPER Check that the states don't become negative if the
      % state is set to noNegative.
      %
      % param: t real Time.
      %      : x [real] States.
      %      : p real. Parameters.
      %      : func Fucntion that evaluates the ODE.
      %
      % return: out

      out = func(t,x,p);

      % For each state no negative state
      for i = 1:length(obj.model.varsIndexNoNegative)
        % Check it der wants to make negative the state.
        if x(obj.model.varsIndexNoNegative(i)) <= 0 && out(obj.model.varsIndexNoNegative(i)) <= 0
          % Is so, make der zero.
          out(obj.model.varsIndexNoNegative(i),1) = 0;
        end
      end
    end % noNegativeWrapper

    function [out] = initialConditionWrapper(obj,t,xAlgebraic,x0,p)
      %% INITIALCONDITIONWRAPPER Combines the initial conditions to be
      % compatible with fsolve funtions.
      %
      % param: t real Time.
      %      : xAlgebraic [real] Algebraic initial condition in a row vector.
      %      : x0 [real] Initial condition vector as used in simulatTX. It
      %        contains both the algebraic and derivatives intial conditions.
      %      : p real. Parameters.
      %
      % return: out [real] Output of the algebraic model that should be zero.
      
      x0Ders = x0.*~obj.model.varsIsAlgebraic';

      ind = find(obj.model.varsIsAlgebraic);
      x(ind) = xAlgebraic;
      
      out = obj.fncAlgebraicModel(t,(x0Ders+x)',p);
      
    end % initialConditionWrapper

    function [] =  generateOdeFunction(obj,name)
      %% GENERATEODEFUNCTION Generate a matlab function that evaluates the ODE 
      % of the model.
      %
      % param: name [char] Name of the file where the funtion is saved.
      %
      % return: void

      if nargin < 2
        name = [class(obj.model) 'OdeFun'];
      end
      
      tokenReduced = obj.model.isReduced;
      obj.model.isReduced = true;

      % Write ModelClassV2 model to file.
      fm = fopen(['./build/' name '.m'],'w');

      % Function definition.
      aux=compose("function [dxdt] =  %s(t,x,p)", name);
      fprintf(fm,'%s\n',aux);

      % Main comment of the function.
      aux=compose(...
        "%%%% %s Function that evaluates the ODEs of %s.mc",...
      upper(name),class(obj.model));
      fprintf(fm,'%s\n',aux);

      % Secondary comment.
      aux=compose(...
        "%% This function was autogenerated with ModelClass %s.",...
      ModelClass.version());
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'%%\n',aux);

      % Param comment.
      aux=compose(...
        "%% param: t Current time in the simulation.");
      fprintf(fm,'%s\n',aux);

      aux=compose(...
        "%%      : x Vector with states values.");
      fprintf(fm,'%s\n',aux);

      aux=compose(...
        "%%      : p Struct with the parameters.");
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'%%\n',aux);

      % Return comment.
      aux=compose(...
        "%% return: dxdt Vector with derivatives values.");
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'\n',aux);

      % Define states.
      aux=compose("%% States");
      fprintf(fm,'%s\n',aux);
      for i = 1:obj.model.varsNum
        aux=compose("%% x(%d,:) = %s",i, char(obj.model.vars(i)));
        fprintf(fm,'%s',aux);
        if (obj.model.varsIsAlgebraic(i))
          aux=compose(" %% (Algebraic state)");
          fprintf(fm,'%s',aux);
        end
        fprintf(fm,'\n');
      end
      fprintf(fm,'\n');

      % Write ODEs.
      sf = char(obj.fncDaeModel);
      % Remove the header.
      sf = extractAfter(sf,min(strfind(sf,'[')));
      % Remove the end bracket.
      sf = extractBefore(sf,min(strfind(sf,']')));
      odes = split(sf,';');

      for i = 1:length(obj.daeModel)
        aux=compose("%% der(%s)", char(obj.model.vars(i)));
        fprintf(fm,'%s',aux);

        % Comment if it is an algebraic state.
        if obj.model.varsIsAlgebraic(i)
          aux=compose(" (Algebraic state)");
          fprintf(fm,'%s',aux);
        end

        % Comment if it is an no negative state.
        if obj.model.varsIsNoNegative(i)
          aux=compose(" (No negative)");
          fprintf(fm,'%s',aux);
        end

        fprintf(fm,'\n');
        aux=compose("dxdt(%d,1) = %s;", i, odes{i} );
        fprintf(fm,'%s',aux);

        % Avoid negative states.
        if obj.model.varsIsNoNegative(i)
          fprintf(fm,'\n\n');

          aux=compose("%% Check if the state tries to be negative.");
          fprintf(fm,'%s\n',aux);

          aux=compose("if x(%d,1) <= 0.0 && dxdt(%d,1) <= 0.0"...
          ,i,i);
          fprintf(fm,'%s',aux);

          fprintf(fm,'\n');
          aux=compose("dxdt(%d,1) = 0.0;"...
          ,i);
          fprintf(fm,'\t%s',aux);

          fprintf(fm,'\n');
          aux=compose("end");
          fprintf(fm,'%s',aux);
        end

        fprintf(fm,'\n\n');
      end

      fprintf(fm,"end");
      
      obj.model.isReduced = tokenReduced;
    end % generateOdeFunction

    function [] =  generateDriverOdeFunction(obj,name)
      %% GENERATEDRIVERODEFUNCTION  Generates a driver script for simulating the ODE
      % function.
      %
      % param: name [char] Name of the driver for the der function.
      %
      % return: void

      if nargin < 2
        name = [class(obj.model) 'DriverOdeFun'];
      end

      tokenReduced = obj.model.isReduced;
      obj.model.isReduced = true;
      
      % Open driver file.
      fm = fopen(['./build/' name '.m'],'w');

      % Scrit main comment.
      aux=compose(...
        "%%%% Driver script for simulating the ODE function %s", ...
      name);
      fprintf(fm,'%s\n',aux);

      % Secondary comment.
      aux=compose(...
        "%% This script was autogenerated with ModelClass %s.",...
      ModelClass.version());
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'\n',aux);

      fprintf(fm,'clear all;\n',aux);
      fprintf(fm,'close all;\n\n');

      % Define mass matrix.
      aux=compose(...
        "%% Mass matrix for algebraic simulations."...
      );
      fprintf(fm,'%s\n',aux);

      aux=compose(...
        "M = ["...
        );
      fprintf(fm,'%s\n',aux);

      for i = 1:size(obj.massMatrix,1)
        fprintf(fm,'\t');
        fprintf(fm,'%g\t',obj.massMatrix(i,:));
        fprintf(fm,'\n');
      end

      aux=compose(...
        "];"...
        );
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'\n',aux);

      % Options for the solver.
      aux=compose(...
        "%% Options for the solver.\nopt = odeset('AbsTol',1e-8,'RelTol',1e-8);"...
      );
      fprintf(fm,'%s\n',aux);

      % In DAE simualtions, the mass matrix is needed.
      aux=compose(...
        "opt = odeset(opt,'Mass',M);"...
        );
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'\n',aux);

      % Simulation time span.
      fprintf(fm,'%% Simulation time span.\n',aux);
      aux=compose(...
        "tspan = [0 10];"...
        );
      fprintf(fm,'%s\n\n',aux);

      % Initial condition for the model.
      fprintf(fm,'%% Default initial condition value.\n',aux);
      fprintf(fm,'x0 = [\n',aux);

      for i = 1:obj.model.varsNum
        aux=compose(...
          "\t %e %% %s",...
        obj.model.varsStart(i),...
        char(obj.model.vars(i)));
        fprintf(fm,'%s\n',aux);
      end

      fprintf(fm,'];\n\n',aux);

      % Paremeters definition.
      fprintf(fm,'%% Default parameters value.\n',aux);

      params = obj.model.params;
      for i = 1:length(params)
        aux=compose(...
          "p.%s = %e;",...
        char(params(i)),...
        obj.model.paramsValue(i));
        fprintf(fm,'%s\n',aux);
      end

      fprintf(fm,'\n',aux);

      % Simulate using the ode15s and using previous defined parameters.
      aux=compose(...
        "[t,x] = ode15s(@(t,x) %sOdeFun(t,x,p), tspan, x0, opt);",...
        class(obj.model));
      fprintf(fm,'%s\n',aux);

      fprintf(fm,'\n',aux);

      % Plot the result of the simulation.
      fprintf(fm,'plot(t,x);\n');

      % Plot a legend.
      fprintf(fm,'legend(');

      aux=compose(...
        "'%s'",...
        char(obj.model.vars(1)));
      fprintf(fm,'%s',aux);

      for i = 2:obj.model.varsNum
        aux=compose(...
          ",'%s'",...
          char(obj.model.vars(i)));
        fprintf(fm,'%s',aux);
      end

      fprintf(fm,');\n');
      fprintf(fm,'grid on;\n');
      
      obj.model.isReduced = tokenReduced;

    end % generateDriverOdeFunction

    function [out] =  get.daeModel(obj)
      %% GET.DAEMODEL Get DAE model.
      %
      % return: out [sym] DAE model.

      out = sym([]);

      vars = obj.model.vars;
      varsIsAlgebraic = obj.model.varsIsAlgebraic;
      eqnsRight = obj.model.eqnsRight;
      eqnsLeft = obj.model.eqnsLeft;

      for i = 1:length(vars)
        if varsIsAlgebraic(i)
          out(i,1) = eqnsRight(i) - eqnsLeft(i);
        else
          out(i,1) = eqnsRight(i);
        end
      end

    end % get.daeModel

    function [out] = get.algebraicModel(obj)
      %% GET.ALGEBRAICMODEL Get the algebraic equations of the model.
      %
      % return: out [sym] Algebraic model.
      
      out = obj.daeModel(obj.model.varsIsAlgebraic);
      
    end % get.algebraicModel

    function [out] = get.subsModel(obj)
      %% GET.SUBSMODEL Get the substitution model, the equations that evaluate the
      % substitution variables from the state variables.
      %
      % return: out [sym] subsModel.

      % Calculate substitution variables.
      obj.model.isReduced = false;
      subsVars = obj.model.vars(obj.model.isSubs).';
      subsEqns = obj.model.eqnsRight(obj.model.isSubs);

      out = subsEqns;

      if ~isempty(subsVars)
             
        aux = true;
        
        while aux
            try
                aux = any(ismember(symvar(out).', subsVars.', 'rows'));
            catch
                aux = false;
            end
          out = subs(out,subsVars,subsEqns);
        end
      
      end

      obj.model.isReduced = true;

    end % get.subsModel

    function [out] =  get.massMatrix(obj)
      %% GET.MASSMATRIX get Mass matrix for DAE.
      %
      % return: out [[real]] Mass matrix.

      if isempty(obj.massMatrix)
        out = diag(1-obj.model.varsIsAlgebraic);
        obj.massMatrix = out;
      else
        out = obj.massMatrix;
      end

    end % get.massMatrix


    function [out] =  get.fncDaeModel(obj)
      %% GET.FNCDAEMODEL Get function that evaluates the DAE model.
      %
      % return: out Function handler that evaluates the DAE model.

      if isempty(obj.fncDaeModel)
        out = obj.model.symbolic2MatlabFunction(obj.daeModel,'t,x,p');
        obj.fncDaeModel = out;
      else
        out = obj.fncDaeModel;
      end

    end % get.fncDaeModel

    function [out] = get.fncAlgebraicModel(obj)
      %% GET.FNCALGEBRAICMODEL Get function that evaluates the algebraic model.
      %
      % return: out Function handler that evaluates the algebraic model.

      if isempty(obj.fncAlgebraicModel)
        out = obj.model.symbolic2MatlabFunction(obj.algebraicModel,'t,x,p');
        obj.fncAlgebraicModel = out;
      else
        out = obj.fncAlgebraicModel;
      end

    end % get.fncAlgebraicModel

    function [out] = get.fncSubsModel(obj)
      %% GET.FNCSUBSMODEL Get function that evaluates the subsModel.
      %
      % return: out Function handler that evaluates the subsModel.

      if isempty(obj.fncSubsModel)
        out = obj.model.symbolic2MatlabFunction(obj.subsModel,'t,x,p');
        obj.fncSubsModel = out;
      else
        out = obj.fncSubsModel;
      end

    end % get.fncSubsModel

  end % methods

end % classdef
