classdef (Abstract) Command
  %% COMMAND Base command definition.
  %
  % This is the base command class to define ModelClassParser commands.

  properties (Abstract)
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords

  end % properties

  methods (Abstract)

    %% FINDCOMMAND Is the start of the command found?
    %
    % param: raw Raw text from the ModelClass file.
    %
    % return: true if the start of the command is found.
    out = findCommand(obj, raw);

    %% ISARGUMENTCOMPLETE Does the command have everything it needs to run?
    %
    % param: raw Raw text from the ModelClass file.
    %
    % return: true if the argument is complete.
    out = isArgumentComplete(obj, raw)

    %% EXECUTE Execute the command.
    %
    % param: raw  Raw text from the ModelClass file.
    %        mcp  ModelClassParser object.
    %
    % return: true if the argument is complete.
    [] = execute(obj, raw, mcp)

  end % methods

end % classdef
