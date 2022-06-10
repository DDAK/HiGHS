# HiGHS
HiGHS - Linear optimization software is available at [ERGO-CODE/HiGHS](https://github.com/ERGO-Code/HiGHS).


Objective here is to dockerize HiGHS and be able to run it as a container on a cloud paltform as a service- a Solver-as-a-Service.


## Docker build for Mac M1 

  `docker build --progress=plain --platform=linux/amd64 -t highs/image .`

## Docker run
  
  `docker run --platform=linux/amd64 highs/image`
