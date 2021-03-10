classdef ObjectCommand < LineCommand

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
      % param: raw Raw text from the ModelClass file.
      %
      % return: out true if the start of the command is found.
      
      if isempty(obj.mcp.className)
          out = false;
          return;
      end

      % The command is found when the name of a defined class is found.
      [tokens] = regexp(raw,'\s*(\w*)\s*','tokens');    
      
      if any(strcmp(tokens{1}{1},obj.mcp.className))
        out = true;
      else
        out = false;
      end

    end % findCommand 

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      [tokens] = regexp(raw,'\s*(\w*)\s*(\w*);','tokens');
      
      className = tokens{1}{1};
      objectName = tokens{1}{2};
      
      try
        classCode = obj.mcp.classCode{strcmp(className, obj.mcp.className)};
      catch
        error('"%s" does not correspond to any object declared.',raw)
      end
      
      % Add a namespace with the object name.
      classCode = ['namespace ' objectName ';' newline classCode];
      classCode = [classCode newline 'namespace;'];
      
      fClass = fopen([className '_class.mc'], 'w');
      fprintf(fClass, '%s', classCode);
      fclose(fClass);
      
      fClass = fopen([className '_class.mc']);
      obj.mcp.executeFileLines(fClass,obj.mcp.fout);
      fclose(fClass);
      
      delete([className '_class.mc']);

    end % execute

  end % methods

end % classdef


