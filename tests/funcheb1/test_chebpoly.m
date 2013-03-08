% Test file for funcheb1/chebpoly.
function pass = test_chebpoly(varargin)

% Set a tolerance (pref.eps doesn't matter)
tol = 100*eps;

%%
% Test that a single value is converted correctly
v = sqrt(2);
c = funcheb1.chebpoly(v);
pass(1) = (v == c);

%%
% Some simple data 
v = (1:6).';
% Exact coefficients
cTrue = [sqrt(6)/2-5*sqrt(2)/6; 0; sqrt(2)/6 ; 0 ; sqrt(6)/2+5*sqrt(2)/6 ; 7/2];

%%
% Test real branch
c = funcheb1.chebpoly(v);
pass(2) = norm(c - cTrue, inf) < tol;
pass(3) = ~any(imag(c));

%%
% Test imaginary branch
c = funcheb1.chebpoly(1i*v);
pass(4) = norm(c - 1i*cTrue, inf) < tol;
pass(5) = ~any(real(c));

%%
% Test general branch
c = funcheb1.chebpoly((1+1i)*v);
pass(6) = norm(c - (1+1i)*cTrue, inf) < tol;

%%
% Test for array input
c = funcheb1.chebpoly([v, v(end:-1:1)]);
tmp = ones(size(cTrue)); tmp(end-1:-2:1) = -1;
pass(7) = norm(c(:,1) - cTrue, inf) < tol && ...
          norm(c(:,2) - tmp.*cTrue, inf) < tol;
      
end