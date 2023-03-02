% Calculate constraints for benchmark problem

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%%
Nom_Results = load([ResultsDirectoryPath, filesep, 'Nominal_Performance_Statistics.mat']);
Nom_Eval = Nom_Results.Evaluations;

%%
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

alt_tmp = Nom_Results.Task_List_Continuous{1,1}.Altitude;
U_sigma = CS25_341_U_sigma_ref(alt_tmp) * Calculate_Fg_CRM(alt_tmp);
vgust_idx = dl2idx(Nom_Eval.Output_Names(:), {'vgust_z'});

%% Constraints

constraint_names = {'HR.OSID.21.MX','nz','de','da_sym_in','da_sym_out','de_dot','da_sym_in_dot', 'da_sym_out_dot'};
constraint_envelope_multiplier = [2, 1,   0, 0, 0, 0, 0, 0 ]; 
constraint_envelope_constant = [0, 0, 0.5*20, 0.5*20, 0.5*20, 0.8*40, 0.8*40, 0.8*40  ];

envelope_DG_switch   =              [1, 1, 0, 0, 0, 0, 0, 0];
envelope_CT_switch   =              [1, 1, 1, 1, 1, 1, 1, 1];

constraint_idxs = dl2idx(Nom_Eval.Output_Names', constraint_names);

constraint_max_OL_DG = Nom_Eval.Configurations(idx_OL).CS25_341a.Outputs.max_max(constraint_idxs);
constraint_min_OL_DG = Nom_Eval.Configurations(idx_OL).CS25_341a.Outputs.max_max(constraint_idxs);
constraint_max_OL_CT = Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.max_max(constraint_idxs);
constraint_min_OL_CT = Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.max_max(constraint_idxs);
constraint_limit_OL_CT = U_sigma*(Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.std_max(constraint_idxs)...
                    ./Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.std_max(vgust_idx));

constraint_peak_OL = max(abs([[constraint_max_OL_DG;constraint_min_OL_DG].*envelope_DG_switch;constraint_limit_OL_CT.*envelope_CT_switch]),[],1);

PIP_OL = Nom_Eval.Configurations(idx_OL).CS25_341b.Outputs.PIP_max;

constraint_envelope = constraint_peak_OL.*constraint_envelope_multiplier + constraint_envelope_constant;

constraint_max_nom_DG = [];
constraint_min_nom_DG = [];
constraint_max_nom_CT = [];
constraint_min_nom_CT = [];
constraint_limit_nom_CT = [];
constraint_peak_nom = [];
PIP_nom = [];
for ii = 1:length(Nom_Eval.Configs_List)
    if ~strcmp(Nom_Eval.Configs_List(ii).Identifier, 'Controller_Config__OL')
        max_tmp_DG = Nom_Eval.Configurations(ii).CS25_341a.Outputs.max_max(constraint_idxs);
        min_tmp_DG = Nom_Eval.Configurations(ii).CS25_341a.Outputs.min_min(constraint_idxs);
        max_tmp_CT = Nom_Eval.Configurations(ii).CS25_341b.Outputs.max_max(constraint_idxs);
        min_tmp_CT = Nom_Eval.Configurations(ii).CS25_341b.Outputs.min_min(constraint_idxs);
        limit_tmp_CT = U_sigma*(Nom_Eval.Configurations(ii).CS25_341b.Outputs.std_max(constraint_idxs)...
                    ./Nom_Eval.Configurations(ii).CS25_341b.Outputs.std_max(vgust_idx));
        
        PIP_nom = [PIP_nom; Nom_Eval.Configurations(ii).CS25_341b.Outputs.PIP_max];
        
        constraint_peak_nom = [constraint_peak_nom; max(abs([[max_tmp_DG; min_tmp_DG].*envelope_DG_switch;limit_tmp_CT.*envelope_CT_switch]),[],1)];
        constraint_max_nom_DG = [constraint_max_nom_DG; max_tmp_DG];
        constraint_min_nom_DG = [constraint_min_nom_DG; min_tmp_DG];
        constraint_max_nom_CT = [constraint_max_nom_CT; max_tmp_CT];
        constraint_min_nom_CT = [constraint_min_nom_CT; min_tmp_CT];
        constraint_limit_nom_CT = [constraint_limit_nom_CT; limit_tmp_CT];

    end
end


clear max_tmp_DG min_tmp_DG max_tmp_CT min_tmp_CT limit_tmp_CT 
%% Store results in struct
Constraint_Eval = [];
Constraint_Eval.Names = constraint_names;

Constraint_Eval.Envelope = constraint_envelope;

Constraint_Eval.OL.Peak = constraint_peak_OL;
Constraint_Eval.OL.DG.Min  = constraint_min_OL_DG;
Constraint_Eval.OL.DG.Max  = constraint_max_OL_DG;
Constraint_Eval.OL.CT.Min  = constraint_min_OL_CT;
Constraint_Eval.OL.CT.Max  = constraint_max_OL_CT;
Constraint_Eval.OL.CT.Limit  = constraint_limit_OL_CT;

Constraint_Eval.Nominal.Peak = constraint_peak_nom;
Constraint_Eval.Nominal.DG.Min = constraint_min_nom_DG;
Constraint_Eval.Nominal.DG.Max = constraint_max_nom_DG;
Constraint_Eval.Nominal.CT.Min = constraint_min_nom_CT;
Constraint_Eval.Nominal.CT.Max = constraint_max_nom_CT;
Constraint_Eval.Nominal.CT.Limit = constraint_limit_nom_CT;

%% Print limit values
disp('Constrained variable limit values:');
disp('Limit  |  Open-Loop  |  Nominal  ');
disp('==========================================');
for jj = 1:length(Config_List_GLA)
    disp(Config_List_GLA{jj});
    disp('-----------------------------------------');
    for ii = 1:length(constraint_names)
            disp(constraint_names{ii});
            disp([num2str(constraint_envelope(1, ii), '%10.2e\n'), ' | ', num2str(constraint_peak_OL(1, ii), '%10.2e\n'), ' | ',...
                num2str(constraint_peak_nom(jj, ii), '%10.2e\n')]); 
            disp('-----------------------------------------');
    end
end

%% Print PIP
PIP_positions = {'Forward station', 'CG station', 'Aftward station'};

disp('Percentage of Ill Passengers');
disp('Limit  |  Open-Loop  |  Nominal ');
disp('==========================================');
for jj = 1:length(Config_List_GLA)
    disp(Config_List_GLA{jj});
    disp('-----------------------------------------');
    
    for ii = 1:3
        disp(PIP_positions{ii});
        disp([num2str(PIP_OL(1, ii), '%10.2e\n'), ' | ', num2str(PIP_OL(1, ii), '%10.2e\n'), ' | ',...
            num2str(PIP_nom(jj, ii), '%10.2e\n'), ' | ']); 
        disp('-----------------------------------------');
    end
end

%% Clean up 
clear constraint_idxs constraint_envelope constraint_envelope_multiplier constraint_envelope_constant envelope_CT_switch envelope_DG_switch...
    constraint_max_nom_DG constraint_max_OL_DG constraint_min_nom_DG constraint_min_OL_DG ...
    constraint_max_nom_CT constraint_max_OL_CT constraint_min_nom_CT constraint_min_OL_CT ...
    constraint_limit_OL_CT constraint_limit_nom_CT...
    constraint_names constraint_peak_nom constraint_peak_OL...
    PIP_OL PIP_nom PIP_positions...
    U_sigma vgust_idx alt_tmp ii jj Nom_Eval idx_OL Config_List_GLA  max_tmp min_tmp...
    Nom_Results Nom_Eval