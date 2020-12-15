classdef TestCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Test';
    % struct with the list of keywords that must be reserved for this command.
    keywords = {};
    
  end % properties 

  methods

    function [] = execute(obj, raw, mcp)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        mcp  ModelClassParser object.
      %
      % return: true if the argument is complete.

      mcp.print('%% This is a test comment.\n');
    end

  end % methods

end
