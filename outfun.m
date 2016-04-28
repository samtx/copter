function history = outfun(x,optimValues,state)
stop = false;
history.fval = [history.fval; optimValues.fval];
x; %#ok<*VUNUS>
history.x(end+1,:) = x;
end