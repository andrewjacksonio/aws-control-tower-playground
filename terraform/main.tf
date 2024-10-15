

locals {
  control_names = [
    "AWS-GR_SNS_CHANGE_PROHIBITED",
    "AWS-GR_CT_AUDIT_BUCKET_LIFECYCLE_CONFIGURATION_CHANGES_PROHIBITED",
    "AWS-GR_SNS_SUBSCRIPTION_CHANGE_PROHIBITED",
    "AWS-GR_CT_AUDIT_BUCKET_ENCRYPTION_CHANGES_PROHIBITED",
    "AWS-GR_CLOUDTRAIL_VALIDATION_ENABLED",
    "AWS-GR_CLOUDTRAIL_CLOUDWATCH_LOGS_ENABLED",
    "AWS-GR_IAM_ROLE_CHANGE_PROHIBITED",
    "AWS-GR_CT_AUDIT_BUCKET_LOGGING_CONFIGURATION_CHANGES_PROHIBITED",
    "AWS-GR_CONFIG_AGGREGATION_CHANGE_PROHIBITED",
    "AWS-GR_LOG_GROUP_POLICY",
    "AWS-GR_CONFIG_ENABLED",
    "AWS-GR_LAMBDA_CHANGE_PROHIBITED",
    "AWS-GR_DETECT_CLOUDTRAIL_ENABLED_ON_SHARED_ACCOUNTS",
    "AWS-GR_CONFIG_AGGREGATION_AUTHORIZATION_POLICY",
    "AWS-GR_CT_AUDIT_BUCKET_POLICY_CHANGES_PROHIBITED",
    "AWS-GR_CLOUDTRAIL_CHANGE_PROHIBITED",
    "AWS-GR_CLOUDWATCH_EVENTS_CHANGE_PROHIBITED",
    "AWS-GR_AUDIT_BUCKET_DELETION_PROHIBITED",
    "AWS-GR_CONFIG_CHANGE_PROHIBITED",
    "AWS-GR_AUDIT_BUCKET_PUBLIC_READ_PROHIBITED"
  ]
}

data aws_region current {}

data aws_organizations_organization andrewjacksonio {}

data aws_organizations_organizational_units root {
  parent_id = data.aws_organizations_organization.andrewjacksonio.roots[0].id
}

resource aws_organizations_account security {
  name              = var.org_accounts[0].name
  email             = var.org_accounts[0].email
  parent_id         = data.aws_organizations_organizational_units.root.id
  close_on_deletion = true
}

resource aws_organizations_account sandbox {
  name              = var.org_accounts[1].name
  email             = var.org_accounts[1].email
  parent_id         = data.aws_organizations_organizational_units.root.id
  close_on_deletion = true
}

resource aws_controltower_control andrewjacksonio {
  for_each = toset(local.control_names)

  target_identifier  = data.aws_organizations_organization.andrewjacksonio.arn
  control_identifier = "arn:aws:controltower:${data.aws_region.current.name}::control/${each.value}"
}

resource aws_controltower_landing_zone andrewjacksonio {
  version       = "3.3"
  manifest_json = templatefile(
    "${path.module}/LandingZoneManifest.json.tftpl",
    {
      aws_region          = data.aws_region.current.name,
      security_account_id = aws_organizations_account.security.id,
      logging_account_id  = aws_organizations_account.sandbox.id
    }
  )
}