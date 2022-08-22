%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Single-region ARIO postprocessing script
%   Stanford Urban Resilience Initiative
%   Summer 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main analysis settings

close all; clear all; clc;

addpath ../inputs
addpath ../functions

load('sr_ario_results.mat')

% Enter analysis settings
settings.n_sim   = length(sr_output);
settings.dt      = 1/365;
settings.Nstep   = 10 / settings.dt;
settings.epsilon = 1.e-6;
settings.t       = [0,1:settings.Nstep]*settings.dt;    

% get_sectors
f_name.sectors    = "sr_ario_economic_sectors.csv";
input.sectors     = fn_get_sectors(f_name.sectors);
        
% Enter postprocessing settings
settings.tpost   = [0, settings.t(1,2:7:end)];
settings.Nstep   = length(settings.tpost) - 1;

%% Extract main results

% Preallocate memory for solution
  solution_VA                       = zeros(settings.n_sim, settings.Nstep+1);
  solution_net_VA_loss              = zeros(settings.n_sim,1);
  solution_t95_VA                   = zeros(settings.n_sim,1);
  solution_net_VA_loss_sector       = zeros(settings.n_sim,input.sectors.N);
  solution_net_VA_loss_ratio_sector = zeros(settings.n_sim,input.sectors.N);
  
for idx = 1:settings.n_sim  

    sr = sr_output(idx);
    
    % Compute net loss (direct and indirect)
    solution_VA(idx,:)                       = sum(sr.value_added,2)';
    [VA_loss_stats]                          = fn_compute_VA_loss(input.sectors.name(1:input.sectors.N), settings.tpost, sr.value_added, sr.value_added(1,:), input, settings, sr);    
    solution_net_VA_loss(idx)                = sum(VA_loss_stats.indirect);
    solution_net_VA_loss_sector(idx,:)       = VA_loss_stats.net_VA_loss;
    solution_net_VA_loss_ratio_sector(idx,:) = VA_loss_stats.net_VA_loss_ratio;

    % compute time to 95% of pre-EQ value added
     VA_pre_EQ  = sum(sr.value_added(1,:));
     search_t95 = find(sum(sr.value_added,2) > 0.95 * VA_pre_EQ);
     if length(search_t95) > 1
        solution_t95_VA(idx)    = search_t95(2);
     else
        solution_t95_VA(idx)    = inf;
     end
       
end

%% Single region ARIO dashboard 

% Plotting
% define colors
colorspec{1} = [56 95 150]/255;
colorspec{2} = [207 89 33]/255;
colorspec{3} = [158 184 219]/255;    

fig = figure
fig.Position = [300 100 1150 600]

    subplot(3,3,1)
        for idx = 1:settings.n_sim  
        delta_VA(idx,:) =  100.*((solution_VA(idx,:)-solution_VA(idx,1))./solution_VA(idx,1));
        plot(settings.tpost, delta_VA(idx, :), 'color', [0,0,0,0.1])
        hold on
        grid on
        xlim([0 5])
        ylim([-25 10])

    end
    xlabel('time after EQ (years)','interpreter', 'latex')
    ylabel('\% change (in pre-EQ VA)','interpreter', 'latex')
    plot(settings.tpost, median(delta_VA), 'k-', 'linewidth', 2.5, 'DisplayName', 'Mean')
    
    subplot(3,3,4)
    h = histogram(solution_net_VA_loss, 'Normalization', 'probability')
    h.FaceColor = colorspec{2};  
    h.BinWidth = 0.1;
    xlabel('indirect losses (trillion Yen)','interpreter', 'latex')
    ylabel('probability','interpreter', 'latex')
    xline(median(solution_net_VA_loss),'k--', 'linewidth', 2.5)
    grid on
    xlim([-0.50 3.50])

    subplot(3,3,7)
    h = histogram(solution_t95_VA, 'Normalization', 'probability')
    h.FaceColor = colorspec{1};  
    h.BinWidth = 20;
    xlabel('time to 95\% pre-EQ VA (days)','interpreter', 'latex')
    ylabel('probability','interpreter', 'latex')
    xlim([0 730])
    xline(median(solution_t95_VA(solution_t95_VA ~= Inf)),'k--', 'linewidth', 2.5)
    grid on

    ax1 = subplot(3,3,[2,5,8])
    plot_combined_direct_indirect_loss_dash(sr.direct_losses_vector, [sr.value_added(1,:), 0], [median(solution_net_VA_loss_sector,1), 0], [median(solution_net_VA_loss_ratio_sector, 1), 0], input.sectors.name, 'abs')            
    ax1.Position = ax1.Position + [0.09 0 -0.05 0]
    xlim([-0.25 1.25])

    
    ax2 = subplot(3,3,[3,6,9])
    plot_combined_direct_indirect_loss_dash(sr.direct_losses_vector, [sr.value_added(1,:), 0], [median(solution_net_VA_loss_sector,1), 0], [median(solution_net_VA_loss_ratio_sector, 1), 0], input.sectors.name, 'rel')            
    ax2.Position = ax2.Position + [0.13 0 -0.05 0]
    xlim([-0.50 2.00])

    sgtitle(strcat('ARIO analysis: 2016 Kumamoto Earthquake (', num2str(settings.n_sim),' simulation(s))')  ,'interpreter', 'latex')






















