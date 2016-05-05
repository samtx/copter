function [ d2val, err ] = d2fdx2( x, h, fun)
% compute the second derivative of function fun at point x with step size h
% using central differences

f = fun;

% central diff
d2val = ( f(x+h) - 2*f(x) + f(x-h))/(h^2);
err = h^2;

% backwards diff
% d2val = (f(x)-2*f(x-h)+f(x-2*h))/(h^2);
% err = h;

end

