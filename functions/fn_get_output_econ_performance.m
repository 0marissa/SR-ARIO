function [sr] = fn_get_output_econ_performance(k, input, sr)
%Function to calculate output economic performance for timestep k.
    
    % Calculate value added
    sr.value_added(k+1,:) = sr.production(k+1,:) - sr.imports(k,:)...
        - sum(sr.IO_norm.* repmat(sr.production(k+1,:),input.sectors.N,1),1);
    
    
end