classdef ModelClassParser < handle
  %% MODELCLASSPARSER This class parses files .mc into ModelClass models.
  %

  properties
    % [char] Name of the model to parse.
    filename
    % [char] Base name of the model without extension.
    basename
    % [char] Name for the ModelClass model.
    nameM
    % File descriptor of the ouput model file.
    fout
    % {Command} List of command defined for the parser.
    commands = {}
    % {filename} Filename of extended files. This is to avoid infinite recursion
    % of files
    filenameExtended = {}
    % {[char]} List of name of defined classes.
    className = {}
    % {[char]} The ModelClass code of the defined classes.
    classCode = {}

  end % properties

  methods 

    function [obj] = ModelClassParser(filename)
      %% Constructor of ModelClassParser.
      %
      % param: filename File to parse into a ModelClass.

      obj.filename = filename;

      [folder, baseFileNameNoExt, extension] = fileparts(obj.filename);

      obj.basename = baseFileNameNoExt;

      obj.nameM = [baseFileNameNoExt '.m'];

      % Add here all the commands of the parser.
      obj.commands = {
        TestCommand(obj),
        VariableCommand(obj),
        ParameterCommand(obj),
        EquationCommand(obj),
        ImportCommand(obj),
        MatlabCodeCommand(obj),
        SimOptionsCommand(obj),
        ClassCommand(obj),
        NamespaceCommand(obj),
        ObjectCommand(obj),
        UseCommand(obj),
        ExtendsCommand(obj)
      };

    end % ModelClassParser

    function [] = parse(obj)
      %% PARSE Parse the file into the a ModelClass.
      %
      % return: void

      % Open the model.
      obj.avoidRecursion(obj.filename);
      fid = fopen(obj.filename);

      % Check if build directory exists.
      if ~exist('build', 'dir')
       mkdir('build')
      end

      addpath('build');

      % Open the generated model.

      obj.fout = fopen(['build/' obj.nameM],'w');

      obj.addHeader(obj.fout);

      obj.executeFileLines(fid,obj.fout);

      obj.addFooter(obj.fout);

      fclose(fid);
      fclose(obj.fout);

    end % parse

    function [] = executeFileLines(obj,fid,fout,opt)
      %% EXECUTEFILELINES 
      %
      % param: fid File descriptor to read.
      %      : fout File descriptor to write.
      %      : opt [char] options for the changing the behavior.
      %
      % return: void

      if nargin < 4
        opt = '';
      end

      % Read a line of the model.
      tline = fgets(fid);

      % Aux buffer for preparing the lines to be executed.
      aux = '';

      % Variable to store the current command to execute.
      cmd = [];

      while ischar(tline)
        % Remove commented text in lines.
        tline = obj.removeComments(tline);

        % Remove empty lines.
        if isempty(tline)
          tline = fgets(fid);
          continue;
        end

        % Process char by char the line readed.
        for i = 1:length(tline)
          aux(end+1) = tline(i);

          % If we did not find a command.
          if isempty(cmd)
            % Look if any of the commands in the list is found.
            for i = 1:length(obj.commands)
              % If any of the commands if found.
              if obj.commands{i}.findCommand(aux)
                % Save it and stop looking for more commands.
                cmd = obj.commands{i};
                break;
              end
            end
          end

          % If we have found a command
          if ~isempty(cmd)
            % Collect all the argument data needed for the command in aux.

            % Does the command all it needs to be executed? 
            if cmd.isComplete(aux)
              if ~strcmp(opt,'execUse') || (strcmp(opt,'execUse') && cmd.execUse)
                % Execute the comand.
                cmd.execute(aux);

                fprintf(fout,'\n');
              end

                % Reset the aux for new lines.
                aux = '';
                % Reset the cmd for new commands.
                cmd = [];
              
            end
          end
        end

        % Read the next line in the document.
        tline = fgets(fid);
      end

      % Check if something is remaining in aux after finishing the model.
      if ~all(isspace(aux)) && ~isempty(aux)
        feval(cmd,obj,aux,-1);
      end
    end % executeFileLines

    function [out] = removeComments(obj,tline)
      %% REMOVECOMMENTS Remove commented text of the model text.
      %
      % param: tline Line where to find and remove comments.
      %
      % return: out Line without comments.

      ind = strfind(tline,'%');

      if ~isempty(ind)
        tline = tline(1:ind(1)-1);
      end

      out = tline;

    end % removeComments

    function [] = print(obj,str)
      %% PRINT Prints 'str' into the output file.
      %
      % param: str String to be printed.
      
      fprintf(obj.fout,['\t\t\t' str]);
      
    end % print

    function [] = addHeader(obj,fout)
      %% ADDHEADER Add the header to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void

      fprintf(fout,'classdef %s < ModelClass\n',obj.basename);
      fprintf(fout,'\tmethods\n');
      fprintf(fout,'\t\tfunction [obj] = %s()\n',obj.basename);

    end % addHeader

    function [] = addFooter(obj,fout)
      %% ADDFOOTER Add the footer to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void

      fprintf(fout,'\t\t\tobj.checkValidModel();\n');

      fprintf(fout,'\t\tend\n');
      fprintf(fout,'\tend\n');
      fprintf(fout,'end\n');

    end % addFooter

    function [] = avoidRecursion(obj,filename)
      %% AVOIDRECURSION Check if the filename was already used to avoid
      % recursion.
      %
      % param: filename Filename to check.
      %
      % return: void

      [pathstr,name,ext] = fileparts(filename);

      if any(strcmp(obj.filenameExtended,name),'all')
        error('The file "%s" was already included in the model. The parsing of the model was stoped to avoid infinite recursion.',name);
      end

      obj.filenameExtended{end+1} = name;

    end % avoidRecursion

  end %methods

end % classdef
