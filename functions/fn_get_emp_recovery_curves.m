function [recovery] = get_emp_recovery_curves(f_name, input, settings, type)
%Function responsible for loading empirical recovery curves from input file.

switch(type)
    case('no_UQ')

        % Load empirical building recovery data, sort by recovery time.
        empirical_data = readtable(fullfile('inputs',f_name));
        empirical_data = sortrows(empirical_data,'TimeToRecovery_day');

        % Load sector data from input
        sectors = input.sectors;

        % Load analysis settings
        N          = sectors.N;
        N_wHousing = sectors.N_wHousing;
        Nstep      = settings.Nstep;
        dt         = settings.dt;

        % Pre-allocate memory for recovery arrays
        fitted_recovery_curve       =  ones(N_wHousing, Nstep);
        fitted_slope_recovery_curve = zeros(N_wHousing, Nstep-1);

        % Initialize time domain
        t_domain = linspace(0,Nstep*dt,Nstep);

        for sub = 1 : N_wHousing
            
            sector_id = sectors.id(sub);
            raw_sector_RT_data = empirical_data.TimeToRecovery_day(empirical_data.IndustrySector_Code == sector_id)./365;
            raw_sector_N_data  = empirical_data.N(empirical_data.IndustrySector_Code == sector_id);

            if(length(raw_sector_RT_data)>0)

                raw_recovery_traj = cumsum(raw_sector_N_data)./sum(raw_sector_N_data);

                [val, idx, ~] = unique([raw_sector_RT_data]);  
                ecdf_values = raw_recovery_traj(idx);
                days = val;
                
                  % Uncomment for an empirical CDF  
                  %   [ecdf_values, days] = ecdf(raw_sector_RT_data);
                  %     ecdf_diff = diff(ecdf_values)./diff(days);

%                 % Exponential CDF fit
                ecdf_recovery_fit = expcdf(t_domain, mean((raw_sector_RT_data)) , std((raw_sector_RT_data)))'; 
                d_ecdf_recovery_fit = diff(ecdf_recovery_fit)./diff(t_domain)';
                fitted_recovery_curve(sub,:)       = ecdf_recovery_fit;
                fitted_slope_recovery_curve(sub,:) = d_ecdf_recovery_fit;

                % Add slight randomness to assist in interpolation
                rand('seed',1)
                days = days - rand*10e-5;
                raw_recovery_curve_values{sub}      =  interp1(days,ecdf_values,t_domain);

                idx_min = find(~isnan(raw_recovery_curve_values{sub}), 1 ,'first');        
                idx_max = find(~isnan(raw_recovery_curve_values{sub}), 1 ,'last');        

                raw_recovery_curve_values{sub}(1:idx_min-1)   =  0;
                raw_recovery_curve_values{sub}(idx_max+1:end) =  1;
                raw_recovery_curve_days{sub}                  =  days;

                raw_recovery_curve_slope{sub}       =  diff(raw_recovery_curve_values{sub})./diff(t_domain);
                raw_recovery_curve_slope{sub}(isnan(raw_recovery_curve_slope{sub})) = 0;

                smooth_recovery_fit = movmean(raw_recovery_curve_values{sub}, [20 0]);
                d_smooth_recovery_fit =  diff(smooth_recovery_fit)./diff(t_domain);

                smooth_recovery_curve(sub,:)       = smooth_recovery_fit;
                smooth_slope_recovery_curve(sub,:) = d_smooth_recovery_fit;        

            else
               raw_recovery_curve_values{sub} = ones(1, Nstep); 
               raw_recovery_curve_slope{sub} = zeros(1, Nstep-1); 

                smooth_recovery_fit = movmean(raw_recovery_curve_values{sub}, [20 0]);
                d_smooth_recovery_fit = diff(smooth_recovery_fit)./diff(t_domain);
                smooth_recovery_curve(sub,:)       = smooth_recovery_fit;
                smooth_slope_recovery_curve(sub,:) = d_smooth_recovery_fit;        

                raw_recovery_curve_slope{sub}       =  diff(raw_recovery_curve_values{sub})./diff(t_domain);
                raw_recovery_curve_slope{sub}(isnan(raw_recovery_curve_slope{sub})) = 0;        

            end
        end        

        recovery.smooth_recovery_curve =         smooth_recovery_curve;
        recovery.smooth_slope_recovery_curve =   smooth_slope_recovery_curve;
        recovery.raw_recovery_curve =            raw_recovery_curve_slope;
        recovery.raw_slope_recovery_curve =      raw_recovery_curve_days;
        
%         % temporary replacement
%         addpath inputs
%         input_old = load('smooth_slope_recovery_curve_old.mat');
%         recovery.smooth_slope_recovery_curve = input_old.fitted_slope_recovery_curve;

    otherwise
        disp("loss data type not yet implemented.")


end
