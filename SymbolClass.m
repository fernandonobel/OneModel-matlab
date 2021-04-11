classdef SymbolClass < ModelPartClass
  %% SYMBOLCLASS This class is a base for defining symbols for the OneModel.
  %

  properties
    % sym Symbolic name used for manipulating the symbol in equations.
    nameSym
    % [char] Name for LaTeX generation.
    nameTex
    % [char] Physical units of the symbol.
    units
    % [char] Comment of the symbol.
    comment
    % [char] Reference where the symbol value is from.
    reference
    % [real] Range of valid values for the symbol.
    range
    % plot Should the variable be plot?
    isPlot
    % [Real Real] x-limits for plotting.
    xlim
    % [Real Real] y-limits for plotting.
    ylim
    % [char] Label for the x axis.
    xlabel
    % [char] Label for the y axis.
    ylabel
    % [char] Title used for plotting.
    title
    % [char] Plot the variable in other plots.
    plotIn
    % bool Is the symbol just a substitution of variables?
    isSubstitution
    % bool Should the symbol be used for LaTex code generation?
    isTex
  end % properties

  methods 

    function [obj] = SymbolClass(mc, name)
      %% Constructor of ValueClass.
      %
      % param: mc   OneModel object.
      %        name Name of the symbol. 

      obj = obj@ModelPartClass(mc);

      % Define the name taking into account the namespace.
      name = [obj.namespace name];

      obj.name = name;
      obj.nameSym = sym(name);
      obj.nameTex = name;
      obj.isPlot = false;
      obj.xlim = [-inf inf];
      obj.ylim = [-inf inf];
      obj.xlabel = 'Time (t)';
      obj.ylabel = '';
      obj.title = obj.name;
      obj.plotIn = '';
      obj.isSubstitution = false;
      obj.isTex = true;

    end % SymbolClass

    function [] =  set.nameSym(obj,nameSym)
      %% SET.NAMESYM Set interface for nameSym propierty.
      %
      % param: nameSym sym Symbolic name.
      %
      % return: void

      if ~strcmp(class(nameSym),'sym')
        error('nameSym must be a symbolic expression.');
      end

      obj.nameSym = nameSym;

    end % set.nameSym

    function [] =  set.nameTex(obj,nameTex)
      %% SET.NAMETEX Set interface for nameTex propierty.
      %
      % param: nameTex [char] String with the named used for LaTeX.
      %
      % return: void

      if ~isstring(nameTex) && ~ischar(nameTex)
        error('nameTex must be a string.');
      end

      obj.nameTex = nameTex;

    end % set.nameTex

    function [] = set.units(obj,units)
      %% SET.UNITS Set interface for units propierty.
      %
      % param: units [char] Units.
      %
      % return: void

      if ~isstring(units) && ~ischar(units)
        error('units must be a string.');
      end

      obj.units = units;

      % If the ylabel is not defined.
      if strcmp(obj.ylabel,'')
        % Use the units.
        obj.ylabel = ['$[' obj.units ']$'];
      end

    end % set.units

    function [] = set.comment(obj,comment)
      %% SET.COMMENT Set interface for comment propierty.
      %
      % param: comment [char] Comment.
      %
      % return: void

      if ~isstring(comment) && ~ischar(comment)
        error('comment must be a string.');
      end

      obj.comment = comment;

    end % set.comment

    function [] = set.reference(obj,in)
      %% SET.REFERENCE Set interface for reference propierty.
      %
      % param: in [char] Reference.
      %
      % return: void

      if ~isstring(in) && ~ischar(in)
        error('reference must be a string.');
      end

      obj.reference = in;

    end % set.reference

    function [] = set.range(obj,in)
      %% SET.RANGE Set interface for range propierty.
      %
      % param: in [real] Range [min max].
      %
      % return: void

      if ~isnumeric(in) || sum((size(in) ~= [1 2]))
        error('range must be numeric and [1 2] size.');
      end

      obj.range = in;

    end % set.range

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

    function [] = set.plotIn(obj,plotIn)
      %% SET.PLOTIN Set interface for plotIn propierty.
      %
      % param: plotIn
      %
      % return: void

      if ~ischar(plotIn) 
        error('plotIn must be a char array.');
      end

      obj.plotIn = plotIn;

    end % set.plotIn

    function [] = set.isSubstitution(obj,isSubstitution)
      %% SET.ISSUBSTITUTION Set interface for isSubstitution propierty.
      %
      % param: isSubstitution
      %
      % return: void

      if ~islogical(isSubstitution)
        error('isSubstitution must be logical.');
      end

      obj.isSubstitution = isSubstitution;

    end % set.isSubstitution

  end % methods

end % classdef
