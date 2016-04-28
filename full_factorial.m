% Full factorial discrete copter trials


% Flight plan constants
mission.z0       =   0;   % initial altitude [m]
mission.zf       = 100; % final altitude [m]
mission.zdot_max =  10; % max ascent velocity [m/s]
mission.zdotdot  =   5;   % vertical takeoff acceleration [m/s2]
mission.zbuffer  =  10; % buffer height to stop accelerating as going upward [m]
mission.complete =   0;
mission.target_velocity = 10;

% what are wanting to optimize?
opt_flag = 1;  % maximize time
scale = [];

% function to optimize
fun = @(x) copter_simulate(x,mission,opt_flag,scale);

% We have 5 batteries, 5 motors, and 5 propellers
% --> 3 indep vars, 1 dep var (time)
dFF = fullfact([5,5,5]);
hist = zeros(1,length(dFF));
tic;
parfor i = 1:length(dFF)
    x = dFF(i,:);
    fprintf('Running... i=%3d --> Bat #%d,   Mot #%d,   Prop #%d \n',[i,x]);
	hist(i) = -fun(x)/60;
end
t = toc;
fprintf('Parallel computation time = %5.2f sec for %3d runs\n',[t,length(dFF)]);

% put results in 3D matrix indexed by component number
times = zeros(5,5,5);
for i = 1:length(hist)
    a = dFF(i,1);
    b = dFF(i,2);
    c = dFF(i,3);
    times(a,b,c) = hist(i);
end

% Make 3D bar graphs for full factorial results

% times( 'Bat#' , 'Mot#', 'Prop#') = time

for i = 1:5
    figure;
    bar3(times(:,:,i))
    title(['Flight Time (Min) with Prop # ',num2str(i)]);
    xlabel('Battery #'); ylabel('Motor #');
end

save('full_factorial_new.mat');

            