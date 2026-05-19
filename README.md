# 云原生持续交付部署平台
## 项目介绍
my-monitoring-deployment 是一套云原生持续交付自动化部署解决方案，基于 Jenkins 构建完整 CI/CD 流水线、Docker 完成应用容器化打包，
通过 Kubernetes (K3s) 实现容器编排与滚动更新部署；并依托流水线集成配置语法预检、代码冒烟测试、镜像构建推送、业务 HTTP 健康探测、
部署故障自动回滚与 Docker 冗余镜像自动清理能力，无缝对接自研全栈运维监控平台 my-monitoring-app，
实现 GitHub 代码提交后全自动构建、发布、故障兜底回滚的持续交付闭环。

## 线上流程运行实证

流水线全部在腾讯云服务器上真实运行，以下是三种典型场景的 Jenkins 控制台日志摘要，完整日志见 **[流水线详解](docs/cicd-pipeline.md)**。

### 质量门禁拦截
```log
FAILED tests/test_smoke.py::test_flask_startup
ModuleNotFoundError: No module named 'oss'
Stage "推送镜像" skipped due to earlier failure(s)
```

### 健康探测失败自动回滚
```log
curl 探测异常，服务不可用
kubectl rollout undo deployment/flask-app -n monitoring
deployment.apps/flask-app rolled back
```

### 全链路平稳发布上线
```log
Successfully tagged ...my-monitoring-app:git-74753aa
deployment "flask-app" successfully rolled out
Finished: SUCCESS
```

## 技术亮点

- **K8s 更新策略实战调优与自愈回滚**：结合 hostNetwork 主机网络模式下的端口占用冲突问题，主动切换为 Recreate 重建更新策略，实现服务稳定部署；联动 HTTP 存活探针实时探测服务健康状态，部署异常时自动触发版本回滚，保障线上业务不中断。
- **全流程质量门禁与自动化触发**：在 Jenkins 流水线中集成配置语法预检与 Pytest 冒烟测试双重质量关卡，前置拦截不通过直接终止流程；对接 GitHub WebHook，代码提交后自动拉起流水线，实现无人值守的持续交付闭环。
- **Docker 镜像全维度工程化优化**：采用 Alpine 轻量基础镜像与非 root 用户运行，遵循权限最小化原则；依赖与代码分层拷贝充分利用构建缓存，配置国内镜像源解决依赖拉取慢与超时问题；配套冗余镜像自动清理脚本，兼顾构建效率与服务器资源管控。

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

## 技术栈与实现

| 技术选型                 | 工程落地应用                                                                          |
|----------------------|---------------------------------------------------------------------------------|
| Jenkins              | 编写 Jenkinsfile 声明式流水线，配置语法预检、Pytest 冒烟测试、镜像构建推送阶段，设置质量门禁阻断异常代码                  |
| Docker               | 编写多阶段构建 Dockerfile，使用 Alpine 轻量基础镜像，非 root 用户运行，通过层缓存优化构建速度                     |
| K3s / Kubernetes     | 编写 Namespace、Deployment、Service 资源清单，配置 RollingUpdate 策略实现零停机滚动更新，HTTP 存活探针健康检查 |
| Shell                | 开发镜像构建推送脚本 `push-images.sh`，流水线中集成自动清理冗余镜像脚本                                    |
| Prometheus / Grafana | 对接自研监控平台，实现 CI/CD 流水线执行状态的可视化与告警（由 my-monitoring-app 承载）                        |
| Git / GitHub         | 采用功能分支开发模型，拆分 Docker、K8s、CI/CD 独立分支，代码提交触发全自动流水线                                |

## 快速开始

详细部署步骤、环境依赖与常见问题排查详见 **[部署文档](docs/deployment-guide.md)**。

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