# HelloApples	

For the provision of the Apples app it is assumed that you have the environment set: 
* Azure subscription with a service principal which has the rights to create and manage AKS
* Terraform installed on your system
* kubectl command line utils
  

! Note that the script should be executes on a Windows machine with Powershell (tested on 5.1) with execution policy enabled and the required libraries installed!

For successfully provisioning the application, follow the steps below:
1.  Select the desired folder to work from and run **git init**. 
1.  Get the files from **"https://github.com/Andreyji/HelloApples.git new"**.
2.  Fill up the subscription_id, client_id, client_secret and tenant_id of your registered app and Azure subscription details
    in the vars.tf file.
3.  Execute **terraform init** then **terraform plan -out="."** in the local directory to which the repo is pulled.
4.  Run **terraform apply** to provision the resources on your Azure subscription.
5.  Execute **script.ps1** for running the application.
6.  Enjoy!
