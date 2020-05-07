classdef (Abstract) ModelClass < handle
  %% MODELCLASS This class simplifies working with ODE models.
  % The main idea is to simplify the work of building a ODE model,
  % and therefore reducing the time spent in this process. The main
  % utilities of this class are: (i) doing simulations from symbolic
  % ODEs, (ii) linearize the model at the equilibrium point, (iii)
  % calculate eigenvalues. Using this class has many advantages like
  % having to code less, it is easier to maintain ODE models and all 
  % your models will have these utilities.

  properties

  end % properties

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
    % Array with structs with all the information of the model.
    symbols             
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
    function [s] =  newSymbol(~)
      %% NEWSYMBOL Create a default new symbol.
      %
      % return: s Default new symbol.

      s.name = '';
      s.eqn = '';
      s.isAlgebraic = false;
      s.xlim = [-inf inf];
      s.ylim = [-inf inf];
      s.xlabel = 'Time [t]';
      s.ylabel = '[a.u.]';
      s.title = '';
      s.noNegative = false;
      s.plot = true;
      s.name_tex = ''; % Name for LaTeX generation.
    end % newSymbol

    function [] =  addSymbol(obj,s)
      %% ADDSYMBOL Add a symbol to the model.
      %
      % param: s Symbol to add.

      s = obj.checkSymbol(s);

      if isempty(obj.symbols)
        obj.symbols = s;
      else
        obj.symbols(end+1) = s;
      end
    end % addSymbol

    function [s] =  checkSymbol(obj,s)
      %% CHECKSYMBOL Check that the symbol is well configured.
      %
      % param: s Symbol to check.
      % 
      % return: s Symbol checked.

      % If state does not have a title, just use the name for the
      % title.
      if strcmp(s.title,'')
        s.title = s.name;
      end

      % If state does not have a name_tex, just use the name for the
      % name_tex.
      if strcmp(s.name_tex,'')
        s.name_tex = s.name;
      end

      % Check if the name of the state is already used.
      if obj.getSymbolIndex(s.name) ~= -1
        error(['Error: Symbol name "' s.name 
        '" is already used. Change the name of one of the symbols.']);
      end

      % Check is the state is algebraic.
      if isempty(strfind(s.eqn,['d_' s.name]))
        s.isAlgebraic = true;
      end
    end % checkSymbol

    function [ind] =  getSymbolIndex(obj,name)
      %% GETSYMBOLINDEX Get the index of a symbol by its name.
      % Return -1 if symbol not found.
      %
      % param: name Name of the symbol.
      %
      % return: ind Index of the symbol.

      for i = 1:length(obj.symbols)
        if strcmp(obj.symbols(i).name,name)
          ind = i;
          return;
        end
      end
      ind = -1;
    end % getSymbolIndex

    function [s] =  getSymbol(obj,name)
      %% GETSYMBOL Get a symbol by its name.
      %
      % param: name Name of the symbol.
      %
      % return: s Symbol found.

      ind = obj.GetSymbolIndex(name);
      s = obj.symbols(ind);
    end % getSymbol

    function [] =  updateSymbol(obj,s)
      %% UPDATESYMBOL Update the information of a symbol.
      %
      % param: s Symbol with the updated information.

      ind = obj.GetSymbolIndex(s.name);
      obj.symbols(ind) = s;
    end % updateSymbol

  end % methods

  %% Model data.
  methods
    function [out] =  get.vars(obj)
      %% GET.VARS Get symbolic variables of the model.
      %
      % return: out Symbolic varibles array.

      out = str2sym({obj.symbols.name}).';
    end % get.vars

    function [out] =  get.varsIsAlgebraic(obj)
      %% GET.VARSISALGEBRAIC Are the variables algebraics?
      % Get a boolean array, if true the varibale corresponding to that 
      % index is algebraic.
      %
      % return: out Boolean array.

      out = [obj.symbols.isAlgebraic].';
    end % get.varsIsAlgebraic

    function [out] =  get.varsName(obj)
      %% GET.VARSNAME  Get vars name.
      %
      % return: out {[char]} Names of the vars of the model.
      
      out = {obj.symbols.name}.';
    end % get.varsName

    function [out] =  get.varsIsNoNegative(obj)
      %% GET.VARSNONEGATIVE Get no negative vars.
      %
      % return: out [bool] True if the var on that index is no negative.

      out = [obj.symbols.noNegative];
      
    end % get.varsNoNegative

    function [out] =  get.varsIndexNoNegative(obj)
      %% GET.VARSINDEXNONEGATIVE Get index of no negative vars.
      %
      % return: out [int] Index of no negative vars.

      out = [];

      for i = 1:length(obj.symbols)
        if obj.symbols(i).noNegative == true
          out(end+1) = i;
        end
      end
      
    end % get.varsIndexNoNegative


    function [out] =  get.varsPlot(obj)
      %% GET.VARSPLOT Should var be plotted?
      %
      % return: out [bool] varsPlot.

      out  = [obj.symbols.plot];
    end % get.varsPlot

    function [out] =  get.eqns(obj)
      %% GET.EQNS Get symbolic equations of the model.
      %
      % return: out Symbolic equations array.

      out = str2sym({obj.symbols.eqn}).';
    end % get.eqns


    function [out] =  get.eqnsLeft(obj)
      %% GET.EQNSLEFT Get left equal part of the equations of the model.
      %
      % return: out Simbolic left part of equations.

      ind_equal = cellfun(@(x) strfind(x,'='),...
        {obj.symbols.eqn},'Uni',0);

      out = cellfun(@(x,y) x(1:y(1)-1),...
        {obj.symbols.eqn},ind_equal,'Uni',0);

      out = str2sym(out).';
    end % get.eqnsLeft

    function [out] =  get.eqnsRight(obj)
      %% GET.EQNSRIGHT Get right equal part of the equations of the model.
      %
      % return: out Simbolic right part of equations.

      ind_equal = cellfun(@(x) strfind(x,'='),...
        {obj.symbols.eqn},'Uni',false);

      out = cellfun(@(x,y) x(y(2)+1:end),...
        {obj.symbols.eqn},ind_equal,'Uni',false);

      out = str2sym(out).';
    end % get.eqnsRight

    function [out] =  get.ders(obj)
      %% GET.DERS Get derivatives of variables of the model.
      %
      % return: out Symbolic derivatives.

      out = cellfun(@(x) sym(['d_' x]),...
        {obj.symbols([obj.symbols.isAlgebraic]==false).name}...
        ,'Uni',false);
      out = [out{:}];
    end % get.ders


    function [out] =  get.params(obj)
      %% GET.PARAMS Get symbolic parameters of the model.
      %
      % return: out Symbolic parameters array.

      out = sym([]);

      % Init model params
      aux = '';
      for i = 1:length(obj.symbols)
        aux = [aux char(obj.eqns(i)) ' '];
      end

      ind = false(size(aux));
      % Search for everything but words.
      % Words cannot start with a number but they can contain numbers.
      ind(regexp(aux,'\W|(?<=[0-9])[a-zA-Z]')) = true;
      aux(ind)= ' ';
      % Remove numbers that follow an empty space.
      while 1
        ind_old = ind;
        ind(regexp(aux,'(?<=\s)\d')) = true;
        aux(ind)= ' ';
        if ~sum(ind ~= ind_old)
          break;
        end
      end
      aux = split(aux);
      aux = sort(aux);

      [~,idx]=unique(  strcat(aux(:)) );
      aux = aux(idx,:); % List of string of all symbolic params.

      % Remove vars from the list.
      ind = ismember(aux,arrayfun(@char, obj.vars, 'uniform', 0));
      aux = aux(~ind);
      % Remove ders form the list.
      ind = ismember(aux,arrayfun(@char, obj.ders, 'uniform', 0));
      aux = aux(~ind);
      % Remove void.
      ind = ismember(aux,'');
      aux = aux(~ind);

      for i = 1:length(aux)
        out(i) = str2sym(aux{i});
      end
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
