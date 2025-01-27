resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}
resource "aws_route_table" "vpc_rtb" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc_igw.id
    }

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
}

resource "aws_route_table_association" "rtba_subnet_1" {
  route_table_id = aws_route_table.vpc_rtb.id
  subnet_id      = aws_subnet.subnet_1.id
}

resource "aws_route_table_association" "rtba_subnet_2" {
  route_table_id = aws_route_table.vpc_rtb.id
  subnet_id      = aws_subnet.subnet_2.id
}

resource "aws_route_table_association" "rtba_subnet_3" {
  route_table_id = aws_route_table.vpc_rtb.id
  subnet_id      = aws_subnet.subnet_3.id
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  tags = var.tags
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = data.aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.task_family
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode(var.cont_definitions)
  tags                  = var.tags
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.container_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  tags            = var.tags

  network_configuration {
    assign_public_ip = true
    subnets         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
    security_groups = [aws_security_group.allow_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = var.container_name
    container_port   = 8080
  }
}

resource "aws_lb" "ecs_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name     = "ecs-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_api" "ecs_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  tags = var.tags
  cors_configuration {
    allow_credentials = var.cors_configuration.allow_credentials
    allow_headers     = var.cors_configuration.allow_headers
    allow_methods     = var.cors_configuration.allow_methods
    allow_origins     = var.cors_configuration.allow_origins
    expose_headers    = var.cors_configuration.expose_headers
    max_age           = var.cors_configuration.max_age
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.ecs_api.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy
}

resource "aws_apigatewayv2_route" "ecs_api_route" {
  api_id    = aws_apigatewayv2_api.ecs_api.id
  route_key = "GET /sports"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
  authorization_type = var.authorization_type
}

resource "aws_apigatewayv2_integration" "ecs_integration" {
  api_id                  = aws_apigatewayv2_api.ecs_api.id
  integration_type        = var.integration_type
  integration_uri         = var.integration_uri
  integration_method      = var.integration_method
}