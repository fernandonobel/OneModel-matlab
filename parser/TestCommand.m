classdef TestCommand < Command

  properties 
    % struct with the list of keywords that must be reserved for this command.
    keywords = {
      'Test'
      };
    
  end % properties 

  methods

    function [out] = findCommand(obj, raw)
      %% FINDCOMMAND Is the start of the command found?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: out true if the start of the command is found.

      out = true;

    end % findCommand 

    function out = isArgumentComplete(obj, raw)
      %% ISARGUMENTCOMPLETE Does the command have everything it needs to run?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      out = true;
    end

    function [] = execute(obj, raw, fout)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        fout File output.
      %
      % return: true if the argument is complete.

      disp('Executing command');
    end

  end % methods

end
