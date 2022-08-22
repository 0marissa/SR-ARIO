function [] = plot_combined_direct_indirect_loss_dash(Destr_capital_ini, VA_pre_eq, net_VA_loss, net_VA_loss_rel, sector_names, type)
% Omar Issa

% example call to function
% [net_VA_loss, net_VA_loss_rel] = computeVALoss(N, t_results, VA_results, VA_pre_eq);
% 
% plot_combined_direct_indirect_loss(Destr_capital_ini, VA_pre_eq, ...
%                                   net_VA_loss, net_VA_loss_rel, sector_names)                    
                              
% define Baker Research group color scheme
colorspec{1} = [56 95 150]/255;
colorspec{2} = [207 89 33]/255;
colorspec{3} = [158 184 219]/255;    

sectors = sector_names;
Destr_capital_rel = [Destr_capital_ini./ VA_pre_eq'];

switch(type)
    case('abs')
        sectors = sector_names;
        Destr_capital_rel = [Destr_capital_ini./ VA_pre_eq'];

        % Left figure: absolute losses (million Yen)
        Total_loss = Destr_capital_ini' - net_VA_loss;
        [~, idx] = sortrows(Total_loss', 'descend');
        x = categorical(sectors);
        x = reordercats(x, sectors(idx));
        y = [Destr_capital_ini'; -net_VA_loss]./1000000; % convert from millions to trillion
        ba = barh(x, y, 'stacked','FaceColor','flat');
        ba(1).CData = colorspec{1};
        ba(2).CData = colorspec{2};
        xlim([-0.2 1.2])
        xlabel('Absolute losses (trillion Yen)', 'interpreter', 'latex')
        grid on
        legend('direct loss', 'median indirect loss', 'interpreter', 'latex')
        
    case('rel')
        
        % Right figure: relative losses (million Yen)
        Total_loss_rel = Destr_capital_rel' - net_VA_loss_rel;
        [~, idx] = sortrows(Total_loss_rel', 'descend');
        x = categorical(sectors);
        x = reordercats(x, sectors(idx));
        y = [Destr_capital_rel'; -net_VA_loss_rel];
        ba = barh(x, y, 'stacked','FaceColor','flat');
        ba(1).CData = colorspec{1};
        ba(2).CData = colorspec{2};
        xlabel('losses as fraction of pre-EQ value added', 'interpreter', 'latex')
        grid on
        legend('direct loss', 'median indirect loss', 'interpreter', 'latex')
end


end