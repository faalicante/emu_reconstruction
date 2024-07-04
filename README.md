## MIC2 CERN
Microscope 2 at CERN has undergone 4 different correction sets, so far (last update 03/07/24)
1. July 2023, when the microscope was installed.
2. December 2023, after fixing the oil ring.
3. April 2024 (09), after many months stop due to rebooting issue.
4. April 2024 (17), after correcting the camera acquisition framerate.

### July 2023 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/ /diff_matrix_*_2021.txt`

Films scanned with this configuration:
- RUN1 W4 B2
- RUN3 W5 B1 P1-40

### December 2023 corrections
Matrices to be used in the linking:
`/eos/experiment/sndlhc/emulsionData/2022/ /diff_matrix_*_2021.txt`

Films scanned with this configuration:
- RUN3 W5 B1 P41-60 + rescans

### April 2024 (09) corrections 
There is no need to apply offline matrices, as `mean_matrix.bin` was used.

Films scanned with this configuration:
- RUN2 W2 B4 P54-57

### April 2024 (17) corrections 
There is no need to apply offline matrices, as `mean_matrix.bin` was used.

Films scanned with this configuration:
- RUN2 W2 B4 P1-54
- RUN2 W5 B3
