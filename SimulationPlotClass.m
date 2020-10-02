classdef SimulationPlotClass < handle
  %% SIMULATIONPLOTCLASS This class plots the result of a simulation of the
  % SimulationClass.
  %

  properties
    % ModelClass object of the simulation.
    model    
    % Names of vars plotted in each plot of the subplot.
    plotNames                    
    % Rows in the subplot.
    rows                        
    % Columns in the subplot. 
    cols                        
  end % properties

  methods 

    function [obj] = SimulationPlotClass(model)
      %% Constructor of SimulationPlotClass.
      %
      % param: ModelClass object of the simulation.
      %
      % return: obj SimulationPlotClass object.

      obj.model = model;

    end % SimulationPlotClass

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
      
      v = obj.model.getSymbolByName(name);

      if ~isempty(v)
        xlim(v.xlim);

        % if the data is all positive and 
        if all(out.(name) >= 0) && all(v.ylim == [-inf inf])
          ylim([0 inf]);
        else
          ylim(v.ylim);
        end

        xlabel(v.xlabel);
        ylabel(v.ylabel);
        title(v.title);
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
      for i = 1:length(obj.model.symbolsIsPlot)
        % Check if we want to plot that state
        if obj.model.symbolsIsPlot(i)
            defaultNames = strcat(defaultNames,obj.model.symbolsName{i}," ");
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

      % Plot variables in other plots defined in the plotIn propierty.
      for i = 1:length(obj.model.symbols)
        if ~isempty(obj.model.symbols{i}.plotIn)
          try
            obj.selectSubplotByName(obj.model.symbols{i}.plotIn);
            plot(out.t, out.(obj.model.symbols{i}.name));
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
