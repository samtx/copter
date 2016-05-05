% Copter Main Script

% Main optimize script
% clc
% clear all
% close all
% use fmincon to find setup with maximum battery life

% Set up optimization function

% Initial Points for Copter Optimization

% load copter variables
copter_vars = load_vars();

% ------------ SCALING? ---------------------------
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
%
% x0(1) = copter_vars{1}(3).mass*scale.batt;  % battery
% x0(2) = copter_vars{2}(1).mass*scale.mot;  % motor
% x0(3) = copter_vars{3}(5).mass*scale.prop;  % propeller
% x0(4) = copter_vars{4}(1).mass*scale.pay;  % payload
% x0(5) = 8*scale.num; %copter_vars{1}(1).num*scale.num;  % number of rotors
% x0

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
%

% Use discrete design variables?
isDiscrete = true;
if isDiscrete
    lb = [1,1,1,1];   % with discrete design vars
    ub = [5,5,5,3];
    x0 = zeros(1,5);  % x5 = payload mass = 0
else
    lb = [0.095, 0.032, 0.0071];   % with continuous design vars
    ub = [0.618, 0.079, 0.0250];
    % Random start
    x0 = zeros(1,length(lb));
    for i = 1:length(lb)
        x0(i) = rand*(ub(i)-lb(i))+lb(i);
    end
end



% Scaling?
scale.all = 1;
scale.batt = 1;
scale.mot = 1;
scale.prop = 1;
scale.num = 1;
scale.pay = 1;

% what are wanting to optimize?
objFlag = 1;  % maximize time
dt = 0.1;

% Run optimization
tic;
hist = copter_optimize(x0,lb,ub,scale,isDiscrete,objFlag,dt);
t = toc;
% print out function iteration history
fprintf('Run time = %8.1f sec\n',t);
fprintf(' iter |  t (min) | bat mass | mot mass | prop mass| pay mass | prop num |\n');
for i = 1:length(hist.fval)
    fprintf('%5d |%10.6f|%10.6f|%10.6f|%10.6f|%10.6f|%10d|',[i,-hist.fval(i)/60,hist.x(i,:)]);
    fprintf('\n');
end
