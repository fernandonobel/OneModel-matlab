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

    end % ModelClassParser

    function [] = parse(obj)
      %% PARSE Parse the file into the a ModelClass.
      %
      % return: void

      % Open the model.
      fid = fopen(obj.filename);

      % Open the generated model.
      fout = fopen(obj.nameM,'w');

      obj.addHeader(fout);

      % Read the model line by line.
      tline = fgetl(fid);

      while ischar(tline)
        % Remove commented text in lines.
        tline = obj.removeComments(tline);

        % Remove empty lines.
        if isempty(tline)
          tline = fgetl(fid);
          continue
        end

        disp(tline)

        [cmd,arg] = obj.getCmdArgLine(tline);

        obj.executeCommand(cmd,arg,fout);

        tline = fgetl(fid);
      end

      obj.addFooter(fout);

      fclose(fid);
      fclose(fout);

    end % parse

    function [out] = removeComments(obj,tline)
      %% REMOVECOMMENTS Remove commented text of the model text.
      %
      % param: tline Line where to find and remoce comments.
      %
      % return: out Line without comments.

      ind = strfind(tline,'%');

      if ~isempty(ind)
        tline = tline(1:ind(1)-1);
      end

      out = tline;

    end % removeComments

    function [cmd, arg] = getCmdArgLine(obj,tline)
      %% GETCMDARGLINE Get the command and argument of a line.
      % argument.
      %
      % param: tline Line of the model to interprect.
      %
      % return: void

      cmd = [];
      arg = [];

      expression = '(\w*)\s(.+);';

      [tokens,matches] = regexp(tline,expression,'tokens','match');

      if ~isempty(tokens)
        cmd = tokens{1}{1};
        arg = tokens{1}{2};
      end

    end % getCmdArgLine

    function [] = executeCommand(obj,cmd,arg,fout)
      %% EXECUTECOMMAND Execute a command to build the ModelClass file.
      %
      % param: cmd Command to execute.
      %        arg Argument for the command to execute.
      %        fout File output.
      %
      % return: void

      switch cmd
        case 'Variable'
          obj.addVariable(arg,fout);

        case 'Parameter'
          obj.addParameter(arg,fout);

        case 'Equation'
          obj.addEquation(arg,fout);

        otherwise
          disp('Error')

      end

    end % executeCommand

    function [] = addVariable(obj,arg,fout)
      %% ADDVARIABLE Add a varible to the Model Class.
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: void

      expression = '(\w*)\((.+)\)';

      [tokens,matches] = regexp(arg,expression,'tokens','match');

      if isempty(tokens)
        nameVar = arg;
        options = [];
      else
        nameVar = tokens{1}{1};
        options = split(tokens{1}{2},',');
        options
      end
      
      fprintf(fout,'v = VariableClass(''%s'');\n',nameVar);

      for i=1:length(options)
        fprintf(fout,'v.%s;\n',options{i});
      end

      fprintf(fout,'obj.addVariable(v);\n\n');
      
    end % addVariable

    function [] = addParameter(obj,arg,fout)
      %% ADDPARAMETER Add a parameter to the Model Class.
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: void
      
      fprintf(fout,'p = ParameterClass(''%s'');\n',arg);
      fprintf(fout,'obj.addParameter(p);\n\n');
      
    end % addParameter

    function [] = addEquation(obj,arg,fout)
      %% ADDEQUATION Add an equation to the Model Class.
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: void
      
      fprintf(fout,'e = EquationClass(''%s'');\n',arg);
      fprintf(fout,'obj.addEquation(e);\n\n');
      
    end % addEquation

    function [] = addHeader(obj,fout)
      %% ADDHEADER Add the header to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void
      
      fprintf(fout,'classdef %s < ModelClass\n',obj.basename);
      fprintf(fout,'methods\n');
      fprintf(fout,'function [obj] = %s()\n',obj.basename);
      
    end % addHeader

    function [] = addFooter(obj,fout)
      %% ADDFOOTER Add the footer to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void
      
      fprintf(fout,'end\n');
      fprintf(fout,'end\n');
      fprintf(fout,'end\n');
      
    end % addFooter

  end % methods

end % classdef
