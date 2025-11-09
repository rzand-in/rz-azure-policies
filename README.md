# rz-azure-policies
Investigating an easy way to implement and manage Azure policies.

## Purpose
I found the Azure policies management difficult to maintain.

The Microsoft Landing Zones repositories manage the policies in a way that is not easy for me to understand.

I find difficult to have a picture of which policies are attached to what with the above-mentioned repositories.

I quickly looked at the Microsoft [Enterprise Policy As Code (EPAC)](https://azure.github.io/enterprise-azure-policy-as-code/) once and I found it also difficult.

I wondered if instead of using time and energy to understand how the mentioned solution work can be better ised in creating my own solution. My idea is of using something easy to undestantand and universaly available like bash scripts and az cli commands and a file system structure to manage Azure policies.

## The idea
The idea is to represent the Azure Management Groups structure in a file system directory structure, add in the folder the policies details or just the name of the policy to assign and have a script to do the job.

## The steps
A short script, easy to customize can create the file system directory structure.
Another script can read the file system and create the management groups and attach policies to them.

The linux command tree would show the Management Group tree

tree rzand-li/
rzand-li/
├── decomissioned
├── landingzones
├── platform
│   ├── connectivity
│   ├── identity
│   ├── management
│   └── security
└── sandbox

where the directory names are the management group to be created and contain the az cli command files that can deploy the policies.

First difficulty is to programmatically place the policies in the folder. These should be files that can be executed to assign the policy.

** Decision: lets only assign Initiatives (policy set) as also reccomended at https://www.azurecitadel.com/policy/basics/dine/ :
> Our recommendation would be to always assign initiatives, even if it contains only one policy. If > you modify that initiative, adding, removing or modifying the constituent policies, then they will > be auto-assigned to the correct scope.

So lets find all the Initiatives that are not deprecated:
```
az policy set-definition list --query "[?!(contains(displayName, 'Deprecated'))].{Name:name, DisplayName:displayName}" -o table 
```
Adding the 
```
| wc -l
```
we can see that we have 131 Initiatives.

We need to find a way to automate the creation of the files that assign the Initiatives.
```
INITIATIVES_NAMES=$(az policy set-definition list --query "[?!(contains(displayName, 'Deprecated'))].name" -o tsv)
```
Then for each of the initiatives we need to get some information to put in files. The information are displayName, description and the parameters with their default values.
