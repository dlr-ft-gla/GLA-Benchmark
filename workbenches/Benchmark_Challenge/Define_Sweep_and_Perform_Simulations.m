% Define simulation cases and launch simulations

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Assemble task list

N_MassCases      = size(MassCases,1);
N_AltitudeCases  = size(AltitudeCases,1);
N_SpeedCases     = size(SpeedCases,1);

list_aircraft_models{1,1} = 'Default';
list_aircraft_models{2,1} = MassCases{1,1};
list_aircraft_models{3,1} = AltitudeCases{1,1};
list_aircraft_models{4,1} = SpeedCases{1,1}; 

N_list_of_aircraft_models = size(list_aircraft_models,2);

%% Prepare sweep information          
sweepNames    = sweepData(:,1);
sweepValues   = sweepData(:,2);
sweepSize     = length(sweepNames);

for ii = 1:sweepSize
    sweepValuesSize(ii,1) = length(sweepValues{ii,1}); 
end

if (sweepType == 2) && (sum(sweepValuesSize) ~= sweepValuesSize(1)*sweepSize)
    error('For parallel sweeps, all value vectors must be the same length');
end

%%

listOfTasks={};
taskIdx = 0;
% Sweep engine
for idx_type = 1:length(load_type_list)
    sweepComplete = false;

    sweepIdxs = ones(sweepSize,1); 
    sweepPoint = zeros(sweepSize,1);
     
    while ~sweepComplete
        taskIdx = taskIdx + 1;
        % Assign values to variables
        for ii = 1:sweepSize
            sweepPoint(ii,1) = sweepValues{ii,1}(sweepIdxs(ii));
        end

        listOfTasks{taskIdx}.Aircraft               = Aircraft_Name;
        listOfTasks{taskIdx}.Aircraft_Configuration = list_aircraft_models{1,1};
        listOfTasks{taskIdx}.Mass_Configuration     = list_aircraft_models{2,1};
        listOfTasks{taskIdx}.Altitude               = list_aircraft_models{3,1};
        listOfTasks{taskIdx}.Speed                  = list_aircraft_models{4,1};
        listOfTasks{taskIdx}.Load_Type              = load_type_list{idx_type}; %'CS25_341a';
        listOfTasks{taskIdx}.Sweep_Point            = sweepPoint;
        listOfTasks{taskIdx}.Sweep_Names            = sweepNames;
        listOfTasks{taskIdx}.Task_Idx               = taskIdx;

        %Update the index vector
        for updateRow = 1:sweepSize

            sweepIdxs(updateRow) = sweepIdxs(updateRow)+1;
            if sweepIdxs(updateRow)>sweepValuesSize(updateRow) %Index has reached max
                sweepIdxs(updateRow) = 1; %Reset to 1, and allow loop to update next value
            else
                if sweepType == 1
                    break; %Update complete, break the update loop
                end
            end

        end

        %Sweep is complete when all indices have been reset to 1
        if sum(sweepIdxs) == sweepSize
            sweepComplete = true;
        end
    end
end

%% Initialize simulation

Init_HybridSim_Default_CRM;
minimum_output_names = {'vgust_z', 'alpha_aero', 'Theta', 'DTheta_Dt', 'az', 'gamma', 'z',...
               'de', 'de_dot', 'da_sym_in', 'da_sym_in_dot', 'da_sym_out', 'da_sym_out_dot',...
               'WR.OSID.112.MX', 'WR.OSID.120.MX', 'WR.OSID.128.MX', 'WR.OSID.136.MX', 'WR.OSID.144.MX', 'WR.OSID.154.MX',...
               'WR.OSID.112.TZ', 'HR.OSID.21.MX', 'HR.OSID.21.TZ', 'FU.OSID.170.MY', 'FU.OSID.190.MY', 'FU.OSID.225.MY'...
                };

output_names = unique([minimum_output_names(:); desired_output_names(:)]);

CRM = Set_ModelOutputs_CRM(output_names, CRM, model_description);

%% Run through all chosen cases (CS-25)
for taskIdx=1:length(listOfTasks) 
	disp(['Case #',num2str(taskIdx),'/',num2str(length(listOfTasks)),' :']);   
    TaskDefinition = listOfTasks{taskIdx};
    if strcmp(TaskDefinition.Load_Type, 'CS25_341a')
        Perform_and_Save_SingleGustCase;
    elseif strcmp(TaskDefinition.Load_Type, 'CS25_341b')
        Perform_and_Save_ContinuousTurbulenceCase;
    end 
end

close_system(SimConfig.Model_Name,0);

close_system(SimConfig.Model_Name,0); % DO NOT SAVE THE SYSTEM WITH A NEWER MATLAB VERSION (MODIFIED FOR COMMENTING OUT INACTIVE CONTROLLERS)

clearvars N_MassCases N_AltitudeCases N_SpeedCases N_list_of_aircraft_models...
          sweepNames sweepData sweepSize sweepValuesSize sweepComplete sweepIdxs sweepPoint...
          taskIdx minimum_output_names output_names TaskDefinition 
