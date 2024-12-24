resource "aws_ami_from_instance" "amis" {
  name               = "naveen-ami"
  source_instance_id = aws_instance.server[0].id
  tags = {
    Name = "${var.vpc_name}-ami"
  }

}

#create launch template

resource "aws_launch_template" "naveen-shankar" {
  name = "shankar"

  image_id = aws_ami_from_instance.amis.id

  instance_initiated_shutdown_behavior = "terminate"



  instance_type = "t2.micro"

  key_name = "naveen"


  monitoring {
    enabled = true
  }

  # Remove network_interfaces block
  network_interfaces {
    security_groups = [aws_security_group.sg.id]
  }
  vpc_security_group_ids = [aws_security_group.sg.id] # Define security group here




  placement {
    availability_zone = "us-east-2a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }


}
resource "aws_autoscaling_group" "prod" {
  availability_zones = ["us-east-2a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1


  launch_template {
    id      = aws_launch_template.naveen-shankar.id
    version = "$Latest"
  }
}



# resource "aws_autoscaling_policy" "scaleout" {
#     name = "scaleout"
#     scaling_adjustment = 1
#     adjustment_type = "ChangeCapacity"
#     autoscaling_group_name = aws_autoscaling_group.prod.name


# }

# resource "aws_autoscaling_policy" "scalein" {
#     name = "scalein"
#     scaling_adjustment = -1
#     adjustment_type = "ChangeCapacity"
#     autoscaling_group_name = aws_autoscaling_group.prod.name


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
#     AutoScalingGroupName = aws_autoscaling_group.prod.name
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
#     AutoScalingGroupName = aws_autoscaling_group.prod.name
#   }
# }

