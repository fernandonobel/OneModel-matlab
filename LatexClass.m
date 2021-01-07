classdef LatexClass < handle
  %% LATEXCLASS This class generates LaTeX code for representing the model.
  %

  properties
    % ModelClass object to simulate.
    model
  end % properties

  methods 

    function [obj] = LatexClass(model)
      %% Constructor of LatexClass.
      %
      % param: model ModelClass object.

      obj.model = model;

    end % LatexClass

    function [out] = parametersTable(obj)
      %% PARAMETERSTABLE Generates a table with the parameters of the model.
      %
      % return: out [char] LaTeX code.

      parameters = obj.model.parameters;

      f = fopen('code.tex','w');

      fprintf(f,'\\begin{table}[h]\n');
      fprintf(f,'\\centering\n');
      fprintf(f,'\\begin{tabular}{\n');
      fprintf(f,'\tP{0.10\\linewidth}\n');
      fprintf(f,'\tP{0.50\\linewidth}\n');
      fprintf(f,'\tP{0.2\\linewidth}\n');
      fprintf(f,'\tP{0.1\\linewidth}\n');
      fprintf(f,'}\n');
      fprintf(f,'\\toprule\n');
      fprintf(f,'\t\\textbf{Name} & \\textbf{Description} & \\textbf{Value} & \\textbf{Units} \\\\\n');
      fprintf(f,'\\midrule\n');

      for i = 1:length(parameters)
        fprintf(f,'\t$%s$ & & & & \\\\\n', parameters(i).nameTex);
      end

      fprintf(f,'\\bottomrule\n');
      fprintf(f,'\\end{tabular}\n');
      fprintf(f,'\t\\label{Add label HERE}\n');
      fprintf(f,'\t\\caption{Add caption HERE}\n');
      fprintf(f,'\\end{table}\n');

      fclose(f);

    end % parametersTable


  end % methods

end % classdef
