## MIC1 CERN
Microscope 1 in CERN has undergone 3 different correction sets, so far (last update 03/04/24)
- First corrections are performed in July 2021
- A second set is performed after fixing the oil ring on the objective in December 2023
- The last set has been performed in January 2024.

### Nov 2022 corrections
The correction matrices used are from the same period and on C:\LASSO_x64\ they are named as:
	- `cormtx_mic2_0.bin`
- `cormtx_mic2_1.bin`
mic1_cern_corrmtx_old/2.cormtx/bot_2

Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_2021.txt`
Films scanned with this configuration:
- RUN1 W4 B1
- RUN1 W4 B4
        - RUN3 W5 B4 P29-60

### January 2024 corrections
The correction matrices used are from the same period and on `C:\LASSO_x64\` they are named as:
- cormtx_mic2_half_0.bin
- cormtx_mic2_half_1.bin

Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_Jan24.txt`
Films scanned with this configuration:
- never used

### April 2024 corrections
The correction matrix used is just one and is the mean between top and bottom layer and on `C:\LASSO_x64\`` it is named as:
- `mean_matrix.bin`
Films scanned with this configuration:
- RUN3 W5 B4 P1-28
- RUN2 W2 B3
using directly mean matrix
- RUN2 W5 B2

