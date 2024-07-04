## MIC4 CERN
Microscope 4 at CERN has undergone 2 different correction sets, so far (last update 03/07/24)
1. December 2023, when the microscope was installed.
2. July 2024, after replacing the broken objective with mic2 one in July 2024.

### December 2023 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/CERN/CALIBRATIONS/mic4/diff_matrix_*_Dec23.txt`

Films scanned with this configuration:
- RUN3 W1 B2 P1-16
- RUN2 W2 B2

There is no need to apply offline matrices, as `mean_matrix.bin` was used since 06 June 2024.

Films scanned with this configuration:
- RUN2 W5 B1 P1-28 (17-28 with broken objective)

### July 2024 corrections 
There is no need to apply offline matrices, as `mean_matrix.bin` was used.

Films scanned with this configuration:
- RUN2 W5 B1 P17-57 (P17-28 rescans)
