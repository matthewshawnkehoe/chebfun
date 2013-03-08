function pass = test_size(pref)

if ( nargin < 1 )
    pref = funcheb1.pref;
end

f = funcheb1(@(x) sin(x), 0, pref);
pass(1) = all(size(f) == [14, 1]);

f = funcheb1(@(x) [sin(x), cos(x), 1i*exp(x)], 0, pref);
pass(2) = all(size(f) == [15, 3]);

p = pref;
p.funcheb1.n = 101;
f = funcheb1(@(x) [sin(x), cos(x), 1i*exp(x)], 0, p);
pass(3) = all(size(f) == [101, 3]);

end