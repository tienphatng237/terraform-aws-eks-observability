variable "project_name" { 
    type = string 
    }

variable "oidc_provider_arn" { 
    type = string 
    }

variable "cluster_openid_issuer" { 
    type = string 
    }

variable "namespace" { 
    type = string 
    default = "observability" 
    }

variable "loki_s3_bucket" { 
    type = string 
    default = "" 
    }

variable "tempo_s3_bucket" { 
    type = string
    default = "" 
    }