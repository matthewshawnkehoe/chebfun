% Test file for funcheb1/feval.

function pass = test_feval(pref)

% Get preferences.
if ( nargin < 1 )
    pref = funcheb1.pref();
end

% Generate a few random points to use as test values.
rng('default'), rng(0);
x = 2 * rand(1000, 1) - 1;

%%
% Spot-check values for a couple of functions.  We can only expect accuracy on
% the order of the truncation level, so we use this as our criterion.

f = funcheb1(@(x) exp(x) - 1, pref);
f_exact = @(x) exp(x) - 1;
pass(1) = (norm(feval(f, x) - f_exact(x), 'inf') < 10*f.epslevel);

f = funcheb1(@(x) 1./(1 + x.^2), pref);
f_exact = @(x) 1./(1 + x.^2);
pass(2) = (norm(feval(f, x) - f_exact(x), 'inf') < 10*f.epslevel);

f = funcheb1(@(x) cos(1e4*x), pref);
f_exact = @(x) cos(1e4*x);
pass(3) = (norm(feval(f, x) - f_exact(x), 'inf') < 10*f.epslevel);

z = exp(2*pi*1i/6);
f = funcheb1(@(t) sinh(t*z), pref);
f_exact = @(t) sinh(t*z);
pass(4) = (norm(feval(f, x) - f_exact(x), 'inf') < 10*f.epslevel);

%%
% Check row vector and matrix input.

err = feval(f, x.') - f_exact(x.');
pass(5) = (all(size(err) == [1 1000])) && (norm(err(:), 'inf') < 10*f.epslevel);

x_mtx = reshape(x, [100 10]);
err = feval(f, x_mtx) - f_exact(x_mtx);
pass(6) = (all(size(err) == [100 10])) && (norm(err(:), 'inf') < 10*f.epslevel);

x_3mtx = reshape(x, [10 10 10]);
err = feval(f, x_3mtx) - f_exact(x_3mtx);
pass(7) = (all(size(err) == [10 10 10])) && (norm(err(:), 'inf') < 10*f.epslevel);

%%
% Check operation for vectorized funcheb1 objects.

f = funcheb1(@(x) [sin(x) x.^2 exp(1i*x)], pref);
f_exact = @(x) [sin(x) x.^2 exp(1i*x)];
err = feval(f, x) - f_exact(x);
pass(8) = all(max(abs(err)) < 10*f.epslevel);

%%
% Test for evaluating vectorized funcheb1 objects at matrix arguments if the
% operation makes sense.
f = funcheb1(@(x) [sin(pi*x) cos(pi*x) exp(pi*x)], pref);
x = [-1 0 1 ; .25 .5 .75];
fx = feval(f, x);
f_exact = [0 0 0 -1 1 -1 exp(-pi) 1 exp(pi)
          [1 sqrt(2) 1 1 0 -1]/sqrt(2) exp(pi.*[.25 .5 .75])];
pass(9) = all(all(abs(fx - f_exact) < 100*f.epslevel));

end
