[
    {
      "name": "grafana",
      "image": "grafana/grafana:latest-ubuntu",
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
        },
        {
          "name": "GF_INSTALL_PLUGINS",
          "value": "https://cloudspout.bintray.com/cloudspout-button-panel/cloudspout-button-panel_1.0.0.zip"
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