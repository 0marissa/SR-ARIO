function [] = plotVA(agg_option, y_axis_option, t, sectors_custom, VA_pre_eq, VA, Demand, Production, sector_names, save_flag)
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
    

% generate plot
fig = figure

switch(agg_option)

    case('sector')
        fig.Position = [300 100 1500 900]
        switch(y_axis_option)
            case('delta')  
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(6,7,sub)
                    plot(t, 100.*(VA(:,sub) - VA(1,sub))/VA(1,sub), 'color', colorspec{1}, 'linewidth', 2.5)
                    hold on
                    title(sector_names(sub), 'interpreter', 'latex')
                    grid on
                    ylim([-15 15])
                    xlim([0 5])
                Lgnd = legend('50th percentile value added', 'Position', [0.35 0.125 0.12 0.05]);

                end
            case('abs')
                for subset = 1:length(sectors_custom)
                    sub = sub_idx_selected(subset);
                    subplot(7,6,sub)
                    plot(t, VA(:,sub), 'color', colorspec{1}, 'linewidth', 2.5)
                    hold on
                    title(sector_names(sub), 'interpreter', 'latex')
                    grid on
                    ylim([0 max(max(VA(:,:)))])
                end                
        end
            
            
    case('agg')
        switch(y_axis_option)
            case('delta')  
                plot(t, 100.*(sum(VA(:,sub_idx_selected),2)- sum(VA(1,sub_idx_selected),2))./ sum(VA_pre_eq(sub_idx_selected)), 'color', colorspec{1}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('Change in value added (VA) (\%)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Value Added'); 
            case('abs')
                plot(t, sum(VA(:,sub_idx_selected),2), 'color', colorspec{1}, 'linewidth', 2.5);
                xlabel('Time (years)', 'interpreter', 'latex')
                ylabel('Value added (VA) (million Yen)', 'interpreter', 'latex')
                grid on
                Lgnd = legend('Value Added');    
        end
end

if(save_flag == "true")
    filename = 'fig_VA';    
    print('-painters','-dsvg',filename)
end

end

