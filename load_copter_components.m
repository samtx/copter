function [mybat,mymot,myprop] = load_copter_components(x)
% load copter variables as struct objects

%% load battery variables, Table IV
bat(1).volt = 12;     % battery voltage (V)
bat(1).cap = 2200;    % battery capacity (mAh)
bat(1).c_rate = 25;   % battery C-rating (1/h)
bat(1).mass = 0.179;  % mass of single battery (kg)
bat(1).num = 1;       % number of batteries

bat(2).volt = 12;     % battery voltage (V)
bat(2).cap = 1000;    % battery capacity (mAh)
bat(2).c_rate = 25;   % battery C-rating (1/h)
bat(2).mass = 0.095;  % mass of single battery (kg)
bat(2).num = 1;       % number of batteries

bat(3).volt = 12;     % battery voltage (V)
bat(3).cap = 4000;    % battery capacity (mAh)
bat(3).c_rate = 25;   % battery C-rating (1/h)
bat(3).mass = 0.309;  % mass of single battery (kg)
bat(3).num = 1;       % number of batteries

bat(4).volt = 12;     % battery voltage (V)
bat(4).cap = 8000;    % battery capacity (mAh)
bat(4).c_rate = 25;   % battery C-rating (1/h)
bat(4).mass = 0.618;  % mass of single battery (kg)
bat(4).num = 1;       % number of batteries

bat(5).volt = 12;     % battery voltage (V)
bat(5).cap = 5000;    % battery capacity (mAh)
bat(5).c_rate = 25;   % battery C-rating (1/h)
bat(5).mass = 0.397;  % mass of single battery (kg)
bat(5).num = 1;       % number of batteries

%% load motor variables, Table III
mot(1).mass = 0.032;        % mass of single motor (kg)
mot(1).kv = 3900;           % unsure what this is
mot(1).max_watt = 200;      % max wattage of motor (W)
mot(1).resistance = 0.064;  % motor resistance (ohms)
% mot(1).num = 4;             % number of motors

mot(2).mass = 0.054;        % mass of single motor (kg)
mot(2).kv = 2640;           % unsure what this is
mot(2).max_watt = 375;      % max wattage of motor (W)
mot(2).resistance = 0.063;  % motor resistance (ohms)
% mot(2).num = 4;             % number of motors

mot(3).mass = 0.054;        % mass of single motor (kg)
mot(3).kv = 3200;           % unsure what this is
mot(3).max_watt = 415;      % max wattage of motor (W)
mot(3).resistance = 0.040;  % motor resistance (ohms)
% mot(3).num = 4;             % number of motors

mot(4).mass = 0.064;        % mass of single motor (kg)
mot(4).kv = 2608;           % unsure what this is
mot(4).max_watt = 430;      % max wattage of motor (W)
mot(4).resistance = 0.048;  % motor resistance (ohms)
% mot(4).num = 4;             % number of motors

mot(5).mass = 0.079;        % mass of single motor (kg)
mot(5).kv = 1630;           % unsure what this is
mot(5).max_watt = 600;      % max wattage of motor (W)
mot(5).resistance = 0.079;  % motor resistance (ohms)
% mot(5).num = 4;             % number of motors

%% load propeller variables, Table II
prop(1) = struct(...
    'mass',0.0071,...           % mass of propeller (kg)
    'length',8 *(0.0254),...    % propeller diameter (m), convert inches to meters 
    'ct',0.1338);             % propeller coefficient of thrust
prop(1).cp = 0.0897;             % propeller coefficient of power
% prop(1).num = 4;                 % number of propellers

prop(2).mass = 0.0091;           % mass of propeller (kg)
prop(2).length = 9 *(0.0254);    % propeller diameter (m), convert inches to meters 
prop(2).ct = 0.1262;             % propeller coefficient of thrust
prop(2).cp = 0.0837;             % propeller coefficient of power
% prop(2).num = 4;                 % number of propellers

prop(3).mass = 0.0119;           % mass of propeller (kg)
prop(3).length = 10 *(0.0254);   % propeller diameter (m), convert inches to meters 
prop(3).ct = 0.1222;             % propeller coefficient of thrust
prop(3).cp = 0.0797;             % propeller coefficient of power
% prop(3).num = 4;                 % number of propellers

prop(4).mass = 0.0139;           % mass of propeller (kg)
prop(4).length = 11 *(0.0254);   % propeller diameter (m), convert inches to meters 
prop(4).ct = 0.1156;             % propeller coefficient of thrust
prop(4).cp = 0.0746;             % propeller coefficient of power
% prop(4).num = 4;                 % number of propellers

% skip p5 in table so that we only have 5 propellers 

prop(5).mass = 0.0250;           % mass of propeller (kg)
prop(5).length = 14 *(0.0254);   % propeller diameter (m), convert inches to meters 
prop(5).ct = 0.1027;             % propeller coefficient of thrust
prop(5).cp = 0.0630;             % propeller coefficient of power
% prop(5).num = 4;                 % number of propellers

%% Return selected components as structs

mybat = bat(x(1));
mymot = mot(x(2));
myprop = prop(x(3));
    
end
