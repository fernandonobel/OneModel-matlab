classdef SimulationOptionsClass < handle
  %% SIMULATIONOPTIONSCLASS This class manages the options of the solver.
  %

  % Odeset properties.
  properties
    % real Absolute error tolerance.
    AbsTol
    % real Relative error tolerance.
    RelTol
  end % properties

  % Non-odeset properties.
  properties
    % [real] Time span for the simulation.
    TimeSpan
  end

  properties (Dependent)
    % odeset options.
    opts
  end % properties (Dependent)

  methods 

    function [obj] = SimulationOptionsClass(param)
      %% Constructor of SimulationOptionsClass.
      %
      % param: param

      % Default values for odeset properties.
      obj.AbsTol = 1e-3;
      obj.RelTol = 1e-6;

      % Default values for non-odeset properties.
      obj.TimeSpan = [0 10];

    end % SimulationOptionsClass

    function [] = set.AbsTol(obj,value)
      %% SET.ABSTOL Set interface for AbsTol propierty.
      %
      % param: value Value to be set.
      %
      % return: void
      
      if ~isnumeric(value) || length(value) ~= 1
        error('Error ''AbsTol'' must be a real number.');
      end

      obj.AbsTol = value;
      
    end % set.AbsTol

    function [] = set.RelTol(obj,value)
      %% SET.RELTOL Set interface for RelTol propierty.
      %
      % param: value Value to be set.
      %
      % return: void

      if ~isnumeric(value) || length(value) ~= 1
        error('Error ''RelTol'' must be a real number.');
      end

      obj.RelTol = value;
      
    end % set.RelTol

    function [] = set.TimeSpan(obj,value)
      %% SET.TIMESPAN Set interface for TimeSpan propierty.
      %
      % param: value Value to be set.
      %
      % return: void

      if ~isnumeric(value) || length(value) ~= 2
        error('Error ''TimeSpan'' must be a real vector of two elements.');
      end

      obj.TimeSpan = value;
      
    end % set.TimeSpan

    function [opts] = get.opts(obj)
      %% GET.OPTS Get all the odeset propierties as an odeset struct.
      %
      % return: opts Odeset struct.

      opts = odeset('AbsTol',obj.AbsTol,'RelTol',obj.RelTol);
      
    end % get.opts

  end % methods

end % classdef
