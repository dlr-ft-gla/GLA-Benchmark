% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Flight_Point] = Calculate_FlightPoint_CRM(Mach,z)
% Calculate full data of the flight point using
% Mach, altitude, and ISA formulas.

Flight_Point.z = z;
Flight_Point.Mach = Mach;

Flight_Point.g0 = 9.81;
%ISA
Flight_Point.R       = 287.058;
Flight_Point.gam0    = 1.4;
Flight_Point.rho0    = 1.225;    % kg/m^3
Flight_Point.p0      = 101325;   % Pa
Flight_Point.T0      = 288.15;   % K

Flight_Point.T   = Flight_Point.T0 - (Flight_Point.z*6.5/1000); % K
Flight_Point.rho = Flight_Point.rho0 * (Flight_Point.T0 / Flight_Point.T)^(1 + (Flight_Point.g0 /(Flight_Point.R*-6.5/1000)));
Flight_Point.p   = Flight_Point.p0 * (Flight_Point.T0 / Flight_Point.T)^(Flight_Point.g0 /(Flight_Point.R*-6.5/1000));
% 
Flight_Point.a       = sqrt(Flight_Point.gam0*Flight_Point.R*(Flight_Point.T));     % m/s
Flight_Point.Vt      = Flight_Point.Mach*Flight_Point.a;                                  % m/s
Flight_Point.Vc      = Flight_Point.Vt * sqrt(Flight_Point.rho/Flight_Point.rho0 );       % m/s

end

