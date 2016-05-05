function [copter] = hover(copter)
% Simulate hovering of copter
% given input parameters
d = copter.propeller.length;         % prop diameter (m)
Vb = copter.battery.volt;        % battery voltage (V)
C = copter.battery.cap;         % battery capacity (mAh)
C_rate = copter.battery.c_rate;
rho = copter.atm.density;                  % density of air (kg/m3)
ct = copter.propeller.ct;                    %
cp = copter.propeller.cp;
g = copter.atm.gravity;                       % grav acc (m/s2)
numprop = copter.propeller.num;

% syms n              % angular velocity (rev/s) symbolic variable for solver

% Find total weight (kg)
weight = copter.mass * g;
currentThrust = -weight/numprop;
% Find thrust force
% Thrust = weight (per motor)
% eqn = ct * rho * n^2 * d^4 == weight/4;

% Find motor speed (RPM)
% solve thrust=weight for speed for n
n = sqrt(currentThrust/(ct * rho *d^4));
% RPM = n*60;

% Find power consumed (W)
P_req = cp * rho * n^3 * d^5; 

%-------
% can't use more power than max power for motor
            P_max = copter.motor.max_watt;  % motor maximum wattage (W)
            P_con = min(P_req, P_max);
            % Find total power consumed (W)
            P_tot = P_con * numprop;
            
            % Find current consumption (A)
            % current = power/(motor voltage)
            I_req = P_tot/Vb;
            I_max = (C/1000) * C_rate;
            I_con = min(I_req, I_max);
            
%             % Find charge consumed [mAh]
%             Q_con = I_con*dt*1000/3600;
%-------

% Find current consumption (A)
% current = power/(motor voltage)
% I = P/Vb;

% Find flight time (hr)
% time=current*capacity /1000mA/A *60min/hr
t = (C/1000*3600)/I_con;
copter.data.time(end) = t;
end
