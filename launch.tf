
# resource "aws_ami_from_instance" "amis" {
#     name = "naveen-ami"
#     source_instance_id = aws_instance.server[0].id

# }
# resource "aws_launch_template" "stack" {
#     name_prefix = var.name_prefix
#     image_id = aws_ami_from_instance.amis.id
#     instance_type = var.instance_type
#     network_interfaces {
#       associate_public_ip_address = true
#       subnet_id = aws_subnet.public[0].id
#       security_groups = [aws_security_group.sg.id]
#     }
#     tag_specifications {
#       resource_type = "instance"
#       tags = {
#         Name= "${var.vpc_name}-naveen"
#       }
#     }

# }

# resource "aws_autoscaling_group" "shankar" {
#     launch_template {
#       id = aws_launch_template.stack.id
#       version = "$Latest"
#     }
#     min_size = 2
#     max_size = 5
#     desired_capacity = 2
#     vpc_zone_identifier = var.azs
#     target_group_arns = [aws_lb_target_group.ram.arn]
#      tag {
#     key                 = "Name"
#     value               = "naveen-asg"
#     propagate_at_launch = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_policy" "scaleout" {
#     name = "scaleout"
#     scaling_adjustment = 1
#     adjustment_type = "ChangeCapacity"
#     autoscaling_group_name = aws_autoscaling_group.shankar.name


# }

# resource "aws_autoscaling_policy" "scalein" {
#     name = "scalein"
#     scaling_adjustment = -1
#     adjustment_type = "ChangeCapacity"
#     autoscaling_group_name = aws_autoscaling_group.shankar.name


# }

# resource "aws_cloudwatch_metric_alarm" "scaleout_alarm" {
#   alarm_name          = "scaleout-alarm"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300  # 5-minute period
#   statistic           = "Average"
#   threshold           = 80  # 80% CPU utilization threshold
#   alarm_description   = "Alarm when CPU usage is over 80% for 5 minutes"
#   alarm_actions       = [aws_autoscaling_policy.scaleout.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.shankar.name
#   }
# }

# # CloudWatch Alarm for Scale-In Policy
# resource "aws_cloudwatch_metric_alarm" "scalein_alarm" {
#   alarm_name          = "scalein-alarm"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300  # 5-minute period
#   statistic           = "Average"
#   threshold           = 20  # 20% CPU utilization threshold
#   alarm_description   = "Alarm when CPU usage is under 20% for 5 minutes"
#   alarm_actions       = [aws_autoscaling_policy.scalein.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.shankar.name
#   }
# }