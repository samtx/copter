% Copter Main Script

% multistart gradient-based optimization

clc
clear all
close all
% use fmincon to find setup with maximum battery life

% save workspace to .mat file at end
date = datestr(now,'yyyymmddHHMMSS');
fname = ['multistart_fmincon_',date,'.mat'];


% Create Parallel Pool of up four workers
c = gcp('nocreate');
if c.Connected 
    if c.NumWorkers ~= 4;
    delete(gcp)
    end
else
    parpool('local',4)
end

% Set up optimization function

% design variables
%     x(1) = battery
%     x(2) = motor
%     x(3) = propeller
%     x(4) = payload
%     x(5) = number of motors/props


% Constraints
% ----------------------------------
% battery mass between 0.095 and 0.618
% motor mass between 0.032 and 0.079
% propeller mass between 0.0071 and 0.025
% propeller number one of set [4, 6, 8]
% Set constant payload at 0 kg.


% Initial Points
% -----------------------------------------
% Use discrete design variables?
isDiscrete = false;
if isDiscrete
    lb = [1,1,1];   % with discrete design vars
    ub = [5,5,5];
else
    lb = [0.095, 0.032, 0.0071];   % with continuous design vars
    ub = [0.618, 0.079, 0.0250];
end

numprop = [4,6,8];  % propeller configurations
m = 10;  % number of random starts
N = m * length(numprop);  % total number of trials
times = zeros(N,6);
allhist = cell(N,1);  % cell array to store opt history for each run
runtime = zeros(N,2);  % store runtimes for each optimization
x0 = zeros(N,5);  % all initial points

j = 1;
for i = 1:m
    % Pick random start for batmass, motmass, propmass
    randstart = rand(1,3).*(ub-lb)+lb;
    x0(j:j+2,1:3) = repmat(randstart,[3,1]);
    x0(j:j+2,4) = numprop';  % use a different prop config for each setup
    x0(j:j+2,5) = zeros(3,1);  % payload mass = zero, constant
    j = j + 3;
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

% Run optimization
fprintf('Initial points, x0...\n');
disp(x0)
fprintf('Run optimzation for %d starting points\n',N);
t1 = tic;
parfor i = 1:N
%     t2 = tic;
    thisx0 = x0(i,:);
    fprintf('begin optimizer for i=%d\n',i);
    hist = copter_optimize(thisx0,lb,ub,scale,isDiscrete,objFlag);
%     fprintf('finished optimizer for i=%d\n',i);
    %times(i,:) = [hist.x(end,:), -hist.fval(end)/60];
%     t2end = toc(t2);
%     t1end = toc(t1);
%     fprintf('collected runtimes for i=%d\n',i);
%     runtime(i,:) = [t2end, t1end];
%     fprintf('stored runtimes for i=%d\n',i);
%     flighttime = -hist.fval(end)/60;
    fprintf('\n Completed Opt for i = %3d\n',i);
%     fprintf('%10d |%16.5|\n\n',[i,flighttime]);
    allhist{i} = hist;
    fprintf('...stored hist for i = %3d\n',i);
%     fprintf('\n CompltOpt#| RunSplt(min)| RunTotl(min)| FlightTime(min)|\n');
%     fprintf('%10d |%12.2f |%12.2f |%16.5|\n\n',[i,t2end/60,t1end/60,-hist.fval(end)/60]);
end
t1end = toc(t1);

% print out function iteration history
fprintf('Total Run time = %.2f sec  (%.2f min)\n',[t1end,t1end/60]);
% fprintf(' iter |  t (min) | bat mass | mot mass | prop mass| prop num | pay mass |\n');
% for i = 1:length(hist.fval)
%     fprintf('%5d |%10.6f|%10.6f|%10.6f|%10.6f|%9d |%10.6f|',[i,-hist.fval(i)/60,hist.x(i,:)]);
%     fprintf('\n');
% end

save(fname);
