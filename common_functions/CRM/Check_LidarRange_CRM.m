% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [delta_x] = Check_LidarRange_CRM(CRM,LIDAR,WindReconstruction)
%   Checks lidar maximum range against estimation lead time.
%   If lidar max. range along the flight path is shorter than estimation
%   lead distance, a warning is emitted.

Vt     = CRM.Flight_Point.Vt;
x_lead = WindReconstruction.t_lead * Vt;

x_lidar = (LIDAR.Geometry.R_min + LIDAR.Geometry.Delta_R*(LIDAR.Geometry.N_bins-1)) * cos(LIDAR.Scanner.SemiApertureAngle * pi/180);

delta_x = x_lidar - x_lead;

if delta_x < 0
    warning('Lidar maximum range is shorter than the estimation lead distance. Leading wind nodes may not be based on measured data.');
end

end

