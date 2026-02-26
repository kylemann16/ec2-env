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

##### Connect

To connect to your instance via SSH run. This will open a SSH terminal to either
`bash` or `powershell`, depending on the system.

```
./scripts/connect.sh
```

To connect to a windows via remote desktop, you can find the file `ec2_env.rdb` in `.secrets/{workspace}/`. You can use this configuration to connect to a windows instance via RDP, or if you are on Mac and have the Windows App, you can just open this file and the Windows App will automatically connect you.

To get the password for your windows instance, you can run

```
./scripts/win_pass.sh
```

which will produce the output

```
Username: {external_ip}.{ec2_region}.compute.amazonaws.com\Administrator
Password: {password}
```

##### Workspaces

Terraform allows you to create multiple workspaces, meaning you can have multiple implementations of the same architecture. When you run the `up` or `down` scripts, you will be asked for the workspace you want (Defaults to `default`), and then a path to a terraform variables file.

Make sure that when you're destroying your architecture that you have the correct workspace and variable file selected or things could get wonky.