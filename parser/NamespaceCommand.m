classdef NamespaceCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Namespace';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';

  end % properties 

  methods

    function [obj] = NamespaceCommand(mcp)
      %% Constructor of NamespaceCommand.
      %
      % param: mcp  ModelClassParser object.

      obj = obj@LineCommand(mcp);

      % We want to execute this command with "use" command.
      obj.execUse = true;

    end % LineCommand


    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % Remove intros.
      raw = raw(raw~=newline);

      [tokens] = regexp(raw,'\s*Namespace\s*(\w*)\s*;','tokens');

      if isempty(tokens)
        fprintf(obj.mcp.fout,'\t\t\tobj.namespace = '''';\n');
      else
        fprintf(obj.mcp.fout,'\t\t\tobj.namespace = ''%s'';\n',tokens{1}{1});
      end

    end % execute

  end % methods

end % classdef


