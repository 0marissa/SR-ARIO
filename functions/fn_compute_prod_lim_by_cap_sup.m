function [sr] = fn_compute_prod_lim_by_cap_sup(k, input, sr, settings)
%Function to calculate production limited by supplies.
    
    % Compute target inventories
    stock_required = repmat(sr.prod_lim_by_cap(k+1,:),input.sectors.N,1).*...
        sr.IO_norm.*repmat(input.params.n_stock(:)*settings.dt,1,input.sectors.N);
    
    % Compute production ratio (compared to pre-event production) by stock
    product_ratio = sr.stock(:,:,k)./(repmat(input.params.psi(:),1,input.sectors.N).*stock_required);
    
    % Compute the production constraints on sector i by sector j and
    % resultant actual production limited by both capacity and supplies
    dom_product_constraint = repmat(transpose(sr.dom_prod_lim_by_cap(k+1,:)),1,input.sectors.N); % how much industry i can produce constrained on j
    for i = 1:input.sectors.N
       for j = 1:input.sectors.N
           if sr.stock(j,i,k)< input.params.psi(j)*stock_required(j,i)
               dom_product_constraint(i,j) = dom_product_constraint(i,j) * min(1,product_ratio(j,i));
           end
       end
       sr.dom_production(k+1,i) = min(dom_product_constraint(i,:));
       if sr.dom_production(k+1,i)<sr.dom_prod_lim_by_cap(k+1,i)
           sr.imports(k,i) = min(sr.imports(k,i)+sr.dom_prod_lim_by_cap(k+1,i)-sr.dom_production(k+1,i),sr.imports(1,i));
       end
       sr.production(k+1,i) = sr.dom_production(k+1,i) + sr.imports(k,i);
    end
    
end