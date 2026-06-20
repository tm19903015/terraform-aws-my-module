# ============================================================
# Terraform Backend Configuration: Remote State (prod)
# ============================================================
bucket  = "tm-tfstate-503782778940"
key     = "env/prod/terraform.tfstate"
region  = "ap-northeast-1"
encrypt = true
