function [sectors] = fn_get_sectors(f_name)
%Function responsible for loading sector data from input file.

% Load data from file.
    sector_data          = readtable(f_name);
    sectors.id           = sector_data.ID;
    sectors.name         = sector_data.Sector;
    sectors.mask         = [sectors.id > 0];
    sectors.N            = sum(sectors.mask);
    sectors.N_wHousing   = length(sectors.name);
    sectors.non_stock    = sector_data.non_stock;

end
