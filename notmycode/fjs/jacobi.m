function varargout=jacobi(l,m,x)
% P=JACOBI(l,m,x)
%
% Calculates the Jacobi polynomial P_l^{m,0}(x) by summation.
%
% INPUT:
%
% l      The degree                           [scalar]
% m      The first upper index, usually alpha [scalar]
% x      The abscissas                        [vector]
%
% OUTPUT:
%
% P      The Jacobi polynomial at x          [vector]
%
% EXAMPLE:
%
% jacobi('demo1') % Checks the equivalence with Legendre polynomials
% jacobi('demo2') % Checks the equivalence with hypergeometric functions
%
% Last modified by fjsimons-at-alum.mit.edu, 03/26/2009
% Last modified by dongwang-at-princeton.edu, 06/02/2008

% Should modify this to use the three-term recursion and return the whole
% set; this will be faster

% Supply default values for the arguments
defval('l',5)

if ~isstr(l)
  % Supply default values for the arguments
  defval('l',5)
  
  if l>64
    warning('High-degree Jacobi polynomials may be inaccurate')
  end
  
  defval('m',0)
  defval('x',linspace(0,1,20))
  % Make sure the argument is a row vector
  x=x(:)';
  
  % Initialize the matrix
  P=zeros(1,length(x));
  
  % Loop through the iteration
  for n=0:l
    % This according to De Villiers (2003) eq. (44) which appears to have
    % a typo - or, thus, ultimately, Szego - and see the demos.
    P=P+(x-1).^n.*(x+1).^(l-n)/...
      factorial(n+m)/factorial(l-n)^2/factorial(n);
    % This according to Abramowitz and Stegun p. 775, same thing
    % P=P+(x-1).^(l-n).*(x+1).^n/...
    %  factorial(n)/factorial(l+m-n)/factorial(l-n)/factorial(n);
  end
  % Apply the constants
  P=P*factorial(l+m)*factorial(l)/2^l;
  % Provide output
  vars={P};
  varargout=vars(1:nargout);
elseif strcmp(l,'demo1')
  % Calculate the Legendre functions
  x=linspace(0,1,20); m=0;
  for l=0:15
    difer(jacobi(l,m,x)-rindeks(legendre(l,x),m+1))
  end
elseif strcmp(l,'demo2')
  % Calculate the hypergeometric functions
  x=linspace(0,1,20); m=0;
  for l=0:15
    % This according to Mathworld eq. (25) which used to have a typo
    difer(jacobi(l,m,x)-factorial(l+m)/factorial(l)/factorial(m)*...
	  hypergeom([-l,l+m+1],m+1,1/2*(1-x)))
    % This according to Mathworld eq. (27) which was typo-free
    %    difer(jacobi(l,m,x)-factorial(l+m)/factorial(l)/factorial(m)*...
    %	  ((x+1)/2).^l.*hypergeom([-l,-l],m+1,(x-1)./(x+1)))
  end
end




