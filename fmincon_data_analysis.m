% Analyze data for fmincon experiments

% rslts array has only the final design variables and obj values
% iters array has all the iterations for each opt run

prop4 = rslts(:,4)==4;
prop6 = rslts(:,4)==6;
prop8 = rslts(:,4)==8;

circsize = 50;

figure;
scatter3(rslts(prop4,1),rslts(prop4,2),rslts(prop4,3),circsize,rslts(prop4,6),'filled')
xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
title('Flight Time with 4 Propellers');
colorbar;

figure;
scatter3(rslts(prop6,1),rslts(prop6,2),rslts(prop6,3),circsize,rslts(prop6,6),'filled')
xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
title('Flight Time with 6 Propellers');
colorbar;

figure;
scatter3(rslts(prop8,1),rslts(prop8,2),rslts(prop8,3),circsize,rslts(prop8,6),'filled')
xlabel('Battery Mass');ylabel('Motor Mass');zlabel('Propeller Mass');
title('Flight Time with 8 Propellers');
colorbar;