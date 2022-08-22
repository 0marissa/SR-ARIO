function [] = plotUnsat_Dem_UQ(agg_option, y_axis_option, t, sectors_custom, Production_pre_eq, ...
                               Final_demand_unsatisfied_UQ, Demand_UQ, Production_UQ, sector_names, Nsim, save_flag)
%plotUnsat_Dem Plots sector-level and aggregate unsatisfied demand
% Omar Issa

% User inputs:
%   y_axis_option: {'abs', 'delta'}
%   agg_option: {'sector', 'agg'}
%   save_flag: {'true', 'false'}

% example call to function:
%    plotUnsat_Dem('sector', 'delta', t, sector_names.ID, ...
%    Production_pre_eq, Final_demand_unsatisfied, ...
%    Demand, Production, sector_names, 'false')


% define Baker Research group color scheme
colorspec{1} = [56 95 150]/255;
colorspec{2} = [207 89 33]/255;
colorspec{3} = [158 184 219]/255;    

sectors_custom_idx = ismember(sector_names, sectors_custom);
sub_idx =            [1:height(sector_names)]';
sub_idx_selected   = sub_idx(sectors_custom_idx);
    

% generate plot
fig = figure

switch(agg_option)

    case('sector')
        fig.Position = [300 100 1500 900]
        switch(y_axis_option)
            case('delta_UQ')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub);
                    
                       % Compute the mean and standard devation of all simulations
                       med_val = median(Final_demand_unsatisfied_UQ(:,sub,:),3);
                       sigma = std(Final_demand_unsatisfied_UQ(:,sub,:),[],3);
                       p90_val = prctile(Final_demand_unsatisfied_UQ(:,sub,:),90,3);
                       p10_val = prctile(Final_demand_unsatisfied_UQ(:,sub,:),10,3);
                       
                       % Overlay the mean
                       mu_s = plot(t, 100.*(med_val - Final_demand_unsatisfied_UQ(1,sub,1))./ (Production_pre_eq(sub)), 'color', colorspec{2}, 'linewidth', 2.5);
                       hold on         
                       grid on                       
                       
                       % Plot confidence bounds 
                       xconf = [t t(end:-1:1)] ; 
                       yconf_ub = 100.*(p90_val - (Final_demand_unsatisfied_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                       yconf_lb = 100.*(p10_val - (Final_demand_unsatisfied_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                       yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                       p = fill(xconf,yconf,'blue');
                       p.FaceColor = colorspec{2};      
                       p.EdgeColor = 'none'; 
                       alpha(p,.3)
                       
                       uistack(mu_s,'top')
                       
                       title(sector_names{sub}, 'interpreter', 'latex')
                       ylim([-25 5])
                       xlim([0 5])
                end
                
               Lgnd = legend('Unsatisfied demand 80% CI', '50th percentile unsatisfied demand', 'Position', [0.35 0.125 0.12 0.05]);

               if(save_flag == "true")
                    filename = 'AllSector_UnsatDemand_Dash_UQ';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end                        

                if(save_flag == "true")
                    filename = 'AllSector_UnsatDemand_Dash_UQ';    
                    print('-painters','-dsvg',filename)
                end        
                
            case('delta_mean')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub);
                    
%                     % Uncomment to plot individual realizations
%                      for n = 1:Nsim
%                         t = [1:length(Demand_UQ)]./365;
%                         plot(t, 100.*(Final_demand_unsatisfied_UQ(:,sub,n) - Final_demand_unsatisfied_UQ(1,sub,n))/Production_pre_eq(sub), 'color', colorspec{2}, 'linewidth', 0.5)
%                         hold on
%                         title(sector_names.Sector{sub}, 'interpreter', 'latex')
%                         grid on
%                      end                    
                    
                       % Compute the mean and standard devation of all simulations
                       med_val = mean(Final_demand_unsatisfied_UQ(:,sub,:),3);
                       sigma = std(Final_demand_unsatisfied_UQ(:,sub,:),[],3);
                       p90_val = prctile(Final_demand_unsatisfied_UQ(:,sub,:),90,3);
                       p10_val = prctile(Final_demand_unsatisfied_UQ(:,sub,:),10,3);
                       
                       % Overlay the mean
                       mu_s = plot(t, 100.*(med_val - Final_demand_unsatisfied_UQ(1,sub,1))./ (Production_pre_eq(sub)), 'color', colorspec{2}, 'linewidth', 2.5);
                       hold on         
                       grid on                       
                       
                       uistack(mu_s,'top')
                       
                       title(sector_names.Sector{sub}, 'interpreter', 'latex')
                       ylim([-25 5])
                       xlim([0 5])
                end
                
               Lgnd = legend('Unsatisfied demand', 'Position', [0.35 0.125 0.12 0.05]);               
               
               if(save_flag == "true")
                    filename = 'AllSector_UnsatDemand_Dash';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end                        

                if(save_flag == "true")
                    filename = 'AllSector_UnsatDemand_Dash';    
                    print('-painters','-dsvg',filename)
                end             
                
%             case('abs')
%                 for subset = 1:length(sectors_custom)
%                     sub = sub_idx_selected(subset);
%                     subplot(7,6,sub)
%                     t = [1:length(Demand)]./365;
%                     %plot(t_results/365,VA_delta(:,sub), 'color', colorspec{1}, 'linewidth', 2.5)
%                     plot(t, Final_demand_unsatisfied_UQ(:,sub), 'color', colorspec{2}, 'linewidth', 2.5)
%                     hold on
%                     title(sector_names.Sector{sub}, 'interpreter', 'latex')
%                     grid on
%                     ylim([0 max(max(Final_demand_unsatisfied_UQ(:,:)))])
%                 end                
        end
            
            
    case('agg')
        switch(y_axis_option)
            case('delta')  
                plot(t, 100.*(sum(Final_demand_unsatisfied_UQ(:,sub_idx_selected),2)- sum(Final_demand_unsatisfied_UQ(1,sub_idx_selected),2))./ sum(Production_pre_eq(sub_idx_selected)), 'color', colorspec{2}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('\% change in final demand unsatisfied (w.r.t. to pre-EQ production)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Value Added'); 
            case('abs')
                plot(t, sum(Final_demand_unsatisfied_UQ(:,sub_idx_selected),2), 'color', colorspec{2}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('Unsatisfied demand (VA) (million Yen)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Value Added');    
        end
end

end

