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

      % The command is found when 'Test is found.
      [matches] = regexp(raw,'\s*Test\s*','match');
      
      out = ~isempty(matches);

    end % findCommand 

    function out = isArgumentComplete(obj, raw)
      %% ISARGUMENTCOMPLETE Does the command have everything it needs to run?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % The argument is complete when ';' is found.
      [matches] = regexp(raw,';','match');
      
      out = ~isempty(matches);
    end

    function [] = execute(obj, raw, fout)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        fout File output.
      %
      % return: true if the argument is complete.

      fprintf(fout,'%% This is a test comment.\n');
    end

  end % methods

end
