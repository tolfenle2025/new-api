#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-"$HOME/new-api"}
REPO_URL=${REPO_URL:-"https://github.com/QuantumNous/new-api.git"}
BRANCH=${BRANCH:-"main"}
PORT=${PORT:-3000}
DB_TYPE=${DB_TYPE:-postgres}
DB_PASSWORD=${DB_PASSWORD:-$(openssl rand -hex 12)}
REDIS_PASSWORD=${REDIS_PASSWORD:-$(openssl rand -hex 12)}
TZ_VALUE=${TZ_VALUE:-UTC}

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker 未安装，请先安装 Docker。"
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "[ERROR] 未找到 docker compose / docker-compose。"
  exit 1
fi

if [ ! -d "$PROJECT_DIR/.git" ]; then
  echo "[INFO] 克隆仓库到 $PROJECT_DIR"
  git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$PROJECT_DIR"
else
  echo "[INFO] 更新仓库到最新 $BRANCH"
  git -C "$PROJECT_DIR" fetch origin "$BRANCH"
  git -C "$PROJECT_DIR" checkout "$BRANCH"
  git -C "$PROJECT_DIR" reset --hard "origin/$BRANCH"
fi

cd "$PROJECT_DIR"

cp docker-compose.yml docker-compose.override.yml

if [ "$DB_TYPE" = "mysql" ]; then
  sed -i 's|SQL_DSN=postgresql://root:123456@postgres:5432/new-api|SQL_DSN=root:123456@tcp(mysql:3306)/new-api|' docker-compose.override.yml
  sed -i 's|\- postgres|# - postgres|' docker-compose.override.yml
  sed -i 's|#      - mysql|      - mysql|' docker-compose.override.yml
  sed -i 's|#  mysql:|  mysql:|' docker-compose.override.yml
  sed -i 's|#    image: mysql:8.2|    image: mysql:8.2|' docker-compose.override.yml
  sed -i 's|#    container_name: mysql|    container_name: mysql|' docker-compose.override.yml
  sed -i 's|#    restart: always|    restart: always|' docker-compose.override.yml
  sed -i 's|#    environment:|    environment:|' docker-compose.override.yml
  sed -i 's|#      MYSQL_ROOT_PASSWORD: 123456|      MYSQL_ROOT_PASSWORD: 123456|' docker-compose.override.yml
  sed -i 's|#      MYSQL_DATABASE: new-api|      MYSQL_DATABASE: new-api|' docker-compose.override.yml
  sed -i 's|#    volumes:|    volumes:|' docker-compose.override.yml
  sed -i 's|#      - mysql_data:/var/lib/mysql|      - mysql_data:/var/lib/mysql|' docker-compose.override.yml
  sed -i 's|#    networks:|    networks:|' docker-compose.override.yml
  sed -i 's|#  mysql_data:|  mysql_data:|' docker-compose.override.yml
fi

sed -i "s/POSTGRES_PASSWORD: 123456/POSTGRES_PASSWORD: ${DB_PASSWORD}/" docker-compose.override.yml || true
sed -i "s|--requirepass\", \"123456|--requirepass\", \"${REDIS_PASSWORD}|g" docker-compose.override.yml || true
sed -i "s|REDIS_CONN_STRING=redis://:123456@redis:6379|REDIS_CONN_STRING=redis://:${REDIS_PASSWORD}@redis:6379|" docker-compose.override.yml || true
sed -i "s|TZ=Asia/Shanghai|TZ=${TZ_VALUE}|" docker-compose.override.yml || true

$COMPOSE_CMD -f docker-compose.override.yml up -d

echo "[OK] 部署完成"
echo "访问地址: http://$(hostname -I | awk '{print $1}'):${PORT}"
echo "项目目录: $PROJECT_DIR"
