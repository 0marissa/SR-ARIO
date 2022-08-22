%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Japan-ARIO project: Single-region wrapper script
%   Applied to the 2016 Kumamoto Earthquake
%   Stanford Urban Resilience Initiative
%
%   Summer 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean up MATLAB workspace
clc; clear all; close all;
  
%% Main analysis settings
    % Enter analysis_platform: "local_non_HPC" to run on single core, "hpc" or "local" to run
    % analysis on multiple cores.
    analysis_platform = "local"
    
    % Enter the number of desired simulations. 
    settings.n_sim   = 10;
    settings.dt      = 1/365;
    settings.Nstep   = 10 / settings.dt;
    settings.epsilon = 1.e-6;
    settings.t       = [0,1:settings.Nstep]*settings.dt;
    
%% HPC Settings  
   switch(analysis_platform)
    case "hpc"
        parpool('local', str2num(getenv('SLURM_CPUS_PER_TASK')), 'IdleTimeout', 120)
    case "local"
        parpool('local', 8, 'IdleTimeout', 120)
   end
    
%% Enter path settings    
    % Enter file names for input data. All files are stored in ./inputs
    addpath inputs
    addpath functions
    
    f_name.IO      = "sr_ario_IO_data.mat";
    f_name.econ    = "sr_ario_econ_data.mat";
    f_name.loss    = "sr_ario_loss_data.mat";
    f_name.dmg     = "sr_ario_building_damage.csv";
    f_name.sectors = "sr_ario_economic_sectors.csv";

%% Load analysis input parameters/data
    % get_sectors
        input.sectors     = fn_get_sectors(f_name.sectors);
        input.construction_idx = 21;  % manually identified the index for construction sector
        
    % get_IO_data
        input.IO          = fn_get_IO_data(f_name.IO);
    
    % get_economic_data
        input.econ        = fn_get_economic_data(f_name.econ, settings, 'no_UQ');
    
    % get_loss_data 
        input.loss        = fn_get_loss_data(f_name.loss, settings, 'no_UQ');
        input.loss.K16_losses_per_sector = input.loss.K16_losses_per_sector .* input.loss.recon_demand_assignment;

    % get_t95_data or get_emp_recovery_curves    
        input.recovery    = fn_get_emp_recovery_curves(f_name.dmg, input, settings, 'no_UQ');
    
    % get_behavorial_parameters     
        input.params_UQ  = fn_simulate_behavorial_parameters(input, settings, 'UQ_tr_norm_sector_specfic_refined');    

        %  fn_simulate_behavorial_parameters: user may select from:
        %    Refined (mean, deterministic, sector-specific):     noUQ_sector_specfic_refined
        %    Refined (truncated normal, UQ, sector-specific):    UQ_tr_norm_sector_specfic_refined
        %    Refined (uniform, UQ, sector-specific):             UQ_uniform_sector_specfic_refined
        %    Default (uniform, UQ, sector-specific):             UQ_uniform_sector_specfic_default
        %    Default (uniform, UQ, economy-specific):            UQ_uniform_economy_specific_default
           
%% Run single_region_ARIO function    
    % Prepopulate cell array to store UQ solutions
    sr_output = cell(1, settings.n_sim);
    
    % Run ARIO analysis and store results for each simulation 
	[sr_output] = run_sr_ario_batch(input, settings, settings.n_sim, sr_output);    
    
    %% Save result to file
    save('output/sr_ario_results.mat', 'sr_output')
        
    %% Function definitions
     function  [sr_output] = run_sr_ario_batch(input, settings, nsim, output)

         parfor idx = 1:nsim

             % get_behavorial_parameters
             input_sim = fn_get_behavorial_parameters(input, idx);    
             sr = run_sr_ario(input_sim, settings);
             sr_output(idx) = sr;
                         
            % Print progress
            disp("Sample " +num2str(idx)+" complete.")
            
        end

     end
     
     