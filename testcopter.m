function [] = testcopter()% load copter variables
copter_vars = load_vars();

% scale.batt=1;
% scale.mot=1;
% scale.prop=1;
% scale.pay=1;
% scale.num=1;
% scale.all=[scale.batt scale.mot scale.prop scale.pay scale.num];
% 
% x0(1) = copter_vars{1}(4).mass*scale.batt;  % battery
% x0(2) = copter_vars{2}(1).mass*scale.mot;  % motor
% x0(3) = copter_vars{3}(5).mass*scale.prop;  % propeller
% x0(4) = copter_vars{4}(1).mass*scale.pay;  % payload
% x0(5) = 4*scale.num; %copter_vars{1}(1).num*scale.num;  % number of rotors
% % x0
% 
% % design variables
% %     x(1) = battery
% %     x(2) = motor
% %     x(3) = propeller
% %     x(4) = payload
% %     x(5) = number of motors/props
% 
% % Constraints
% 
% % battery mass between 0.095 and 0.618
% % motor mass between 0.032 and 0.079
% % propeller mass between 0.0071 and 0.025
% 
% lb = [0.095*scale.batt;
%     0.032*scale.mot;
%     0.0071*scale.prop;
%     0*scale.pay;
%     4*scale.num]';
% lb=.999*lb;
% 
% ub = [0.618*scale.batt;
%     0.079*scale.mot;
%     0.025*scale.prop;
%     2.5*scale.pay;
%     8*scale.num]';
% ub=1.001*ub;
% 
% % Mission variables

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
mission.z0 = 0;   % initial altitude [m]
mission.zf = 100; % final altitude [m]
mission.zdot_max = 20; % max ascent velocity [m/s]
mission.zdotdot = 5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer = 10; % buffer height to stop accelerating as going upward [m]
mission.complete=0;
mission.target_velocity = 10;

% what are wanting to optimize?
opt_flag = 1;  % maximize time
% opt_flag = 2;  % maximize altitude
% 
% x0(1) = copter_vars{1}(4);  % battery
% x0(2) = copter_vars{2}(1);  % motor
% x0(3) = copter_vars{3}(5);  % propeller
% x0(4) = copter_vars{4}(1);  % payload
% x0(5) = 4; %copter_vars{1}(1).num*scale.num;  % number of rotors
% 
% fprintf('\ntry\n');
% x = x0;
% fprintf('bat=%4.4e mot=%4.4e prop=%4.4e pay=%3.3e num=%3.3e\n',x);
% % create copter object from design variables
% % bat.mass = x(1)/scale.batt;
% % [bat.cap, bat.c_rate, bat.volt] = load_battery(bat.mass);
% % mot.mass = x(2)/scale.mot;
% % [mot.max_watt, mot.resistance, mot.kv] = load_motor(mot.mass);
% % prop.mass = x(3)/scale.prop;
% % [prop.length, prop.ct, prop.cp] = load_prop(prop.mass);
% % pay.mass = x(4)/scale.pay;
bat = copter_vars{1}(4);  % battery
mot = copter_vars{2}(1);  % motor
prop = copter_vars{3}(5);  % propeller
pay = copter_vars{4}(1); % payload
% prop.num = 4;
% mot.num = 4;

% fixed variables
bat.num = 1;
chas = struct;
chas.mass = 1.0;
contr = struct;
contr.mass = 1.0;
contr.KPv = 1;
contr.KDv = 0;
contr.KIv = 0;

% initial state vectors
r0 = [0, 0, mission.z0];
v0 = [0, 0, 0];
a0 = [0, 0, 0];

% create Copter object with initial variables
copter = Copter(bat,mot,prop,pay,chas,contr,r0,v0,a0);
% fprintf('Copter set\n')

%save('copter_simulate.mat');
% Simulate flight
% fprintf('integrate\n')
tic
[Y cop]=integrate_flight(copter,mission,14400,0.1);
toc
end

function [cap, c_rate, volt] = load_battery(m)
% INPUT
%   m  =  mass [kg]
% fit 2nd degree polynomial
cap = -711*m^2 +1.38e4*m - 274.9;  
% fixed values
c_rate = 25;  
volt = 12;    
end

function [max_watt,resistance,kv] = load_motor(m)
% INPUT
%   m  =  mass [kg]
% fit 2nd degree polynomial
max_watt = 9237*m^2 + 7190*m - 34.7;
kv = (-2.364e5)*(m^2) - (2.097e4)*m + 4795;
resistance = 39.86*m^2 - 4.16*m + 0.1572;
end

function [length,ct,cp] = load_prop(m)
% INPUT
%   m  =  mass [kg]
% fit 2nd degree polynomial
length = -210.5*m^2 +15.27*m +0.1056;
cp = 56.85*(m^2) - (3.297)*m + 0.1099;
ct = 70.57*m^2 - 3.973*m + 0.1579;
end