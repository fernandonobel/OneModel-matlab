classdef ExtendsCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'extends';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';
    
  end % properties 

  methods

    function [obj] = ExtendsCommand(mcp)
      %% Constructor of ExtendsCommand.
      %
      % param: mcp  ModelClassParser object.

      obj = obj@LineCommand(mcp);

      % We want to execute this command with "use" command.
      obj.execUse = false;

      obj.introEnd = false;

    end % LineCommand

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % Remove intros.
      raw = raw(raw~=newline);
      arg = obj.getArgument(raw);
      [className,options] = obj.getOptions(arg);

      % Check if the class exists.
      classFound = false;
      
      for i = 1:length(obj.mcp.className)
          if strcmp(className, obj.mcp.className{i})
              classFound = true;
              break;
          end
      end
      
      if ~classFound
          error('the class "%s" is not defined.', className);
      end
      
      fClass = fopen([className '_class.mc'], 'w');
      fprintf(fClass, '%s', obj.mcp.classCode{i});
      fclose(fClass);
      
      fClass = fopen([className '_class.mc']);
      obj.mcp.executeFileLines(fClass,obj.mcp.fout);
      fclose(fClass);
      
      delete([className '_class.mc']);


      end % execute

  end % methods

end % classdef

