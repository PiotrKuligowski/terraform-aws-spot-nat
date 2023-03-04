module "this" {
  source                    = "git::https://github.com/PiotrKuligowski/terraform-aws-spot-asg.git"
  ami_id                    = var.ami_id
  ssh_key_name              = var.ssh_key_name
  subnet_ids                = var.subnet_ids
  vpc_id                    = var.vpc_id
  user_data                 = local.user_data
  policy_statements         = local.required_policy
  project                   = var.project
  component                 = var.component
  tags                      = var.tags
  instance_type             = var.instance_type
  security_groups           = var.security_groups
  disable_source_dest_check = true
}

# LOCALS ----------------------------------------------------------------------

locals {
  user_data = <<-EOT
#!/bin/bash
echo '#!/bin/bash
if [[ $(iptables -t nat -L) != *"MASQUERADE"* ]]; then
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -s ${var.vpc_cidr} -j MASQUERADE
fi
' | tee /etc/network/if-pre-up.d/nat-setup
chmod +x /etc/network/if-pre-up.d/nat-setup
/etc/network/if-pre-up.d/nat-setup
  EOT

  required_policy = {
    AllowEC2Modification = {
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances",
        "ec2:ModifyInstanceAttribute"
      ]
      resources = ["*"]
    }
  }
}