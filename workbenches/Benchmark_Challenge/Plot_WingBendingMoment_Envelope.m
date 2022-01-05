% Generate wing bending moment envelope plots

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%%
load_station_names = {'WR.OSID.112'; 'WR.OSID.122'; 'WR.OSID.130'; 'WR.OSID.138'; 'WR.OSID.146'};
load('Load_Stations.mat');

load_station_idxs = dl2idx(Load_Stations.WR.Names, load_station_names);
load_station_ypos = Load_Stations.WR.Coord.y(load_station_idxs);

clear Load_Stations
%%

Nom_Results = load([ResultsDirectoryPath, filesep, 'Nominal_Performance_Statistics.mat']);
Nom_Eval = Nom_Results.Evaluations;

Rob_Results = load([ResultsDirectoryPath, filesep, 'Robust_Performance_Statistics.mat']);
Rob_Eval = Rob_Results.Evaluations;

%%

alt_tmp = Nom_Results.Task_List_Continuous{1,1}.Altitude;
U_sigma = CS25_341_U_sigma_ref(alt_tmp) * Calculate_Fg_CRM(alt_tmp);
vgust_idx = dl2idx(Nom_Eval.Output_Names(:), {'vgust_z'});

eval_load_names = strcat(load_station_names, '.MX');
eval_loads_idxs = dl2idx(Nom_Eval.Output_Names(:), eval_load_names);

%% Open Loop Envelope
idx_OL = 0;
Config_List_GLA = [];
for ii = 1:length(Nom_Eval.Configs_List)
    if strcmp(Nom_Eval.Configs_List(ii).Identifier, 'Controller_Config__OL')
        idx_OL = ii;
    else
        Config_List_GLA = [Config_List_GLA; {Nom_Eval.Configs_List(ii).Identifier}]; 
    end
end
if idx_OL == 0; error('Open Loop data not present'); end

loads_OL_max_DG = Nom_Eval.Configurations(idx_OL).CS25_341a.Outputs.max_max(eval_loads_idxs);
loads_OL_min_DG = Nom_Eval.Configurations(idx_OL).CS25_341a.Outputs.min_min(eval_loads_idxs);
loads_OL_limit_CT = U_sigma*(Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.std_max(eval_loads_idxs)...
                    ./Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.std_max(vgust_idx));

loads_OL_max_CT = Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.max_max(eval_loads_idxs);
loads_OL_min_CT = Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.min_min(eval_loads_idxs);

Envelope_OL = max(abs([loads_OL_max_DG;loads_OL_min_DG;loads_OL_limit_CT]),[],1);

Envelope_Target = 0.75 * Envelope_OL;

%% Calculate load envelopes with controllers

nominal_loads_max_DG = [];
nominal_loads_min_DG = [];
nominal_loads_max_CT = [];
nominal_loads_min_CT = [];
nominal_loads_limit_CT = [];
Envelope_Nominal = [];

for ii = 1:length(Nom_Eval.Configs_List)
    if ~strcmp(Nom_Eval.Configs_List(ii).Identifier, 'Controller_Config__OL')
        max_tmp_DG = Nom_Eval.Configurations(ii).CS25_341a.Outputs.max_max(eval_loads_idxs);
        min_tmp_DG = Nom_Eval.Configurations(ii).CS25_341a.Outputs.min_min(eval_loads_idxs);
        max_tmp_CT = Nom_Eval.Configurations(ii).CS25_341b.Outputs.max_max(eval_loads_idxs);
        min_tmp_CT = Nom_Eval.Configurations(ii).CS25_341b.Outputs.min_min(eval_loads_idxs);
        limit_tmp_CT = U_sigma*(Nom_Eval.Configurations(ii).CS25_341b.Outputs.std_max(eval_loads_idxs)...
                    ./Nom_Eval.Configurations(ii).CS25_341b.Outputs.std_max(vgust_idx));
        
        Envelope_Nominal = [Envelope_Nominal; max(abs([max_tmp_DG; min_tmp_DG; limit_tmp_CT]),[],1)];
        
        nominal_loads_max_DG = [nominal_loads_max_DG; max_tmp_DG];
        nominal_loads_min_DG = [nominal_loads_min_DG; min_tmp_DG];
        nominal_loads_max_CT = [nominal_loads_max_CT; max_tmp_CT];
        nominal_loads_min_CT = [nominal_loads_min_CT; min_tmp_CT];
        nominal_loads_limit_CT = [nominal_loads_limit_CT; limit_tmp_CT];
        
    end
end

robust_loads_max_DG = [];
robust_loads_min_DG = [];
robust_loads_max_CT = [];
robust_loads_min_CT = [];
robust_loads_limit_CT = [];
Envelope_Robust = [];

for ii = 1:length(Rob_Eval.Configs_List)
    if ~strcmp(Rob_Eval.Configs_List(ii).Identifier, 'Controller_Config__OL')
        max_tmp_DG = Rob_Eval.Configurations(ii).CS25_341a.Outputs.max_max(eval_loads_idxs);
        min_tmp_DG = Rob_Eval.Configurations(ii).CS25_341a.Outputs.min_min(eval_loads_idxs);
        max_tmp_CT = Rob_Eval.Configurations(ii).CS25_341b.Outputs.max_max(eval_loads_idxs);
        min_tmp_CT = Rob_Eval.Configurations(ii).CS25_341b.Outputs.min_min(eval_loads_idxs);
        limit_tmp_CT = U_sigma*(Rob_Eval.Configurations(ii).CS25_341b.Outputs.std_max(eval_loads_idxs)...
                    ./Rob_Eval.Configurations(ii).CS25_341b.Outputs.std_max(vgust_idx));
        
        Envelope_Robust = [Envelope_Robust; max(abs([max_tmp_DG; min_tmp_DG; limit_tmp_CT]),[],1)];

        robust_loads_max_DG = [robust_loads_max_DG; max_tmp_DG];
        robust_loads_min_DG = [robust_loads_min_DG; min_tmp_DG];
        robust_loads_max_CT = [robust_loads_max_CT; max_tmp_CT];
        robust_loads_min_CT = [robust_loads_min_CT; min_tmp_CT];
        robust_loads_limit_CT = [robust_loads_limit_CT; limit_tmp_CT];
        
    end
end

clear max_tmp_DG min_temp_DG max_tmp_CT min_tmp_CT limit_tmp_CT

%% Plot 

scaleColor = 0.5* [1 1 1];

for ii = 1:length(Config_List_GLA)
    figure('position',  [500 200 800 450]);
    hold on

    plot([-2,-1], [0,0], '--k', 'LineWidth', 1);
    plot([-2,-1], [0,0], '-k', 'LineWidth', 1, 'Marker', 'x');
    plot([-2,-1], [0,0],  '-', 'LineWidth', 2, 'Marker', 'o', 'Color', 'b');
    plot([-2,-1], [0,0], '-', 'LineWidth', 2, 'Marker', '^', 'Color',[0.8500 0.3250 0.0980] );

    plot(load_station_ypos, Envelope_OL, '--k', 'LineWidth', 1);
    plot(load_station_ypos, Envelope_Target, '-k', 'LineWidth', 1, 'Marker', 'x');

    text(load_station_ypos(1), Envelope_OL(1), '100%',...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Color', scaleColor);

    for inScale = 0.9:-0.1:0.1
        plot(load_station_ypos, inScale* Envelope_OL, ':', 'Color', scaleColor, 'LineWidth', 1);

        text(load_station_ypos(1), inScale*Envelope_OL(1), [num2str(inScale*100), '%'],...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Color', scaleColor);
    end

    plot(load_station_ypos, Envelope_Nominal(ii,:), '-', 'LineWidth', 2, 'Marker', 'o', 'Color', 'b');
    plot(load_station_ypos, Envelope_Robust(ii,:), '-', 'LineWidth', 2, 'Marker', '^', 'Color',[0.8500 0.3250 0.0980] );

    grid on

    xlim([0 max(load_station_ypos)]);
    xlabel('Distance from centerline, m');
    ylabel('\Delta M_X, Nm');
    legend({'Reference envelope', 'Load alleviation objective', 'Nominal envelope', 'Robust envelope'})
    
    config_name_split = split(Config_List_GLA{ii}, '__');
    if length(config_name_split)> 1
        config_name_tmp = join(config_name_split(2:end), '__'); 
    end

    title(['Peak Vertical Bending Moment Along Wing -', ' ', char(config_name_tmp)], 'Interpreter', 'none');
end


%% Clean up
clear load_station_idxs load_station_names load_station_ypos load_stations load_stations_coord ...
    Nom_Eval Rob_Eval idx_OL eval_load_names eval_loads_idxs Config_List_GLA ...
    loads_OL_max_CT loads_OL_min_CT loads_OL_max_DG loads_OL_min_DG loads_OL_limit_CT...
    nominal_loads_max_CT nominal_loads_min_CT nominal_loads_max_DG nominal_loads_min_DG nominal_loads_limit_CT...
    robust_loads_max_CT robust_loads_min_CT robust_loads_max_DG robust_loads_min_DG robust_loads_limit_CT...
    Envelope_OL Envelope_Nominal Envelope_Robust Envelope_Target ...
    alt_tmp U_sigma vgust_idx ii inScale scaleColor config_name_split config_name_tmp...
    Nom_Results Nom_Eval Rob_Results Rob_Eval