function [CRM] = Init_CRM(model_description, sim_config) 

% Initialization function for CRM simulink model / environment
% The CRM struct must be placed in the base workspace to work correctly.
% 
% Inputs:
%   - model_description: Mandatory input. Contains CRM model description list
%   - sim_config: Simulation configuration script. See Init_SimConfig.m
% 
%
% Contents of this script:
%     Preliminary
%     Flight Point
%     Sensors
%     Actuators
%     Flight Control
%     Aircraft
%     Actuators
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Preliminary
model_filename = 'C2_M0_86_9100m.mat';
    
addpath(genpath([pwd(),filesep,'data']));
addpath(genpath([pwd(),filesep,'lib_slk']));
addpath(genpath([pwd(),filesep,'helper_functions']));

CRM = [];

%% Flight Point
%Air Data and Flight Point
fp_tmp = load(model_filename, 'flight_point');
CRM.Flight_Point = fp_tmp.flight_point;

clear fp_tmp

%% Sensors

Classical.Signal_Names = { 'nz','Dz_Dt', 'z', 'Theta', 'DTheta_Dt',...
                           'gamma', 'alpha_inertial', 'alpha_aero', 'V', 'V_dot',...
                           'de', 'da_sym_in', 'da_sym_out','de_dot', 'da_sym_in_dot', 'da_sym_out_dot'};
Flex.Signal_Names = {};

Classical.Output_Idxs = dl2idx(model_description.AC_Outputs,Classical.Signal_Names, 1);
Flex.Output_Idxs      = dl2idx(model_description.AC_Outputs,Flex.Signal_Names, 1);

Classical.Num_Signals = length(Classical.Signal_Names);
Flex.Num_Signals      = length(Flex.Signal_Names);

WindEst.horizon = -1; %-1: no wind field, 0: measured @ A/C nose
WindEst.dt = 1/100;
WindEst.trail = 0; 

WindEst.t_coords_ctrl = [0];%[-WindEst.trail:max(0,WindEst.horizon)].*0.01;


CRM.Sensors.Classical     = Classical;
CRM.Sensors.Flex          = Flex;
CRM.Sensors.WindEst       = WindEst;

CRM.Sensors.Measure_Delay = 0; %Global measurement delay, in controller cycles

CRM.Sensors.Total_Output_Idxs = [CRM.Sensors.Classical.Output_Idxs, CRM.Sensors.Flex.Output_Idxs];
CRM.Sensors.Total_Output_Names = [CRM.Sensors.Classical.Signal_Names, CRM.Sensors.Flex.Signal_Names];
CRM.Sensors.Num_Total_Signals = CRM.Sensors.Classical.Num_Signals + CRM.Sensors.Flex.Num_Signals;

clear Classical Flex WindEst

%% Flight Control System

CRM.FCS = [];

CRM = Load_ControlConfigurations_CRM(CRM, sim_config.Model_Name);

CRM.FCS.Command_Delay   = 0; %Global command delay, in controller cycles
CRM.FCS.SampleTime      = 0.01; % Control system oeprates at 100Hz by default 


%% Aircraft Model

%Load statespace matrices
CRM.Aircraft = load(model_filename, 'linear_sys');

Output_Names = {'vgust_z', 'WR.OSID.112.MX', 'WR.OSID.122.MX', 'WR.OSID.130.MX', 'WR.OSID.138.MX', 'WR.OSID.146.MX','HR.OSID.21.MX'};
Output_Idxs = dl2idx(model_description.AC_Outputs,Output_Names, 1);

CRM.Aircraft.C_sensors = CRM.Aircraft.linear_sys.C(CRM.Sensors.Total_Output_Idxs,:);
CRM.Aircraft.D_sensors = CRM.Aircraft.linear_sys.D(CRM.Sensors.Total_Output_Idxs,:);

CRM = Set_ModelOutputs_CRM(Output_Names, CRM, model_description);

clear Output_Names Output_Idxs 

%% Actuators

Act_Default.w_SO    = 10;    % Natural freq [rad/s]
Act_Default.d_SO    = 0.8;   % Damping ratio
Act_Default.K_st    = 1;     % Static gain
Act_Default.rateLim = 40;    % Rate limit [deg/s]
Act_Default.posLim  = 20;    % Deflection limit [deg]

Actuators.OuterAileron = Act_Default;
Actuators.InnerAileron = Act_Default;
Actuators.Elevator     = Act_Default;

Actuators.Global_Delay = 0; %Global actuator transport delay, in seconds

CRM.Actuators = Actuators;
clear Actuators Act_Default

end
