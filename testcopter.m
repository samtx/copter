% function [] = testcopter()% load copter variables
copter_vars = load_vars();

useHover = true;

batmass = 0.618;
motmass = 0.0320;
propmass = 0.0250;
numprop = 8;
paymass = 0;

x = [batmass, motmass, propmass, numprop, paymass];

isDiscrete = false;
dt = 0.1;

scale = struct;
% scale.all = 1;
scale.batt = 1;
scale.mot = 1;
scale.prop = 1;
scale.num = 1;
scale.pay = 1;
scale.timemult = 1;
scale.timeadd = 0;
scale.vector = [scale.batt, scale.mot, scale.prop, scale.num, scale.pay];

% Flight plan constants
% 1: start at ground level with v = 0, then accelerate to max takeoff
% velocity
% 2: continue going upwards with max takeoff velocity until you reach just
% below desired altitude
% 3: decellerate from max takeoff velocity to zero velocity so that the end
% state is in a hover mode at the desired altitude
% 4: hover at desired altitude
% 5 - 7, repeat steps 1-3 in reverse
mission.z0       =   0;   % initial altitude [m]
mission.zf       = 100; % final altitude [m]
mission.zdot_max =  10; % max ascent velocity [m/s]
mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
mission.complete =   0;
mission.target_velocity = 10;

% what are wanting to optimize?
objFlag = 1;  % maximize time

% function to optimize
fun = @(x) copter_simulate(...
    x(1),...    % battery mass
    x(2),...    % motor mass
    x(3),...    % propeller mass
    x(4),... % number of propellers
    x(5),... % payload mass
    mission,... % mission parameters
    scale,...   % scaling
    isDiscrete,...
    objFlag,... % 1=maxtime, 2=maxpayload
    dt,...      % time step
    useHover);  % use low-fidelity hover model
tic;
-fun(x);
toc
