classdef MatlabCodeCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'MatlabCode';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = 'end;';
    
  end % properties 

  methods

    function [] = execute(obj, raw, mcp)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        mcp  ModelClassParser object.
      %
      % return: true if the argument is complete.

      [tokens,matches] = regexp(raw,'\s*MatlabCode\s([\s\S]*)end;','tokens','match');
      fprintf(mcp.fout,tokens{1}{1});

      end % execute

  end % methods

end % classdef
