classdef Copter < matlab.System
    % copter object definition
    %
    properties
        battery;     % struct defined in load_vars.m
        motor;       % struct defined in load_vars.m
        propeller;   % struct defined in load_vars.m
        payload;     % struct defined in load_vars.m
        chassis;
        control;
        
        mass;        % total mass of copter [kg]
        data;        % struct
        atm;         % struct for environmental parameters
        thrust;
        status;      % state of copter
    end
    
    methods
        function obj = Copter(bat,mot,prop,pay,chas,cont,r,v,a)
            obj.battery = bat;
            obj.motor = mot;
            obj.propeller = prop;
            obj.payload = pay;
            obj.chassis = chas;
            obj.control = cont;
            
            % total mass
            obj.mass = obj.get_total_mass();
            
            % initialize data vectors as empty************************
            data = struct();
            data.time = 0;
            data.theta = 0;
            % data.ang_vel = 0;
            data.thrust = 0;
            data.fnet = [0,0,0];
            data.rpm = 0;
            data.capacity = obj.battery.cap;
            data.error = [];
            % initial values
            data.position = r;
            data.velocity = v;
            data.acceleration = a;
            obj.data = data;
            
            % initialize the atmosphere struct
            atm.gravity = -9.81; % [m/s2]
            obj.atm = atm;
            obj.update_atm();
            
            % thrust
            thrust = struct();
            thrust.currentVec = 0;
            obj.thrust = thrust;
            obj.thrust_limits();
            
            status.launched=false;
            status.descending=false;
            status.hovering=false;
            status.batt_low=false;
            status.batt_dead=false;
            obj.status=status;
        end
        
        function mass = get_total_mass(obj)
            % calculate the toal mass
            mass = obj.payload.mass + ...
                obj.control.mass + ...
                obj.chassis.mass + ...
                (obj.battery.mass * obj.battery.num) + ...
                (obj.propeller.mass * obj.propeller.num) + ...
                (obj.motor.mass * obj.motor.num);
        end
        
        function [] = thrust_limits(obj)    % mc 4/6 added max thrust equation
            % calculate the maximun and minimum thrust
            obj.thrust.min = 0;
            n_max = nthroot(obj.motor.max_watt/(obj.propeller.cp*obj.atm.density*obj.propeller.length^5), 3);
            obj.thrust.max = obj.propeller.ct*obj.atm.density*n_max^2*obj.propeller.length^4;
        end
        
        function [] = update_copter(obj,dt)
            % update fields in copter struct
            % dt            (scalar) Time interval(this is the same time interval set in the integrator of the IDE)
            
            % find angular velocity from roll/pitch/yaw
            %copter.omega = thetadot2omega(copter.thetadot, theta);
            
            % find thrust necessary
            obj.thrust_controller(dt);
            
            % find battery charge used
            obj.update_battery(dt);
            
            % find air density
            obj.update_atm();
        end
        
        function [] = thrust_controller(obj,dt)
            % Compute the necessary thrust
            
            % find error
            e = obj.control.target_velocity - obj.data.velocity(end,3);
            obj.data.error(end+1) = e;
            
            % controller gains
            KP = obj.control.KPv;
            KD = obj.control.KDv;
            %  KI = obj.control.KIv;
            
            % dt    = obj.data.time(end)-obj.data.time(end-1);
            ei    = obj.data.error(end);
            if length(obj.data.error)<3
                eim1  = 0;
                eim2  = 0;
            elseif length(obj.data.error)<2
                eim1  = obj.data.error(end-1);
                eim2  = 0;
            else
                eim1  = obj.data.error(end-1);
                eim2  = obj.data.error(end-2);
            end
            dedt  = (3*ei-4*eim1+eim2)/2/dt;
            % ie    = trapz(obj.data.time,obj.data.error);
            
            % control to determine thrust
            currentThrust = KP*e + KD*dedt + ...KI*ie + ...
                -obj.mass*obj.atm.gravity/obj.motor.num;
            
            % average propeller rotational speed
            n = sqrt(currentThrust/( obj.propeller.ct * obj.atm.density * obj.propeller.length^4)); % (rev/s)
            obj.data.rpm(end+1) = n*60;
            
            % make sure does thrust possible
            if currentThrust > obj.thrust.max
                currentThrust = obj.thrust.max;
            elseif currentThrust < obj.thrust.min
                currentThrust = obj.thrust.min;
            end
            
            if obj.status.batt_dead
                currentThrust=0;
            end
            obj.thrust.currentVec = eye(3) * [0 0 currentThrust]';
            obj.data.thrust(end+1) = obj.thrust.currentVec(3);
            
        end
        
        function [] = update_battery(obj,dt)
            % calculate the energy drained from the battery
            Vb = obj.battery.volt;           % bat voltage (V)
            C = obj.battery.cap;             % battery capacity (mAh)
            C_rate = obj.battery.c_rate;     % battery C-rating (1/h)
            cp = obj.propeller.cp;           % coeff of power
            d = obj.propeller.length;        % prop diameter (m)
            num_prop = obj.propeller.num;    % number of propellers
            n = obj.data.rpm(end)/60;        % prop rot speed (rev/s)
            Ra = obj.motor.resistance;       % internal resistance (ohms)
            rho = obj.atm.density;                   % density of air (kg/m3)
            
            % Find power consumed (W) from each propeller  Eqn.(2)
            P_req = cp * rho * n^3 * d^5;
            %fprintf('Power consumed = %4.2f W\n',P);
            
            % can't use more power than max power for motor
            P_max = obj.motor.max_watt;  % motor maximum wattage (W)
            P_con = min(P_req, P_max);
            % Find total power consumed (W)
            P_tot = P_con * num_prop;
            
            % Find current consumption (A)
            % current = power/(motor voltage)
            I_req = P_tot/Vb;
            I_max = (C/1000) * C_rate;
            I_con = min(I_req, I_max);
            
            % Find charge consumed [mAh]
            Q_con = I_con*dt*1000/3600;
            obj.data.capacity(end+1) = obj.data.capacity(end) - Q_con;
            
        end
        
        function [] = update_atm(obj)
            obj.atm.temperature = 15.04 - .00649 * obj.data.position(end,3); % [C]
            obj.atm.pressure = 101.29 * ((obj.atm.temperature+273.1)/288.08)^5.256; % [K-Pa]
            obj.atm.density = obj.atm.pressure/(0.2869*(obj.atm.temperature+273.1)); % [kg/m^3]
        end
        
    end
    
end

