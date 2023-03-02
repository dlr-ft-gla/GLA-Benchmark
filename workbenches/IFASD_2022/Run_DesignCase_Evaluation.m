% Evaluate benchmark problem

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

clc
clear
clear mex

%% Load path(s)
file_path = fileparts(mfilename('fullpath'));
addpath([file_path, filesep, '..', filesep]);

Set_Path;

%% Define load cases 

Aircraft_Name   = 'CRM';
MassCases       = {'C2'};       
AltitudeCases   = {9100};
SpeedCases      = {'M0_86'};

ActiveControlConfigs = {'Controller_Config__FFGLA_IFASDCase1';'Controller_Config__FFGLA_IFASDCase2';'Controller_Config__FFGLA_IFASDCase3' };
                          
desired_output_names = {'de', 'da_sym_in', 'da_sym_out', 'de_dot', 'da_sym_in_dot', 'da_sym_out_dot', ...
                'nz', 'gamma', 'alpha_aero', 'DTheta_Dt', 'Theta', 'Dz_Dt', 'V', 'V_dot', 'vgust_z',...
                'WR.OSID.112.MX', 'WR.OSID.122.MX', 'WR.OSID.130.MX', 'WR.OSID.138.MX', 'WR.OSID.146.MX','HR.OSID.21.MX'};
                         
%% Common initial processing steps (paths and saving conditions)

currentTime          = now();
ResultsDirectoryName = [datestr(currentTime,'yyyy_mm_dd'),'__',datestr(currentTime,'HH'),'h',datestr(currentTime,'MM'),'m',datestr(currentTime,'SS'),'s'];
                   
ResultsDirectoryPath = [init_path, filesep, 'results',filesep,ResultsDirectoryName];

ResultsDirectory_Nominal = [ResultsDirectoryPath, filesep, 'Nominal'];
ResultsDirectory_Robust  = [ResultsDirectoryPath, filesep, 'Robust'];

if ~exist(ResultsDirectoryPath,'dir'); mkdir(ResultsDirectoryPath); end                   
if ~exist(ResultsDirectory_Nominal,'dir'); mkdir(ResultsDirectory_Nominal); end  
if ~exist(ResultsDirectory_Robust,'dir'); mkdir(ResultsDirectory_Robust); end  

clear currentTime

%% Nominal sweep

% Discrete gusts
% Define the sweep data. Col 1: Variable names, Col 2: Variable values
sweepData  = {'Atmosphere.WindConfig.H',         [30 90 150 210 280 350].*0.3048
              'CRM.Actuators.Global_Delay',      [0.03]};

sweepType = 1; % 1 = cross, 2 = parallel          

control_configs_list = [{ 'Controller_Config__OL'};
                         ActiveControlConfigs];
                     
load_type_list = {'CS25_341a'};

ResultsDirectoryFullPath = ResultsDirectory_Nominal;

disp('Simulating Nominal CS 25.341a discrete gust encounters: ');
Define_Sweep_and_Perform_Simulations;

Nominal_Task_List_DG = listOfTasks;

%Continuous turbulence:
sweepData  = {'CRM.Actuators.Global_Delay',      [0.03]};

load_type_list = {'CS25_341b'};

disp('Simulating Nominal CS 25.341b continuous turbulence encounters: ');
Define_Sweep_and_Perform_Simulations;

Nominal_Task_List_CT = listOfTasks;

%% Clean up after simulation
% Closing the system without saving to prevent unnecessary overwriting of
% the version in git (and shadowing the other workbenches if we switch)
close_system(SimConfig.Model_Name,0);

%% Analyze simulation results

disp('Analyzing simulation results')
Analyze_SimulationResults
