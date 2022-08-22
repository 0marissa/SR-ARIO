function [sr] = fn_initialize_sr_variables(input, settings)
%Function responsible for pre-allocate memory for major storage containers
% in the analysis, and handle assignment of pre-earthquake values where
% applicable. 
%
% Leverages information entered in the settings and input struct. 
% User can modify assumptions here, and add additional variables.
%
% Inputs:
%           input
%           sr
%           settings
% Output:
%           sr (containing initialized variables)
%

%% Step 1: Pre-allocate memory for storage containers 

    sr.imports                         = zeros(settings.Nstep+1, input.sectors.N);
    sr.exports                         = zeros(settings.Nstep+1, input.sectors.N);    
    sr.local_demand                    = zeros(settings.Nstep+1, input.sectors.N);
    sr.inter_purchases                 = zeros(settings.Nstep+1, input.sectors.N);
    sr.demand                          = zeros(settings.Nstep+1, input.sectors.N);
    sr.production                      = zeros(settings.Nstep+1, input.sectors.N);
    sr.production_cap                  = zeros(settings.Nstep+1, input.sectors.N);
    sr.dom_production_cap              = zeros(settings.Nstep+1, input.sectors.N);
    sr.value_added                     = zeros(settings.Nstep+1, input.sectors.N);  
    sr.scarcity_index                  = zeros(settings.Nstep+1, input.sectors.N);
    
    sr.dom_production                  = zeros(settings.Nstep+1, input.sectors.N);
    sr.dom_prod_lim_by_cap             = zeros(settings.Nstep+1, input.sectors.N);

    sr.orders                          = zeros(input.sectors.N, input.sectors.N, settings.Nstep+1);
    sr.supply                          = zeros(input.sectors.N, input.sectors.N, settings.Nstep+1);
    sr.stock                           = zeros(input.sectors.N, input.sectors.N, settings.Nstep+1);
    sr.long_ST                         = zeros(input.sectors.N, input.sectors.N);

    sr.reconstr_demand_matrix          = zeros(input.sectors.N_wHousing, input.sectors.N, settings.Nstep+1);
    sr.reconstr_demand_rate            = zeros(input.sectors.N_wHousing, input.sectors.N, settings.Nstep+1);
    sr.reconstr_needs                  = zeros(settings.Nstep+1, input.sectors.N_wHousing);    
    sr.reconstr_inv                    = zeros(settings.Nstep+1, input.sectors.N_wHousing);
    sr.reconstr_demand_sat             = zeros(settings.Nstep,   input.sectors.N_wHousing);

    sr.budget                          = zeros(1, settings.Nstep+1);
    sr.profit                          = zeros(settings.Nstep+1, input.sectors.N);
    sr.labor_comp                      = zeros(settings.Nstep+1, input.sectors.N);
    sr.macro_effect                    = ones(settings.Nstep,1);
    sr.total_labor                     = zeros(1, settings.Nstep+1);
    sr.total_profit                    = zeros(1, settings.Nstep+1);
    sr.price                           = ones(settings.Nstep+1, input.sectors.N);
    
    sr.destr                           = zeros(settings.Nstep+1, input.sectors.N);

    %05/11 OI: totals can be computed one time at the end as a summation.

%% Step 2: Assign pre-earthquake values 

    % Economic variables and containers
        sr.alpha_prod                            = ones(input.sectors.N, settings.Nstep+1);
%         sr.total_ouptut                          = input.econ.total_output_pre_eq *  settings.exchange_rate;
        sr.labor_comp(1,:)                       = input.econ.labor_comp_pre_eq   *  settings.exchange_rate;
        sr.assets                                = input.econ.value_added_pre_eq  .* input.econ.ratio_K2Y_pre_eq  .* settings.exchange_rate;
        sr.price                                 = ones(settings.Nstep+1,  input.sectors.N);
        sr.imports(1, :)                         = input.econ.imports_pre_eq       *  settings.exchange_rate;
        sr.exports(1, :)                         = input.econ.exports_pre_eq       *  settings.exchange_rate;
        
%         sr.exports(1, :)                         = input.econ.exports_pre_eq * settings.exchange_rate - input.econ.imports_pre_eq' * settings.exchange_rate;
        
        sr.local_demand(1, :)                    = input.econ.local_demand_pre_eq  *  settings.exchange_rate;
        sr.inter_sales(1, :)                     = sum(input.IO, 2);
        sr.inter_purchases(1, :)                 = sum(input.IO, 1);
        sr.production(1, :)                      = sr.exports(1, :)'   + sr.local_demand(1, :)'   + sr.inter_sales(1, :)';
        sr.IO_norm                               = input.IO./repmat(sr.production(1, :), input.sectors.N, 1);
        sr.demand(1, :)                          = sr.production(1, :);
        
        sr.dom_production(1, :)                  = sr.production(1, :) - sr.imports(1, :);
        
        sr.production_cap(1, :)                  = sr.production(1, :);
        sr.value_added(1, :)                     = sr.production(1, :) - sr.inter_purchases(1, :) - sr.imports(1, :);  

        % Orders, stocks
            for i = 1:input.sectors.N  
                for j = 1:input.sectors.N                          
                    sr.stock(i,j,1)   = input.IO(i,j) * input.params.n_stock(i)*settings.dt;
                    sr.long_ST(i,j) = sr.stock(i,j);
                    sr.orders(i,j,1)  = input.IO(i,j);
                end
            end

        % Household budget modeling & macroeconomic effect
            sr.profit(1, :)                           = sr.production(1, :) - (sr.inter_purchases(1, :) + (settings.wage * sr.labor_comp(1, :)) + sr.imports(1, :));
            sr.macro_effect(1)                        = 1;
            sr.total_labor(1)                         = sum(sr.labor_comp(1, :));
            sr.total_profit(1)                        = sum(sr.profit(1, :));

            % Profits from businesses outside the affected region
            % Assumption: Profits that leave the region are equal to Profits that enter the region
            sr.Pi                                     = (1 - settings.alpha) * sum(sr.profit(1, :));

            % Initial household consumption and investment 
            sr.DL_initial                             = settings.wage * sum(sr.labor_comp(1,:))+ settings.alpha * sum(sr.profit(1, :) ) + sr.Pi;

        % Losses and reconstruction demand
            sr.direct_losses_matrix                   = input.loss.K16_losses_per_sector .* settings.ampl;
            sr.direct_losses_vector                   = sum(sr.direct_losses_matrix,2)   .* input.loss.frac_loss_prod';
            sr.destr_wHousing                         = sr.direct_losses_vector'         ./ input.econ.FA_wHousing_pre_eq;
            sr.destr(1,:)                             = sr.destr_wHousing(1:input.sectors.N);

            % Initialization of reconstruction demand 
                for i = 1:input.sectors.N_wHousing
                    for j = 1:input.sectors.N
                        sr.reconstr_demand_matrix(i,j,1) = sr.direct_losses_matrix(i,j);
                    end
                end                

            % Initialize reconstruction needs using sum of direct losses
                sr.reconstr_needs(1,:) = sum(sr.direct_losses_matrix,2)';
            
end