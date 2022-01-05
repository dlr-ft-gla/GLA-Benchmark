% Compute basic performance statistics from simulation data

% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Evaluation of each controller configuration on each load type


for load_type_idx=1:length(load_types.config)

    load_type_idstr = load_types.config(load_type_idx).identifier;
    tmp_stats.(load_type_idstr).nb_cases = length(load_types.config(load_type_idx).file_list);
    nbCases = tmp_stats.(load_type_idstr).nb_cases;
    if nbCases>0
        load([load_types.config(load_type_idx).directory,filesep,load_types.config(load_type_idx).file_list(1).name]);
        
        tmp_ControllerConfigs = SimResults.(Aircraft_Name).FCS.Configurations;
        
        Evaluations.Configs_List = tmp_ControllerConfigs;
        Evaluations.Output_Names = SimResults.(Aircraft_Name).Aircraft.Total_Output_Names;
        %
        idx_az = find_str_in_cell_array('az', Evaluations.Output_Names);
        idx_q = find_str_in_cell_array('DTheta_Dt', Evaluations.Output_Names);
        %
        % it is assumed (and that will checked along the way) that the 
        % structure of all datasete is the same and we infer the size of 
        % the required vectors and matrices from the sizes observed in the
        % first result file and for the first configuration
        
        for idx_config=1:length(tmp_ControllerConfigs)
            tmp_first_Data = SimResults.SimOut.(tmp_ControllerConfigs(idx_config).Identifier);
            tmp_first_Fieldnames   = fieldnames(tmp_first_Data);
            % since not all controllers are active in every configuration,
            % the number of fields and their names can differ
            for idx_Fieldname=1:length(tmp_first_Fieldnames)
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_first_Fieldnames{idx_Fieldname}).max  =  zeros(nbCases , tmp_first_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.dimensions );
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_first_Fieldnames{idx_Fieldname}).min  =  zeros(nbCases , tmp_first_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.dimensions );   
            
            end 
        end, clear idx_config tmp_Data tmp_Fieldnames idx_Fieldname
  
        for idx_case=1:tmp_stats.(load_type_idstr).nb_cases
            load([load_types.config(load_type_idx).directory,filesep,load_types.config(load_type_idx).file_list(idx_case).name]);
            
            % checking that the load type in the file matches the expected one
            if ~strcmp(load_type_idstr , SimResults.TaskDefinition.Load_Type)
                error('The load type found in file ''%s'' does not match the expected load type ''%s''!',...
                      [load_types.config(load_type_idx).directory,filesep,load_types.config(load_type_idx).file_list(idx_case).name],...
                      load_type_idstr);
            end
%             
            if ~isequal(tmp_ControllerConfigs,SimResults.(Aircraft_Name).FCS.Configurations)
                error('The controller configurations contained in files %s and %s are not equal! This assessment script assumes that the evaluated configurations are the same in all results files.');
            end
            
            for idx_config=1:length(Evaluations.Configurations)
                tmp_Data = SimResults.SimOut.(tmp_ControllerConfigs(idx_config).Identifier);
%                 tmp_Data = SimResults.SimOut.Default;
                tmp_Fieldnames   = fieldnames(tmp_Data);
                % since not all controllers are active in every configuration,
                % the number of fields and their names can differ
                for idx_Fieldname=1:length(tmp_Fieldnames)
                    Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).max(idx_case,:) = max(tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values,[],1) ;
                    Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).min(idx_case,:) = min(tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values,[],1) ;
                    
                    Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).std(idx_case,:) = std(tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values,0,1) ;
                    Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).mean(idx_case,:) = mean(tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values,1) ;
                    
                    %PIP:
                    if strcmp(load_type_idstr, 'CS25_341b')                        
                        Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).PIP(idx_case,:) = Compute_PIP(tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values(:,idx_az),...
                                                                                                                                         tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).signals.values(:,idx_q),...
                                                                                                                                         tmp_Data.(tmp_first_Fieldnames{idx_Fieldname}).time);
                    end
                end
            end, clear idx_config tmp_Data tmp_Fieldnames idx_Fieldname;
        end, clear idx_case;

        for idx_config=1:length(Evaluations.Configurations)
            tmp_Data = SimResults.SimOut.(tmp_ControllerConfigs(idx_config).Identifier);

            tmp_Fieldnames   = fieldnames(tmp_Data);
            % since not all controllers are active in every configuration,
            % the number of fields and their names can differ
            for idx_Fieldname=1:length(tmp_Fieldnames)
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).max_max = max( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).max, [], 1 ) ;
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).min_min = min( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).min, [], 1 ) ;
                
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).std_max = max( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).std, [], 1 ) ;
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).std_min = min( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).std, [], 1 ) ;
                
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).mean_max = max( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).mean, [], 1 ) ;
                Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).mean_min = min( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).mean, [], 1 ) ;
                
                if isfield(Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}), 'PIP')
                    Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).PIP_max = max( Evaluations.Configurations(idx_config).(load_type_idstr).(tmp_Fieldnames{idx_Fieldname}).PIP, [], 1 ) ;
                end
            end

        end, clear idx_config tmp_Data tmp_Fieldnames idx_Fieldname;
        clear idx_az idx_q


%         %%
%         determineViolationOfLimits = true;
% 
%         for idx_config=1:length(Evaluations.Configurations)
%             % fill with zeros or NaN as default (possibly partly overwritten right after)
%             Evaluations.Configurations(idx_config).(load_type_idstr).upperLimitViolation    = zeros(nbCases,size(Limits,1));
%             Evaluations.Configurations(idx_config).(load_type_idstr).lowerLimitViolation    = zeros(nbCases,size(Limits,1));
%             Evaluations.Configurations(idx_config).(load_type_idstr).output_upperLimitViolation = NaN * zeros(nbCases,size(model_description.AC_Outputs,1));
% 
% 
%             if determineViolationOfLimits
%                 Evaluations.Configurations(idx_config).(load_type_idstr).upperLimitViolation(:,:)   = (Evaluations.Configurations(idx_config).(load_type_idstr).max_Yabsac(:,limit2output_mapping)    > repmat([Limits{:,4}],[size(Evaluations.Configurations(idx_config).(load_type_idstr).max_Yabsac   ,1),1]));
%                 Evaluations.Configurations(idx_config).(load_type_idstr).lowerLimitViolation(:,:)   = (Evaluations.Configurations(idx_config).(load_type_idstr).min_Yabsac(:,limit2output_mapping)    < repmat([Limits{:,3}],[size(Evaluations.Configurations(idx_config).(load_type_idstr).min_Yabsac   ,1),1]));
% 
%                 Evaluations.Configurations(idx_config).(load_type_idstr).sum_upperLimitViolation    = sum(Evaluations.Configurations(idx_config).(load_type_idstr).upperLimitViolation);
%                 Evaluations.Configurations(idx_config).(load_type_idstr).sum_lowerLimitViolation    = sum(Evaluations.Configurations(idx_config).(load_type_idstr).lowerLimitViolation);
% 
%                 % these are based on the list of outputs (an output without upper or
%                 % lower limit, cannot violate the non-existent limit => always 0 then)
% 
%                 Evaluations.Configurations(idx_config).(load_type_idstr).output_upperLimitViolation(:,limit2output_mapping)    = Evaluations.Configurations(idx_config).(load_type_idstr).upperLimitViolation;
%                 Evaluations.Configurations(idx_config).(load_type_idstr).output_lowerLimitViolation(:,limit2output_mapping)    = Evaluations.Configurations(idx_config).(load_type_idstr).lowerLimitViolation;
% 
%                 Evaluations.Configurations(idx_config).(load_type_idstr).sum_output_upperLimitViolation    = sum(Evaluations.Configurations(idx_config).(load_type_idstr).output_upperLimitViolation);
%                 Evaluations.Configurations(idx_config).(load_type_idstr).sum_output_lowerLimitViolation    = sum(Evaluations.Configurations(idx_config).(load_type_idstr).output_lowerLimitViolation);
% 
%             end
% 
%         end, clear idx_config;
    end
    
    
end, clear load_type_idx

%% Ratios between the different controller configurations


Evaluations.Relative_Perfs = [];
for load_type_idx=1:length(load_types.config)

    load_type_idstr = load_types.config(load_type_idx).identifier;
    
    % under the "relative_perfs" field we fill 2D-struct-array in which the
    % various relative performance index between controllers are stored
    % e.g. element (i,j) is the performance of controller configuration 'i'
    % relatively to controller configuration 'j'
    for idx_config_i=1:length(Evaluations.Configurations)
        for idx_config_j=1:length(Evaluations.Configurations)
            tmp_Fieldnames_i   = fieldnames( SimResults.SimOut.(tmp_ControllerConfigs(idx_config_i).Identifier) );
            tmp_Fieldnames_j   = fieldnames( SimResults.SimOut.(tmp_ControllerConfigs(idx_config_j).Identifier) );
%             tmp_Fieldnames_i   = fieldnames( SimResults.SimOut.Default );
%             tmp_Fieldnames_j   = fieldnames( SimResults.SimOut.Default );
            % note that since not all controllers are active in every configuration, the number of fields and their names can differ and not match
            for idx_Fieldname_i=1:length(tmp_Fieldnames_i)
                if length(find_str_in_cell_array(tmp_Fieldnames_i{idx_Fieldname_i},tmp_Fieldnames_j))==1 
                    % this means that the field is present for both configurations (e.g. individual controller commands of inactive controllers are not saved and are not really useful to make ratios like 0/something or something/0 for them)
                    Evaluations.Relative_Perfs(idx_config_i,idx_config_j).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).max_max = (-1) + Evaluations.Configurations(idx_config_i).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).max_max ./ Evaluations.Configurations(idx_config_j).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).max_max ;
                    Evaluations.Relative_Perfs(idx_config_i,idx_config_j).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).min_min = (-1) + Evaluations.Configurations(idx_config_i).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).min_min ./ Evaluations.Configurations(idx_config_j).(load_type_idstr).(tmp_Fieldnames_i{idx_Fieldname_i}).min_min ;
                end
            end          
        end, clear idx_config_j;
    end, clear idx_config_i;
    clear tmp_Fieldnames_i tmp_Fieldnames_j;
    
end, clear load_type_idx

clear nbCases
