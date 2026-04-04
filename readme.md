# Hybrid Cloud Identity Lab

Building an enterprise-grade hybrid identity environment using Azure, Terraform, and on-premises infrastructure.

## What this lab covers
- Azure infrastructure deployed via Terraform (IaC)
- Active Directory + Entra ID hybrid identity
- Microsoft Intune endpoint management
- Security hardening and PAM

## Architecture
- Virtual Network: 10.0.0.0/16 with management, identity, and endpoints subnets
- Remote state stored in Azure Blob Storage
- Infrastructure as Code — no portal clicks

## Completed Sessions
- Session 1: Environment setup, Azure provider, resource group deployed
- Session 2: Remote state, VNet, NSG, Windows Server 2022 VM deployed and verified via RDP

## Up Next
- Session 3: Active Directory Domain Services, domain controller deployment, hybrid identity
