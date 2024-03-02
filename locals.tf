locals {
  name = "aws-${var.team}-${var.env}-${var.app}-rtype-${var.project}"
  common_tags = {
    Environment = var.env
    Team        = var.team
    Application = var.app
    Managed_By  = var.managed_by
    Owner       = var.owner
  }
}