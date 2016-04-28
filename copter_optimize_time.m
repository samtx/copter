function [history] = copter_optimize_time(x0,lb,ub,scale)

% Set up shared variables with OUTFUN
history.x = [];
history.fval = [];


% Mission variables

% flight plan:
% 1: start at ground level with v = 0, then accelerate to max takeoff
% velocity
% 2: continue going upwards with max takeoff velocity until you reach just
% below desired altitude
% 3: decellerate from max takeoff velocity to zero velocity so that the end
% state is in a hover mode at the desired altitude
% 4: hover at desired altitude
% 5 - 7, repeat steps 1-3 in reverse

% Flight plan constants
mission.z0       =   0;   % initial altitude [m]
mission.zf       = 100; % final altitude [m]
mission.zdot_max =  10; % max ascent velocity [m/s]
mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
mission.complete =   0;
mission.target_velocity = 10;

% what are wanting to optimize?
opt_flag = 1;  % maximize time

% function to optimize
fun = @(x) copter_simulate(x,mission,opt_flag,scale);

opts = optimoptions('fmincon');
opts.Display = 'iter';
opts.OutputFcn = @myoutfun;
opts.Algorithm = 'sqp';

% constrained minimization function
IntCon = [1,2,3];
opts = gaoptimset('ga');
opts.OutputFcn = @myoutfun;
opts.UseParallel = true;
opts.Display = 'iter';
opts.PlotFcns = {@gaplotbestf @gaplotbestindiv @gaplotdistance};
    [x,fval,exitflag,output,pop,scores] = ga(fun,3,[],[],[],[],...
        lb,ub,[],IntCon,opts);


% x0./scale.all;
% x./scale.all;

    function stop = myoutfun(x,optimValues,state)
        stop = false;
        if strcmp(state,'iter')
            history.fval = [history.fval; optimValues.fval];
            x; %#ok<*VUNUS>
            history.x(end+1,:) = x;
        end
    end


end