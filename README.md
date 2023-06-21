# HelloApples	

Structure:

The app is being provisioned on AKS, using 2 single poded (for the moment) deployments,
**first** of which is the Mongo DB mounting the data from the **data.json** file and 
**the second** is the node.js app itself that simply presents the webpage on the provisioned address 
using one argument from the "fruits" collection to ensure successfull connection.
Also there is a secret for db credentials and a Load Balancer service to expose it all.

Note that there are two stages of provision: one to create the resources on AKS
and the other (running the script) to setup the app itself.

Instructions follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For the provision of the Apples app it is assumed that you have the environment set: 
* Azure subscription with an app registration, which has the rights to create and manage AKS
* Terraform installed on your system
* kubectl command line utils
  

! Note that the script should be executes on Powershell (tested on 5.1) with execution policy
  enabled and the required libraries installed!

For successfully provisioning the application, follow the steps below:
1.  Select the desired folder to work from and run **git init**. 
2.  Get the files from **"https://github.com/Andreyji/HelloApples.git new"**.
3.  Fill up the subscription_id, client_id, client_secret and tenant_id of your registered app
    and Azure subscription details in the **vars.tf** file.
4.  Execute **terraform init** then **terraform plan** on the directory to which the repo is pulled.
5.  Run **terraform apply** to provision the resources on your Azure subscription.
6.  Execute **script.ps1** for running the application.
7.  Enjoy!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
