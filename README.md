# 云原生持续交付平台
## 项目介绍
云原生持续交付平台：基于 Docker + Kubernetes + Jenkins 的自动化部署解决方案
本项目实现了一个完整的云原生应用交付流水线，将你现有的监控平台容器化，并自动化部署到 Kubernetes 集群中，通过 CI/CD 流水线实现代码变更后的自动构建与滚动更新。
my-monitoring-deployment/

## 目录结构
```plaintext
my-monitoring-deployment/
├── docker/                 # Dockerfile 和 docker-compose 配置
│   ├── flask-app/
│   │   └── Dockerfile
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   └── provisioning/
│   └── docker-compose.yaml
├── k8s/                    # Kubernetes 部署清单
│   ├── namespace.yaml
│   ├── configmap-prometheus.yaml
│   ├── pv-prometheus.yaml
│   ├── deployment-flask.yaml
│   ├── service-flask.yaml
│   ├── deployment-prometheus.yaml
│   └── ...                  # Grafana, ingress 等
├── ci-cd/                   # CI/CD 流水线脚本
│   ├── Jenkinsfile
│   └── .gitlab-ci.yml
├── docs/                    # 详细部署文档
│   ├── docker-setup.md
│   ├── k8s-setup.md
│   ├── jenkins-setup.md
│   └── ...
└── README.md                # 项目总览与快速开始
```
