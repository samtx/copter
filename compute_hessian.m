% Hessian of optimal copter design


% Optimal design, x0
x0 = [.618,...    % battery mass
    .032,...    % motor mass
    .025,...    % propeller mass
    8];...    % number of propellers
    J = 16.723333333336;  % optimum flight time
% Finite difference step size
h = 1e-3;
% dt value
dt = 0.1;


% central difference for 2nd derivative

% Parameters
% Scaling?
scale = struct;
% scale.all = 1;
scale.batt = 1;
scale.mot = 10;
scale.prop = 10;
scale.num = 1;
scale.pay = 1;
scale.timemult = 1e-5;
scale.timeadd = 0;
scale.vector = [scale.batt, scale.mot, scale.prop, scale.num];
% Flight plan constants
mission.z0       =   0;   % initial altitude [m]
mission.zf       = 100; % final altitude [m]
mission.zdot_max =  10; % max ascent velocity [m/s]
mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
mission.complete =   0;
mission.target_velocity = 10;
% Use discrete case?
isDiscrete = false;
% what are wanting to optimize?
objFlag = 1;  % maximize time

% other
paymass = 0;

% function to optimize
f = @(x) copter_simulate(...
    x(1),...    % battery mass
    x(2),...    % motor mass
    x(3),...    % propeller mass
    x(4),...    % number of propellers
    paymass,... % payload mass
    mission,... % mission parameters
    scale,...   % scaling
    isDiscrete,...
    objFlag,... % 1=maxtime, 2=maxpayload
    dt);        % time step

d2dx = zeros(1,3);

% apply scaling
x0 = x0 .* scale.vector;

% d2dx(1) = d2val(x0,[h, 0, 0, 0]);
% d2dx(2) = d2val(x0,[0, h, 0, 0]);
% d2dx(3) = d2val(x0,[0, 0, h, 0]);

tic;
% central diff
% if dt == 0.05
%     J0 = -1.003299999999635e+03;  % with dt=0.05
% elseif dt == 0.1
%     J0 = -1.003400000000160e+03;
% else
%     J0 = f(x0);
%     fprintf('J0 = %.20f\n',J0);
% end
fprintf('\nCompute J(x0) with scaling...\n');
disp(scale);
fprintf('flight time (min)| bat mass | mot mass | prop mass| prop num | pay mass |\n');
J0 = f(x0);
fprintf('J0 = %.20f   =  %.20f min\n',[J0,-J0/60]);
fprintf('  f(x0)...\n')
fprintf('%17.12f|%10.6f|%10.6f|%10.6f|%9d |%10.6f|\n',[J,x0(1:4),0])
fprintf('  computing Hessian at x0 with h = %.3e, dt = %.3e\n',[h,dt]);

d2val = @(x,h) (f(x+h) - 2*J0 + f(x-h))/(sum(h)^2);
err = h.^2;

parfor i = 1:3
    h0 = zeros(1,4);
    h0(i) = h;
    d2dx(i) = d2val(x0,h0);
end
t1end = toc;
fprintf('\n Hessian diagonal matrix:\n');
disp(diag(d2dx));
fprintf('Total Run time = %.2f sec  (%.2f min)\n',[t1end,t1end/60]);