variable "resourcePrefix" {
    type = string
    description = "Prefix for Azure resource naming"
    default = "my-fah"
}

variable "location" {
    type = string
    description = "Location to deploy Azure resources"
    default = "eastus"
}

variable "dnsName" {
    type = string
    description = "DNS prefix for the host"
}

variable "adminUser" {
    type = string
    description = "VM User for SSH and FAH Web Client"
}

variable "adminPassword" {
    type = string
    description = "VM Password for FAH Web Client"
}

variable "fahUser" {
    type = string
    description = "FAH Client username"
    default = "anonymous"
}

variable "fahTeam" {
    type = string
    description = "FAH Client team number"
    default = "0"
}

variable "fahPasskey" {
    type = string
    description = "FAH Client passkey"
    default = ""
}

variable "vmSize" {
    type = string
    description = "VM Size"
    default = "Standard_NV6"
}

variable "spotVm" {
    type = bool
    description = "Use Spot VM"
    default = false
}

variable "spotVmMaxPrice" {
    type = string
    description = "The max price to pay for a Spot VM before eviction"
    default = "-1"
}