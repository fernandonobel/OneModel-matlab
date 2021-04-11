classdef ChangeAtributeCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name;
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';

  end % properties 

  methods

    function [out] = findCommand(obj, raw)
      %% FINDCOMMAND Is the start of the command found?
      %
      % param: raw Raw text from the OneModel file.
      %
      % return: out true if the start of the command is found.
      
      [matches] = regexp(raw,'\s*(\w*.\w*\s*=\s*.+;)\s*','match');    
      
      out = ~isempty(matches);

    end % findCommand 

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the OneModel file.
      %
      % return: true if the argument is complete.

      [tokens] = regexp(raw,'\s*(\w*)(.\w*\s*=\s*.+;)\s*','tokens');
      
      name = tokens{1}{1};

      rest = tokens{1}{2};

      fprintf(obj.mcp.fout,'\t\t\tobj.getModelPartByName(''%s'')%s\n',name,rest);

    end % execute

  end % methods

end % classdef


