% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [F_g] = Calculate_Fg_CRM(alt)
% Compute flight profile alleviation factor for CRM.
% Inputs:
% - alt: Altitude (m)

%Flight profile alleviation factor - Data taken from B777
Zmo = 13100;    % (m)
MTOW = 260000;  % (kg)
MZFW = 195000;   % (kg)
MLW = 200000;   % (kg)

F_g = CS25_341_Fg(alt, Zmo, MTOW, MLW, MZFW);

end

