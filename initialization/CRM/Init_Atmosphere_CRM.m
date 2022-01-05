% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Atmosphere] = Init_Atmosphere_CRM(FP)
% Initialize Atmosphere struct for S-function 
Atmosphere = [];

Atmosphere.rho = FP.rho;
Atmosphere.a   = FP.a;
Atmosphere.T   = FP.T;
Atmosphere.p   = FP.p;

% Definition of wind output for model: 
% Columnwise definition: 1-3: x, y, z coordinates; 4: axis (x=1, y=2, z=3), 5: Derivative level 
Atmosphere.RequiredWindOutputs = [[0, 0, 0, 1, 0];
                                  [0, 0, 0, 2, 0];
                                  [0, 0, 0, 3, 0]];

% Definition of gust. By default, initialized with 0-amplitude discrete
% gust.
Atmosphere.WindConfig.WindModelType = 'OneMinusCosineGusts';
Atmosphere.WindConfig.WindModelDef  = [0, 10, 0];
Atmosphere.WindConfig.H = 10;
Atmosphere.WindConfig.U_ds = 0; % Note: only absolute value counts.
Atmosphere.WindConfig.x_start = 0;
Atmosphere.WindConfig.gust_dir = 1; % 1 or -1

end

