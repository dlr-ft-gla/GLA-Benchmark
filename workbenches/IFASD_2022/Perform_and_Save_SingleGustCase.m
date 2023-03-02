% Simulate single discrete gust encounter

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Initialization of aircraft model 
 
SimConfig.EndTime = 12;

%% Atmosphere parameters at current flight condition

Atmosphere.WindConfig.WindModelType = 'OneMinusCosineGusts';
Atmosphere.WindConfig.U_ds          = -1;
Atmosphere.WindConfig.x_start       = (WindReconstruction.StartEstimationTime + 2) * CRM.Flight_Point.Vt;

%% Initialization of the controller struct

[CRM.FCS.Controllers,CRM.FCS.Configurations] = Load_Controller_and_ControllerConfigurations(SimConfig.Model_Name,control_configs_list);
[CRM.FCS]                                    = Process_FCS_Configuration_Settings(CRM.FCS);

%% Update simulation parameter values

Assign_SweepValues(TaskDefinition.Sweep_Point, TaskDefinition.Sweep_Names);

Atmosphere.WindConfig = Update_WindConfig_CRM(Atmosphere.WindConfig, CRM.Flight_Point);

%% Hybrid simulation(s)  

for i_HS=1:(size(CRM.FCS.Configurations,2))
    
    CRM.FCS.Active_Config = i_HS;

    CRM.FCS.Controller_Data = [];    
                        
    [CRM.FCS.Controller_Data] = Initialize_Active_Controllers(CRM,SimConfig.Model_Name);

    %% Save Meta Information
    Store_Configuration; % still to be adapted to XRF1 
    tic;
    clear mex;clear mex;
    simOut = sim(SimConfig.Model_Name);
    
    SimResults.SimOut.(CRM.FCS.Configurations(CRM.FCS.Active_Config).Identifier) = [];
    SimResults.SimOut.(CRM.FCS.Configurations(CRM.FCS.Active_Config).Identifier).Outputs  = simOut.get('yout');    
    clear simOut;

    toc;

end

%% Saving Results
SimResults.CRM.FCS.Active_Config = []; % delete the active config info as it may be misleading (the saved structure contains results for all configs)

directory_str = [ResultsDirectoryFullPath,filesep,TaskDefinition.Load_Type];
file_str = ['Task_',num2str(taskIdx)];
if ~exist(directory_str,'dir')
    mkdir(directory_str);
end
save([directory_str,filesep,file_str,'.mat'],'SimResults');

    
% EOF