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
  properties 
    % When defining the model it is possible to declare Varibles and Equations
    % that are just a substitution of variables or parameters. Then this
    % subsitution equations are only useful for grouping terms to simplify the
    % reading of the model but these equation do not provide new relationships
    % between variables. So normally, we would like to work with the
    % susbtitution (model not reduced) but sometimes (for simulation purposes)
    % it is better to have the model without out any of these intermediate 
    % variables (model reduced). For this purpose it is defined the property 
    % 'isReduced' to swicth between these two behaivours.

    % bool Use the extended model?
    isReduced = false
  end

  properties (Dependent)
    % [sym] Variables of the model.      
    vars                
    % [bool] Is an algebraic variable?     
    varsIsAlgebraic
    % {[char]} Names of the vars of the model.
    varsName
    % [real] Initial condition of the vars.
    varsStart
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
    % [bool] Is the equation just a substitution of vars?
    isSubs
    % [sym] Parameters of the model.
    params              
    % {[char]} Names of the parameters of the model.
    paramsName
    % [real] Default value of the parameters.
    paramsValue 
    % {[char]} Names of the symbols of the model.
    symbolsName
    % [bool] Should the symbol be plotted?
    symbolsIsPlot
  end % propierties (Dependent)

  %properties (Dependent, Access = private)
  properties (Dependent, Access = public)
    % [int] Index that match each variable with the related equation.
    varIndex 
  end % properties (Dependent)

  properties % (Access = private)
    % [SymbolClass] Arrta with all the symbols of the model.
    symbols
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

  % ModelClass propierties.
  methods
    function [] = set.isReduced(obj,isReduced)
      %% SET.ISREDUCED Set interface for isReduced propierty.
      %
      % param: isReduced [bool] Use the reduced model?.
      %
      % return: void

      if ~islogical(isReduced)
        error('isReduced must be logical.');
      end

      obj.isReduced = isReduced;
      
    end % set.isReduced
    
  end % methods

  %% Model definition.
  methods
    function [] =  addVariable(obj,v)
      %% ADDVARIABLE Add a variable to the model.
      %
      % param: v Variable to include.
      %
      % return: void

      if isempty(obj.variables)
        obj.variables = v;
      else
        obj.variables(end+1) = v;
      end

      if isempty(obj.symbols)
        obj.symbols{1} = v;
      else
        obj.symbols{end+1} = v;
      end

    end % addVariable

    function [] =  addParameter(obj,p)
      %% ADDVARIABLE Add a parameter to the model.
      %
      % param: p Parameter to include.
      %
      % return: void

      if isempty(obj.parameters)
        obj.parameters = p;
      else
        obj.parameters(end+1) = p;
      end

      if isempty(obj.symbols)
        obj.symbols{1} = p;
      else
        obj.symbols{end+1} = p;
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

    function [out] = getSymbolByName(obj,name)
      %% GETSYMBOLBYNAME Get the Symbol (Variable or Parameter) object by its 
      % name.
      %
      % param: name [char] String with the name of the Symbol.
      %
      % return: out Variable Object symbol.

      aux = obj.isReduced;
      obj.isReduced = false;

      names = obj.symbolsName();

      out = obj.symbols{strcmp(name, names)};
      
      obj.isReduced = aux;

    end % getSymbolByName

    function [] = checkValidModel(obj)
      %% CHECKVALIDMODEL Check if the model is valid. 
      % This involves: 
      %   (1) duplicate use of symbols names.
      %
      % return: void


      % (1) Check if there is duplicate use of symbols names.
      [U, I] = unique(obj.symbolsName, 'first');

      if length(obj.symbolsName) ~= length(U)
        % There are duplicates.
        duplicateNames = obj.symbolsName;
        duplicateNames(I) = [];
        
        error('The symbol name "%s" is duplicated in the model. Please change the name in one of its definitions.', duplicateNames{1});
      end
      
    end % checkValidModel

  end % methods

  %% Model data.
  methods
    function [out] =  get.vars(obj)
      %% GET.VARS Get symbolic variables of the model.
      %
      % return: out Symbolic varibles array.

      out = [obj.variables.nameSym].';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.vars

    function [out] =  get.varsIsAlgebraic(obj)
      %% GET.VARSISALGEBRAIC Are the variables algebraics?
      % Get a boolean array, if true the variable corresponding to that 
      % index is algebraic.
      %
      % return: out Boolean array.

      equations = [obj.equations(obj.varIndex)];

      for i = 1:length(obj.variables)
        out(i,1) = equations(i).isAlgebraic;
      end

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsIsAlgebraic

    function [out] =  get.varsName(obj)
      %% GET.VARSNAME  Get vars name.
      %
      % return: out {[char]} Names of the vars of the model.
      
      out = {obj.variables.name}.';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsName

    function [out] = get.varsStart(obj)
      %% GET.VARSSTART Get vars start.
      %
      % return: out [real] Initial condition values.
      
      out = [obj.variables.start];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end
      
    end % get.varsStart

    function [out] =  get.varsIsNoNegative(obj)
      %% GET.VARSNONEGATIVE Get no negative vars.
      %
      % return: out [bool] True if the var on that index is no negative.

      out = [];

      for i = 1:length(obj.variables)
        if obj.variables(i).isNoNegative == true
          out(end+1) = i;
        end
      end

      out = [obj.variables.isNoNegative];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

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

      % Return reduced model if needed.
      if obj.isReduced && ~isempty(out)
        out = out(~obj.isSubs);
      end
      
    end % get.varsIndexNoNegative


    function [out] =  get.varsPlot(obj)
      %% GET.VARSPLOT Should var be plotted?
      %
      % return: out [bool] varsPlot.

      out  = [obj.variables.isPlot];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsPlot

    function [out] = get.varIndex(obj)
      %% GET.VARINDEX Index that relates each variable with the equation that
      % calculate it.
      %
      % return: out [int] varIndex

      % It is necessay to order the eqns to math the order of the vars. This way
      % the process of simualtion is simplified a lot.

      % The number of free variables must match the number of equations.
      if length(obj.variables) ~= length(obj.equations)
        error('The number of free variables of the model does not match the number of equations');
      end

      % Index to match each equation to its corresponding free variable.
      eqnIndex = zeros(size(obj.variables));
      % Index to match each variable to its corresponding equations.
      varIndex = zeros(size(obj.variables));

      % First match equations with derivatives to the corresponding free
      % variable.
      for i = 1:length(obj.equations)
        ders = obj.equations(i).dersStr;

        if isempty(ders)
          continue;
        end

        for j = 1:length(obj.variables)
          if strcmp(ders,obj.variables(j).name)
            eqnIndex(i) = j;
            varIndex(j) = i;
          end
        end

      end
      
      % Now match substitution variables with the substitution equation.
      for i = 1:length(obj.equations)
        
        % Skip not subsitution equations.
        if ~obj.equations(i).isSubstitution
          continue;
        end
        
        for j = 1:length(obj.variables)
          if strcmp(obj.equations(i).varsStr(1),obj.variables(j).name)
            eqnIndex(i) = j;
            varIndex(j) = i;
          end
        end

      end

      % Then match the algebraic equation with the remaining freeVariables.
      knownVars = {obj.parameters.name obj.variables(eqnIndex(eqnIndex>0)).name};

      while ~isempty(find(eqnIndex==0))
        for i = 1:length(obj.equations)
          % If the equation has an index, skip it.
          if eqnIndex(i) > 0
            continue
          end
          
          % Check the number of free variables in the equantion.
          eqnVars = obj.equations(i).varsStr;
          eqnVars = eqnVars(~ismember(eqnVars,knownVars));

          % If there is only one free var.
          if length(eqnVars) == 1
            % We have a match!
            ind = find(ismember({obj.variables.name},eqnVars));
            eqnIndex(i) = ind;
            varIndex(ind) = i;
            % And add the var to known vars.
            knownVars(end+1) = eqnVars;
          end

        end
      end

      out = varIndex;

    end % get.varIndex
    
    function [out] =  get.eqns(obj)
      %% GET.EQNS Get symbolic equations of the model.
      %
      % return: out Symbolic equations array.

      out = [obj.equations(obj.varIndex).eqnSym].';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);

        obj.isReduced = false;

        subsVars = (obj.vars(obj.isSubs)).';
        subsEqns = obj.eqnsRight(obj.isSubs);

        obj.isReduced = true;
        
        while any(ismember(symvar(out).', subsVars.', 'rows'))
          out = subs(out,subsVars,subsEqns);
        end
      end

    end % get.eqns


    function [out] =  get.eqnsLeft(obj)
      %% GET.EQNSLEFT Get left equal part of the equations of the model.
      %
      % return: out Simbolic left part of equations.

      out = [obj.equations(obj.varIndex).left];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.eqnsLeft

    function [out] =  get.eqnsRight(obj)
      %% GET.EQNSRIGHT Get right equal part of the equations of the model.
      %
      % return: out Simbolic right part of equations.

      out = [obj.equations(obj.varIndex).right];

      % Return reduced model if needed.
      if obj.isReduced
        subsEqns = out(obj.isSubs);
        out = out(~obj.isSubs);

        obj.isReduced = false;

        subsVars = (obj.vars(obj.isSubs)).';

        obj.isReduced = true;
        
        while any(ismember(symvar(out).', subsVars.', 'rows'))
          out = subs(out,subsVars,subsEqns);
        end
      end

    end % get.eqnsRight

    function [out] =  get.ders(obj)
      %% GET.DERS Get derivatives of variables of the model.
      %
      % return: out Symbolic derivatives.

      out = cellfun(@(x) sym(['d_' x]),...
        {obj.variables.name}...
        ,'Uni',false);
      out = [out{:}];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.ders

    function [out] = get.isSubs(obj)
      %% GET.ISSUBS is the varible or equation just a substitution?
      %
      % return: out [bool] isSubs.

      out = [obj.variables.isSubstitution];
      
    end % get.isSubs


    function [out] =  get.params(obj)
      %% GET.PARAMS Get symbolic parameters of the model.
      %
      % return: out Symbolic parameters array.

      out = [obj.parameters.nameSym];
    end % get.params

    function [out] =  get.paramsName(obj)
      %% GET.PARASNAME  Get params name.
      %
      % return: out {[char]} Names of the params of the model.
      
      out = {obj.parameters.name}.';

    end % get.paramsName

    function [out] = get.paramsValue(obj)
      %% GET.PARAMSVALUE Get the defautl value of the parameters of the model.
      %
      % return: out [Real] Array with the default values of the parameters.

      out = [obj.parameters.value];

    end % get.paramsValue

    function [out] = get.symbols(obj)
      %% GET.SYMBOLSNAME Get symbols of the model.
      %
      % return: out {SymbolClass} symbols.

      out = {};

      for i = 1:length(obj.symbols)
        % Skip subsitution symbols if the model is reduced.
        if obj.symbols{i}.isSubstitution && obj.isReduced
          continue
        end

        out{end+1} = obj.symbols{i};
      end

    end
    
    function [out] =  get.symbolsName(obj)
      %% GET.SYMBOLSNAME Get symbols name.
      %
      % return: out {[char]} Names of the symbols of the model.
      
      out = {};
      for i = 1:length(obj.symbols)
        out{end+1} = obj.symbols{i}.name;
      end

    end % get.varsName

    function [out] = get.symbolsIsPlot(obj)
      %% GET.SYMBOLSISPLOT Should the symbol be plot?
      %
      % return: out [bool] symbolsIsPlot.

      out = [];
      for i = 1:length(obj.symbols)
        out(end+1) = obj.symbols{i}.isPlot;
      end
      
    end % get.symbolsIsPlot

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

  methods (Static)
    function [] = version(~)
      %% VERSION Prints the version of the ModelClass software.
      %
      % return: void

      [filepath, name, ext]  = fileparts(which('ModelClass.m'));

      pathVersion = [filepath '/version'];

      fid = fopen(pathVersion);

      tline = fgetl(fid);

      fclose(fid);

      disp([tline ' Fernando Nóbel (fersann1@upv.es)']);
      
    end % version
    
  end % methods

end % classdef
