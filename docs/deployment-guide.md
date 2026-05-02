# 部署指南
## 1. 前置环境要求
- Docker 版本：29.0.2
- Docker Compose 版本：v2.27.1
- Kubernetes 版本：K3s v1.34.4
- 说明：需提前配置腾讯云 TCR 仓库访问凭证，执行 `docker login ccr.ccs.tencentyun.com` 完成登录

## 2. 环境准备
### 2.1 克隆代码
```bash
git clone https://github.com/devops-automation-jt/my-monitoring-deployment
cd my-monitoring-deployment
```

### 2.2 环境校验
校验核心组件版本是否符合要求：
```bash
# 验证Docker版本
docker --version
# 验证Docker Compose版本
docker compose version
# 验证K3s版本
k3s --version
```

## 3. 部署方式（两种可选）
### 3.1 Docker Compose 本地快速部署（适合快速验证）
```bash
# 启动服务
docker-compose up -d

# 验证服务可用性
curl http://localhost:8080/health

# 停止服务
docker-compose down
```

### 3.2 Kubernetes 集群部署（生产级）
```bash
# 创建监控专用命名空间
kubectl apply -f k8s/namespace.yaml

# 部署应用与服务
kubectl apply -f k8s/flask-deployment.yaml -n monitoring
kubectl apply -f k8s/flask-service.yaml -n monitoring

# 验证部署状态
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 卸载部署
kubectl delete -f k8s/ -n monitoring
```

## 4. Jenkins CI/CD 流水线配置
### 4.1 必备插件
- GitHub Integration Plugin
- Pipeline Plugin
- Docker Plugin
- Kubernetes Plugin

### 4.2 流水线配置
1. 新建流水线任务，选择 `从SCM获取流水线脚本`
2. 仓库地址：`https://github.com/devops-automation-jt/my-monitoring-deployment`
3. 脚本路径：`ci-cd/Jenkinsfile`
4. 触发方式：配置 GitHub WebHook 实现代码提交自动构建部署

### 4.3 运行验证
```bash
# 查看Pod日志
kubectl logs -f [pod名称] -n monitoring
# 服务健康检查
curl http://[集群节点IP]:[暴露端口]/health
```

## 5. 常见问题排查
### 5.1 镜像推送失败
- 原因：TCR 仓库凭证错误或权限不足
- 解决：重新登录仓库 `docker login ccr.ccs.tencentyun.com`

### 5.2 流水线执行中断
- 原因：脚本未关闭异常退出机制
- 解决：在 Jenkinsfile 开头添加 `set +e`

### 5.3 K8s 应用异常
- 原因：镜像拉取失败/资源不足/配置错误
- 解决：执行 `kubectl describe pod [pod名称] -n monitoring` 排查详情