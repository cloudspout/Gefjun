[
    {
      "name": "influxdb",
      "image": "influxdb:1.6",
      "cpu": ${cpu},
      "memory": ${memory},
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8086,
          "hostPort": 8086
        }
      ],
      "environment": [
        {
          "name": "INFLUXDB_DB",
          "value": "${db_name}"
        },
        {
          "name": "INFLUXDB_HTTP_AUTH_ENABLED",
          "value": "true"
        },
        {
          "name": "INFLUXDB_ADMIN_USER",
          "value": "${admin_username}"
        },
        {
          "name": "INFLUXDB_READ_USER",
          "value": "${grafana_username}"
        },
        {
          "name": "INFLUXDB_WRITE_USER",
          "value": "${lambda_username}"
        }
      ],
      "secrets": [
        {
          "name": "INFLUXDB_ADMIN_PASSWORD",
          "valueFrom": "${admin_password-arn}"
        },
        {
          "name": "INFLUXDB_READ_USER_PASSWORD",
          "valueFrom": "${grafana_password-arn}"
        },
        {
          "name": "INFLUXDB_WRITE_USER_PASSWORD",
          "valueFrom": "${lambda_password-arn}"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "influxdb-storage",
          "containerPath": "/var/lib/influxdb"
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