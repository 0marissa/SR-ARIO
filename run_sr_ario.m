function [sr_output] = run_sr_ario(input, settings)
% 
%   Single-region ARIO function
%   Stanford Urban Resilience Initiative
%
%   Summer 2022
%
% Inputs:
%           input (sectors, IO, econ, loss, recovery, params)
%           settings (n_sim, st, NStep)
% Output:
%           sr_output

    %% Load_default_ARIO_model_settings 
        % Load default analysis settings
        [settings]     = fn_load_default_ario_settings(input, settings);

    %% Initialize storage containers 
        [sr]           = fn_initialize_sr_variables(input, settings);

    %% Main loop
    for k = 1:settings.Nstep

            %% Stage 1: get_production
            % Purpose of this stage: leverage (i) demand, (ii)production capacity, and
            % (iii) supply constraints to generate actual production for each time
            % step

            % Compute demand 
            [sr] = fn_compute_demand(k, input, sr, settings);

            % Impose constraint 1: production capacity 
            [sr] = fn_compute_prod_lim_by_cap(k, sr, input);

            % Impose constraint 2: supply 
            [sr] = fn_compute_prod_lim_by_cap_sup(k, input, sr, settings);

            %% Stage 2: calculate result economic metrics and update for next time step
            % Purpose of this stage: leverage satisfied ratio (production/demand) 
            % to compute (i) output economic metrics for timestep k,
            % (ii) input economic metrics for timestep k+1, and (iii)
            % output economic performance for timestep k

            sr.satisfied_ratio(k+1,:)          = sr.production(k+1,:) ./ sr.demand(k+1,:);
            sr.satisfied_ratio_wHousing(k+1,:) = [sr.satisfied_ratio(k+1,:) sr.satisfied_ratio(input.construction_idx)];
            sr.final_demand_unsatisfied(k+1,:) = sr.production(k+1,:) - sr.demand(k+1,:);
            
            % Calculate the output economic metrics for timestep k 
            [sr] = fn_get_output_econ_metrics(k, input, sr);

            % Update the input economic metrics for timestep k+1
            [sr] = fn_update_input_econ_metrics(k, input, sr, settings);

            % Calculate the output economic performance for timestep k 
            [sr] = fn_get_output_econ_performance(k, input, sr);

    end   
        
    % Save variables of interest at one-week resolution
    sr_output.value_added                    = sr.value_added([1,2:7:end],:);
    sr_output.demand                         = sr.demand([1,2:7:end],:);
    sr_output.production                     = sr.production([1,2:7:end],:);
    sr_output.production_cap                 = sr.production_cap([1,2:7:end],:);
    sr_output.direct_losses_vector           = sr.direct_losses_vector;
    sr_output.final_demand_unsatisfied       = sr.final_demand_unsatisfied([1,2:7:end],:);
    sr_output.reconstr_needs                 = sr.reconstr_needs([1,2:7:end],:);
    

end