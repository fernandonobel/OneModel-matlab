classdef VariableClass < SymbolClass
  %% VARIABLECLASS This class defines a variable value or state.
  %
  
  properties
    % bool Is the variable no negative?
    isNoNegative
    % plot Should the variable be plot?
    isPlot
    % [Real Real] x-limits for plotting.
    xlim
    % [Real Real] y-limits for plotting.
    ylim
    % [char] Label for the x axis.
    xlabel
    % [char] Label for teh y axis.
    ylabel
    % [char] Title used for plotting.
    title
  end % properties

  methods 
  
    function [obj] = VariableClass(name)
      %% Constructor of VariableClass.
      %
      % param: name Name of the symbol. 

      obj = obj@SymbolClass(name);
      obj.isNoNegative = false;
      obj.isPlot = true;
      obj.xlim = [-inf inf];
      obj.ylim = [-inf inf];
      obj.xlabel = 'Time (t)';
      obj.ylabel = 'Concentration [A.U.]';
      obj.title = obj.name;
      
    end % VariableClass

    function [] =  set.isNoNegative(obj,isNoNegative)
      %% SET.ISNONEGATIVE Set interface for isNoNegative propierty.
      %
      % param: isNoNegative
      %
      % return: void
      
      if ~islogical(isNoNegative)
        error('isNoNegative must be logical.');
      end

      obj.isNoNegative = isNoNegative;
      
    end % set.isNoNegative

    function [] =  set.isPlot(obj,isPlot)
      %% SET.ISPLOT Set interface for isPlot propierty.
      %
      % param: isPlot
      %
      % return: void

      if ~islogical(isPlot);
        error('isPlot must be logical.');
      end

      obj.isPlot = isPlot;
      
    end % set.isPlot

  function [] =  set.xlim(obj,xlim)
      %% SET.XLIM Set interface for xlim propierty.
      %
      % param: xlim
      %
      % return: void

      if ~isnumeric(xlim) || sum((size(xlim) ~= [1 2]))
        error('xlim must be numeric and [1 2] size.');
      end
      
      obj.xlim = xlim;
      
    end % set.xlim

    function [] =  set.ylim(obj,ylim)
      %% SET.YLIM Set interface for ylim propierty.
      %
      % param: ylim
      %
      % return: void

      if ~isnumeric(ylim) || sum((size(ylim) ~= [1 2]))
        error('ylim must be numeric and [1 2] size.');
      end
      
      obj.ylim = ylim;
      
    end % set.ylim
    	
    function [] =  set.xlabel(obj,xlabel)
      %% SET.XLABEL Set interface for xlabel propierty.
      %
      % param: xlabel
      %
      % return: void

      if ~ischar(xlabel) 
        error('xlabel must be a char array.');
      end
      
      obj.xlabel = xlabel;
      
    end % set.xlabel

    function [] =  set.ylabel(obj,ylabel)
      %% SET.YLABEL Set interface for ylabel propierty.
      %
      % param: ylabel
      %
      % return: void

      if ~ischar(ylabel) 
        error('ylabel must be a char array.');
      end
      
      obj.ylabel = ylabel;
      
    end % set.title

    function [] =  set.title(obj,title)
      %% SET.TITLE Set interface for title propierty.
      %
      % param: title
      %
      % return: void

      if ~ischar(title) 
        error('title must be a char array.');
      end
      
      obj.title = title;
      
    end % set.title

  end % methods
  
end % classdef
