# HiGHS
HiGHS - Linear optimization software is available at [ERGO-CODE/HiGHS](https://github.com/ERGO-Code/HiGHS).


Objective here is to dockerize HiGHS and be able to run it as a container service, on a cloud paltform -- a Solver-as-a-Service.


## Docker build for Mac M1 

  `docker build --progress=plain --platform=linux/amd64 -t highs/image .`

## Docker run
  
  `docker run --platform=linux/amd64 highs/image`
  
## Exporting  [MPS](https://www.gurobi.com/documentation/9.5/refman/mps_format.html) from open-source and commercial solvers [Reference](https://www.gurobi.com/resource/exporting-mps-files/).

  Exporting MPS files using the CBC Python API: Insert `s.writeMps(“model.mps”,0,2,0)` after you have built your model and right before the call of the optimization routine

