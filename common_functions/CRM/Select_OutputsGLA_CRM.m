% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [CRM] = Select_OutputsGLA_CRM(CRM)
% Recalculates the input selection vector for the standard GLA
% controller
%   
active_ctrl_fnames = fieldnames(CRM.FCS.Controller_Data);

for in = 1:length(active_ctrl_fnames)
    if isfield(CRM.FCS.Controller_Data.(active_ctrl_fnames{in}), 'measure_idx')
        GLA_tmp = CRM.FCS.Controller_Data.(active_ctrl_fnames{in});
    else
        continue;
    end

    w_idx = find(strncmp(GLA_tmp.Input_Names, 'w_', 2));
    last_out_idx = min(w_idx)-1;

    if last_out_idx < 1
        GLA_tmp.measure_idx = w_idx + CRM.Sensors.Num_Total_Signals;
    else    
        out_idx = [];
        for input_idx = 1:last_out_idx
            out_idx = [out_idx; find(strcmp(CRM.Sensors.Total_Output_Names , GLA_tmp.Input_Names))];
        end
        GLA_tmp.measure_idx = [out_idx; w_idx+CRM.Sensors.Num_Total_Signals];
    end

end

end

