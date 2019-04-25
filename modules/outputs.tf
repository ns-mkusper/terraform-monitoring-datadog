#
# Outputs
# https://www.terraform.io/docs/configuration/outputs.html
#
output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}
output "subnet_ids" {
    value = ["${module.vpc.public_subnets}"]
}
output "instance_id" {
    value = "${aws_instance.monitor_host.id}"
}
output "instance_ip" {
    value = "${aws_instance.monitor_host.public_ip}"
}
output "datadog_common_foo_monitor_id" {
    value = "${datadog_monitor.foo.id}"
}
