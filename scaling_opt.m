% Copter Main Script

% multistart gradient-based optimization

clc
clear all
close all
% use fmincon to find setup with maximum battery life


% Create Parallel Pool of up four workers
% c = gcp('nocreate');
% if c.Connected
%     if c.NumWorkers ~= 4;
%         delete(gcp)
%     end
% else
%     parpool('local',4)
% end

delete_prev = 0;

if delete_prev
    % Delete previous data files
    relpath = './data/';
    expname = 'multistart';
    files = dir([relpath,expname, '*.mat']); % .mat files are in ./data directory
    for i = 1:length(files)  % loop over .mat files
        fname = files(i).name;  % get filename
        delete([relpath fname]);
    end
end


for bigloop = 1:1
    
    % save workspace to .mat file at end
    date = datestr(now,'yyyymmddHHMMSS');
    fpath = './data/';  % put in data folder
    fname = [fpath,'multistart_fmincon_',date,'.mat'];
    
    
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
    
    %
    % -----------------------------------------
    m = 1;      % ***   NUMBER OF RANDOM STARTS     ***
    dt = 0.1;   % ***         TIME STEP             ***
    
    
    % ------------ SCALING? ---------------------------
    scale = struct;
    % scale.all = 1;
    scale.batt = 1;
    scale.mot = 10;
    scale.prop = 10;
    scale.num = 1;
    scale.pay = 1;
    scale.timemult = 1e-5;
    scale.timeadd = 0;
    scale.vector = [scale.batt, scale.mot, scale.prop, scale.num, scale.pay];
    
    %     N = m * length(numprop);  % total number of trials
    N = 1;
    %     times = zeros(N,6);
    allhist = cell(N,1);  % cell array to store opt history for each run
    %     runtime = zeros(N,2);  % store runtimes for each optimization
    %     x0 = zeros(N,5);  % all initial points
    
    %     j = 1;
    %     for i = 1:m
    %         % Pick random start for batmass, motmass, propmass
    %         randstart = rand(1,3).*(ub-lb)+lb;
    %         x0(j:j+2,1:3) = repmat(randstart,[3,1]);
    %         x0(j:j+2,4) = numprop';  % use a different prop config for each setup
    %         x0(j:j+2,5) = zeros(3,1);  % payload mass = zero, constant
    %         j = j + 3;
    %     end
    
    % Previously defined optimum solution
    x0 = [0.618, 0.032, 0.0250, 8, 0.0];
    
    % apply scaling
    x0 = x0 .* scale.vector;
    
    fprintf('Scaling factors...\n');
    disp(scale);
    % what are wanting to optimize?
    objFlag = 1;  % maximize time
    
    % Run optimization
    fprintf('Initial points, x0, with scaling...\n');
    
    disp(x0)
    fprintf('Run optimzation for %d starting points\n',N);
    t1 = tic;
    parfor i = 1:N
        %     t2 = tic;
        thisx0 = x0(i,:);
        fprintf('begin optimizer for i=%d\n',i);
        hist = copter_optimize(thisx0,lb,ub,scale,isDiscrete,objFlag,dt);
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
        
        % add numprop and paymass back to hist.x array of iterations
        hist.x = [hist.x, repmat(thisx0(4:5),[size(hist.x,1),1])];
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
    
    save(fname,'allhist');
end
