### EC2 Generation in Terraform

#### Usage

##### Startup
To create the environment, you can run `source scripts/start.sh`. If the environment has already been created, this will activate it.

```
source scripts/start.sh #create conda environment or select it if already made
```

We can then startup the instance with `up.sh`, which will ask which workspace and which config file you would like to use.

```
./scripts/up.sh # asks for variable file and workspace name as user inputs
Terraform workspace? [default]: my-workspace-name
Variable file path? [None]: my-env.tfvars
```

#####


Make it quick to start up an instance with correct settings that is on the platform I currently need to debug in.

TODO
 - Allow users (me) to replace userdata script or concat their own onto the stock one