## MIC1 CERN
Microscope 1 in CERN has undergone 3 different correction sets, so far (last update 03/04/24)
1. July 2021, when the microscope was installed.
2. December 2023, after fixing the oil ring.
3. January 2024

### July 2021 corrections
mic1_cern_corrmtx_old/2.cormtx/bot_2

Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/ /diff_matrix_*_2021.txt`

Films scanned with this configuration:
- RUN1 W4 B1
- RUN1 W4 B3
- RUN1 W4 B4
- RUN3 W5 B4 P29-60

### December 2023 corrections
Films scanned with this configuration:
- never used

### January 2024 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/ /diff_matrix_*_2021.txt`

Films scanned with this configuration:
- RUN3 W5 B4 P1-28
- RUN2 W2 B3

There is no need to apply offline matrices, as `mean_matrix.bin` was used.
Films scanned with this configuration:
- RUN2 W5 B2
