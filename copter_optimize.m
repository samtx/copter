function [history] = copter_optimize(x0,lb,ub,scale,isDiscrete,objFlag,dt)

print_output = false;

if isempty(dt)
    dt = 0.1;
end

if isempty(isDiscrete)
    isDiscrete = false;  % default continuous
end
if isempty(objFlag)
    objFlag = 1;         % default time
end

% Set up shared variables with OUTFUN
history.x = [];
history.fval = [];

% Mission flight plan:
%   1: start at ground level with v = 0, then accelerate to max takeoff
%      velocity
%   2: continue going upwards with max takeoff velocity until you reach just
%      below desired altitude
%   3: decellerate from max takeoff velocity to zero velocity so that the end
%      state is in a hover mode at the desired altitude
%   4: hover at desired altitude
%   5 - 7, repeat steps 1-3 in reverse

% Flight plan constants
mission.z0       =   0;   % initial altitude [m]
mission.zf       = 100; % final altitude [m]
mission.zdot_max =  10; % max ascent velocity [m/s]
mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
mission.complete =   0;
mission.target_velocity = 10;

numprop = x0(4);
paymass = x0(5);
x0(4:5) = [];  % remove design variables from initial vector

% function to optimize
fun = @(x) copter_simulate(...
    x(1),...    % battery mass
    x(2),...    % motor mass
    x(3),...    % propeller mass
    numprop,... % number of propellers
    paymass,... % payload mass
    mission,... % mission parameters
    scale,...   % scaling
    isDiscrete,...
    objFlag,... % 1=maxtime, 2=maxpayload
    dt);        % time step


if isDiscrete
    % heuristic constrained minimization function
    IntCon = [1,2,3];
    opts = gaoptimset('ga');
    opts.OutputFcn = @myoutfun;
    opts.UseParallel = true;
    opts.Display = 'iter';
    opts.PlotFcns = {@gaplotbestf @gaplotbestindiv @gaplotdistance};
    %     [x,fval,exitflag,output,pop,scores] = ga(fun,3,[],[],[],[],...
    %         lb,ub,[],IntCon,opts);
    ga(fun,3,[],[],[],[],lb,ub,[],IntCon,opts);
else
    % use gradient-based constrained optimization
    opts = optimoptions('fmincon');
    opts.Display = 'none';
    opts.OutputFcn = @myoutfun;
    opts.DiffMinChange = 1e-4;
    opts.UseParallel = false;
    %     opts.Algorithm = 'sqp';
    if print_output
        opts.Display = 'iter-detailed';
        fprintf('Begin optimization...\n');
        fprintf('fmincon optimoptions:\n')
        fprintf('   .DiffMinChange = %6e\n',opts.DiffMinChange);
        opts
        fprintf(' iter |  t (min) | bat mass | mot mass | prop mass| prop num | pay mass |\n');
    end
    fmincon(fun,x0,[],[],[],[],lb,ub,[],opts);
end

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