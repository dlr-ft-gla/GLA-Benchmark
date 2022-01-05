% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Resp] = RespPMT(model, lambda)

% 03/09/2020: This function retrieves the Responsitivity value (in A/W)
% from the data of the different PMT models
% Input wavelength in nm!

load PMT_Responsitivities.mat

switch model
    case 'H7260'
        Resp=pchip(RespH7260(:,1),RespH7260(:,2),lambda);       
    case 'R7400'
        Resp=pchip(RespR7400U03(:,1),RespR7400U03(:,2),lambda);    
    case '9078B'
        Resp=pchip(RespET9078B(:,1),RespET9078B(:,2),lambda);    
             
    otherwise
        error('Type the PMT model correctly: H7260, R7400 or 9078B')
end