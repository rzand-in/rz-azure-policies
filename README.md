# rz-azure-policies
Investigating an easy way to implement and manage Azure policies.

## Purpose
I found the Azure policies management difficult to maintain.

The Microsoft Landing Zones repositories manage the policy in a way that is not easy for me to understand.

I find it difficult to have a picture of which policies are attached to what with the above-mentioned repositories.

I quickly looked at the Microsoft [Enterprise Policy As Code (EPAC)](https://azure.github.io/enterprise-azure-policy-as-code/) once and I found it a bit difficult as well.

So I want to try an idea of using az cli, bash script and a file system structure to manage Azure policies.

## The idea
The idea is to represent the Azure Management Groups structure in a file system directory structure, add in the folder the policies details or just the name of the policy to assign and have a script to do the job.




