% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [CRM] = Load_ControlConfigurations_CRM(CRM, Model_Name, Control_Conf_List)

if nargin > 2 %Have the control configurations been specified? 

    if ~iscell(Control_Conf_List)
        Control_Conf_List = {Control_Conf_List};
    end
    
    [CRM.FCS.Controllers,CRM.FCS.Configurations] = Load_Controller_and_ControllerConfigurations(Model_Name,Control_Conf_List);
    Default_Conf = Control_Conf_List(1);
else
    
    [CRM.FCS.Controllers,CRM.FCS.Configurations] = Load_Controller_and_ControllerConfigurations(Model_Name);
    Default_Conf = {'Controller_Config__FFGLA_Default'};
end

[CRM.FCS] = Process_FCS_Configuration_Settings(CRM.FCS);

CRM = Set_ActiveControlConfiguration_CRM(CRM, Model_Name, Default_Conf);

end

