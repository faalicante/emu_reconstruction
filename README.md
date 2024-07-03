## MIC2
Microscope 2 in Naples has undergone 3 different correction sets, so far (last update 20/05/24)
- First corrections are performed in July 2021
- A second set is performed after the removal of the revolver in January 2024
- The last set has been performed after that oil leaked onto the encoder, in April 2024.

### July 2021 corrections
The correction matrices used are from the same period and on C:\LASSO_x64\ they are named as:
- `cormtx_mic2_0.bin`
- `cormtx_mic2_1.bin`

Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_2021.txt`
Films scanned with this configuration:
- RUN1 W2 B1
- RUN1 W2 B3
- RUN1 W2 B4
- RUN3 W4 B2
- RUN3 W3 B1 P1-35
### January 2024 corrections
The correction matrices used are from the same period and on `C:\LASSO_x64\` they are named as:
- cormtx_mic2_half_0.bin
- cormtx_mic2_half_1.bin

Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_Jan24.txt`
Films scanned with this configuration:
- RUN3 W3 B1 P36-57 (no 51, 56 rescan)

### April 2024 corrections
The correction matrix used is just one and is the mean between top and bottom layer and on `C:\LASSO_x64\`` it is named as:
- `mean_matrix.bin`
Films scanned with this configuration:
- RUN3 W3 B1 P51, 56
