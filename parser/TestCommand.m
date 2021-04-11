classdef TestCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'test';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';
    
  end % properties 

  methods

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the OneModel file.
      %
      % return: true if the argument is complete.

      obj.mcp.print('%% This is a test comment.\n');
    end

  end % methods

end
