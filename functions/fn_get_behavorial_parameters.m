function [input] = fn_get_behavorial_parameters(input, sim)
%Function responsible for loading behavorial parameters from input file.
    
   % Initialize each variable    
      input.params.alpha_prod_max = input.params_UQ.alpha_prod_max(:,sim);
      input.params.n_stock        = input.params_UQ.n_stock(:,sim);
      input.params.psi            = input.params_UQ.psi(:,sim);
      input.params.tau_alpha      = input.params_UQ.tau_alpha(:,sim);
      input.params.tau_stock      = input.params_UQ.tau_stock(:,sim);

end
