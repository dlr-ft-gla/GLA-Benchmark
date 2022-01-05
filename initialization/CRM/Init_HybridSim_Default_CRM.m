% Initialize the CRM Hybrid Simulation to default values.

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Initialize Simulation Config

SimConfig = Init_SimConfig();
SimConfig.SampleTime = 0.002; % 500Hz default 

%% CRM initialisation

model_description = Load_ModelDescriptionLists_CRM(); 

CRM = Init_CRM(model_description, SimConfig);

%% LIDAR Simulation und Wind Reconstruction
[LIDAR,WindReconstruction] = Init_Lidar_and_WindReco;

%% Atmosphere (including default zero-amplitude gust)
Atmosphere = Init_Atmosphere_CRM(CRM.Flight_Point); 
