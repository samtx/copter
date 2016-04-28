function [ J ] = copter_simulate(x,mission,obj_flag,scale)
% simulate copter flight and return requested output

% fprintf('\ntry\n');
% fprintf('%4.4e %4.4e %4.4e %3.3e %3.3e\n',x);
% create copter object from design variables
bat.mass = x(1)/scale.batt;
[bat.cap, bat.c_rate, bat.volt] = load_battery(bat.mass);
mot.mass = x(2)/scale.mot;
[mot.max_watt, mot.resistance, mot.kv] = load_motor(mot.mass);
prop.mass = x(3)/scale.prop;
[prop.length, prop.ct, prop.cp] = load_prop(prop.mass);
pay.mass = x(4)/scale.pay;
prop.num = x(5)/scale.num;
mot.num = x(5)/scale.num;

% fixed variables
bat.num = 1;
chas = struct;
chas.mass = 1.0;
contr = struct;
contr.mass = 1.0;
contr.KPv = 1;
contr.KDv = 0;
contr.KIv = 0;
contr.target_velocity = mission.target_velocity;

% initial state vectors
r0 = [0, 0, mission.z0];
v0 = [0, 0, 0];
a0 = [0, 0, 0];

% create Copter object with initial variables
copter = Copter(bat,mot,prop,pay,chas,contr,r0,v0,a0);
% fprintf('Copter set\n')


% Simulate flight 
% fprintf('integrate\n')
[Y cop]=integrate_flight(copter,mission,14400,0.05);
% fprintf('integrated\n')

if obj_flag == 1
    % return the total flight time
    J = -cop.data.time(end);
elseif obj_flag == 2
    % return the maximum flight altitude
    J = -cop.data.position(:,3);
end
% fprintf('output\n\n')

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

