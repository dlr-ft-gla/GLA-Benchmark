% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [SimConfig] = Init_SimConfig()

SimConfig = [];

SimConfig.StartTime           =  0.000;  % [s]
SimConfig.EndTime             = 12.0;    % [s] 
SimConfig.SampleTime          =  0.002;  % [s] 500 Hz by default
SimConfig.SamplingFrequency   =  1./SimConfig.SampleTime;   % [Hz]

SimConfig.Logging.DesiredSamplingTime = 0.002;   % [s]
SimConfig.Logging.DecimationFactor = round(SimConfig.Logging.DesiredSamplingTime/SimConfig.SampleTime);

SimConfig.Solver = 'ode5';

SimConfig.Model_Name = 'simCRM_Hybrid';

SimConfig.TimeVector = (SimConfig.StartTime:SimConfig.SampleTime:SimConfig.EndTime)';

SimConfig.Run      = 1;

end

