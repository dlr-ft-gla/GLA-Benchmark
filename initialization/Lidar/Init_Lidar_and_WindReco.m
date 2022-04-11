% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [LIDAR,WindReconstruction] = Init_Lidar_and_WindReco()
%% Location of the Lidar sensor aboard the aircraft

% Definition of reference point with respect to model gust input
tmp_Ref_Position = [-3,0,0]; % [m]
% Definition Sensor location with respect to the reference point
tmp_LIDAR_position = 2; % default LIDAR position unter the nose
switch tmp_LIDAR_position
    case 1
        %above A/C nose
        LIDAR.Installation.Position_b = tmp_Ref_Position + [0,0,-1.1];
    case 2
        %under A/C nose
        LIDAR.Installation.Position_b = tmp_Ref_Position + [0,0,1.1];
    case 3
        %right of A/C nose 
        LIDAR.Installation.Position_b = tmp_Ref_Position + [0,1.1,0.0];
    case 4
        %left of A/C nose
        LIDAR.Installation.Position_b = tmp_Ref_Position + [0,-1.1,0.0];
end

clear tmp_LIDAR_position tmp_Ref_Position

%% Initialize Lidar sensor parameters

% Power aperture product
LIDAR.Instrument.PAP              = 0.05; % [W*m^2]
% Laser wavelength
LIDAR.Instrument.lambda_nm        = 355.0; % [nm]
% Detector responsitivity. Detector choices: 'H7260', 'R7400', '9078B'
LIDAR.Instrument.Responsitivity   = RespPMT('H7260', LIDAR.Instrument.lambda_nm); % [A/W]

% Note:
% PAP = Ep * PRF * A
%
% Ep:   Laser pulse power in J
% PRF:  Pulse repetition frequency in Hz
% A:    Receiver telescope area in m^2

LIDAR.Instrument.PRF = 500;
LIDAR.Instrument.N_Average = 1;

% Noise simulation parameters
LIDAR.Instrument.UseSurrogateModel = 1;
LIDAR.Instrument.EnableMeasurementNoise = 1;
% enable random measurement error generation -> [0] random seed, [1] fixed seed (deterministic measurement error)
LIDAR.Instrument.FixErrorSeed  = 1; % [-]

% radial distance of the closest point 
LIDAR.Geometry.R_min        = 60; % [m]
% measurement interval size for each point, range gate
LIDAR.Geometry.Delta_R      = 15; % [m]
% number of measurements along LOS 
LIDAR.Geometry.N_bins       = 9;  % [-]

% rotational speed of the LIDAR measurement direction
LIDAR.Scanner.RotationFrequency = 13; % [Hz]
% semi aperture angle of LIDAR measurement cone
LIDAR.Scanner.SemiApertureAngle = 15; % [deg]


%% Definition of wind field reconstruction algorithm parameters

% Delay for the first estimation, 
% necessary to fill the buffer with LIDAR measurements
WindReconstruction.StartEstimationTime = 4; % s

% Size of LOS measurement database
WindReconstruction.MaxBufferSize = 12288; % [-]

% Definition of wind field model nodes
%Number of Nodes
WindReconstruction.N_Nodes       = 33;
%lead time delay for node positioning in wind field model
WindReconstruction.t_lead        = 0.55;
%lag time delay for node positioning in wind field model
WindReconstruction.t_lag         = 0.3;

% Tikonov regularization parameter
%Tikonov parameter for wind model first order time derivative consideration
WindReconstruction.Tikhonov.alpha = 1.79;
%Tikonov parameter for wind model second order time derivative consideration
WindReconstruction.Tikhonov.beta  = 2.345;


end


