function U_sigma_ref = CS25_341_U_sigma_ref(alt)
% function U_sigma_ref = CS25_341_U_sigma_ref(alt)
%
% Calculates the reference turbulence intensity U_sigma_ref according to
% CS25.341(b)(3)(i). Reference: CS25 Amendment 26 (July 2021)
%
% 10.08.2021    German Aerospace Center (DLR), Institute of Flight Systems
%               Daniel Kiehn (daniel.kiehn@dlr.de)
%
% Input:    Altitude in meters
% Output:   Reference turbulence intensity in m/s
%
% Note:
% The "easy access" EASA certification specifications can be found under:
% https://www.easa.europa.eu/document-library/easy-access-rules/easy-access-rules-large-aeroplanes-cs-25
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

if alt <= 0
    U_sigma_ref = 27.43;
elseif (alt > 0) && (alt < 7315)
    U_sigma_ref = 27.43 + (24.08-27.43)/7315 * alt;
else
    U_sigma_ref = 24.08;
end

end