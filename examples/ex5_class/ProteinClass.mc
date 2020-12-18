Class Protein

  Variable w_x; % Input

  Variable x;  

  Parameter d_x(value = 1.0);

  Equation der_x == w_x - d_x*x;

end Protein;

Protein p1;
Protein p2;

Parameter A(value = 1);

Equation (
  p1__w_x == A,
  isSubstitution = true
  );

Equation (
  p2__w_x == p1__x,
  isSubstitution = true
  );
