% function [cap, c_rate, volt] = load_battery(m)
% INPUT
%   m  =  mass [kg]
% fit 2nd degree polynomial

% vars = load_vars();
% for i= 1:length(vars{1})
% batcap(i) = vars{1}(i).cap;
% batmass(i) = vars{1}(i).mass;
% end
%
% xx = linspace(min(batmass),max(batmass));
% figure;
% hold on
% plot(batmass,batcap,'o');
% xlabel('battery mass');ylabel('battery capacity');
%
% s = polyfit(batmass,batcap,1);
% yy1 = s(1).*xx + s(2);
% plot(xx,yy1,'-.k')
% yy2 = -711.*xx.^2 +1.38e4.*xx - 274.9;
% plot(xx,yy2,'--r')
% legend(['data points','linear','quadratic']);
%
% return

% motor
for i= 1:length(vars{2})
    propcp(i) = vars{2}(i).max_watt;
    motmass(i) = vars{2}(i).mass;
    motkv(i) = vars{2}(i).kv;
    motresist(i) = vars{2}(i).resistance;
end

% xx = linspace(min(motmass),max(motmass));
% figure;
% hold on
% title('Motor Mass vs MaxWatt');
% plot(motmass,motwatt,'o');
% xlabel('motor mass');ylabel('motor max watt');
% % linear fit
% s = polyfit(motmass,motwatt,1);
% yy1 = s(1).*xx + s(2);
% % fit 2nd degree polynomial
% yy2 = 9237.*xx.^2 + 7190.*xx - 34.7;
% plot(xx,yy1,'-.k',xx,yy2,'--r')
% legend('data points','linear','quadratic');
% return

% xx = linspace(min(motmass),max(motmass));
% figure;
% hold on
% title('Motor Mass vs Kv');
% plot(motmass,motkv,'o');
% xlabel('motor mass');ylabel('motor kv');
% % linear fit
% s = polyfit(motmass,motkv,1);
% yy1 = s(1).*xx + s(2);
% % fit 2nd degree polynomial
% yy2 = (-2.364e5).*(xx.^2) - (2.097e4).*xx + 4795;
% plot(xx,yy1,'-.k',xx,yy2,'--r')
% legend('data points','linear','quadratic');
% return

% xx = linspace(min(motmass),max(motmass));
% figure;
% hold on
% title('Motor Mass vs Resistance');
% plot(motmass,motresist,'o');
% xlabel('motor mass');ylabel('motor resist');
% % linear fit
% s = polyfit(motmass,motresist,1);
% yy1 = s(1).*xx + s(2);
% % fit 2nd degree polynomial
% yy2 = 39.86.*xx.^2 - 4.16.*xx + 0.1572;
% % fit 3rd degree poly
% s = polyfit(motmass,motresist,3);
% yy3 = s(1).*xx.^3 + s(2).*xx.^2 + s(3).*xx + s(4);
% plot(xx,yy1,'-.k',xx,yy2,'--r',xx,yy3,'-.m')
% % fit 4th degree poly
% % s = polyfit(motmass,motresist,4);
% % yy4 = s(1).*xx.^4 + s(2).*xx.^3 + s(3).*xx.^2 + s(4).*xx + s(5);
% % plot(xx,yy4,'.');
% legend('data points','linear','quadratic','cubic');
% return

%% prop
for i= 1:length(vars{3})
    propcp(i) = vars{3}(i).cp;
    propmass(i) = vars{3}(i).mass;
    propct(i) = vars{3}(i).ct;
    proplen(i) = vars{3}(i).length;
end
xx = linspace(min(propmass),max(propmass));

% xx = linspace(min(propmass),max(propmass));
% figure;
% hold on
% title('Propeller Mass vs Length');
% plot(propmass,proplen,'o');
% xlabel('prop mass');ylabel('prop length');
% % linear fit
% s = polyfit(propmass,proplen,1);
% yy1 = s(1).*xx + s(2);
% % fit 2nd degree polynomial
% yy2 = (-210.5).*(xx.^2) + (15.27).*xx + 0.1056;
% plot(xx,yy1,'-.k',xx,yy2,'--r')
% %  fit 3rd degree poly
% s = polyfit(propmass,proplen,3);
% yy3 = s(1).*xx.^3 + s(2).*xx.^2 + s(3).*xx + s(4);
% plot(xx,yy3,'-.m')
% legend('data points','linear','quadratic','cubic');
% return



% figure;
% hold on
% title('Propeller Mass vs cp');
% plot(propmass,propcp,'o');
% xlabel('prop mass');ylabel('prop cp');
% % linear fit
% s = polyfit(propmass,propcp,1);
% yy1 = s(1).*xx + s(2);
% % fit 2nd degree polynomial
% yy2 = ( 56.85).*(xx.^2)  - (3.297).*xx + 0.1099;
% plot(xx,yy1,'-.k',xx,yy2,'--r')
% %  fit 3rd degree poly
% s = polyfit(propmass,propcp,3);
% yy3 = s(1).*xx.^3 + s(2).*xx.^2 + s(3).*xx + s(4);
% plot(xx,yy3,'-.m')
% legend('data points','linear','quadratic','cubic');
% return


figure;
hold on
title('Propeller Mass vs ct');
plot(propmass,propct,'o');
xlabel('prop mass');ylabel('prop ct');
% linear fit
s = polyfit(propmass,propct,1);
yy1 = s(1).*xx + s(2);
% fit 2nd degree polynomial
yy2 = ( 70.57).*(xx.^2)  - (3.973).*xx + 0.1579;
plot(xx,yy1,'-.k',xx,yy2,'--r')
%  fit 3rd degree poly
s = polyfit(propmass,propct,3);
yy3 = s(1).*xx.^3 + s(2).*xx.^2 + s(3).*xx + s(4);
plot(xx,yy3,'-.m')
legend('data points','linear','quadratic','cubic');
return
% fit 2nd degree polynomial
length = -210.5*m^2 +15.27*m +0.1056;
cp = 56.85*(m^2) - (3.297)*m + 0.1099;
ct = 70.57*m^2 - 3.973*m + 0.1579;




% function [max_watt,resistance,kv] = load_motor(m)
% INPUT
%   m  =  mass [kg]

% end

% function [length,ct,cp] = load_prop(m)
% INPUT
%   m  =  mass [kg]

% end
