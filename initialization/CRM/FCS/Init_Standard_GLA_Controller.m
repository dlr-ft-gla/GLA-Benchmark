% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [GLA] = Init_Standard_GLA_Controller(CRM, controller_idx)

% Load Controller
controller_id = CRM.FCS.Controllers(controller_idx).Identifier;
controller_filename = [controller_id, '.mat'];

load(controller_filename, 'controller_data');


if isfield(controller_data, 'K')
    K = controller_data.K;

    GLA.dt = K.Ts;

    GLA.A = K.A;
    GLA.B = K.B;
    GLA.C = K.C;
    GLA.D = K.D;

    GLA.Output_Names = K.OutputName;
    GLA.Input_Names = K.InputName;

    GLA.Num_Outputs = length(GLA.Output_Names);
    GLA.Num_Inputs = length(GLA.Input_Names);


    w_idx = find(strncmp(GLA.Input_Names, 'w_', 2));
    last_out_idx = min(w_idx)-1;

    if last_out_idx < 1
        GLA.measure_idx = w_idx + CRM.Sensors.Num_Total_Signals;
    else    
        out_idx = [];
        for input_idx = 1:last_out_idx
            out_idx = [out_idx; find(strcmp(CRM.Sensors.Total_Output_Names , GLA.Input_Names))];
        end
        GLA.measure_idx = [out_idx; w_idx+CRM.Sensors.Num_Total_Signals];
    end

    clear out_idx w_idx last_out_idx
    
    % Check whether some outputs are unused
    GLA.de_idx = find(strncmp(GLA.Output_Names, 'de_c', 4));
    if isempty(GLA.de_idx); GLA.de_idx = 0; end

    GLA.dain_idx = find(strncmp(GLA.Output_Names, 'da_in_c', 7));
    if isempty(GLA.dain_idx); GLA.dain_idx = 0; end

    GLA.daout_idx = find(strncmp(GLA.Output_Names, 'da_out_c', 8));
    if isempty(GLA.daout_idx); GLA.daout_idx = 0; end

    clear  K
else
    warning('No controller found!');
end

GLA.control_active = 1;

%% Update wind estimation parameters

if isfield(controller_data.config, 'wind_horizon')
    WindEst.horizon = controller_data.config.wind_horizon;  % Number of leading wind nodes
    WindEst.trail = controller_data.config.wind_trail;    % Number of trailing wind nodes
else
    WindEst.horizon = -1;
    WindEst.trail = 0;
end
    
WindEst.dt = GLA.dt;

WindEst.t_coords_ctrl = [-WindEst.trail:max(0,WindEst.horizon)].*WindEst.dt;

GLA.WindEst = WindEst;
clear WindEst

end