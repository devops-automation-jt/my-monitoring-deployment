# 云原生持续交付部署平台
## 项目介绍
my-monitoring-deployment 是一套云原生持续交付自动化部署解决方案，基于 Jenkins 构建完整 CI/CD 流水线、Docker 完成应用容器化打包，
通过 Kubernetes (K3s) 实现容器编排与滚动更新部署；并依托流水线集成配置语法预检、代码冒烟测试、镜像构建推送、业务 HTTP 健康探测、
部署故障自动回滚与 Docker 冗余镜像自动清理能力，无缝对接自研全栈运维监控平台 my-monitoring-app，
实现 GitHub 代码提交后全自动构建、发布、故障兜底回滚的持续交付闭环。

## 目录结构
```plaintext
my-monitoring-deployment/
├── README.md                 # 项目总览
├── license.md                # 开源许可证
├── docker/                   # 容器化配置
│   ├── flask-app/            # Flask应用容器构建
│   │   ├── Dockerfile        # 镜像构建脚本
│   │   └── requirements.txt  # Python依赖清单
│   ├── prometheus/           # Prometheus配置
│   │   └── prometheus.yml    # 时序数据配置
│   ├── docker-compose.yaml   # 容器编排文件
│   └── push-images.sh        # 镜像构建推送脚本
├── k8s/                      # K8s部署清单
│   ├── namespace.yaml        # 命名空间配置
│   ├── flask-deployment.yaml # 应用部署配置
│   └── flask-service.yaml    # 服务暴露配置
├── ci-cd/                    # CI/CD流水线配置
│   └── Jenkinsfile           # 自动化流水线脚本
├── docs/                     # 项目文档
│   ├── deployment-guide.md   # 部署指南
│   ├── architecture/         # 架构相关
│   │    └── arch.png         # 极简架构图
│   ├── cicd-pipeline.md      # 流水线详解
│   └── possible_problems.md  # 常见问题
```

## 核心技术栈
| 模块         | 技术选型       | 选型原因                                  |
|--------------|----------------|-------------------------------------------|
| 自动化构建   | Jenkins        | 企业级CI/CD工具，支持流水线编排、阶段拦截，插件生态完善 |
| 容器化       | Docker         | 标准化应用打包，环境隔离，保证开发、测试、生产环境一致性 |
| 轻量编排     | K3s            | 轻量化K8s发行版，资源占用低，适配个人学习与小规模生产部署 |
| 容器编排     | Kubernetes     | 原生支持滚动更新、健康探针、版本回滚，是云原生部署标准方案 |
| 流水线能力   | 冒烟测试/健康检查 | 前置质量门禁，上线前拦截代码语法、依赖异常，降低发布故障风险 |

## 核心功能
1. 全自动CI/CD流水线：GitHub代码提交触发，完成拉代码、语法校验、冒烟测试全流程；
2. 容器化标准化交付：Docker镜像打包，统一环境依赖，支持Compose本地快速启动；
3. 云原生滚动部署：基于K3s实现服务无停机滚动更新，保障业务高可用；
4. 质量门禁拦截：构建阶段集成Pytest冒烟测试，代码异常直接阻断后续推送部署；
5. 故障自愈兜底：部署后HTTP健康探测失败，自动执行K8s版本回滚至上一稳定版本；
6. 自动化资源清理：流水线后置自动清理Docker冗余容器与镜像，节省服务器磁盘资源。

## 快速开始
### 环境准备
- Linux虚拟机（CentOS 7+/Ubuntu 20.04+）；
- Docker 20+ / Docker Compose v2；
- K3s 轻量级K8s集群；
- Jenkins 2.400+；
- Python 3.9+。

### 快速部署
```bash
# 克隆代码
git clone https://github.com/devops-automation-jt/my-monitoring-deployment.git
cd my-monitoring-deployment

# 构建并推送应用镜像
bash docker/push-images.sh

# 本地容器化启动测试
docker-compose -f docker/docker-compose.yaml up -d

# 部署至K3s集群
kubectl apply -f k8s/
```

### 核心分支说明
| 分支名                | 功能说明                                  |
|-----------------------|-------------------------------------------|
| feature/docker-setup    | Docker容器化构建、编写镜像构建与推送脚本 |
| feature/k8s-deployment  | 编写K3s命名空间、部署、Service全套资源清单 |
| feature/jenkins-cicd    | 编写Jenkinsfile流水线，实现测试、构建、部署、回滚全流程 |
| feature/docs-completion | 整理项目架构、部署指南、流水线详解与常见问题文档 |

## 文档入口
- 部署文档：[deployment-guide.md](docs/deployment-guide.md)
- 流水线详解：[cicd-pipeline.md](docs/cicd-pipeline.md)
- 常见问题排查：[possible_problems.md](docs/possible_problems.md)