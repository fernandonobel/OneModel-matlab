classdef ModelPartClass < handle
  %% MODELPARTCLASS This class is the base for all objects defined in a OneModel model.

  properties
    % [char] String with the name of the ModelPart.
    name
    % [char] The namespace of this object.
    namespace = ''
    % OneModel The object of the OneModel which this ModelPart is added.
    mc

  end % properties

  methods 

    function [obj] = ModelPartClass(mc)
      %% Constructor of ModelPartClass.
      %
      % param: mc OneModel object.

      % Get the namespace that is being used.
      obj.namespace = mc.namespace;

      % Save the OneModel object for later use.
      obj.mc = mc;


    end % ModelPartClass

    function [] =  set.name(obj,name)
      %% SET.NAME Set interface for name propierty.
      %
      % param: name [char] Name for the symbol.
      %
      % return: void

      if ~isstring(name) && ~ischar(name)
        error('name must be a string.');
      end

      % Check if name is a valid name for a symbol.

      % Check if the name is empty.
      if isempty(name)
        error('the name of the symbol is empty.');
      end

      % Find non-word symbols.
      if ~isempty(regexp(name,'\W','ONCE'))
        error('the name of the symbol is not valid: it contains no-word characters.');
      end

      % Check if the name starts with a number.
      if ~isempty(regexp(name(1),'[0-9]','ONCE'))
        error('the name oh the symbol is not valid: it starts with a number.');
      end

      % Check if the name is a keyword of matlab.
      if exist(name,'builtin')
        error('the name of the symbol is not valid: it is a keyword of MATLAB.');
      end

      % Check if the name is 't' ('t' is the time in the simulation).
      if strcmp(name,'t')
        error('the name of the symbol is not valid: ''t'' must be reserved for the time in the simulation.');
      end

      % Check if the name is 'e' or 'e\d*' (it mess up with the exponential
      % notation of numbers.
      if name(1) == 'e' 
        if length(name) == 1
          error('the name of the symbol is not valid: ''e'' must be reserved for the cientific notation of numbers.');
        end
        if ~isnan(str2double(name(2:end)))
          error(['the name of the symbol is not valid: ''' name ''' must be reserved for the cientific notation of numbers.']);
        end
      end

      obj.name = name;

    end % set.name

  end % methods

end % classdef
