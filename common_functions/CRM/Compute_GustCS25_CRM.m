% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [WindConfig] = Compute_GustCS25_CRM(h, gustDir, Vt, alt, time2input)

%Function to calculate the 1-cos gust parameters according to CS25.
% Inputs: -Vt:            Trimmed true airspeed (m/s)
%         -alt:           Trimmed altitude (m)
%         -h:             Gust gradient (in CS25 from 9m to 107m) (m)
%         -time2input:    (Optional) Time until the gust arrives at either  
%                         the LIDAR detection range or aircraft nose 
%                         (i.e. no LIDAR) (s)

if nargin < 5
    time2input = 0;
end

%% Gust peak speed 

F_g = Calculate_Fg_CRM(alt);

U_ds = CS25_341_U_ds(h,F_g,alt);
U_ds = gustDir * U_ds;              % Upwards/downwards gust

%% Gust velocity vector

xStart = time2input*Vt;

%% Output
WindConfig = [];
WindConfig.WindModelDef = [xStart, h, U_ds];
WindConfig.WindModelType = 'OneMinusCosineGusts';
WindConfig.H = h;
WindConfig.U_ds = U_ds;
WindConfig.x_start = xStart;

end