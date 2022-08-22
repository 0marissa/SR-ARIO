function [] = plotVA_UQ(agg_option, y_axis_option, t, sectors_custom, VA_pre_eq, VA_UQ, Demand_UQ, Production_UQ, sector_names, Nsim, save_flag)
%plotVA Plots sector-level and aggregate valued-added output
% Omar Issa

% User inputs:
%   y_axis_option: {'abs', 'delta'}
%   agg_option: {'sector', 'agg'}
%   save_flag: {'true', 'false'}

% example call to function:
%     plotVA('sector', 'delta', t, sector_names.ID, ...
%            VA_pre_eq, VA, ...
%            Demand, Production, sector_names, 'false')

% define Baker Research group color scheme
colorspec{1} = [56 95 150]/255;
colorspec{2} = [207 89 33]/255;
colorspec{3} = [158 184 219]/255;    

sectors_custom_idx = ismember(sector_names, sectors_custom);
sub_idx =            [1:height(sector_names)]';
sub_idx_selected   = sub_idx(sectors_custom_idx);
    
Nsim = size(VA_UQ,3);

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
                       med_val = median(VA_UQ(:,sub,:),3);
                       sigma = std(VA_UQ(:,sub,:),[],3);
                       p90_val = prctile(VA_UQ(:,sub,:),90,3);
                       p10_val = prctile(VA_UQ(:,sub,:),10,3);

                       % Overlay the mean
                       mu_v = plot(t, 100.*(med_val - (VA_UQ(1,sub,1)))./ (VA_pre_eq(sub)), 'color', colorspec{1}, 'linewidth', 2.5);
                       hold on         
                       grid on
                       
                       % Plot confidence bounds 
                       xconf = [t t(end:-1:1)] ; 
                       yconf_ub = 100.*(p90_val - (VA_UQ(1,sub,1)))./ (VA_pre_eq(sub));
                       yconf_lb = 100.*(p10_val - (VA_UQ(1,sub,1)))./ (VA_pre_eq(sub));
                       yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                       p = fill(xconf,yconf,'blue');
                       p.FaceColor = colorspec{3};      
                       p.EdgeColor = 'none'; 
                       alpha(p,.5)
                       ylim([-20 10])
                       xlim([0 5])
                       
                       uistack(mu_v,'top')
                       
                       title(sector_names{sub}, 'interpreter', 'latex')
                end
                
               Lgnd = legend('Value added 80% CI', '50th percentile value added', 'Position', [0.35 0.125 0.12 0.05]);

               if(save_flag == "true")
                    filename = 'AllSector_VA_Dash_UQ';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end                        

                if(save_flag == "true")
                    filename = 'AllSector_VA_Dash_UQ';    
                    print('-painters','-dsvg',filename)
                end                       
                
            case('delta_mean')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub);

                    % Uncomment to plot individual realizations
%                      for n = 1:Nsim
%                         t = [1:length(Demand_UQ)]./365;
%                         plot(t, 100.*(VA_UQ(:,sub,n) - VA_UQ(1,sub,n))/VA_UQ(1,sub,n), 'color', colorspec{1}, 'linewidth', 0.5)
%                         hold on
%                         title(sector_names.Sector{sub}, 'interpreter', 'latex')
%                         grid on
%                      end
                    
                       % Compute the mean and standard devation of all simulations
                       med_val = mean(VA_UQ(:,sub,:),3);
                       sigma = std(VA_UQ(:,sub,:),[],3);
                       p90_val = prctile(VA_UQ(:,sub,:),90,3);
                       p10_val = prctile(VA_UQ(:,sub,:),10,3);

                       % Overlay the mean
                       plot(t, 100.*(med_val - (VA_UQ(1,sub,1)))./ (VA_pre_eq(sub)), 'color', colorspec{1}, 'linewidth', 2.5);
                       hold on         
                       grid on
                       
                       ylim([-20 10])
                       xlim([0 5])
                      
                       title(sector_names.Sector{sub}, 'interpreter', 'latex')
                end
                
               Lgnd = legend('Value added', 'Position', [0.35 0.125 0.12 0.05]);
                
                if(save_flag == "true")
                    filename = 'AllSector_VA_Dash';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end                        

                if(save_flag == "true")
                    filename = 'AllSector_VA_Dash';    
                    print('-painters','-dsvg',filename)
                end                      
                
                
                
%             case('abs')
%                 for subset = 1:length(sectors_custom)
%                     sub = sub_idx_selected(subset);
%                     subplot(7,6,sub)
%                     t = [1:length(Demand)]./365;
%                     plot(t, VA(:,sub), 'color', colorspec{1}, 'linewidth', 2.5)
%                     hold on
%                     title(sector_names.Sector{sub}, 'interpreter', 'latex')
%                     grid on
%                     ylim([0 max(max(VA(:,:)))])
%                 end   
                
                
        end
            
            
    case('agg')
        switch(y_axis_option)
            case('delta_UQ')  
               fig.Position = [300 100 350 250]

               % Compute the mean, standard devation, and relevant percentiles of all simulations
               med_val = mean(sum(VA_UQ(:,sub_idx_selected,:),2),3);
               sigma = std(sum(VA_UQ(:,sub_idx_selected,:),2),[],3);
               p90_val = prctile(sum(VA_UQ(:,sub_idx_selected,:),2),90,3);
               p10_val = prctile(sum(VA_UQ(:,sub_idx_selected,:),2),10,3);
               
               % Overlay the mean
                   mu = plot(t, 100.*(med_val - sum(VA_UQ(1,sub_idx_selected,1),2))./ sum(VA_pre_eq(sub_idx_selected)), 'color', colorspec{1}, 'linewidth', 2.5);
                   hold on
                   grid on
                   
               % Plot confidence interval
                   xconf = [t t(end:-1:1)]; 
                   yconf_ub = 100.*(p90_val - sum(VA_UQ(1,sub_idx_selected,1),2))./ sum(VA_pre_eq(sub_idx_selected));
                   yconf_lb = 100.*(p10_val - sum(VA_UQ(1,sub_idx_selected,1),2))./ sum(VA_pre_eq(sub_idx_selected));
                   yconf = [yconf_ub' yconf_lb(end:-1:1)'];
                   p = fill(xconf,yconf,'blue');
                   p.FaceColor = colorspec{3};      
                   p.EdgeColor = 'none'; 
                   alpha(p,.5)
                   ylim([-20 5])
                   xlim([0 5])
               
               % Uncomment to plot individual realizations
               for n = 1:Nsim
                  s_line = plot(t, 100.*(sum(VA_UQ(:,sub_idx_selected,n),2) - sum(VA_UQ(1,sub_idx_selected,n),2))./ sum(VA_pre_eq(sub_idx_selected)),  'Color', [0.8 0.8 0.8, 0.5], 'linewidth', 0.5);
                  hold on
               end

               Lgnd = legend('Value added', '80 % CI', 'simulation'); 

               uistack(p,'top')
               uistack(mu,'top')
               xlabel('Time (years)', 'interpreter', 'latex')
               ylabel('Change in value added (VA) (\%)', 'interpreter', 'latex')
               grid on

                if(save_flag == "true")
                    filename = 'Agg_DeltaVA';    
                    print('-painters','-dsvg',filename)
                end

                if(save_flag == "true")
                    filename = 'Agg_DeltaVA';    
                    exportgraphics(fig,strcat(filename,'.png'),'Resolution',600) 
                end

%             case('abs')
%                mean_val = mean(sum(VA_UQ(:,sub_idx_selected,:),2),3);
%                p90_val = prctile(sum(VA_UQ(:,sub_idx_selected,:),2),90,3);
%                p10_val = prctile(sum(VA_UQ(:,sub_idx_selected,:),2),10,3);                
%                 
%                % Overlay the mean
%                    plot(t, mean_val, 'color', colorspec{1}, 'linewidth', 2.5);
%                    hold on
%                    grid on
%                
%                % Plot confidence interval
%                    xconf = [t t(end:-1:1)] ; 
%                    yconf_ub = p90_val;
%                    yconf_lb = p10_val;
%                    yconf = [yconf_ub' yconf_lb(end:-1:1)'];
%                    p = fill(xconf,yconf,'blue');
%                    p.FaceColor = colorspec{3};      
%                    p.EdgeColor = 'none'; 
%                    alpha(p,.5)
%                    xlim([0 5])                
%                 
%                 xlabel('Time (years)', 'interpreter', 'latex')
%                 ylabel('Value added (VA) (million Yen)', 'interpreter', 'latex')
%                 grid on
%                 Lgnd = legend('Value Added');

        end
end




end


























