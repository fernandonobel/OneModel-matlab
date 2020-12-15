classdef (Abstract) BaseCommand

  properties (Abstract)
    % struct with the list of keywords that must be reserved for this command.
    keywords 

  end % properties

  methods (Abstract, Static)

    %% FINDCOMMAND Is the start of the command found?
    %
    % param: raw Raw text from the ModelClass file.
    %
    % return: true if the start of the command is found.
    out = findCommand(raw);

  end

  methods (Abstract)

    %% ISARGUMENTCOMPLETE Does the command have everything it needs to run?
    %
    % param: raw Raw text from the ModelClass file.
    %
    % return: true if the argument is complete.
    out = isArgumentComplete(obj, raw)

    %% EXECUTE Execute the command.
    %
    % param: raw  Raw text from the ModelClass file.
    %        fout File output.
    %
    % return: true if the argument is complete.
    [] = execute(obj, raw, fout)

  end % methods

end
