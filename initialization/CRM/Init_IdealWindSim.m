% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Atmosphere, IdealWind] = Init_IdealWindSim(Atmosphere, VTAS, rel_t_coords)
% Initialize Atmosphere and IdealWind to run the 'IdealWind' version of the
% lidar model (i.e. with perfect estimated wind field values and reduced computation).

IdealWind = [];
IdealWind.rel_t_coords = rel_t_coords(:);
IdealWind.rel_x_coords = IdealWind.rel_t_coords * VTAS;
IdealWind.n_nodes = length(rel_t_coords);

Atmosphere.RequiredWindOutputs = [[[0, 0, 0, 1, 0];
                                  [0, 0, 0, 2, 0];
                                  [0, 0, 0, 3, 0]];...
     [IdealWind.rel_x_coords, zeros(IdealWind.n_nodes,2), 3*ones(IdealWind.n_nodes,1), zeros(IdealWind.n_nodes,1)]];

end

