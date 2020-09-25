## Overview
One of the ways my friends and I have been trying to contribute to COVID-19 research is through the [Folding@Home project](https://foldingathome.org/).  

Because there is nothing better than fake Internet points, we are often trying to squeeze out extra Work Units any way we can get them.  

One of the ways I have been doing that is with a [GitHub project](https://github.com/theonemule/fahclient-azure-vm) that provisions an Azure Linux VM and installs the Folding@Home client as well.  This template also stands up nginx properly configured so you can access the web-based client controls.

In an effort to learn more about Infrastructure as Code, I decided to take the existing ARM template and convert it to Terraform.

## Installation
1) If you do not have Terraform installed, follow the instuctions [here](https://www.terraform.io/downloads.html).
2) Clone the repository:

  `git clone https://github.com/seanmcgettrick/terraform-fahclient.git`

## Configuration
1) Edit terraform.tfvars.  At a minimum you must set **dnsName**, **adminUser**, and **adminPassword**. 

2) Optional variables include:

|Setting|Description|Default Value
|:--|:--|:--|
|resourcePrefix|Prefix for Azure resource naming|my-fah|
|location|Azure Region to deploy resources|eastus|
|fahUser|Folding@home Username|anonymous|
|fahTeam|Folding@home Team|0 (but I suggest 258829)|
|fahPasskey|Foldign@Home Passkey|Go to https://apps.foldingathome.org/getpasskey and set one|
|vmSize|VM Size|Standard_NV6 (1 Tesla M60 GPU)|
|spotVm|Use a Spot VM|false|
|spotVmMaxPrice|Max price before deallocating VM|-1 (no cap)|

## Provisioning
If you have not used Terraform before, this [documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-powershell) will show you how to get up and running.  After authenticating against Azure, the important steps are:
1) **terraform init**
2) **terraform plan**
3) **terraform apply**
4) **terraform destroy** (if you want to wipe everything out)

## Spot VM Support
Not all Azure regions have Spot VM capacity.  If you attempt to provision a Spot VM in a region without capacity, you will receive a [SkuNotAvailable error](https://docs.microsoft.com/en-us/azure/virtual-machines/error-codes-spot).

## Shameless Plug
Whether you ultimately make use of an Azure-based folding machine or just want to run the client at home on your own computers, we would love to have you over at [r00t f0lds](https://folding.extremeoverclocking.com/team_summary.php?s=&t=258829).  We recently just made it into the Top 50 teams and have stickers and challenge coins available for all team members.  Follow us [here](https://twitter.com/r00t0wns/) on Twitter.


## Credits
**Blaize**: For coming up with the [initial idea and ARM template](https://github.com/theonemule/fahclient-azure-vm), as well as the VM configuration script that installs the F@H client as well as configures nginx.

