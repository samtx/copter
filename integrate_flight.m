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
%    copter     (Copter) return the copter with additional


% print output to screen while integration runs?  for testing purposes...
print_output_to_screen = false;
print_mod = 2;   % modulo iteration number to print

i = 1;             % initialize counting variables
t = 0;
descending = false;
hovering = false;
batt_low = false;
batt_dead = false;
mission.complete=false;

%initalize variables for t=0
Y=[copter.data.velocity copter.data.position]';

if print_output_to_screen
    fprintf('mass(kg) = %6.3f     weight(N) = %6.3f  \n',[copter.mass,copter.mass*copter.atm.gravity]);
    fprintf('time(sec) | alt(m) | vel(m/s) | acc(m/s2) | bat(mAh) | Thrust(N) |  T net(N) | Fnet(N) |   RPMs   |\n');
end
%% While loop
while t<tmax && ~mission.complete
    
    %% Conditions for phases
    % launch
    if t == 0 && copter.data.position(end,3) < 10  % drive to altitude
        copter.control.target_velocity=mission.target_velocity;
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
        copter.control.target_velocity=-.8*mission.target_velocity;
        %         fprintf('descent\n')
        descending = true;
    end
    if descending && copter.data.position(end,3) < 10
        copter.control.target_velocity=-1;
        % fprintf('land: care\n')
    elseif descending && copter.data.position(end,3) < 20
        copter.control.target_velocity=-.4*mission.target_velocity;
        % fprintf('land: slow\n')
    end
    
    %% Update Copter
    % update thrust controller
    % update battery consumption
    % update atmospheric conditions
    copter.update_copter(dt);
    
    %% Perform fourth order Runge Kutta
    t = t + dt;
    k1 = feval('dynamics', t, Y(:,i), copter, mission, dt);
    k2 = feval('dynamics', t+dt/2, Y(:,i)+k1*dt/2, copter, mission, dt);
    k3 = feval('dynamics', t+dt/2, Y(:,i)+k2*dt/2, copter, mission, dt);
    k4 = feval('dynamics', t+dt, Y(:,i)+k3*dt, copter, mission, dt);
    Y(:,i+1) = Y(:,i) + (k1 + 2*k2 + 2*k3 + k4)/6 * dt;
    
    %% Save data
    copter.data.time(end+1) = t;
    copter.data.position(end+1,3) = Y(6,i+1);
    copter.data.velocity(end+1,3) = Y(3,i+1);
    fnet = get_forces(copter);
    copter.data.fnet(end+1,:) = fnet;
    copter.data.acceleration(end+1,:) = fnet/copter.mass;
    
    %% print status
    if mod(i,print_mod)==0 && print_output_to_screen
        print_status(copter,t);
    end
    
    %% Check uav conditions
    if  copter.data.position(end,3)<-1   % *sif 3/29/2016 indent for readability
        mission.complete=true;
    end  % *sif 3/29/16 change to logical operator
    if (copter.data.capacity(end) < copter.battery.low_fraction* copter.battery.cap) && ~batt_low % *sif 3/29/16 change to logical operator
        batt_low=true;  % *sif 3/29/16 change to logical operator
        %         fprintf('WARNING: Battery low %d\n',t/60)
    end
    if (copter.data.capacity(end) < 0) && ~batt_dead  % *sif 3/29/16 change to logical operator
        batt_dead = true; % *sif 3/29/16 change to logical operator
        %         fprintf('WARNING: Battery dead %d\n',t/60)
        break
    end
    
    %% Increment Counter
    i = i + 1;
    
end

Y=Y';       % make Y a column vector for neater output

% check ending conditon and print
if print_output_to_screen
    if abs(copter.data.velocity(end,3)) < 3
        fprintf('UAV landed successfully\n')  % *sif+3 3/29/2016  add float decimal formatting
    else
        fprintf('UAV landed too fast\n')
    end
    fprintf('flight time           %5.2f mins\n',copter.data.time(end)/60)
    fprintf('landing velocity      %5.3f m/s\n',copter.data.velocity(end,3))
    fprintf('landing acceleration  %5.3f m/s^2\n',copter.data.acceleration(end,3))
    fprintf('battery charge        %5.2f mAh  (%3.1f%% remaining)\n',[copter.data.capacity(end),100*copter.data.capacity(end)/copter.data.capacity(1)])
end

end

function dydt = dynamics(t, y, copter, mission, dt)
% define 2nd order ODE for Newton's Laws of Motion

% --- Find Net Forces ---
F_net = get_forces(copter);

% --- Setup Differential Equation ---
% y''= a = F_total/m_total
% y' = v = y(1)
dydt(1:3) = F_net / copter.mass;
dydt(4:6) = y(1:3);
dydt=dydt';
end

function F_net = get_forces(copter)
% Find net forces
% Force of gravity
F_g = [0 0 copter.mass*copter.atm.gravity]';
% Drag force ... ignore for now
% F_d = 0.5*atm.density*copter.velocity^2*copter.area*copter.Cd;
% Thrust force
F_t = copter.motor.num * copter.thrust.currentVec;
% net force on system
F_net = F_g + F_t;
end

function [] = print_status(copter,t)    %% Print status if necessary
thisdata = copter.data;
fprintf('%9.1f | %6.2f | %8.2f | %9.2f | %8.3f | %9.3f | %9.3f | %8.3f | %8.3f \n',...
    [t
    thisdata.position(end,3)
    thisdata.velocity(end,3)
    thisdata.acceleration(end,3)
    thisdata.capacity(end)
    thisdata.thrust(end)
    thisdata.thrust(end)*copter.propeller.num
    thisdata.fnet(end,3)
    thisdata.rpm(end)]);
end
