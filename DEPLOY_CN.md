# new-api 一键化部署（简体中文）

> 适用于 Ubuntu/CentOS/Debian 等已安装 Docker 的 Linux 服务器。

## 一键部署

在服务器执行：

```bash
git clone https://github.com/QuantumNous/new-api.git
cd new-api
chmod +x deploy-oneclick.sh
./deploy-oneclick.sh
```

默认会自动：

- 克隆/更新项目目录
- 生成随机数据库与 Redis 密码
- 基于 `docker-compose.yml` 生成运行配置
- 启动 `new-api + redis + postgres`

部署完成后访问：

- `http://服务器IP:3000`

## 可选参数（按需）

### 1) 自定义安装目录

```bash
PROJECT_DIR=/opt/new-api ./deploy-oneclick.sh
```

### 2) 使用 MySQL

```bash
DB_TYPE=mysql ./deploy-oneclick.sh
```

### 3) 指定时区

```bash
TZ_VALUE=Asia/Shanghai ./deploy-oneclick.sh
```

### 4) 固定密码（生产环境建议自行管理）

```bash
DB_PASSWORD='YourStrongDBPass' REDIS_PASSWORD='YourStrongRedisPass' ./deploy-oneclick.sh
```

## 运维命令

```bash
cd ~/new-api

docker compose -f docker-compose.override.yml ps
docker compose -f docker-compose.override.yml logs -f new-api

docker compose -f docker-compose.override.yml pull
docker compose -f docker-compose.override.yml up -d
```
