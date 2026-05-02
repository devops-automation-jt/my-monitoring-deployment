#!/bin/bash
# push-images.sh - 构建并推送Flask监控镜像到腾讯云镜像仓库
# 适配仓库：ccr.ccs.tencentyun.com/devops-automation-jt/flask-monitor

IMAGE_REPO="ccr.ccs.tencentyun.com/devops-automation-jt/flask-monitor"
# 镜像版本标签（可自定义，比如v1、v2、latest）
IMAGE_TAG="v1"
# Flask应用Dockerfile所在目录（相对于当前脚本的路径）
DOCKERFILE_DIR="./flask-app"

# ====================== 脚本核心逻辑 ======================
set -e  # 任意步骤失败则立即退出脚本

# 1. 检查Dockerfile是否存在
if [ ! -f "${DOCKERFILE_DIR}/Dockerfile" ]; then
    echo " 错误：在 ${DOCKERFILE_DIR} 目录下未找到Dockerfile！"
    echo "请确认Dockerfile路径正确（应该在 my-monitoring-deployment/docker/flask-app/ 下）"
    exit 1
fi

# 2. 登录腾讯云镜像仓库（如果未登录，会提示输入账号密码）
echo " 正在登录腾讯云镜像仓库..."
docker login ccr.ccs.tencentyun.com || {
    echo " 登录腾讯云镜像仓库失败！"
    echo "请检查："
    echo "  1. 腾讯云账号是否已实名认证"
    echo "  2. 镜像仓库密码是否正确（在腾讯云控制台「访问凭证」里设置）"
    exit 1
}

# 3. 构建Flask镜像
echo "  正在构建Flask镜像：${IMAGE_REPO}:${IMAGE_TAG}..."
docker build -t "${IMAGE_REPO}:${IMAGE_TAG}" "${DOCKERFILE_DIR}" || {
    echo " 镜像构建失败！"
    echo "请检查Dockerfile语法/依赖安装是否正确"
    exit 1
}

# 4. 推送镜像到腾讯云仓库
echo " 正在推送镜像到腾讯云仓库..."
docker push "${IMAGE_REPO}:${IMAGE_TAG}" || {
    echo " 镜像推送失败！"
    echo "请检查："
    echo "  1. 仓库名称/命名空间是否正确（devops-automation-jt/flask-monitor）"
    echo "  2. 网络是否正常（国内网络需确保能访问腾讯云）"
    exit 1
}

# 5. 推送成功提示
echo -e "\n 镜像推送成功！"
echo "镜像地址：${IMAGE_REPO}:${IMAGE_TAG}"
echo "可通过以下命令拉取：docker pull ${IMAGE_REPO}:${IMAGE_TAG}"

# 可选：登出镜像仓库（如需保留登录状态，可注释这行）
# docker logout ccr.ccs.tencentyun.com

exit 0