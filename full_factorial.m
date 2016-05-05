% Full factorial discrete copter trials

run_trials = false;
make_graphs = true;

if run_trials
    % Flight plan constants
    mission.z0       =   0;   % initial altitude [m]
    mission.zf       = 100; % final altitude [m]
    mission.zdot_max =  10; % max ascent velocity [m/s]
    mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
    mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
    mission.complete =   0;
    mission.target_velocity = 10;
    paymass = 0;
    % what are wanting to optimize?
    objFlag = 1;  % maximize time
    scale = [];
    dt = 0.1;
    isDiscrete = true;
    
    % function to optimize
    fun = @(x) copter_simulate(...
        x(1),...    % battery mass
        x(2),...    % motor mass
        x(3),...    % propeller mass
        x(4),...    % number of propellers
        paymass,... % payload mass
        mission,... % mission parameters
        scale,...   % scaling
        isDiscrete,...
        objFlag,... % 1=maxtime, 2=maxpayload
        dt);        % time step
    % We have 5 batteries, 5 motors, and 5 propellers, 3 propnum configs
    % --> 4 indep vars, 1 dep var (time)
    dFF = fullfact([5,5,5,3]);
    dFF(:,4) = mod(dFF(:,4)-1,3)*2+4;
    hist = zeros(1,length(dFF));
    tic;
    parfor i = 1:length(dFF)
        x = dFF(i,:);
        fprintf('Running... i=%3d --> Bat #%d,   Mot #%d,   Prop #%d,   PropNum=%d \n',[i,x]);
        hist(i) = -fun(x)/60;
    end
    t = toc;
    fprintf('Parallel computation time = %5.2f sec for %3d runs\n',[t,length(dFF)]);
    % put results in matrix 
    times = zeros(length(hist),5);
    for i = 1:length(hist)
        a = dFF(i,1);
        b = dFF(i,2);
        c = dFF(i,3);
        d = dFF(i,4);
        times(i,:)= [a,b,c,d,hist(i)];
    end
    save('full_factorial_new.mat');
end

if make_graphs
    % Make 3D bar graphs for full factorial results
    % times( 'Bat#' , 'Mot#', 'Prop#') = time
    for i = 1:5
        figure(i);
        scatter3(times(:,1,1,4))
        title(['Flight Time (Min) with Prop # ',num2str(i)]);
        xlabel('Battery #'); ylabel('Motor #');
    end
end

