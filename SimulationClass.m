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
    % Substitution vars model.
    subsModel
    % Mass matrix for DAE.
    massMatrix                         
    % Function that evaluates fast the DAE model.
    fncDaeModel                     
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
    function [out] =  simulate(obj,tspan,x0,p,opt)
      %% SIMULATE Simulate the symbolic model.
      %
      % param: tspan [tStart, tEnd] Time interval for the simulation.
      %      : x0 [real] Initial conditions.
      %      : p real. Parameters.
      %      : opt Options for the ode.
      %
      % return: out real. Struct with the result of the simulation.

      if nargin < 5
        opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
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
      fn = fieldnames(p);

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

      x0 = zeros(1,length(obj.model.vars));
      for i = 1:length(obj.model.vars)
        x0(i) = out.(obj.model.varsName{i})(end);
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

      % Check format of x0
      if isstruct(x0)
        x0 = obj.stateArrayFromNamedStruct(x0);
      end

      % Check if the initial conditions match the number of states.
      if length(x0) ~= length(obj.model.vars)
        error('The number of initial conditions do not match with the number of states');
      end

      % Combine the user parameters with the deaults of the model.
      p = obj.combineParam(p);

      % Simulate
      %             [t,x] = ode15s(@(t,x) obj.f_model_odes(t,x,p),tspan,x0,opt);
      [t,x] = ode15s(@(t,x) obj.noNegativeWrapper(t,x,p,obj.fncDaeModel),tspan,x0,opt);

      xSubs = [];
      for i = 1:length(t)
        xSubs = [xSubs; obj.fncSubsModel(t(i),x(i,:)',p)];
      end
      x = [x xSubs];

    end % simulateTX

    function [out] = combineParam(obj,p)
      %% COMBINEPARAM Combines the value of the parameters defined in the model
      % with the parameters p defined for the simulation.
      %
      % Parameters defined in ModelClass have a value protierty, this value is
      % used as a default value if the user does not provide a value for that
      % Parameter in the p struct passed to the simulation.
      %
      % param: p Parameters introduced by the user.
      %
      % return: out Paramters including the default values if needed.

      out = [];
      pDefault = [];

      for i = 1:length(obj.model.params)
        pDefault.(char(obj.model.params(i))) = obj.model.paramsValue(i);
      end

      f = fieldnames(pDefault);

      for i = 1:length(f)
        try 
          out.(f{i}) = p.(f{i});
        catch
          out.(f{i}) = pDefault.(f{i});
        end

        % Check if the parameter has been initialized.
        if isnan(out.(f{i}))
          error('Value of ''%s'' was not defined.', f{i});
        end
      end

    end % combineParam

    function [out] =  stateArrayFromNamedStruct(obj,x0)
      %% STATEARRAYFROMNAMEDSTRUCT Return a intial conditon vector from a struct.
      %
      % param: x0 real. Initial condition struct.
      %
      % return: out Initial condition array.

      out = zeros(1,length(obj.model.vars));
      for i = 1:length(obj.model.vars)
        try
          out(i) = x0.(obj.model.varsName{i});
        catch
          % By default initial states are zero.
          out(i) = 0.0;
        end
      end

    end % stateArrayFromNamedStruct

    function [out] =  noNegativeWrapper(obj,t,x,p,func)
      %% NONEGATIVEWRAPPER Chek that the states don't become negative if the
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

    function [] =  createOdeFunction(obj,name)
      %% CREATEODEFUNCTION Create a matlab function that evaluates the ODE 
      % of the model.
      %
      % param: name [char] Name of the file where the funtion is saved.
      %
      % return: void

      if nargin < 2
        name = [class(obj.model) 'OdeFun'];
      end

      % Write ModelClassV2 model to file.
      fm = fopen([name, '.m'],'w');

      % Function definition.
      aux=compose("function [dxdt] =  %s(t,x,p)", name);
      fprintf(fm,'%s\n',aux);

      % Main comment of the function.
      aux=compose(...
        "%%%% %s Function that evaluates the ODEs of %s.",...
      upper(name),class(obj.model));
      fprintf(fm,'%s\n',aux);

      % Secondary comment.
      aux=compose(...
        "%% This function was autogenerated by the %s.",...
      class(obj));
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
      for i = 1:length(obj.model.vars)
        aux=compose("%% x(%d,:) = %s",i, char(obj.model.vars(i)));
        fprintf(fm,'%s',aux);
        if (obj.model.varsIsAlgebraic(i))
          aux=compose("\t %% (Algebraic state)");
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
    end % createOdeFunction

    function [] =  createDriverOdeFunction(obj,name)
      %% CREATEDRIVERODEFUNCTION  Creates a driver script for simulating the ODE
      % function.
      %
      % param: name [char] Name of the driver for the der function.
      %
      % return: void

      if nargin < 2
        name = [class(obj.model) 'DriverOdeFun'];
      end

      % Open driver file.
      fm = fopen([name, '.m'],'w');

      % Scrit main comment.
      aux=compose(...
        "%%%% Driver script for simulating the ODE function %s", ...
      name);
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
      fprintf(fm,'%% Initial condition.\n',aux);
      fprintf(fm,'x0 = [\n',aux);

      for i = 1:length(obj.model.vars)
        aux=compose(...
          "\t 0.0 %% %s",...
        char(obj.model.vars(i)));
        fprintf(fm,'%s\n',aux);
      end

      fprintf(fm,'];\n\n',aux);

      % Paremeters definition.
      fprintf(fm,'%% Definition of parameters of the model.\n',aux);

      params = obj.model.params;
      for i = 1:length(params)
        aux=compose(...
          "p.%s = 1.0;",...
        char(params(i)));
        fprintf(fm,'%s\n',aux);
      end

      fprintf(fm,'\n',aux);

      % Simulate using the ode15s and using previous defined parameters.
      aux=compose(...
        "[t,x] = ode15s(@(t,x) modelOdeFun(t,x,p), tspan, x0, opt);"...
        );
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

      for i = 2:length(obj.model.vars)
        aux=compose(...
          ",'%s'",...
          char(obj.model.vars(i)));
        fprintf(fm,'%s',aux);
      end

      fprintf(fm,');\n');
      fprintf(fm,'grid on;\n');

    end % createDriverOdeFunction

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

      while any(ismember(symvar(out).', subsVars.', 'rows'))
        out = subs(out,subsVars,subsEqns);
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
