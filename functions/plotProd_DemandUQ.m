function [] = plotProd_DemandUQ(agg_option, y_axis_option, t, sectors_custom, Production_pre_eq, Production_cap_UQ, Demand_UQ, Production_UQ, sector_names, Nsim, save_flag)
%plotProd_Demand Plots sector-level and aggregate production and demand
% Omar Issa

% User inputs:
%   y_axis_option: {'abs', 'delta'}
%   agg_option: {'sector', 'agg'}
%   save_flag: {'true', 'false'}

% example call to function:
% plotProd_Demand('agg', 'abs', t, sectors_custom, ...
%                 Production_pre_eq, Production_cap, ...
%                 Demand, Production, sector_names, 'true')
                
% define Baker Research group color scheme
colorspec{1} = [56 95 150]/255;
colorspec{2} = [207 89 33]/255;
colorspec{3} = [158 184 219]/255;    


sectors_custom_idx = ismember(sector_names, sectors_custom);
sub_idx =            [1:height(sector_names)]';
sub_idx_selected   = sub_idx(sectors_custom_idx);
    
Nsim = size(Production_cap_UQ,3);

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
                    
                   %Demand: Compute the mean and standard devation of all simulations
                   mean_val_dem = mean(Demand_UQ(:,sub,:),3);
                   p90_val_dem = prctile(Demand_UQ(:,sub,:),90,3);
                   p10_val_dem = prctile(Demand_UQ(:,sub,:),10,3);

                   %Production: Compute the mean and standard devation of all simulations
                   mean_val_prod = mean(Production_UQ(:,sub,:),3);
                   p90_val_prod = prctile(Production_UQ(:,sub,:),90,3);
                   p10_val_prod = prctile(Production_UQ(:,sub,:),10,3);

                   %Production capacity: Compute the mean and standard devation of all simulations
                   mean_val_prod_cap = mean(Production_cap_UQ(:,sub,:),3);
                   p90_val_prod_cap = prctile(Production_cap_UQ(:,sub,:),90,3);
                   p10_val_prod_cap = prctile(Production_cap_UQ(:,sub,:),10,3);

                   % Overlay the mean(s)
                   mu_d = plot(t, 100.*(mean_val_dem - (Demand_UQ(1,sub,1)))./ (Production_pre_eq(sub)), 'color', colorspec{2}, 'linewidth', 2.5);
                   hold on         
                   grid on
                   mu_pc = plot(t, 100.*(mean_val_prod_cap - (Production_cap_UQ(1,sub,1)))./ (Production_pre_eq(sub)), '--', 'color', colorspec{1}, 'linewidth', 3.5);
                   mu_p  = plot(t, 100.*(mean_val_prod - (Production_UQ(1,sub,1)))./ (Production_pre_eq(sub)), ':', 'color', colorspec{3}, 'linewidth', 2.5);
                   

                   % Plot confidence bounds: demand 
                   xconf = [t t(end:-1:1)] ; 
                   yconf_ub = 100.*(p90_val_dem - (Demand_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf_lb = 100.*(p10_val_dem - (Demand_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                   p = fill(xconf,yconf,'blue');
                   p.FaceColor = colorspec{2};      
                   p.EdgeColor = 'none'; 
                   alpha(p,.3)
                   
                   % Plot confidence bounds: production capacity
                   xconf = [t t(end:-1:1)] ; 
                   yconf_ub = 100.*(p90_val_prod_cap - (Production_cap_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf_lb = 100.*(p10_val_prod_cap - (Production_cap_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                   p = fill(xconf,yconf,'blue');
                   p.FaceColor = colorspec{1};      
                   p.EdgeColor = 'none'; 
                   alpha(p,.3)
                   
                   % Plot confidence bounds: production 
                   xconf = [t t(end:-1:1)] ; 
                   yconf_ub = 100.*(p90_val_prod - (Production_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf_lb = 100.*(p10_val_prod - (Production_UQ(1,sub,1)))./ (Production_pre_eq(sub));
                   yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                   p = fill(xconf,yconf,'blue');
                   p.FaceColor = colorspec{3};      
                   p.EdgeColor = 'none'; 
                   alpha(p,.2)           

                   
%                     % Uncomment to plot individual realizations
%                         for n = 1:Nsim
%                             plot(t,100.*(Demand_UQ(:,sub,n) - Demand_UQ(1,sub))./Production_pre_eq(sub),  'color', colorspec{2}, 'linewidth', 0.5)
%                             hold on
%                             plot(t,100.*(Production_cap_UQ(:,sub,n) - Production_cap_UQ(1,sub))./Production_pre_eq(sub),'--', 'color', colorspec{1}, 'linewidth', 1.5)
%                             plot(t,100.*(Production_UQ(:,sub,n)     - Production_UQ(1,sub))    ./Production_pre_eq(sub), ':', 'color', colorspec{3}, 'linewidth', 1.5)                               
%                         end
%                         
                   
                   % ensure that the lines are on top of the confidence
                   % interval
                   uistack(mu_d,'top')
                   uistack(mu_pc,'top')
                   uistack(mu_p,'top')
                   
                   title(sector_names{sub}, 'interpreter', 'latex')
                   grid on
                   ylim([-15 15])
                   xlim([0 5])

                end

                % add legend
                Lgnd = legend('Demand 80% CI', 'Production capacity 80% CI', 'Production 80% CI', '50th percentile demand', '50th percentile production capacity', '50th percentile production', 'Position', [0.35 0.125 0.12 0.05]);

                if(save_flag == "true")
                    filename = 'AllSector_ProdDemandCap_Dash_UQ';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',500) 
                end                        
                

                if(save_flag == "true")
                    filename = 'AllSector_ProdDemandCap_Dash_UQ';    
                    print('-painters','-dsvg',filename)
                end                
                

                
            case('delta_mean')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub);
                    
                   %Demand: Compute the mean and standard devation of all simulations
                   mean_val_dem = mean(Demand_UQ(:,sub,:),3);
                   p90_val_dem = prctile(Demand_UQ(:,sub,:),90,3);
                   p10_val_dem = prctile(Demand_UQ(:,sub,:),10,3);

                   %Production: Compute the mean and standard devation of all simulations
                   mean_val_prod = mean(Production_UQ(:,sub,:),3);
                   p90_val_prod = prctile(Production_UQ(:,sub,:),90,3);
                   p10_val_prod = prctile(Production_UQ(:,sub,:),10,3);

                   %Production capacity: Compute the mean and standard devation of all simulations
                   mean_val_prod_cap = mean(Production_cap_UQ(:,sub,:),3);
                   p90_val_prod_cap = prctile(Production_cap_UQ(:,sub,:),90,3);
                   p10_val_prod_cap = prctile(Production_cap_UQ(:,sub,:),10,3);

                   % Overlay the mean(s)
                   mu_d = plot(t, 100.*(mean_val_dem - (Demand_UQ(1,sub,1)))./ (Production_pre_eq(sub)), 'color', colorspec{2}, 'linewidth', 2.5);
                   hold on         
                   grid on
                   mu_pc = plot(t, 100.*(mean_val_prod_cap - (Production_cap_UQ(1,sub,1)))./ (Production_pre_eq(sub)), '--', 'color', colorspec{1}, 'linewidth', 3.5);
                   mu_p  = plot(t, 100.*(mean_val_prod - (Production_UQ(1,sub,1)))./ (Production_pre_eq(sub)), ':', 'color', colorspec{3}, 'linewidth', 2.5);
                   
%                     % Uncomment to plot individual realizations
%                         for n = 1:Nsim
%                             plot(t,100.*(Demand_UQ(:,sub,n) - Demand_UQ(1,sub))./Production_pre_eq(sub),  'color', colorspec{2}, 'linewidth', 0.5)
%                             hold on
%                             plot(t,100.*(Production_cap_UQ(:,sub,n) - Production_cap_UQ(1,sub))./Production_pre_eq(sub),'--', 'color', colorspec{1}, 'linewidth', 1.5)
%                             plot(t,100.*(Production_UQ(:,sub,n)     - Production_UQ(1,sub))    ./Production_pre_eq(sub), ':', 'color', colorspec{3}, 'linewidth', 1.5)                               
%                         end
%                         
                   
                   % ensure that the lines are on top of the confidence
                   % interval
                   uistack(mu_d,'top')
                   uistack(mu_pc,'top')
                   uistack(mu_p,'top')
                   
                   title(sector_names.Sector{sub}, 'interpreter', 'latex')
                   grid on
                   ylim([-15 15])
                   xlim([0 5])

                end

                % add legend
                Lgnd = legend('Demand', 'Production capacity', 'Production', 'Position', [0.35 0.125 0.12 0.05]);

                if(save_flag == "true")
                    filename = 'AllSector_ProdDemandCap_Dash';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end                        

                if(save_flag == "true")
                    filename = 'AllSector_ProdDemandCap_Dash';    
                    print('-painters','-dsvg',filename)
                end

%             case('abs')
%                 for subset = 1:length(sectors_custom)
%                     sub = sub_idx_selected(subset);
%                     subplot(7,6,sub);
%                     plot(t,Demand(:,sub),  'color', colorspec{2}, 'linewidth', 2.5)
%                     hold on
%                     plot(t,Production_cap(:,sub),'--', 'color', colorspec{1}, 'linewidth', 2.5)
%                     plot(t,Production(:,sub), ':', 'color', colorspec{3}, 'linewidth', 2.5)
%                     hold on
%                     title(sector_names.Sector{sub}, 'interpreter', 'latex')
%                     grid on
%                     ylim([0 max(max(Production(:,:)))])
%                 end     
%                 % add legend
%                 Lgnd = legend('Demand', 'Production capacity', 'Production', 'Position', [0.30 0.125 0.12 0.05]);
        end
            
            
%     case('agg')
%         switch(y_axis_option)
%             case('delta')  
%                fig.Position = [300 100 350 250]
% 
%                 % Uncomment to plot individual realizations
%                 for n = 1:Nsim
%                 plot(t, 100.*(sum(Demand_UQ(:,sub_idx_selected,n),2)         - sum(Demand_UQ(1,sub_idx_selected,n),2))          ./sum(Demand_UQ(1,sub_idx_selected,n),2)         , 'color', colorspec{2}, 'linewidth', 1.5);
%                 hold on
%                 plot(t, 100.*(sum(Production_cap_UQ(:,sub_idx_selected,n),2) - sum(Production_cap_UQ(1,sub_idx_selected,n),2))  ./sum(Production_cap_UQ(1,sub_idx_selected,n),2) , '--', 'color', colorspec{1}, 'linewidth', 1.5);
%                 plot(t, 100.*(sum(Production_UQ(:,sub_idx_selected,n),2)  - sum(Production_UQ(1,sub_idx_selected,n),2))      ./sum(Production_UQ(1,sub_idx_selected,n),2)        , ':', 'color', colorspec{3}, 'linewidth', 1.5);
%                 end
%                 
%                 xlabel('Time (years)', 'interpreter', 'latex')
%                 ylabel('Change in production (\%)', 'interpreter', 'latex')
%                 grid on
%                 Lgnd = legend('Demand', 'Production capacity', 'Production'); 
% 
%             case('abs')
%                 plot(t, sum(Demand(:,sub_idx_selected),2)         , 'color', colorspec{2}, 'linewidth', 2.5);
%                 hold on
%                 plot(t, sum(Production_cap(:,sub_idx_selected),2) , '--', 'color', colorspec{1}, 'linewidth', 2.5);
%                 plot(t, sum(Production(:,sub_idx_selected),2)     , ':', 'color', colorspec{3}, 'linewidth', 2.5);
%                 xlabel('Time (years)', 'interpreter', 'latex')
%                 ylabel('Output (million Yen)', 'interpreter', 'latex')
%                 grid on
%                 Lgnd = legend('Demand', 'Production capacity', 'Production', 'Position', [0.30 0.125 0.12 0.05]);
%        end
end


end

