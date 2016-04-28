% Main optimize script
clc
clear all
close all
% use fmincon to find setup with maximum battery life

% Set up optimization function



% load copter variables
copter_vars = load_vars();

scale.batt=1;   % 10
scale.mot=1;    % 100
scale.prop=1;   % 300
scale.pay=1;    % 3
scale.num=1;
scale.all=[scale.batt scale.mot scale.prop scale.pay scale.num];




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
% payload mass between 0 and 2.5

lb = [0.095*scale.batt;
      0.032*scale.mot;
      0.0071*scale.prop;
      0.5*scale.pay;
      4*scale.num]';
% lb=.999*lb;
  
ub = [0.618*scale.batt;
      0.079*scale.mot;
      0.025*scale.prop;
      2.5*scale.pay;
      8*scale.num]';
% ub=1.001*ub;

% Initial Points for Copter Optimization
% randomize initial guess
% x0 = lb + (ub-lb).*rand(1,length(ub));
  
% Mission variables / Flight plan constants
mission.z0 = 0;   % initial altitude [m]
mission.zf = 100; % final altitude [m]
mission.zdot_max = 10; % max ascent velocity [m/s]
mission.zdotdot = 5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer = 10; % buffer height to stop accelerating as going upward [m]
mission.complete=0;
mission.target_velocity = 10;

% what are wanting to optimize?
opt_flag = 1;  % maximize time
% opt_flag = 2;  % maximize altitude 
% opt_flag = 3; % maximize payload mass


% function to optimize
fun = @(x) copter_simulate(x,mission,opt_flag,scale);

% options=optimoptions('fmincon','Display','iter');
% options = optimoptions(@fmincon,'Algorithm','interior-point',...
%                         'Display','iter','PlotFcn',@optimplotfval,...
%                         'OptimalityTolerance',1e-14);
options = optimoptions(@ga,'Display','iter','PlotFcn',@gaplotbestf);
options.UseParallel = true;

% constrained minimization function
% [x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);
[x,fval,exitflag,output] = ga(fun,5,[],[],[],[],lb,ub,[],options);

% x0./scale.all
x./scale.all

% fprintf('Opt Result');
% fprintf('battery ', );
% fprintf('motor ');
% fprintf('propeller ');
% fprintf('rotors ');
% fprintf('total mass ');

% for x = 0.6180    0.0320    0.0250    0.5000    7.9991
% flight time           14.87 mins
% battery charge        569.63 mAh