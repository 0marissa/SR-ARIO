function [VA_loss_stats] = fn_compute_VA_loss(N, t, VA_results, VA_pre_eq, input, settings, sr)
%computeVALoss computes indirect (flow) losses attributed to value added.
% Intergration includes 'gains' and reflects a "net" loss. 

% example:
% [net_VA_loss, net_VA_loss_rel] = computeVALoss(N, t_results, VA_results, VA_pre_eq);

% Compute total duration of analyis in years
t_analysis = max(t);

% Compute total direct losses

% For each sector, compute the indirect loss
for sub = 1:37
    % Compute indirect losses by integrating the value added (VA) curve
    net_VA_loss(sub)       = trapz(t, VA_results(:,sub)) - VA_pre_eq(sub)*t_analysis; 
    net_VA_loss_ratio(sub) = net_VA_loss(sub) / (VA_pre_eq(sub));
end

% Compute sub-total losses (convert all to trillion)
direct        =  sum(sr.direct_losses_vector)                   * 1e6  / 1e12;
indirect      = -sum(net_VA_loss)                               * 1e6  / 1e12;
total         =  direct + indirect;
prop_indirect = indirect / total;

% Store all VA loss metrics in a structure for easy access
VA_loss_stats.net_VA_loss = net_VA_loss;
VA_loss_stats.net_VA_loss_ratio = net_VA_loss_ratio;
VA_loss_stats.indirect = indirect;
VA_loss_stats.direct   = direct;
VA_loss_stats.total    = total;

end
