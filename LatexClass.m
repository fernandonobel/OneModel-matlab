classdef LatexClass < handle
  %% LATEXCLASS This class generates LaTeX code for representing the model.
  %

  properties
    % OneModel object to simulate.
    model
  end % properties

  methods 

    function [obj] = LatexClass(model)
      %% Constructor of LatexClass.
      %
      % param: model OneModel object.

      obj.model = model;

    end % LatexClass

    function [out] = parametersTable(obj,filename,label,caption)
      %% PARAMETERSTABLE Generates a table with the parameters of the model.
      %
      % param: filename [char] Name of the file to create.
      %        label    [char] LaTeX label for the table.
      %        caption  [char] Caption for the table.
      %
      % return: out [char] LaTeX code.

      p = obj.model.parameters;

      f = fopen(filename,'w');

      fprintf(f,'%% The MDPI table float is called specialtable\n');
      fprintf(f,'\\begin{specialtable}[H] \n');
      fprintf(f,'\\centering\n');
      fprintf(f,'\\caption{%s}\n',caption);
      fprintf(f,'\\label{%s}\n',label);
      fprintf(f,'%%%% \\tablesize{} %% You can specify the fontsize here, e.g., \\tablesize{\\footnotesize}. If commented out \\small will be used.\n');
      fprintf(f,'\\begin{tabular}{lllll}\n');
      fprintf(f,'\\toprule\n');
      fprintf(f,'\\textbf{Name}	& \\textbf{Description}	& \\textbf{Value} & \\textbf{Units} & \\textbf{Reference} \\\\\n');
      fprintf(f,'\\midrule\n');

      % fprintf(f,'\\begin{table}[h]\n');
      % fprintf(f,'\\centering\n');
      % fprintf(f,'\\begin{tabular}{\n');
      % fprintf(f,'\tP{0.10\\linewidth}\n');
      % fprintf(f,'\tP{0.50\\linewidth}\n');
      % fprintf(f,'\tP{0.2\\linewidth}\n');
      % fprintf(f,'\tP{0.1\\linewidth}\n');
      % fprintf(f,'}\n');
      % fprintf(f,'\\toprule\n');
      % fprintf(f,'\t\\textbf{Name} & \\textbf{Description} & \\textbf{Value} & \\textbf{Units} \\\\\n');
      % fprintf(f,'\\midrule\n');

      for i = 1:length(p)
        if p(i).isTex
          fprintf(f,'\t$%s$ & %s & %s & $%s$ & %s \\\\\n', p(i).nameTex,p(i).comment,p(i).valueTex,p(i).units,p(i).reference);
        end
      end

      fprintf(f,'\\bottomrule\n');
      fprintf(f,'\\end{tabular}\n');
      fprintf(f,'\\end{specialtable}\n');

      % fprintf(f,'\\bottomrule\n');
      % fprintf(f,'\\end{tabular}\n');
      % fprintf(f,'\t\\label{Add label HERE}\n');
      % fprintf(f,'\t\\caption{Add caption HERE}\n');
      % fprintf(f,'\\end{table}\n');

      fclose(f);

    end % parametersTable

    function [out] = variablesTable(obj,filename,label,caption)
      %% VARIABLESTABLE Generates a table with the variables of the model.
      %
      % param: filename [char] Name of the file to create.
      %        label    [char] LaTeX label for the table.
      %        caption  [char] Caption for the table.
      %
      % return: out [char] LaTeX code.

      v = obj.model.variables;

      f = fopen(filename,'w');

      fprintf(f,'%% The MDPI table float is called specialtable\n');
      fprintf(f,'\\begin{specialtable}[H] \n');
      fprintf(f,'\\centering\n');
      fprintf(f,'\\caption{%s}\n',caption);
      fprintf(f,'\\label{%s}\n',label);
      fprintf(f,'%%%% \\tablesize{} %% You can specify the fontsize here, e.g., \\tablesize{\\footnotesize}. If commented out \\small will be used.\n');
      fprintf(f,'\\begin{tabular}{lllll}\n');
      fprintf(f,'\\toprule\n');
      fprintf(f,'\\textbf{Name}	& \\textbf{Description}	& \\textbf{Equation} & \\textbf{Units} \\\\\n');
      fprintf(f,'\\midrule\n');

      % fprintf(f,'\\begin{table}[h]\n');
      % fprintf(f,'\\centering\n');
      % fprintf(f,'\\begin{tabular}{\n');
      % fprintf(f,'\tP{0.10\\linewidth}\n');
      % fprintf(f,'\tP{0.50\\linewidth}\n');
      % fprintf(f,'\tP{0.2\\linewidth}\n');
      % fprintf(f,'\tP{0.1\\linewidth}\n');
      % fprintf(f,'}\n');
      % fprintf(f,'\\toprule\n');
      % fprintf(f,'\t\\textbf{Name} & \\textbf{Description} & \\textbf{Value} & \\textbf{Units} \\\\\n');
      % fprintf(f,'\\midrule\n');

      for i = 1:length(v)
        if v(i).isTex && v(i).isSubstitution
          fprintf(f,'\t$%s$ & %s & $%s$ & $%s$\\\\\n', v(i).nameTex, v(i).comment, v(i).equationTex, v(i).units);
        end
      end

      fprintf(f,'\\bottomrule\n');
      fprintf(f,'\\end{tabular}\n');
      fprintf(f,'\\end{specialtable}\n');

      % fprintf(f,'\\bottomrule\n');
      % fprintf(f,'\\end{tabular}\n');
      % fprintf(f,'\t\\label{Add label HERE}\n');
      % fprintf(f,'\t\\caption{Add caption HERE}\n');
      % fprintf(f,'\\end{table}\n');

      fclose(f);

    end % variablesTable

    function [out] = statesTable(obj,filename,label,caption)
      %% STATESTABLE Generates a table with the states of the model.
      %
      % param: filename [char] Name of the file to create.
      %        label    [char] LaTeX label for the table.
      %        caption  [char] Caption for the table.
      %
      % return: out [char] LaTeX code.

      v = obj.model.variables;

      f = fopen(filename,'w');

      fprintf(f,'%% The MDPI table float is called specialtable\n');
      fprintf(f,'\\begin{specialtable}[H] \n');
      fprintf(f,'\\centering\n');
      fprintf(f,'\\caption{%s}\n',caption);
      fprintf(f,'\\label{%s}\n',label);
      fprintf(f,'%%%% \\tablesize{} %% You can specify the fontsize here, e.g., \\tablesize{\\footnotesize}. If commented out \\small will be used.\n');
      fprintf(f,'\\begin{tabular}{lllll}\n');
      fprintf(f,'\\toprule\n');
      fprintf(f,'\\textbf{Name}	& \\textbf{Description}	& \\textbf{Units} \\\\\n');
      fprintf(f,'\\midrule\n');

      % fprintf(f,'\\begin{table}[h]\n');
      % fprintf(f,'\\centering\n');
      % fprintf(f,'\\begin{tabular}{\n');
      % fprintf(f,'\tP{0.10\\linewidth}\n');
      % fprintf(f,'\tP{0.50\\linewidth}\n');
      % fprintf(f,'\tP{0.2\\linewidth}\n');
      % fprintf(f,'\tP{0.1\\linewidth}\n');
      % fprintf(f,'}\n');
      % fprintf(f,'\\toprule\n');
      % fprintf(f,'\t\\textbf{Name} & \\textbf{Description} & \\textbf{Value} & \\textbf{Units} \\\\\n');
      % fprintf(f,'\\midrule\n');

      for i = 1:length(v)
        if v(i).isTex && ~v(i).isSubstitution
          fprintf(f,'\t$%s$ & %s & $%s$\\\\\n', v(i).nameTex, v(i).comment, v(i).units);
        end
      end

      fprintf(f,'\\bottomrule\n');
      fprintf(f,'\\end{tabular}\n');
      fprintf(f,'\\end{specialtable}\n');

      % fprintf(f,'\\bottomrule\n');
      % fprintf(f,'\\end{tabular}\n');
      % fprintf(f,'\t\\label{Add label HERE}\n');
      % fprintf(f,'\t\\caption{Add caption HERE}\n');
      % fprintf(f,'\\end{table}\n');

      fclose(f);

    end % statesTable

    function [out] = equations(obj,filename,label)
      %% EQUATIONS Return tex code of the model equations.
      %
      % param: filename [char] Name of the file to create.
      %        label    [char] LaTeX label for the table.
      %
      % return: out [char] LaTeX code.

      v = obj.model.variables;
      
      aux_v = VariableClass.empty();
      
      for i = 1:length(v)
        if v(i).isTex && ~v(i).isSubstitution && ~isempty(v(i).equationTex)
          aux_v(end+1) = v(i);
        end
      end
      
      v = aux_v;

      f = fopen(filename,'w');

      fprintf(f,'\\begin{align}\n');

      for i = 1:length(v)-1
          fprintf(f,'\t %s \\\\\n', v(i).equationTex);
      end
      
      fprintf(f,'\t %s \n', v(i+1).equationTex);

      fprintf(f,'\\end{align}\n');

      fclose(f);

    end % equations

  end % methods

end % classdef
