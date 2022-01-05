% In this script, we run a single simulation and plot the estimated 
% windfield over the course of the simulation.

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

% clear;
% clc;

%% Initialize
file_path = fileparts(mfilename('fullpath'));
addpath([file_path, filesep, '../']);

Set_Path;

Init_HybridSim_Default_CRM;

%% Custom settings
outputNames = {'WR.OSID.112.MX'};

CRM = Set_ModelOutputs_CRM(outputNames, CRM, model_description);

SimConfig.SampleTime = 0.002;

t_start = 6;

Control_Conf = {'Controller_Config__OL'};
CRM = Set_ActiveControlConfiguration_CRM(CRM, SimConfig.Model_Name, Control_Conf);

Check_LidarRange_CRM(CRM,LIDAR, WindReconstruction);

%% Gust definition

Gust.x_start = CRM.Flight_Point.Vt*t_start;
Gust.H       = 100;
Gust.amp     = 20;

Atmosphere.WindConfig.WindModelDef = [Gust.x_start, Gust.H, Gust.amp];

%% Simulate feedforward with Lidar (hybrid simulation)
tic
simOut = sim(SimConfig.Model_Name);


yout = simOut.get('yout'); 
Y_HB = yout.signals.values;
t_out = yout.time;

Inertial_Motion = simOut.get('Inertial_Motion');
Current_Wind = simOut.get('Current_Wind');
xCoords = simOut.get('xCoords_Estimated_Wind_Field_Nodes');
Estimated_Wind_Field = simOut.get('Estimated_Wind_Field');
dt_EWF = diff(Estimated_Wind_Field.time(1:2,1));

close_system(SimConfig.Model_Name,0);
toc
%% Plot results

% close all;

figure();
plot(Inertial_Motion.signals.values(:,1), Current_Wind.signals.values(:,3), 'k--', 'LineWidth', 2);
for in = (5.5/dt_EWF):(0.2/dt_EWF):(8.5/dt_EWF)
    hold on
    plot(xCoords.signals.values(in,:), Estimated_Wind_Field.signals.values(in,:), 'LineWidth', 1);
    grid on;
    hold off
    
end
xlim([1300, 2000]);
ylim([-2 22]);
title('Evolution of Estimated Vertical Wind Field','interpreter','none');
xlabel('Distance from simulation start [m]');
ylabel('Estimated wind speed [m/s]');
legend('True wind speed');

