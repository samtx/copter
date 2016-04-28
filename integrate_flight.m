function [Y,copter] = integrate_flight(copter,mission,tmax,dt)
% Implements an integrator (fourth order Runge-Kutta) for the ODE system
%
% Input Parameters
%    copter     (struct) Data structure containing the parameters of the copter
%    atm        (struct) Data structure containing parameters for atmosphere
%    mission    (struct) Data structure containing mission parameters
%    dt         (scalar) Time interval
%    tmax       (scalar) Maximum run time
%
% Output Parameters
%    Y
%    copter     (Copter object) return the copter object with additional

i = 1;             % initialize counting variables
t = 0;
descending = false;
hovering = false;
batt_low = false;
batt_dead = false;
mission.complete=false;

%initalize variables for t=0
Y=[copter.data.velocity copter.data.position]';  % Output vector*********************
% can give launch params************

while t<tmax && ~mission.complete
%     if mod(i,60*5/dt)==0  % print output every 5 minutes
%         fprintf('t = %5.2f min\n',t/60)
%         fprintf('alt = %5.2f m\n',Y(6,i))
%     end
    
    % Conditions for phases
    % launch
    if t == 0 && copter.data.position(end,3) < 10  % drive to altitude
        copter.control.target_velocity=10;
%         fprintf('launch\n')
    end
    % hover
    if ~hovering && copter.data.position(end,3) > mission.zf  % hold altitude
        copter.control.target_velocity=0;
        hovering = true;
%         fprintf('hover\n')
    end
    % descend after 10mins
    if ~descending && (t>(tmax*.99) || batt_low)
        copter.control.target_velocity=-8;
%         fprintf('descent\n')
        descending = true;
    end
    if descending && copter.data.position(end,3) < 15
        copter.control.target_velocity=-1;
        % fprintf('land: care\n')
    elseif descending && copter.data.position(end,3) < 25
        copter.control.target_velocity=-4;
        % fprintf('land: slow\n')
    end
    
    % update UAV for current t
    copter.update_copter(dt);
    
    %perform fourth order Runge Kutta
    t = t + dt;
    k1 = feval('dynamics', t, Y(:,i), copter, mission, dt);
    k2 = feval('dynamics', t+dt/2, Y(:,i)+k1*dt/2, copter, mission, dt);
    k3 = feval('dynamics', t+dt/2, Y(:,i)+k2*dt/2, copter, mission, dt);
    k4 = feval('dynamics', t+dt, Y(:,i)+k3*dt, copter, mission, dt);
    Y(:,i+1) = Y(:,i) + (k1 + 2*k2 + 2*k3 + k4)/6 * dt;
    
    copter.data.time(end+1) = t;
    copter.data.position(end+1,3) = Y(6,i+1);   %*****************************************
    copter.data.velocity(end+1,3) = Y(3,i+1);
    copter.data.acceleration(end+1,:) = get_forces(copter)/copter.mass;
    
    %copter.omega_dot=I\(feval('Torque',copter,atm)-cross(omega,I*omega));
    
    i = i + 1;  % increment counter
    
    % Check uav conditions
    if  copter.data.position(end,3)<-1   % *sif 3/29/2016 indent for readability
        mission.complete=true;
    end  % *sif 3/29/16 change to logical operator
    if (copter.data.capacity(end) < 0.1 * copter.battery.cap) && ~batt_low % *sif 3/29/16 change to logical operator
        batt_low=true;  % *sif 3/29/16 change to logical operator
%         fprintf('WARNING: Battery low %d\n',t/60)
    end
    if (copter.data.capacity(end) < 0) && ~batt_dead  % *sif 3/29/16 change to logical operator
        batt_dead = true; % *sif 3/29/16 change to logical operator
%         fprintf('WARNING: Battery dead %d\n',t/60)
        break
    end
    
%     % debugging
%     fprintf('%d\n',i)
%     fprintf('%3.2f\n',t)
%     fprintf('%d\n',copter.data.position(end,3))
%     fprintf('%d\n',copter.data.thrust(end))
end
Y=Y';       % make Y a column vector for neater output presentation

% % check ending conditon and print
% if abs(copter.data.velocity(end,3)) < 3
%     fprintf('UAV landed successfully\n')  % *sif+3 3/29/2016  add float decimal formatting
% else
%     fprintf('UAV landed too fast\n')
% end
% fprintf('flight time           %5.2f mins\n',copter.data.time(end)/60)
% fprintf('landing velocity      %5.3f m/s\n',copter.data.velocity(end,3))
% fprintf('landing acceleration  %5.3f m/s^2\n',copter.data.acceleration(end,3))
% fprintf('battery charge        %5.2f mAh\n',copter.data.capacity(end))
end

function dydt = dynamics(t, y, copter, mission, dt)
% define 2nd order ODE for Newton's Laws of Motion
% t = time [s]
% r = position [m], for now this is only the z component
% copter = Copter object
% atm = atmosphere struct

F_t = get_forces(copter);

% differential equation
% y''= a = F_total/m_total
% y' = v = y(1)
dydt(1:3) = F_t / copter.mass;
dydt(4:6) = y(1:3);
dydt=dydt';
end

function F = get_forces(copter)
% Calculate the total forces on the copter at time t

% gravitational force
F_g = [0 0 copter.mass*copter.atm.gravity]';
% drag force
% F_d = 0.5*atm.density*obj.velocity^2*obj.area*copter.Cd;
% thrust force
F_r = copter.motor.num * copter.thrust.currentVec;
% net force on system
F = F_g + F_r;
end
