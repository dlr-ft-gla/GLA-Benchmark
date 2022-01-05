% In this script, we define a continuous turbulence input and run three simulations:
% 1) in open loop,
% 2) with feedforward control based on an ideal (i.e. perfect) wind estimation,and
% 3) with feedforward control in hybrid simulation.

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

clear;
clc;

%% Initialize
file_path = fileparts(mfilename('fullpath'));
addpath([file_path, filesep, '../']);

Set_Path;

Init_HybridSim_Default_CRM;

%% Custom settings

output_names = {'WR.OSID.112.MX', 'vgust_z'};

CRM = Set_ModelOutputs_CRM(output_names, CRM, model_description);

SimConfig.SampleTime = 0.002;

Check_LidarRange_CRM(CRM,LIDAR, WindReconstruction);

%% Gust definition


Atmosphere.WindConfig = Compute_ContTurbCS25_CRM(CRM.Flight_Point.z, CRM.Flight_Point.Vt, SimConfig);

t_vec = (0:SimConfig.SampleTime:SimConfig.EndTime)';

t_shift = CRM.Sensors.WindEst.horizon*CRM.Sensors.WindEst.dt;
t_turb = Atmosphere.WindConfig.WindModelDef(:,1)./CRM.Flight_Point.Vt;
w_turb = Atmosphere.WindConfig.WindModelDef(:,2);

Atmosphere_Def = Atmosphere; 
WindReconstruction_Def = WindReconstruction;

%% Simulate open loop model
tic;

% Initialize Ideal Wind Estimation simulation model
SimConfig.Model_Name = 'simCRM_IdealWindEst';
[Atmosphere, IdealWind] = Init_IdealWindSim(Atmosphere, CRM.Flight_Point.Vt, 0);
WindReconstruction.MaxBufferSize = 1; % Reduces computation time
CRM = Load_ControlConfigurations_CRM(CRM, SimConfig.Model_Name);

Control_Conf = {'Controller_Config__OL'};
CRM = Set_ActiveControlConfiguration_CRM(CRM, SimConfig.Model_Name, Control_Conf);

simOut = sim(SimConfig.Model_Name);

yout = simOut.get('yout'); 
Y_OL = yout.signals.values;
t_OL = yout.time;
clear simIn simOut yout

toc;

%% Simulate feedforward with ideal wind estimation
tic;

Control_Conf = {'Controller_Config__FFGLA_Default'};
CRM = Set_ActiveControlConfiguration_CRM(CRM, SimConfig.Model_Name, Control_Conf);

t_coords_tmp = CRM.FCS.Controller_Data.CRM_FFGLA_Default.WindEst.t_coords_ctrl;
[Atmosphere, IdealWind] = Init_IdealWindSim(Atmosphere, CRM.Flight_Point.Vt, t_coords_tmp);
clear t_coords_tmp

simOut = sim(SimConfig.Model_Name);

yout = simOut.get('yout'); 
Y_CL = yout.signals.values;
t_CL = yout.time;

close_system(SimConfig.Model_Name,0);

clear simIn simOut yout
toc;

%% Simulate feedforward with Lidar (hybrid simulation)
tic;

SimConfig.Model_Name = 'simCRM_Hybrid';
CRM = Load_ControlConfigurations_CRM(CRM, SimConfig.Model_Name);
Atmosphere = Atmosphere_Def; % Restore default Atmosphere struct
WindReconstruction = WindReconstruction_Def; % Restore default Wind Reconstruction struct
WindReconstruction.StartEstimationTime=0;

Control_Conf = {'Controller_Config__FFGLA_Default'};
CRM = Set_ActiveControlConfiguration_CRM(CRM, SimConfig.Model_Name, Control_Conf);

simOut = sim(SimConfig.Model_Name);

yout = simOut.get('yout'); 
Y_HB = yout.signals.values;
t_HB = yout.time; 

close_system(SimConfig.Model_Name,0);
clear yout
toc;
%% Plot results

t_out = t_HB;
% close all
idx_outputs = zeros(size(output_names));

for ii = 1:length(output_names)
    idx_outputs(ii) = find_str_in_cell_array(output_names{ii}, CRM.Aircraft.Total_Output_Names);
end

for ii=1:length(idx_outputs)
    jj = idx_outputs(ii);

    outIdx = dl2idx(model_description.AC_Outputs,CRM.Aircraft.Total_Output_Names(jj),1);
    
    figure(jj);
    hold on
    markerCoord = 1:(round(length(t_out)/30)):length(t_out);
    plot(t_out-WindReconstruction.StartEstimationTime, Y_OL(:,jj),'k--','LineWidth', 2);
    plot(t_out-WindReconstruction.StartEstimationTime, Y_CL(:,jj),'LineWidth', 1.5,'Color','b', 'Marker', 'x', 'MarkerIndices', markerCoord(1:(end-1))+(round(length(t_out)/20))/2);
    plot(t_out-WindReconstruction.StartEstimationTime, Y_HB(:,jj),'LineWidth', 1.5,'Color','r', 'Marker', 'o', 'MarkerIndices', markerCoord);
    grid on
    title([model_description.AC_Outputs{outIdx,4}, ' - Continuous Turbulence'],'interpreter','none');
    hold off
%     xlim([0 8]);
    legend('Open loop','FFGLA with perfect wind information','FFGLA with lidar-based wind reconstruction');
    xlabel('Time [s]');
    ylabel([model_description.AC_Outputs{outIdx,4}, ' [', model_description.AC_Outputs{outIdx,2}, ']']);
end

