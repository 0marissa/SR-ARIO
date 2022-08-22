function [sr] = fn_compute_demand(k, input, sr, settings)
%Function to calculate new demand.
    
    % Export is assumed to be unchanged
    sr.exports(k+1,:) = input.econ.exports_pre_eq';
    
    % Local demand is modified by macro effect
    sr.local_demand(k+1,:) = sr.macro_effect(k) * input.econ.local_demand_pre_eq';    

    % Compute percentage recovery based on unmet reconstruction demand
    percent_recovered = 1 - (sum(sr.reconstr_demand_matrix(:,:,k),2) ./ sum(sr.direct_losses_matrix,2));
    percent_recovered(isnan(percent_recovered)) = 1;
    idx_recovery      = zeros(1,input.sectors.N_wHousing);
    
    % Locate the index of percentage % recovery on the provided empirical recovery curve
    for ind = 1:input.sectors.N_wHousing
        idx_recovery(ind) = find(input.recovery.smooth_recovery_curve(ind,:) >= percent_recovered(ind), 1, 'first');
    end
    
    for ind = 1:input.sectors.N
        raw_slope = input.recovery.smooth_slope_recovery_curve(:,idx_recovery);
        slopes(:,ind) = raw_slope(:,1) .* sr.reconstr_demand_matrix(:,ind,k);
    end
    
    %sr.reconstr_demand_rate(:,:,k+1) = slopes(:,1) .* input.loss.recon_demand_assignment(1:input.sectors.N);
    sr.reconstr_demand_rate(:,:,k+1) = slopes;
    
    
    % Compute aggregated order for each sector
    orders = sum(sr.orders(:,:,k),2)';
    
    % Compute total final demand 
    sr.demand(k+1,:) = max(settings.epsilon,sr.exports(k+1,:) + sr.local_demand(k+1,:) + sum(sr.reconstr_demand_rate(:,:,k+1)) + orders);

end

