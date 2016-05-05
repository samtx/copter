% Combine all .mat files with results from multistart trials

% ttt = 1:15;
% for i = 1:length(ttt)
%     modnum = mod(i-1,3);
%     numprop=(mod(i-1,3))*2+4;
%     fprintf('i=%2d  modnum=%d  numprop=%d \n',[i,modnum,numprop]);
% end
%
% return

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



