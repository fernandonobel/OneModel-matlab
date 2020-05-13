classdef (Abstract) ModelClass < handle
  %% MODELCLASS This class simplifies working with ODE models.
  % The main idea is to simplify the work of building a ODE model,
  % and therefore reducing the time spent in this process. The main
  % utilities of this class are: (i) doing simulations from symbolic
  % ODEs, (ii) linearize the model at the equilibrium point, (iii)
  % calculate eigenvalues. Using this class has many advantages like
  % having to code less, it is easier to maintain ODE models and all 
  % your models will have these utilities.

  % Model data.
  properties (Dependent)
    % [sym] Variables of the model.      
    vars                
    % [bool] Is an algebraic variable?     
    varsIsAlgebraic
    % {[char]} Names of the vars of the model.
    varsName
    % [bool] Is an no negative state?
    varsIsNoNegative
    % [int] Index of variables that are no negative.
    varsIndexNoNegative
    % [bool] Should var be plotted?
    varsPlot
    % [sym] Equations of the model. 
    eqns                
    % [sym] Left part of the equations.
    eqnsLeft
    % [sym] Right part of the equations.
    eqnsRight          
    % [sym] Derivatives of the model.
    ders                
    % [sym] Parameters of the model.
    params              
  end % propierties (Dependent)

  properties % (Access = private)
    % [VariableClass] Array with all the variables of the model.
    variables
    % [ParameterClass] Array with all the parameters of the model.
    parameters
    % [EquationClass] Array with all the equationf of the model.
    equations
  end % Propierties (Access = private)

  %% Contructors
  methods
    function [obj] =  ModelClass()
      %% MODELCLASS Constructor of Model Class.
      %
      % return: obj ModelClass object.

    end % ModelClass
  end % methods

  %% Symbol manipulation.
  methods
    function [] =  addVariable(obj,v)
      %% ADDVARIABLE Add a variable to the model.
      %
      % param: v Variable to include.
      %
      % return: void

      v.checkSymbol();

      if isempty(obj.variables)
        obj.variables = v;
      else
        obj.variables(end+1) = v;
      end
    end % addVariable

    function [] =  addParameter(obj,p)
      %% ADDVARIABLE Add a parameter to the model.
      %
      % param: p Parameter to include.
      %
      % return: void

      p.checkSymbol();

      if isempty(obj.parameters)
        obj.parameters = p;
      else
        obj.parameters(end+1) = p;
      end
    end % addParameter

    function [] =  addEquation(obj,e)
      %% ADDVARIABLE Add an equation to the model.
      %
      % param: e Equation to include.
      %
      % return: void

      if isempty(obj.equations)
        obj.equations = e;
      else
        obj.equations(end+1) = e;
      end
    end % addEquation

  end % methods

  %% Model data.
  methods
    function [out] =  get.vars(obj)
      %% GET.VARS Get symbolic variables of the model.
      %
      % return: out Symbolic varibles array.

      out = [obj.variables.nameSym].';
    end % get.vars

    function [out] =  get.varsIsAlgebraic(obj)
      %% GET.VARSISALGEBRAIC Are the variables algebraics?
      % Get a boolean array, if true the varibale corresponding to that 
      % index is algebraic.
      %
      % return: out Boolean array.

      out = [obj.variables.isAlgebraic].';
    end % get.varsIsAlgebraic

    function [out] =  get.varsName(obj)
      %% GET.VARSNAME  Get vars name.
      %
      % return: out {[char]} Names of the vars of the model.
      
      out = {obj.variables.name}.';
    end % get.varsName

    function [out] =  get.varsIsNoNegative(obj)
      %% GET.VARSNONEGATIVE Get no negative vars.
      %
      % return: out [bool] True if the var on that index is no negative.

      out = [obj.variables.isNoNegative];
      
    end % get.varsNoNegative

    function [out] =  get.varsIndexNoNegative(obj)
      %% GET.VARSINDEXNONEGATIVE Get index of no negative vars.
      %
      % return: out [int] Index of no negative vars.

      out = [];

      for i = 1:length(obj.variables)
        if obj.variables(i).isNoNegative == true
          out(end+1) = i;
        end
      end
      
    end % get.varsIndexNoNegative


    function [out] =  get.varsPlot(obj)
      %% GET.VARSPLOT Should var be plotted?
      %
      % return: out [bool] varsPlot.

      out  = [obj.variables.isPlot];
    end % get.varsPlot

    function [out] =  get.eqns(obj)
      %% GET.EQNS Get symbolic equations of the model.
      %
      % return: out Symbolic equations array.

      out = [obj.equations.nameSym].';
    end % get.eqns


    function [out] =  get.eqnsLeft(obj)
      %% GET.EQNSLEFT Get left equal part of the equations of the model.
      %
      % return: out Simbolic left part of equations.

      out = [obj.equations.left];
    end % get.eqnsLeft

    function [out] =  get.eqnsRight(obj)
      %% GET.EQNSRIGHT Get right equal part of the equations of the model.
      %
      % return: out Simbolic right part of equations.

      out = [obj.equations.right];
    end % get.eqnsRight

    function [out] =  get.ders(obj)
      %% GET.DERS Get derivatives of variables of the model.
      %
      % return: out Symbolic derivatives.

      out = cellfun(@(x) sym(['d_' x]),...
        {obj.variables.name}...
        ,'Uni',false);
      out = [out{:}];
    end % get.ders


    function [out] =  get.params(obj)
      %% GET.PARAMS Get symbolic parameters of the model.
      %
      % return: out Symbolic parameters array.

      out = [obj.parameters.nameSym];
    end % get.params

  end % methods

  %% Utils
  methods
    function [f_exp] = symbolic2MatlabFunction(obj,exp,newHeader)
            % Convert a general symbrootLocusSweep(obj,p_ini,p_end,varargin)olic expression into a well formated
            % matlab function.
            
            % Convert symbolic ODE into a function.
            f = matlabFunction(exp);
            % Convert function into string.
            sf = func2str(f);
            aux = sf;
            % Add 'p.' to all state and parameters.
            ind = false(size(sf));
            % Search for everything but words.
            % Words cannot start with a number but they can contain numbers.
            ind(regexp(aux,'\W|(?<=[0-9])[a-zA-Z]')) = true;
            aux(ind)= ' ';
            % Remove numbers that follow an empty space.
            while 1
                ind_old = ind;
                ind(regexp(aux,'(?<=\s)\d')) = true;
                aux(ind)= ' ';
                offset = 0;
                if ~sum(ind ~= ind_old)
                    break;
                end
            end
            
            for i = regexp(aux,'\w*')
                words = (split(aux(i:end)));
                word = words{1};
                
                if (exist(word,'builtin')==5)
                    continue;
                end
                
                if (strcmp(word,'t'))
                    continue;
                end
                
                sf = insertAfter(sf,i-1+offset,"p.");
                offset = offset +2;
                
            end
            % Remove the header.
            sf = extractAfter(sf,min(strfind(sf,')')));
            % Add the new header.
            sf = strcat('@(',newHeader,')',sf);
            
            % Replace the name of each var for x(i).
            for i = 1:length(obj.vars)
                expr = strcat('p\.',obj.varsName{i},'\>');
                [start,final]=regexp(sf,expr);
                start = flip(start);
                final = flip(final);
                for j = 1:size(start,2)
                    sf = replaceBetween(sf,start(j),final(j),strcat('x(', num2str(i),',:)'));
                end
            end
            % Convert the final string into a func.
            f_exp = str2func(sf);

        end % symbolic2MatlabFunction
 
  end % methods

end % classdef
