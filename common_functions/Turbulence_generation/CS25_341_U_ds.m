function U_ds = CS25_341_U_ds(H,Fg,alt)
% function U_ds = CS25_341_U_ds(H,Fg,alt)
%
% Calculates the design gust velocity U_ds according to CS25.341(a)(5)(i),
% for the case VB < V < VC. Reference: CS25 Amendment 26 (July 2021)
%
% 12.08.2021    German Aerospace Center (DLR), Institute of Flight Systems
%               Daniel Kiehn (daniel.kiehn@dlr.de)
%
% Inputs:
% H         Gust length in m
% Fg        Flight profile alleviation factor according to CS25.341(a)(6)
% alt       Altitude in m
%
% Outputs:
% U_ds      Design gust velocity in m/s (TAS)
%
% Note:
% The "easy access" EASA certification specifications can be found under:
% https://www.easa.europa.eu/document-library/easy-access-rules/easy-access-rules-large-aeroplanes-cs-25
% 
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 


% Calculate reference gust velocity (EAS)
if alt <= 0
    U_ref = 17.07;
elseif (alt > 0) && (alt <= 4572)
    U_ref = 17.07 + (13.41-17.07)/4572 * alt;
elseif (alt > 4572) && (alt <= 18288)
    U_ref = 13.41 + (6.36-13.41)/(18288-7315) * (alt-4572);
else
    U_ref = 6.36;
end

% Calculate the design gust velocity (EAS)
U_ds_EAS = U_ref * Fg * (H/107)^(1/6);

% Define atmospheric properties for conversion from EAS to TAS
rho0    = 1.225;        % Sea-level std air density [kg/m^3]
T0      = 288.15;       % Sea level std temperature [K]
g       = 9.80665;      % Gravitational acceleration [m/s^2]
L       = 0.0065;       % Temperature lapse rate in troposphere [K/m]
R       = 8.31447;      % Ideal gas constant [J/(mol.K)]
M       = 0.0289654;    % Molar mass of dry air [kg/mol]

rho = rho0 * (1 - L*alt/T0)^((g*M/(R*L))-1);    % Density in kg/m^3

% Calculate U_ds (true windspeed)
U_ds = sqrt(rho0/rho)*U_ds_EAS;

end