function [params_UQ] = fn_simulate_behavorial_parameters(input, settings, type)
%Function responsible for loading behavorial parameters from input file.
    
    % Load default sector-specific parameter settings from file       
      refined_alpha_max     = readtable(fullfile('inputs/params/Refined set','default_alpha_max.csv'));
      refined_inventory     = readtable(fullfile('inputs/params/Refined set','default_inventory.csv'));
      refined_psi           = readtable(fullfile('inputs/params/Refined set','default_psi.csv'));
      
      refined_tau_alpha        = readtable(fullfile('inputs/params/Refined set','default_tau_alpha.csv'));
      refined_tau_alpha.lb     = refined_tau_alpha.lb    ./ 12;
      refined_tau_alpha.mean   = refined_tau_alpha.mean  ./ 12;
      refined_tau_alpha.ub     = refined_tau_alpha.ub    ./ 12;
      
      refined_tau_inventory = readtable(fullfile('inputs/params/Refined set','default_tau_inventory.csv'));
      refined_tau_inventory.lb     = refined_tau_inventory.lb    ./ 365;
      refined_tau_inventory.mean   = refined_tau_inventory.mean  ./ 365;
      refined_tau_inventory.ub     = refined_tau_inventory.ub    ./ 365;
            
   % Initialize each variable    
      params_UQ.alpha_prod_max = zeros(input.sectors.N, settings.n_sim); 
      params_UQ.n_stock        = zeros(input.sectors.N, settings.n_sim); 
      params_UQ.psi            = zeros(input.sectors.N, settings.n_sim); 
      params_UQ.tau_alpha      = zeros(input.sectors.N, settings.n_sim); 
      params_UQ.tau_stock      = zeros(input.sectors.N, settings.n_sim); 
      
   % Sample behavioral parameters based on 'type' entered by user   
    switch(type)
        case('noUQ_sector_specfic_refined')
              params_UQ.alpha_prod_max = ones(input.sectors.N, settings.n_sim) .* refined_alpha_max.mean; 
              params_UQ.n_stock        = ones(input.sectors.N, settings.n_sim) .* refined_inventory.mean; 
              params_UQ.psi            = ones(input.sectors.N, settings.n_sim) .* refined_psi.mean; 
              params_UQ.tau_alpha      = ones(input.sectors.N, settings.n_sim) .* refined_tau_alpha.mean; 
              params_UQ.tau_stock      = ones(input.sectors.N, settings.n_sim) .* refined_tau_inventory.mean; 
                      
        case('UQ_tr_norm_sector_specfic_refined')
            params_UQ = fn_sample_param_truncated_norm(input, ...
                                                 params_UQ, ...
                                                 settings.n_sim, ...
                                                 refined_alpha_max, ...
                                                 refined_inventory, ...
                                                 refined_psi, ...
                                                 refined_tau_alpha, ...
                                                 refined_tau_inventory)
              
        case('UQ_uniform_sector_specfic_refined')
            
            for idx = 1:settings.n_sim
                params_UQ.alpha_prod_max(:,idx) = unifrnd(refined_alpha_max.lb,     refined_alpha_max.ub,[input.sectors.N 1]);
                params_UQ.n_stock(:,idx)        = unifrnd(refined_inventory.lb,     refined_inventory.ub,[input.sectors.N 1]);
                params_UQ.psi(:,idx)            = unifrnd(refined_psi.lb,           refined_psi.ub,[input.sectors.N 1]);
                params_UQ.tau_alpha(:,idx)      = unifrnd(refined_tau_alpha.lb,     refined_tau_alpha.ub,[input.sectors.N 1]);
                params_UQ.tau_stock(:,idx)      = unifrnd(refined_tau_inventory.lb, refined_tau_inventory.ub,[input.sectors.N 1]);
            end
            
            
        case('UQ_uniform_sector_specfic_default')
            
            for idx = 1:settings.n_sim
                params_UQ.alpha_prod_max(:,idx) = unifrnd(1.00, 1.50, [input.sectors.N 1]);
                params_UQ.n_stock(:,idx)        = unifrnd(60, 120, [input.sectors.N 1]);
                params_UQ.psi(:,idx)            = unifrnd(0.70, 0.90, [input.sectors.N 1]);
                params_UQ.tau_alpha(:,idx)      = unifrnd(6/12, 18/12, [input.sectors.N 1]);
                params_UQ.tau_stock(:,idx)      = unifrnd(15/365, 45/365, [input.sectors.N 1]);
            end
            
            params_UQ.n_stock(21,:)    = 10e9;
            params_UQ.tau_stock(21,:)  = 10e9;           
            

        case('UQ_uniform_economy_specific_default')
            
            for idx = 1:settings.n_sim
                params_UQ.alpha_prod_max(:,idx) = unifrnd(1.00, 1.50, [1 1])     .* ones(input.sectors.N,1);
                params_UQ.n_stock(:,idx)        = unifrnd(60, 120, [1 1])        .* ones(input.sectors.N,1);
                params_UQ.psi(:,idx)            = unifrnd(0.70, 0.90, [1 1])     .* ones(input.sectors.N,1);
                params_UQ.tau_alpha(:,idx)      = unifrnd(6/12, 18/12, [1 1])    .* ones(input.sectors.N,1);
                params_UQ.tau_stock(:,idx)      = unifrnd(15/365, 45/365, [1 1]) .* ones(input.sectors.N,1);
            end
            
            params_UQ.n_stock(21,:)    = 10e9;
            params_UQ.tau_stock(21,:)  = 10e9;      
            
            
end
