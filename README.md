# 云原生持续交付平台
## 项目介绍
云原生持续交付平台：基于 Docker + Kubernetes + Jenkins 的自动化部署解决方案
本项目实现了一个完整的云原生应用交付流水线，将你现有的监控平台容器化，并自动化部署到 Kubernetes 集群中，通过 CI/CD 流水线实现代码变更后的自动构建与滚动更新。
my-monitoring-deployment/

## 目录结构
```plaintext
my-monitoring-deployment/
├── docker/                                   # 容器化部署核心目录，包含所有Docker相关配置
│   ├── flask-app/                            # Flask监控指标采集应用的容器构建目录
│   │   ├── Dockerfile                       # 自定义Flask镜像构建脚本：封装应用代码、依赖与运行环境
│   │   └── requirements.txt                 # Flask应用依赖清单：定义监控所需Python包（Flask/prometheus-client/ansible等）
│   ├── prometheus/                          # Prometheus指标存储配置目录
│   │   └── prometheus.yml                   # Prometheus核心配置文件：定义指标抓取目标、间隔与存储规则
│   ├── docker-compose.yaml                  # Docker Compose全链路编排文件：整合Flask采集+Prometheus存储+Grafana可视化，实现一键启动
│   └── push-images.sh                       # Flask镜像自动化脚本：一键构建镜像并推送至腾讯云容器镜像仓库（TCR）
├── k8s/                    # Kubernetes部署清单（预留，后续周任务扩展）
│   ├── namespace.yaml      # 监控专用命名空间
│   ├── configmap-prometheus.yaml # Prometheus配置挂载
│   ├── pv-prometheus.yaml  # Prometheus数据持久化
│   ├── deployment-flask.yaml # Flask Deployment
│   ├── service-flask.yaml  # Flask Service（集群内访问）
│   ├── deployment-prometheus.yaml # Prometheus Deployment
│   ├── service-prometheus.yaml # Prometheus Service
│   ├── deployment-grafana.yaml # Grafana Deployment
│   ├── service-grafana.yaml # Grafana Service
│   └── ingress-monitoring.yaml # 外网访问Ingress（可选）
├── ci-cd/                  # CI/CD流水线（预留，后续周任务扩展）
│   ├── Jenkinsfile         # Jenkins自动化构建/部署流水线
│   └── .gitlab-ci.yml      # GitLab CI备选方案
├── docs/                   # 部署文档（分维度，清晰易懂）
│   ├── docker-setup.md     # Docker+Compose部署步骤（第三周核心）
│   ├── k8s-setup.md        # K8s部署步骤（后续扩展）
│   ├── jenkins-setup.md    # CI/CD流水线配置（后续扩展）
│   └── faq.md              # 常见问题（容器化/部署相关）
└── README.md               # 项目总览：云原生持续交付平台+快速开始
```
