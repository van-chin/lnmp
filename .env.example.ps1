# You can overwrite this file in .env.ps1

$CI_HOST="ci.khs1994.com:10000"

# wsl name
# $ wslconfig /l
# $ wsl -l
$DistributionName="Ubuntu-18.04"

$LNMP_PHP_IMAGE="khs1994/php:7.4.11-composer-alpine"

$NGINX_PATH="C:/nginx"
$PHP_PATH="C:/php"

# used by $ lnmp-wnamp start common
$COMMON_SOFT="nginx","php","mysql","wsl-redis"

$LNMP_NODE_IMAGE="node:alpine"
# $LNMP_NODE_IMAGE="khs1994/node:git"

# $LNMP_CACHE=

# 项目存储在 WSL2
# 推荐使用 Ubuntu，其他系统（例如 alpine）可能会遇到错误
# $WSL2_DIST="Ubuntu"
