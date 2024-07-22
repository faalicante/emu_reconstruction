## MIC5
Mic5 microscope is shared between SND@LHC and FOOT:
- First set of corrections has been made on April 2023, including all kind of corrections (**not affecting definitive SND@LHC data**)
- A second set of corrections has been made on November 2023
- A third set of corrections has been made on May 2024 with the `disp_local`
  
### November 2023
This set of corrections is using past corrections except for the cormtx step, correction matrices are stored in `Y:\corr_gen\mic5_24Nov23\2.cormtx\*\correction_matrix.txt`
- Pixel size is `0.345291 -0.345583`
- Correction matrices have been copied to `/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic5_24Nov23/corr_mtx_*.txt`

Films scanned in this configuration:
- RUN3_W4_B1 P[1-10]

### April 2024
This set of corrections includes all kind of corrections and it was made after the installation of the local Dispatcher.
- Pixel size: `0.342817 -0.343588`
- Since it is a recent set of corrections we have only the `mean_matrix.txt`, which is stored at `Y:\corr_gen\mic5_16May24\2.corrmtx\mean_matrix.txt` and `/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic5_16May24/mean_matrix.txt`

Films scanned in this configuration:
- RUN3_W4_B1 P[11-57]
- RUN2_W3_B4 P[1-7] *ongoing*


*last update 22/07/24*