% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [CRM] = Set_ModelOutputs_CRM(output_names, CRM, model_description)
%Sets the output matrices and Controller selector
%indices for the CRM Simulink model

sensor_names_tmp = CRM.Sensors.Total_Output_Names;

% Ensure output_names is a row vector
output_names = output_names(:)';

% Remove outputs already covered by sensors.
output_names = setdiff(output_names, sensor_names_tmp);
 
outputIdxs = dl2idx(model_description.AC_Outputs, output_names, 1);

b_init = ~isfield(CRM.Aircraft, 'C_outputs'); % Initialization?

CRM.Aircraft.C_outputs = CRM.Aircraft.linear_sys.C(outputIdxs,:);
CRM.Aircraft.D_outputs = CRM.Aircraft.linear_sys.D(outputIdxs,:);
CRM.Aircraft.Output_Names = output_names;
CRM.Aircraft.Num_Outputs  = length(output_names);
CRM.Aircraft.Total_Output_Names = [CRM.Sensors.Total_Output_Names CRM.Aircraft.Output_Names];
CRM.Aircraft.Num_Total_Outputs = CRM.Aircraft.Num_Outputs + CRM.Sensors.Num_Total_Signals;

if ~b_init
    CRM = Select_OutputsGLA_CRM(CRM); 
end

end