% SENSITIVITY ANALYSIS
clear
clc

% setup
mission.zf = 100;       % final altitude [m]
mission.z0 = 0;         % initial altitude
mission.target_velocity = 10;
isDiscrete = false;     % continuous variable
objFlag = 1;            % default time
dt = 0.1;               % time step
scale.batt = 1;     scale.mot = 1;      scale.prop = 1;
scale.num = 1;      scale.pay = 1;      % scale

% optimum design vector x*
x_star = [0.618, 0.032, 0.0250];
batmass = x_star(1);
motmass = x_star(2);
propmass = x_star(3);
numprop = 4;
paymass = 0;

fun = @(per,val) copter_simulate_sns(...
    x_star(1),...    % battery mass
    x_star(2),...    % motor mass
    x_star(3),...    % propeller mass
    numprop,... % number of propellers
    paymass,... % payload mass
    mission,... % mission parameters
    scale,...   % scaling
    isDiscrete,...
    objFlag,... % 1=maxtime, 2=maxpayload
    dt,...
    per,...
    val);        % time step

% vary parameters by del
h= 0.1;

% compute objective at optimum J(x*)
J_star = fun(0,0);
param_s = [mass_s Kp_s batt_s vel_s dt runTime_s];

sens_eval = @(per,val) ( (fun(1+per,val)- fun(1-per,val))/(2*per) );


for i=1:5
    % chassis mass: changing frame size or density
    % controller proportional gain
    % battery worn percentage
    % target velocity
    % dt
    dJ(i) = sens_eval(h,i);
end
 dJ(i+1)=(runTimeSen1 - runTimeSen2) /(2*h);
% vary design vector dy del
% battery mass
% motor mass
% propeller mass


% normalize 
% dJ_norm = (x*/J*)*dJ
J_norm = param_s/J_star.*dJ;

% plot