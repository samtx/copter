% Analyze data for fmincon experiments

% Combine all .mat files with results from multistart trials

collect_files = 0;
find_best     = 1;
scatter_plots = 0;
full_factorial_plot = 0;

% ttt = 1:15;
% for i = 1:length(ttt)
%     modnum = mod(i-1,3);
%     numprop=(mod(i-1,3))*2+4;
%     fprintf('i=%2d  modnum=%d  numprop=%d \n',[i,modnum,numprop]);
% end
%
% return

if collect_files
    rslts = []; % 4 design vars, 2 obj
    iters = {};  % to hold all iterations for each opt run
    % cur_row
    relpath = './data/';
    expname = 'multistart_fmincon';
    files = dir([relpath,expname, '*.mat']); % .mat files are in ./data directory
    for i = 1:length(files)  % loop over .mat files
        fname = files(i).name;  % get filename
        s = load([relpath fname],'allhist');
        thishist = s.allhist;
        % loop over hist and put final opt results in rslts array, and full
        % iteration history in iters cell array.
        
        % But I forgot to add the numprop and paymass to this data, but the
        % order it went in was 4,6,8 by mod 3, and paymass=0 for all
        %         paymass = 0;
        %         for j = 1:length(thishist)
        %             numprop=(mod(j-1,3))*2+4;
        %             b = repmat([numprop,paymass],[size(thishist{j}.x,1),1]);
        %             thishist{j}.x = [thishist{j}.x, b]; % add numprop and paymass to iteration history for run j in hist k
        %         end
        %         allhist = thishist;
        %         save([relpath fname],'allhist','-append');
        %
        % Now re-loop over everything and save data to local arrays
        cur_row = size(rslts,1) + 1;
        for j = 1:length(thishist)
            rslts(end+1,:) = [thishist{j}.x(end,:),(-1/60)*thishist{j}.fval(end)];
            iters{end+1,1} = [thishist{j}.x(:,:),(-1/60)*thishist{j}.fval(:,1)];
        end
    end
end


if find_best
    % filter into separate arrays for each prop num
    rslts4 = rslts(rslts(:,4)==4,:);
    rslts6 = rslts(rslts(:,4)==6,:);
    rslts8 = rslts(rslts(:,4)==8,:);
    % overall best
    [allM,allI] = max(rslts(:,6));
    rslts(allI,:)
    % best prop4
    [prop4M,prop4I] = max(rslts4(:,6));
    rslts4(prop4I,:)
    % best prop6
    [prop6M,prop6I] = max(rslts6(:,6));
    rslts6(prop6I,:)
    % best prop8
    [prop8M,prop8I] = max(rslts8(:,6));
    rslts8(prop8I,:)
    
end

% if full_factorial_plot
%     
% end

% rslts array has only the final design variables and obj values
% iters array has all the iterations for each opt run
if scatter_plots
    prop4 = rslts(:,4)==4;
    prop6 = rslts(:,4)==6;
    prop8 = rslts(:,4)==8;
    
    lb = [0.095, 0.032, 0.0071];   % with continuous design vars
    ub = [0.618, 0.079, 0.0250];
    axislims = [lb(1),ub(1),lb(2),ub(2),lb(3),ub(3)];
    circsize = 50;
    %     hold on
    figure(1);
    scatter3(rslts(prop4,1),rslts(prop4,2),rslts(prop4,3),circsize,rslts(prop4,6),'filled','o')
    xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
%     axis(axislims);
    title('Flight Time with 4 Propellers');
    colorbar;
    
    figure(2);
    scatter3(rslts(prop6,1),rslts(prop6,2),rslts(prop6,3),circsize,rslts(prop6,6),'filled','^')
    xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
    title('Flight Time with 6 Propellers');
    axis(axislims);
    colorbar;
    
    figure(3);
    scatter3(rslts(prop8,1),rslts(prop8,2),rslts(prop8,3),circsize,rslts(prop8,6),'filled','p')
    xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
    title('Flight Time with 8 Propellers');
    axis(axislims);
    colorbar;
end

if full_factorial_plot
scatter3(times(times(:,4)==propnum,1),times(times(:,4)==propnum,2),times(times(:,4)==propnum,3),500,times(times(:,4)==propnum,5),'filled','s')
    xlabel('Battery #');ylabel('Motor #');zlabel('Propeller #');
    title('Flight Time with 4 Propellers');
    colorbar;
end