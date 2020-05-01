classdef SimulationClass < handle
  %% SIMULATION This class simulates ModelClass models.
  %

  properties
    % ModelClass object to simulate.
    model
    % Names of vars plotted in each plot of the subplot.
    plotNames                    
    % Rows in the subplot.
    rows                        
    % Columns in the subplot. 
    cols                        
  end % properties

  properties (Dependent)
    % DAE model.
    daeModel                       
    % Mass matrix for DAE.
    massMatrix                         
    % Function that evaluates fast the DAE model.
    fncDaeModel                     
  end % properties (Dependent)

  %% Contructors.
  methods 
    function [obj] =  SimulationClass(model)
      %% SIMULATION  Constructor of Simulatin class.
      %
      % return: out Simulation object.

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

      % Simulate
      [t,x] = obj.simulateTX(tspan,x0,p,opt);

      % Return sim results in a struct.
      out.t = t;
      for i = 1:length(obj.model.vars)
        out.(obj.model.varsName{i}) = x(:,i);
      end
    end % simulate

    function [out] =  simulateContinue(obj,tadd,out,opt,p)
      %% SIMULATECONTINUE Continue simulating an exisiting simulation result.
      %
      % param: tadd real Additional time to simulate.
      %      : out real. Output of a previous simulation.
      %      : opt Options for the ode.
      %      : p real. Parameters.
      %
      % return: out real. Struct with the result of the simulation.

      x0 = zeros(1,length(obj.model.vars));
      for i = 1:length(obj.model.vars)
        x0(i) = out.(obj.model.vars_name{i})(end);
      end
      tspan = [out.t(end) out.t(end)+tadd];

      % Simulate
      [out_new] = obj.simulate(tspan,x0,opt,p);

      % Concat new out to previous out
      out = concatStruct(out, out_new);
    end % simulateContinue

    function [t,x] =  simulateTX(obj,tspan,x0,p,opt)
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
        error('ERROR: The number of initial conditions do not match with the number of states');
      end

      % Save the fncModel to avoid recalculate it as it is a Dependet parameter.
      fncModel = obj.fncDaeModel;
      % Simulate
      %             [t,x] = ode15s(@(t,x) obj.f_model_odes(t,x,p),tspan,x0,opt);
      [t,x] = ode15s(@(t,x) obj.noNegativeWrapper(t,x,p,fncModel),tspan,x0,opt);
    end % simulateTX

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

    function [] =  createDerFunction(obj,name)
      %% CREATEDERFUNCTION Create matlab function that evaluates the ODE 
      % of the model.
      %
      % param: name [char] Name of the file where the funtion is saved.
      %
      % return: void

      if nargin < 2
        name = [class(obj) '_der'];
      end

      % Write ModelClassV2 model to file.
      fm = fopen([name, '.m'],'w');

      % Function definition.
      aux=compose("function [out] =  %s(t,x,p)", name);
      fprintf(fm,'%s\n',aux);

      % Main comment of the function.
      aux=compose("%% Autogenerated function that evaluates the ODEs of the model %s.", class(obj));
      fprintf(fm,'%s\n\n',aux);

      % Define states.
      aux=compose("%% States");
      fprintf(fm,'%s\n',aux);
      for i = 1:length(obj.model.vars)
        aux=compose("%% x(%d,:) = %s",i, char(obj.model.vars));
        fprintf(fm,'%s',aux);
        if (obj.model.vars)
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
        aux=compose("%% der(%s)", char(obj.vars(i)));
        fprintf(fm,'%s',aux);
        if obj.vars_isAlgebraic(i)
          aux=compose(" (Algebraic state)");
          fprintf(fm,'%s',aux);
        end
        fprintf(fm,'\n');
        aux=compose("out(%d,1) = %s;", i, odes{i} );
        fprintf(fm,'%s',aux);

        fprintf(fm,'\n\n');
      end

      fprintf(fm,"end");
    end % createDerFunction

    function [out] =  get.daeModel(obj)
      %% GET.DAEMODEL Get DAE model.
      %
      % return: out [sym] DAE model.

      out = sym([]);

      for i = 1:length(obj.model.vars)
        if obj.model.varsIsAlgebraic(i)
          out(i,1) = obj.model.eqnsRight(i) - obj.model.eqnsLeft(i);
        else
          out(i,1) = obj.model.eqnsRight(i);
        end
      end

    end % get.daeModel

    function [out] =  get.massMatrix(obj)
      %% GET.MASSMATRIX get Mass matrix for DAE.
      %
      % return: out [[real]] Mass matrix.

      out = diag(1-obj.model.varsIsAlgebraic);
    end % get.massMatrix


    function [out] =  get.fncDaeModel(obj)
      %% GET.FNCDAEMODEL Get function that evaluates the DAE model.
      %
      % return: out Function handler that evaluates the DAE mode.

      
      out = obj.model.symbolic2MatlabFunction(obj.daeModel,'t,x,p');
    end % get.fncDaeModel
  end % methods

  %% Plot simulation tools.
  methods
    function [] =  plotState(obj,out,name)
      %% PLOTSTATE Plot nicely one var.
      %
      % param: out real. Simulation result.
      %      : name [char] Name of the var to plot.
      %
      % return: void

      hold on;
      plot(out.t, out.(name));
      grid on;
      set(groot,'DefaultTextInterpreter','latex');

      i = obj.model.getSymbolIndex(name);
      if i >= 0
        xlim(obj.model.symbols(i).xlim);
        ylim(obj.model.symbols(i).ylim);
        xlabel(obj.model.symbols(i).xlabel);
        ylabel(obj.model.symbols(i).ylabel);
        title(obj.model.symbols(i).title);
      else
        title(name);
      end
    end % plotState


    function [] =  plotAllStates(obj,out,varargin)
      %% PLOTALLSTATES Plot all the variables of the model in subplots.
      %
      % param: out real. Simulation result.
      %      : varargin
      %
      % return: void

      p = inputParser;

      defaultNames = [];
      for i = 1:length(obj.model.vars)
        % Check if we want to plot that state
        if islogical(obj.model.varsPlot(i))
          if obj.model.varsPlot(i)
            defaultNames = strcat(defaultNames,obj.model.varsName(i)," ");
          end
        end
      end

      defaultXY = [-1 -1];

      addRequired(p,'obj',@isobject);
      addRequired(p,'out',@isstruct);
      addParameter(p,'names',defaultNames,@ischar);
      addParameter(p,'XY',defaultXY,@isvector);

      parse(p,obj,out,varargin{:});

      cellNames = textscan(p.Results.names,'%s','Delimiter',' ')';
      cellNames = cellNames{1};
      cellNames_num = length(cellNames);

      if p.Results.XY ~= -1
        obj.rows = p.Results.XY(1);
        obj.cols = p.Results.XY(2);
      else
        f = factor(cellNames_num);
        if cellNames_num >=4
          aux = 0;
          while length(f) == 1
            aux = aux +1;
            f = factor(cellNames_num+aux);
          end
        end

        if length(f) == 2
          obj.rows = max(f);
          obj.cols = min(f);
        else

          if cellNames_num >= 4
            x = 4;
          else
            x = cellNames_num;
          end
          y = ceil(cellNames_num/4);
          obj.rows = x;
          obj.cols = y;
        end
      end

      for i = 1:cellNames_num
        % Remap the index to draw each plot in the correct order.
        %                 [row,col] = ind2sub([obj.rows obj.cols],i);
        %                 j = col+(row-1)*obj.cols;
        % Plot the specific state.
        subplot(obj.rows,obj.cols,i);
        obj.plotState(out,cellNames{i});
      end

      obj.plotNames = cellNames;

      for i = 1:length(obj.model.symbols)
        if ischar(obj.model.symbols(i).plot)
          try
            obj.selectSubplotByName(obj.model.symbols(i).plot);
            plot(out.t, out.(obj.model.symbols(i).name));
          catch
          end
        end
      end
    end % plotAllStates

    function [] =  selectSubplotByName(obj,name)
      %% SELECTSUBPLOTBYNAME Focus on selected subplot by name.
      %
      % param: name [char] Name of the subplot.
      %
      % return: void

      % Make focus on seleparamsd subplot by name.
      ind = -1;
      for i = 1:length(obj.plotNames)
        if strcmp(obj.plotNames{i}, name)
          ind = i;
          break;
        end
      end

      if ind == -1
        error('Error: Selected name is not in the plot.');
      end

      subplot(...
        obj.rows,...
        obj.cols,...
        ind);
    end % selectSubplotByName

  end % methods

end % classdef
