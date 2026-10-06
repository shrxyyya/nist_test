# Copyright IBM Corp. 2026

policytest {
  targets = ["network-firewall-should-be-deployed-across-multiple-azs.policy.hcl"]
}

resource "aws_networkfirewall_firewall" "two_azs" {
  attrs = {
    name                = "fw"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    transit_gateway_id  = "tgw-0123456789abcdef0"
    availability_zone_mapping = [
      { availability_zone_id = "use1-az1" },
      { availability_zone_id = "use1-az2" }
    ]
  }
}

resource "aws_networkfirewall_firewall" "three_azs" {
  attrs = {
    name                = "fw"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    transit_gateway_id  = "tgw-0123456789abcdef0"
    availability_zone_mapping = [
      { availability_zone_id = "use1-az1" },
      { availability_zone_id = "use1-az2" },
      { availability_zone_id = "use1-az3" }
    ]
  }
}

resource "aws_networkfirewall_firewall" "one_az" {
  expect_failure = true
  attrs = {
    name                = "fw"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    transit_gateway_id  = "tgw-0123456789abcdef0"
    availability_zone_mapping = [
      { availability_zone_id = "use1-az1" }
    ]
  }
}

resource "aws_networkfirewall_firewall" "empty_mapping" {
  expect_failure = true
  attrs = {
    name                      = "fw"
    firewall_policy_arn       = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    availability_zone_mapping = []
  }
}

resource "aws_networkfirewall_firewall" "null_mapping" {
  expect_failure = true
  attrs = {
    name                      = "fw"
    firewall_policy_arn       = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    availability_zone_mapping = null
  }
}

resource "aws_networkfirewall_firewall" "absent_mapping" {
  expect_failure = true
  attrs = {
    name                = "fw"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
  }
}

