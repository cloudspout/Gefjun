[
    {
      "name": "grafana",
      "image": "grafana/grafana:latest",
      "cpu": ${cpu},
      "memory": ${memory},
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "GF_SECURITY_ADMIN_USER",
          "value": "${admin_username}"
        },
        {
          "name": "GF_INSTALL_PLUGINS",
          "value": "https://github.com/cloudspout/cloudspout-button-panel/releases/download/1.0.2/cloudspout-button-panel.zip;cloudspout-button-panel"
        }
      ],
      "secrets": [
        {
          "name": "GF_SECURITY_ADMIN_PASSWORD",
          "valueFrom": "${admin_password-arn}"
        }
      ],
      "volumesFrom": [],
      "mountPoints": [
        {
          "containerPath": "/var/lib/grafana",
          "sourceVolume": "grafana-storage"
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