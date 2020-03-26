[
    {
      "name": "grafana",
      "image": "grafana/grafana",
      "cpu": ${cpu},
      "memory": ${memory},
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "environment": [
        {
          "name": "GF_SECURITY_ADMIN_USER",
          "value": "${admin_username}"
        }
      ],
      "secrets": [
        {
          "name": "GF_SECURITY_ADMIN_PASSWORD",
          "valueFrom": "${admin_password-arn}"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "grafana-storage",
          "containerPath": "/var/lib/grafana"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]