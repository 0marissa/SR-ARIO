# R-ARIO: Refined Adaptive Regional Input-Output Model

**Stanford Urban Resilience Initiative** <br>
**Original ARIO program by Stéphane Hallegatte, 2014** <br>

MATLAB codebase for quantifying post-disaster economic recovery for a single region using the Refined Adaptive Regional Input-Output (R-ARIO) model. The R-ARIO model extends the original ARIO model (Hallegatte, 2014) with three key enhancements: (i) dynamic reconstruction rates based on sector-specific reconstruction time curves, (ii) explicit modeling of housing losses separate from productive capital losses, and (iii) sector-level modeling and uncertainty quantification of behavioral parameters.

*License: GNU General Public License v3.0 (see LICENSE)*

## Citation

If you use this code in your research, please cite:

> Issa, O., Zhu, T., Markhvida, M., Costa, R., and Baker, J. W. (2025). "Refined adaptive regional input-output model: Application to the 2016 Kumamoto Earthquake." *Natural Hazards Review*, 26(4), 04025050. [https://doi.org/10.1061/NHREFO/NHENG-2207](https://doi.org/10.1061/NHREFO/NHENG-2207)

```bibtex
@article{issa2025rario,
  title={Refined adaptive regional input-output model: Application to the 2016 {Kumamoto} Earthquake},
  author={Issa, Omar and Zhu, Tinger and Markhvida, Maryia and Costa, Rodrigo and Baker, Jack W.},
  journal={Natural Hazards Review},
  volume={26},
  number={4},
  pages={04025050},
  year={2025},
  doi={10.1061/NHREFO/NHENG-2207}
}
```

## Authors

- **Omar Issa** — Dept. of Civil and Environmental Engineering, Stanford University
- **Tinger Zhu** — Dept. of Civil and Environmental Engineering, Stanford University
- **Maryia Markhvida** — Dept. of Systems Design Engineering, University of Waterloo
- **Rodrigo Costa** — Dept. of Systems Design Engineering, University of Waterloo
- **Jack W. Baker** — Dept. of Civil and Environmental Engineering, Stanford University

## Key Features

- **Dynamic reconstruction rates**: Time-dependent, sector-specific reconstruction rates derived from user-provided reconstruction time curves, replacing the constant rate assumption in the original ARIO model.
- **Explicit housing losses**: Housing damage is modeled as a distinct sector that generates reconstruction demand without distorting productive capital calculations for other sectors.
- **Sector-level behavioral parameters**: Five behavioral parameters (time to maximum overproduction, time of inventory restoration, maximum overproduction, target inventory level, and production reduction/heterogeneity) are modeled at the sector level with distributional bounds, enabling uncertainty quantification and global sensitivity analysis.
- **Sobol sensitivity analysis**: Support for variance-based sensitivity analysis to identify the most influential behavioral parameters on predicted indirect loss.

## Program Overview

This repository contains the following:

* **sr_wrapper.m**: Wrapper script governing analysis settings
* **fn_run_sr_ario.m**: Main wrapper function for the single-region R-ARIO program
* **functions/**: Functions for simulating economic recovery and auxiliary post-processing tools
* **inputs/**: Pre-processed input data:
    * Economic inputs (value added, exports, imports, local demand, fixed assets)
    * Damage/loss inputs
    * Input-output table
    * **params/**: Input files for ARIO behavioral parameter distributions
* **output/**: Analysis output and postprocessing scripts

## fn_run_sr_ario Overview

The function `fn_run_sr_ario` is the main function governing the R-ARIO analysis, called by `sr_wrapper` after analysis settings are defined.

* `fn_load_default_ario_settings`: Loads hardcoded analysis parameters
* `fn_initialize_sr_variables`: Initializes containers for all timesteps; sets initial pre-disaster values
* **Main loop** for timestep $k = 1:n$:
    * `fn_compute_demand`: Computes sector-level recovery percentage, updates reconstruction demand rate and total final demand
    * `fn_compute_prod_lim_by_cap`: Computes production constrained by production capacity
    * `fn_compute_prod_lim_by_cap_sup`: Computes production constrained by production capacity and available supplies
    * `fn_get_output_econ_metrics`: Computes actual satisfied demand and actual supply
    * `fn_update_input_econ_metrics`: Updates input economic metrics for the next timestep
    * `fn_get_output_econ_performance`: Updates output economic metrics for the next timestep

## Input Files

* **sr_ario_building_damage.csv**: Individual damage observations/simulations for each building (or building cluster). Used to construct sector-specific recovery curves and control reconstruction rates.
* **sr_ario_econ_data.mat**: Sector-level economic data (exports, final demand, imports, value added, local demand, fixed assets, total output).
* **sr_ario_economic_sectors.csv**: List of sectors modeled in the economy (including housing, if available), with sector ID, name, and non-stockable good status.
* **sr_ario_IO_data.mat**: Raw (non-normalized) input-output table.
* **sr_ario_loss_data.mat**: Sector-level aggregate losses and reconstruction demand assignments.

## Output Files

* **sr_ario_results.mat**: MATLAB struct (`sr_output`) containing all analysis results. Postprocess using `sr_postprocess.m`.

## Running an Analysis

1. Place input files (`sr_ario_building_damage.csv`, `sr_ario_econ_data.mat`, `sr_ario_economic_sectors.csv`, `sr_ario_IO_data.mat`, `sr_ario_loss_data.mat`) in the `inputs/` directory.
2. Configure analysis settings and run `sr_wrapper.m`.
3. Results are saved to the `outputs/` directory.
4. Postprocess using `sr_postprocess.m`. Example postprocessing functions are included in `functions/`.

## Acknowledgments

This work was supported by Sompo Holdings, Inc. and the National Science Foundation (grant CMMI-2053014), with additional support from the Stanford Urban Resilience Initiative.
