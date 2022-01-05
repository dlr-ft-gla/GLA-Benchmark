% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Controller_Data] = Initialize_Active_Controllers(CRM,Model_Name)

    Controller_Data = [];
    Active_Controller_Names_tmp = CRM.FCS.Configurations(CRM.FCS.Active_Config).Active_Controller_Names;
    
    for i_active_controller=1:(length(Active_Controller_Names_tmp))        
            unique_idx = find_str_in_cell_array(Active_Controller_Names_tmp{i_active_controller},{CRM.FCS.Controllers(:).Identifier},'error_if_not_unique');           
            Controller_Data.(Active_Controller_Names_tmp{i_active_controller}) = eval([CRM.FCS.Controllers(unique_idx).Init_Function,'(CRM, unique_idx);']);
    end
    
    if ~strcmp(Model_Name, 'none') % Exception for keyword 'none', i.e. no Simulink model is specified
        open_system  (Model_Name,'loadonly');
        
        warning('off', 'Simulink:Commands:SetParamLinkChangeWarn'); % Disables library link override warning
        
        for ii=1:(length(CRM.FCS.Controllers))
            set_param    (CRM.FCS.Controllers(ii).Block_Path,'commented','on'); 
        end

        for i_active_controller=1:(length(Active_Controller_Names_tmp))        
            unique_idx = find_str_in_cell_array(Active_Controller_Names_tmp{i_active_controller},{CRM.FCS.Controllers(:).Identifier},'error_if_not_unique');    
            set_param    (CRM.FCS.Controllers(unique_idx).Block_Path,'commented','off'); 

%             Controller_Data.(Active_Controller_Names_tmp{i_active_controller}) = eval([CRM.FCS.Controllers(unique_idx).Init_Function,'(CRM, unique_idx);']);
        end
        
        warning('on', 'Simulink:Commands:SetParamLinkChangeWarn'); %Reenables library link override warning
    end

end