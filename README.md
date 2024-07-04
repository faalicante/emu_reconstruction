## MIC2 NA
Microscope 2 in Naples has undergone 3 different correction sets, so far (last update 20/05/24)
- First corrections are performed in July 2021
- A second set is performed after the removal of the revolver in January 2024
- The last set has been performed after that oil leaked onto the encoder, in April 2024.

### July 2021 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_2021.txt`

Films scanned with this configuration:
- RUN1 W2 B1
- RUN1 W2 B3
- RUN3 W4 B2
- RUN3 W3 B1 P1-35

### January 2024 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic2/diff_matrix_*_Jan24.txt`

Films scanned with this configuration:
- RUN3 W3 B1 P36-57 (no 51, 56 rescan)

### April 2024 corrections
There is no need to apply offline matrices, as `mean_matrix.bin` was used.

Films scanned with this configuration:
- RUN3 W3 B1 P51, 56
