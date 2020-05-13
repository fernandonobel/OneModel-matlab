classdef VariableClass < SymbolClass
  %% VARIABLECLASS This class defines a variable value or state.
  %
  
  properties
    % bool Is the variable algebraic?
    isAlgebraic
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
      obj.isAlgebraic = false;
      obj.isNoNegative = false;
      obj.isPlot = true;
      obj.xlim = [-inf inf];
      obj.ylim = [-inf inf];
      obj.xlabel = '';
      obj.ylabel = '';
      obj.title = obj.name
      
    end % VariableClass
    	
  end % methods
  
end % classdef
