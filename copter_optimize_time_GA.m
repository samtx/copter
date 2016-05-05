% Main optimize script
clc
clear all
close all

% scale.batt=1;   % 10
% scale.mot=1;    % 100
% scale.prop=1;   % 300
% scale.pay=1;    % 3
% scale.num=1;
% scale.all=[scale.batt scale.mot scale.prop scale.pay scale.num];

% ------------ SCALING ---------------------------
scale = struct;
% scale.all = 1;
scale.batt = 1;
scale.mot = 10;
scale.prop = 10;
scale.num = 1;
scale.pay = 1;
scale.timemult = 1e-5;
scale.timeadd = 0;
scale.vector = [scale.batt, scale.mot, scale.prop, scale.num, scale.pay];

% design variables
%     x(1) = battery
%     x(2) = motor
%     x(3) = propeller
%     x(4) = payload
%     x(5) = number of motors/props

% Constraints
% battery mass between 0.095 and 0.618
% motor mass between 0.032 and 0.079
% propeller mass between 0.0071 and 0.025
% payload mass 0

lb = [0.095*scale.batt;
      0.032*scale.mot;
      0.0071*scale.prop]';
ub = [0.618*scale.batt;
      0.079*scale.mot;
      0.025*scale.prop;]';
paymass = 0;

% Mission variables / Flight plan constants
mission.z0 = 0;   % initial altitude [m]
mission.zf = 100; % final altitude [m]
mission.zdot_max = 10; % max ascent velocity [m/s]
mission.zdotdot = 5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer = 10; % buffer height to stop accelerating as going upward [m]
mission.complete=0;
mission.target_velocity = 10;

% what are wanting to optimize?
objFlag = 1;  % maximize time
% opt_flag = 2;  % maximize altitude 
% opt_flag = 3; % maximize payload mass

isDiscrete=false;
dt=.1;
numprop=4;

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

% OPTIONS----------------------------------------------------------------
opts = optimoptions(@ga,'Display','iter','PlotFcn',...
    @gaplotbestf,'UseParallel',true);
% opts.UseVectorized=true;
% try dec stall time  

for n=[1,2,3]
    numprop=2*n+2;
    % constrained minimization function
    [xval(n),fval(n),exitflag(n),output(n)] = ga(fun,3,[],[],[],[],lb,ub,[],opts);
end

% for x = 0.6180    0.0320    0.0250    0.5000    7.9991
% flight time           14.87 mins
% battery charge        569.63 mAh