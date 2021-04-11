classdef (Abstract) Command
  %% COMMAND Base command definition.
  %
  % This is the base command class to define OneModelParser commands.

  properties (Abstract)
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords

  end % properties

  properties
    % OneModelParser object.
    mcp
    % bool True if we want to execute this command with "use" command.
    execUse = false

  end % properties

  methods (Abstract)

    %% FINDCOMMAND Is the start of the command found?
    %
    % param: raw Raw text from the OneModel file.
    %
    % return: true if the start of the command is found.
    out = findCommand(obj, raw);

    %% ISCOMPLETE Does the command have everything it needs to run?
    %
    % param: raw Raw text from the OneModel file.
    %
    % return: true if the argument is complete.
    out = isComplete(obj, raw)

    %% EXECUTE Execute the command.
    %
    % param: raw  Raw text from the OneModel file.
    %
    % return: true if the argument is complete.
    [] = execute(obj, raw)

  end % methods

  % Utils functions.
  methods
    function [obj] = Command(mcp)
      %% COMMAND Constructor of Command class.
      %
      % param: mcp  OneModelParser object.
      %
      % return: obj

      obj.mcp = mcp;
      
    end % Command

    function [out] = removeSpace(obj,in)
      %% REMOVESPACE Remove unnecessary space in string but keep the spaces
      % between "'".
      %
      % param: in String with spaces.
      %
      % return: out String without unnecessary spaces.

      % Remove space at the beggining or end of the string.
      expression = '^[ \t]+|[ \t]+$';
      splits = regexp(in,expression,'split');

      % Save option without the empty splits.
      for i = 1:length(splits)
        if ~isempty(splits{i}) 
          in = splits{i};
        end
      end

      out = in;

    end % removeSpace

  end % methods

end % classdef
