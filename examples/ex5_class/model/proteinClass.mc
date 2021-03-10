%% Definition of class Protein.

class Protein
  % Input
  variable omega(
    isPlot = false
    ); 

  variable x;  

  parameter d_x(value = 1.0);

  equation der_x == omega - d_x*x;

end Protein;

%% Stand-alone model.
% This code wont be executed when "use" command is used to import the
% class into another file.

Protein p1;
Protein p2;

% Set a constitutive expression of p1.
connect(p1__omega, 1);

% We can connect the transcription of p2 dependent of p1.
connect(p2__omega, p1__x);