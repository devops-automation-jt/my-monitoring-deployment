# CI/CD 流水线详解
## 一、流水线核心能力
- 代码提交触发：GitHub WebHook 自动拉起构建
- 质量门禁：镜像构建阶段集成 pytest 冒烟测试，代码语法/依赖异常直接拦截后续流程
- 容器交付：自动构建镜像、推送至腾讯云 TCR 仓库
- 云原生部署：K3s 集群滚动更新发布
- 健康探测：部署后自动 HTTP 业务可用性检测
- 故障自愈：探测异常自动触发 K8s 版本回滚
- 资源清理：流水线后置自动清理冗余容器与镜像

## 二、流水线流转流程
```text
GitHub提交代码 → WebHook触发Jenkins → 拉取代码 → 语法预检+冒烟测试
→ 构建镜像 → 推送TCR仓库 → K3s滚动部署 → HTTP健康探测
→ 正常：部署完成 / 异常：自动回滚
```

## 三、核心场景日志佐证
### 3.1 冒烟测试拦截（代码异常直接终止流程）
关键失败节点：
```log
tests/test_smoke.py::test_flask_startup FAILED

app.py:7: ModuleNotFoundError: No module named 'oss'

AssertionError:  Flask服务启动失败：No module named 'oss'

FAILED tests/test_smoke.py::test_flask_startup
The command '/bin/sh -c PYTHONPATH=/app pytest tests/test_smoke.py -v' returned a non-zero code: 1

Stage "推送镜像" skipped due to earlier failure(s)
Stage "部署到K8s & 健康检查 & 自动回滚" skipped
```
效果：**冒烟测试失败，直接跳过镜像推送、K8s 部署全流程**，起到质量门禁作用。

### 3.2 健康检查失败 → K8s 自动回滚
回滚关键节点：
```log
==== HTTP 探测中：验证服务持续可用 ====
curl 探测异常，服务不可用
部署失败/健康检查不通过，执行自动回滚！
kubectl rollout undo deployment/flask-app --namespace=monitoring
deployment.apps/flask-app rolled back
```
效果：**业务健康探测不通过，流水线自动执行版本回滚，无需人工介入**。

### 3.3 代码正常全流程成功部署（已脱敏）

```log 
Started by user admin
[Pipeline] Start of Pipeline
[Pipeline] node
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (拉代码)
[Pipeline] git
Fetching changes from the remote Git repository
Checking out Revision 74753aae6c29c03ea364f2eb79b6bf6c49c3bd95
Commit message: "fix(docker):修复目录上下文路径"
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (配置语法校验)
==== 检查K8s部署文件语法（无实际部署，仅校验） ====
kubectl set image deployment/flask-app ... --dry-run=client
deployment.apps/flask-app image updated (dry run)
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (代码冒烟测试)
冒烟测试将在"构建镜像"阶段随 docker build 自动执行
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (构建镜像)
Sending build context to Docker daemon  1.538MB
Step 1/16 : FROM python:3.9-alpine3.21
Step 2/16 : RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
Step 3/16 : WORKDIR /app
Step 4/16 : ENV PYTHONUNBUFFERED=1     APP_PORT=your_port
Step 5/16 : RUN apk add --no-cache gcc musl-dev python3-dev linux-headers libc-dev openssh-client
Step 6/16 : RUN pip install --no-cache-dir ansible -i https://pypi.tuna.tsinghua.edu.cn/simple
Step 7/16 : COPY flask-backend/requirements.txt .
Step 8/16 : RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
Step 9/16 : RUN pip install --no-cache-dir pytest -i https://pypi.tuna.tsinghua.edu.cn/simple
Step 10/16 : COPY flask-backend/app.py .
Step 11/16 : COPY tests ./tests
Step 12/16 : RUN PYTHONPATH=/app pytest tests/test_smoke.py -v
tests/test_smoke.py::test_flask_startup PASSED
Step 13/16 : RUN addgroup -S flask-group && adduser -S flask-user -G flask-group
Step 14/16 : RUN chown -R flask-user:flask-group /app
Step 15/16 : USER flask-user
Step 16/16 : CMD ["python", "app.py"]
Successfully built 79269e7f4f0b
Successfully tagged ccr.ccs.tencentyun.com/devops-automation-jt/my-monitoring-app:git-74753aa
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (推送镜像)
Login Succeeded
The push refers to repository [ccr.ccs.tencentyun.com/devops-automation-jt/my-monitoring-app]
git-74753aa: digest: sha256:6b3b0955eb3927952db8e339b9dd6ca0c33c3332077e04e838b13c73e49394b1 size: 3664
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (部署到K8s & 健康检查 & 自动回滚)
kubectl set image deployment/flask-app ...
==== 健康检查中：等待服务启动 ====
deployment "flask-app" successfully rolled out
部署成功！当前镜像版本：git-74753aa
[Pipeline] }
[Pipeline] // stage

[Pipeline] stage
[Pipeline] { (Declarative: Post Actions)
docker system prune -f
[Pipeline] }
[Pipeline] // stage

[Pipeline] End of Pipeline
Finished: SUCCESS
```