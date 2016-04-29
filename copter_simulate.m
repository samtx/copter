function [ J ] = copter_simulate(batmass,motmass,propmass,numprop,paymass,mission,scale,isDiscrete,objFlag)

% fprintf('\ntry\n');
% fprintf('bat=%4.4e mot=%4.4e prop=%4.4e pay=%3.3e num=%3.3e\n',x);

print_output = true;

if isDiscrete
    % Load discrete copter components
    [bat,mot,prop] = load_copter_components([batmass,motmass,propmass]);
else
    % create copter object from design variables
    bat.mass = batmass/scale.batt;
    [bat.cap, bat.c_rate, bat.volt] = load_battery(bat.mass);
    mot.mass = motmass/scale.mot;
    [mot.max_watt, mot.resistance, mot.kv] = load_motor(mot.mass);
    prop.mass = propmass/scale.prop;
    [prop.length, prop.ct, prop.cp] = load_prop(prop.mass);
    pay.mass = paymass/scale.pay;
    prop.num = numprop/scale.num;
    mot.num = numprop/scale.num;
end

% fixed variables
bat.num = 1;
chas.mass = 1.0;
contr.mass = 1.0;
contr.KPv = 1;
contr.KDv = 0;
contr.KIv = 0;

% Payload mass
% pay.mass = paymass;

% Number of propellers and motors
% mot.num = numprop;
% prop.num = numprop;
%   Do something here to add mass to the chasis depending upon number of
%   propellers and propeller length

% initial state vectors
r0 = [0, 0, mission.z0];
v0 = [0, 0, 0];
a0 = [0, 0, 0];

% create Copter object with initial variables
copter = Copter(bat,mot,prop,pay,chas,contr,r0,v0,a0);
% fprintf('Copter set\n')

% save('copter_simulate.mat');

% Simulate flight
[~,cop] = integrate_flight(copter,mission,14400,0.1);

if objFlag == 1
    % return the total flight time
    J = -cop.data.time(end);
elseif objFlag == 2
    % return the maximum flight altitude
    J = -cop.data.position(:,3);
end

if print_output
    fprintf('      |%10.6f|%10.6f|%10.6f|%10.6f|%9d |%10.6f|\n',[-J/60,...
        batmass,motmass,propmass,numprop,paymass]);
end

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

