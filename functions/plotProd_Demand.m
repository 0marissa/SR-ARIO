function [] = plotProd_Demand(agg_option, y_axis_option, t, sectors_custom, Production_pre_eq, Production_cap, Demand, Production, sector_names, save_flag)
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
    
    
% generate plot
fig = figure

switch(agg_option)

    case('sector')
        fig.Position = [300 100 1500 900]
        switch(y_axis_option)
            case('delta')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub);
                    plot(t,100.*(Demand(:,sub)         - Demand(1,sub))        ./Production_pre_eq(sub),  'color', colorspec{2}, 'linewidth', 2.5)
                    hold on
                    plot(t,100.*(Production_cap(:,sub) - Production_cap(1,sub))./Production_pre_eq(sub),'--', 'color', colorspec{1}, 'linewidth', 2.5)
                    plot(t,100.*(Production(:,sub)     - Production(1,sub))    ./Production_pre_eq(sub), ':', 'color', colorspec{3}, 'linewidth', 2.5)                    
                    title(sector_names(sub), 'interpreter', 'latex')
                    grid on
                    ylim([-15 15])
                    xlim([0 5])
                end
                
                % add legend
                Lgnd = legend('50th percentile demand', '50th percentile production capacity', '50th percentile production', 'Position', [0.35 0.125 0.12 0.05]);
    
            case('abs')
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(7,6,sub);
                    plot(t,Demand(:,sub),  'color', colorspec{2}, 'linewidth', 2.5)
                    hold on
                    plot(t,Production_cap(:,sub),'--', 'color', colorspec{1}, 'linewidth', 2.5)
                    plot(t,Production(:,sub), ':', 'color', colorspec{3}, 'linewidth', 2.5)
                    title(sector_names(sub), 'interpreter', 'latex')
                    grid on
                    ylim([0 max(max(Production(:,:)))])
                end     
                % add legend
                Lgnd = legend('50th percentile demand', '50th percentile production capacity', '50th percentile production', 'Position', [0.30 0.125 0.12 0.05]);
        end
            
            
    case('agg')
        switch(y_axis_option)
            case('delta')  
                plot(t, 100.*(sum(Demand(:,sub_idx_selected),2)         - sum(Demand(1,sub_idx_selected),2))          ./sum(Demand(1,sub_idx_selected),2), 'color', colorspec{2}, 'linewidth', 2.5);
                hold on
                plot(t, 100.*(sum(Production_cap(:,sub_idx_selected),2) - sum(Production_cap(1,sub_idx_selected),2))  ./sum(Production_cap(1,sub_idx_selected),2), '--', 'color', colorspec{1}, 'linewidth', 2.5);
                plot(t, 100.*(sum(Production(:,sub_idx_selected),2)     - sum(Production(1,sub_idx_selected),2))      ./sum(Production(1,sub_idx_selected),2), ':', 'color', colorspec{3}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('Change in production (\%)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Demand', 'Production capacity', 'Production'); 
            case('abs')
                plot(t, sum(Demand(:,sub_idx_selected),2)         , 'color', colorspec{2}, 'linewidth', 2.5);
                hold on
                plot(t, sum(Production_cap(:,sub_idx_selected),2) , '--', 'color', colorspec{1}, 'linewidth', 2.5);
                plot(t, sum(Production(:,sub_idx_selected),2)     , ':', 'color', colorspec{3}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('Output (million Yen)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Demand', 'Production capacity', 'Production', 'Position', [0.30 0.125 0.12 0.05]);
        end
end

if(save_flag == "true")
    filename = 'fig_prod';    
    print('-painters','-dsvg',filename)
end

end

