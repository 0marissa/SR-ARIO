function [sr] = fn_get_output_econ_metrics(k, input, sr)
%Function to calculate output economic metrics for timestep k.
    
    % Calculate actual satisfied demand
    sr.local_demand_sat(k+1,:) = sr.local_demand(k+1,:).*sr.satisfied_ratio(k+1,:);
    
    % Calculate actual supply
    sr.supply(:,:,k+1) = sr.orders(:,:,k).* transpose(repmat(sr.satisfied_ratio(k+1,:),input.sectors.N,1));
    
end