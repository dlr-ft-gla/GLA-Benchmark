%% Process Simulation Results

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

Set_Path;

% % Set result directory name manually if you want to work on previously
% % saved results and not directory after computing them

Aircraft_Name = 'CRM';
load_types_to_be_analyzed = {'CS25_341a', 'CS25_341b'...
                              };

%% Nominal
for jjj=1:length(load_types_to_be_analyzed)
    load_types.config(jjj).identifier = load_types_to_be_analyzed{jjj};
    load_types.config(jjj).directory  = [ResultsDirectory_Nominal,filesep,load_types.config(jjj).identifier];
    load_types.config(jjj).file_list  = dir([load_types.config(jjj).directory,filesep,'*.mat']);
end

Compute_PerformanceStatistics;

Task_List_Discrete = Nominal_Task_List_DG;
Task_List_Continuous = Nominal_Task_List_CT;
save(['results',filesep,ResultsDirectoryName,filesep,'Nominal_Performance_Statistics.mat'], 'Evaluations', 'Task_List_Discrete', 'Task_List_Continuous', 'load_types')

clear Evaluations listOfTasks load_types

%%
clearvars -except AC_Name CRM Evaluations listOfTasks load_types model_description ...
    ResultsDirectoryFullPath ResultsDirectoryName ResultsDirectoryPath ResultsDirectory_Nominal ResultsDirectory_Robust...
    tuning_result_time output_lowerLimit output_upperLimit  

%% Evaluate Benchmark Problem
Plot_WingBendingMoment_Envelope;

Compute_Constraints;
