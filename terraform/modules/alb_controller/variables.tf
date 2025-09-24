variable "project_name" { 
    type = string 
    }

variable "region" { 
    type = string 
    }

variable "cluster_name" { 
    type = string 
    }

variable "vpc_id" { 
    type = string 
    }

variable "oidc_provider_arn" { 
    type = string 
    }

variable "namespace" { 
    type = string
    default = "kube-system" 
    }