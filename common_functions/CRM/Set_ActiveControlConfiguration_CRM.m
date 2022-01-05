% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [CRM] = Set_ActiveControlConfiguration_CRM(CRM, Model_Name, Control_Conf)

% Find list of controller configurations which have already been loaded.
list_loaded_conf = {CRM.FCS.Configurations.Identifier}';


if iscell(Control_Conf) % Ensure Control_Conf is a cell string
    if numel(Control_Conf)>1 % Ensure only 1 configuration has been specified
        error('Cannot set multiple control configurations to Active.');
    else
        Control_Conf = char(Control_Conf); 
    end
end

if ~iscell(list_loaded_conf)
    idx_conf = find(strcmp(list_loaded_conf, Control_Conf));
else
    idx_conf = find_str_in_cell_array(Control_Conf, list_loaded_conf, 'all');
end

if ~isempty(idx_conf)
    active_idx = idx_conf;
else
    warning('Requested controller configuration not currently loaded. Reloading configurations including new configuration');
    conf_list_ext = [list_loaded_conf; {Control_Conf}];
    [CRM.FCS.Controllers,CRM.FCS.Configurations] = Load_Controller_and_ControllerConfigurations(Model_Name,conf_list_ext);
    [CRM.FCS]                                    = Process_FCS_Configuration_Settings(CRM.FCS);
    active_idx = length(conf_list_ext);
end
    
CRM.FCS.Active_Config = active_idx;
CRM.FCS.Controller_Data = [];
[CRM.FCS.Controller_Data] = Initialize_Active_Controllers(CRM,Model_Name);

end

