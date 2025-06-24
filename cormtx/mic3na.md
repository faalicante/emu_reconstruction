## MIC3 NA
Microscope 3 has undergone 6 correction sets since the SND data-taking start, so far (last update 04/06/24)
- First corrections made in August 2021, named `mic3_2021`
- Second set of corrections made in February 2023, named `mic3_15_Feb_2023` due to the break of the stage, ***but no correction matrices done**
- Third set of corrections, made in November 2023, named `mic3_24Nov23`
- Fourth set of corrections, made in February 2024, named `mic3_9Feb24` (**didn't affect data**)
- Fifth set of corrections, made in April 2024, named `mic3_4Apr24`, due to several changes: lamp got replaced, revolver removed and magnetic frame installed
- Sixth set of corrections, made in May 2024, named `mic3_8May24`, due to oil leaking onto the encoder

### 2021 Corrections
This set of corrections was the first made, pixel size was `0.3455 -0.3462` and the corrections matrices are on `C:\LASSO_x64\`:
- `corr_mtx_bot_1.bin`
- `corr_mtx_top_1.bin`

Text files are stored on EOS: `/eos/experiment/sndlhc/emulsionData/Napoli/CALIBRATIONS/mic3_2021/corr_mtx_*_1.txt`

Matrices to be used in the linking:
**to be generated**

Film scanned in this configration:
- RUN0_W3_B1: P31 - P60
- RUN1_W2_B3 expcept for P12,16,29,36,42,09,13,14,15,23,24

### February 2023 corrections
This set of corrections applied only to flatview and grainvol, so apparently no further correction matrices have been evaluated.

Films scanned in this configuration:
 - RUN1_W2_B3 P12,16,29,36,42,09,13,14,15,23,24
 - RUN1_W2_B2
 - RUN3_W4_B4 (small area)
 - RUN3_W4_B3 P[1-28]
### November 2023 correction
This set of corrections included `2.cormtx` only, pixel size has not been determined again, so it was `0.3455 -0.3462`, correction matrices are stored on `Y:\corr_gen\mic3_24Nov23\2.cormtx\*_1\`:
- `corr_mtx_bot_1.bin`
- `corr_mtx_top_1.bin`

***Warning**: On 22/01/2024 pixel density was changed to `0.3455 -0.3462` from `0.345291 -0.345583`, it happened at plate 3_W4_B3_49 after the installation of Dispatcher on mic3, so plates scanned with `0.345291 -0.345583` pixel density are 3_W4_B3_31-3_W4_B3_49.

Text files are stored on EOS: `/eos/experiment/sndlhc/emulsionData/Napoli/CALIBRATIONS/mic3_24Nov23/corr_mtx_*_1.txt`

Matrices to be used in the linking:
**to be generated**

Films scanned in this configuration:
- RUN3_W4_B3 P[29-57]
- RUN2_W3_B1 P[1-18] except P03 (24/05/24 **reduced area**) and P11 (07/06/24 **reduced area**)

### April 2024 corrections
This set of corrections have been performed after several changes to the mic3 stage:
- Lamp changed
- Revolver removed
- MAgnetic frame installed
For this set all kind of corrections have been made:
- Pixel size measured is `0.34455265 -0.34519676`
- Since this is a recent set of corrections we got the `mean_matrix.txt` already, they are stored in `Y:\corr_gen\mic3_4Apr24\2.cormtx\` and `txt` file in `/eos/experiment/sndlhc/emulsionData/Napoli/CALIBRATIONS/mic3_4Apr24/mean_matrix.txt`

Films scanned in this configuration:
- RUN2_W3_B1 P[19-25]

### May 2024
This set of corrections has been performed due to oil leaking onto the stage, this involved all kind of corrections:
- Pixel size measured is: `0.344199486 -0.345760995`
- Since this is a recent set of corrections we got the `mean_matrix.txt` already, they are stored in `Y:\corr_gen\mic3_8May24\2.cormtx\` and `txt` file in `/eos/experiment/sndlhc/emulsionData/Napoli/CALIBRATIONS/mic3_8May24/mean_matrix.txt`

Films scanned in this configuration:
- RUN2_W3_B1 P03 and P11
- RUN2_W3_B1 P[26-57]
- RUN2_W3_B3 P[1-44] *ongoing*

*last update: 22/07/24*