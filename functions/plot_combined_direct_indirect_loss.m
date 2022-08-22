function [] = plot_combined_direct_indirect_loss(Destr_capital_ini, VA_pre_eq, net_VA_loss, net_VA_loss_rel, sector_names)
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

% f = figure
% f.Position = [100 100 900 500];

sectors = sector_names;
Destr_capital_rel = [Destr_capital_ini./ VA_pre_eq'];

% Left figure: absolute losses (million Yen)
subplot(1,2,1)
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
ylabel('sector', 'interpreter', 'latex')
grid on
legend('Direct loss', 'Indirect loss', 'interpreter', 'latex')

% Right figure: absolute losses as fraction of value added pre-EQ (million Yen)
subplot(1,2,2)
Total_loss_rel = Destr_capital_rel' - net_VA_loss_rel;
[~, idx] = sortrows(Total_loss_rel', 'descend');
x = categorical(sectors);
x = reordercats(x, sectors(idx));
y = [Destr_capital_rel'; -net_VA_loss_rel];
ba = barh(x, y, 'stacked','FaceColor','flat');
ba(1).CData = colorspec{1};
ba(2).CData = colorspec{2};
%xlim([-2.0 2.0])
xlabel('losses as fraction of pre-EQ value added', 'interpreter', 'latex')
ylabel('sector', 'interpreter', 'latex')
grid on
legend('Direct loss', 'Indirect loss', 'interpreter', 'latex')

    filename = 'Exp_indirect_breakdown';    
    exportgraphics(f,strcat(filename,'.png'),'Resolution',500)  
    
    
end