function Fg = CS25_341_Fg(alt, Zmo,MTOW,MLW,MZFW)
% function Fg = CS25_341_Fg(alt, Zmo,MTOW,MLW,MZFW)
%
% Calculates the nondimensional flight profile alleviation factor Fg as
% defined in CS25.341(a)(6). Reference: CS25 Amendment 26 (July 2021)
%
% 10.08.2021    German Aerospace Center (DLR), Institute of Flight Systems
%               Daniel Kiehn (daniel.kiehn@dlr.de)
%
% Inputs:
% alt       Aircraft altitude in m
% Zmo       Maximum operation altitude in m, according to CS25.1527
% MTOW      Maximum take-off weight
% MLW       Maximum landing weight
% MZFW      Maximum zero fuel weight
%           MTOW, MLW and MZFW can be specified in any unit, as long as the
%           the same unit is used for all of them.
%
% Output:
% Fg        Flight profile alleviation factor as defined in CS25.341(a)(6)
%
% Notes:
% The "easy access" EASA certification specifications can be found under:
% https://www.easa.europa.eu/document-library/easy-access-rules/easy-access-rules-large-aeroplanes-cs-25
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

Fgz = 1 - Zmo/76200;

R1 = MLW/MTOW;
R2 = MZFW/MTOW;

Fgm = sqrt(R2*tan(pi*R1/4));

Fg_sl = 0.5*(Fgz + Fgm); % Fg at sea level

Fg = Fg_sl + (1-Fg_sl)*(alt/Zmo);

end