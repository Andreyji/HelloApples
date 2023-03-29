# HelloApples


Greetings!

For successful provisioning of the Apples web application on your AKS
you should have the following:
- Azure subscription and an app registered on it,
  with the permissions of creating an AKS cluster.
- Terraform installed 
- Git installed and a local directory for the files


Then just go through the following steps:

* Clone the code from this repo to your localhost:
  + git clone https://github.com/Andreyji/HelloApples.git
* Insert the values of your Azure authentication (service principle) in the vars.tf file.
* Using your local terminal (Powershell on windows), run a terraform init on the cloned directory
* verify the files:
  + terraform plan
* provision the application:
  + terraform apply

Should be good to go!
Verify the provisioning through your web browser.

