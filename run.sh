# create network
docker network create -d bridge --subnet 172.19.0.0/24 redis-network
# pull redis image
docker pull redis:5.0.3-alpine
# run redis server 1
docker run -v $PWD/redis1/redis.conf:/usr/local/etc/redis/redis.conf \
           --name redis1 \
           --network redis-network \
           --ip 172.19.0.11 \
           -d redis:5.0.3-alpine redis-server /usr/local/etc/redis/redis.conf
# run redis server 2
docker run -v $PWD/redis2/redis.conf:/usr/local/etc/redis/redis.conf \
           --name redis2 \
           --network redis-network \
           --ip 172.19.0.12 \
           -d redis:5.0.3-alpine redis-server /usr/local/etc/redis/redis.conf
# run redis server 3
docker run -v $PWD/redis3/redis.conf:/usr/local/etc/redis/redis.conf \
           --name redis3 \
           --network redis-network \
           --ip 172.19.0.13 \
           -d redis:5.0.3-alpine redis-server /usr/local/etc/redis/redis.conf
# run redis server 4
docker run -v $PWD/redis4/redis.conf:/usr/local/etc/redis/redis.conf \
           --name redis4 \
           --network redis-network \
           --ip 172.19.0.14 \
           -d redis:5.0.3-alpine redis-server /usr/local/etc/redis/redis.conf
# run redis server 5
docker run -v $PWD/redis5/redis.conf:/usr/local/etc/redis/redis.conf \
           --name redis5 \
           --network redis-network \
           --ip 172.19.0.15 \
           -d redis:5.0.3-alpine redis-server /usr/local/etc/redis/redis.conf

# run sentinel 1
docker run -it --network redis-network \
           --ip 172.19.0.21 \
           --name sentinel1 \
           -v $PWD/sentinel1/sentinel.conf:/usr/local/etc/redis/sentinel.conf \
           -d redis:5.0.3-alpine redis-sentinel /usr/local/etc/redis/sentinel.conf
# run sentinel 2
docker run -it --network redis-network \
           --ip 172.19.0.22 \
           --name sentinel2 \
           -v $PWD/sentinel2/sentinel.conf:/usr/local/etc/redis/sentinel.conf \
           -d redis:5.0.3-alpine redis-sentinel /usr/local/etc/redis/sentinel.conf
# run sentinel 3
docker run -it --network redis-network \
           --ip 172.19.0.23 \
           --name sentinel3 \
           -v $PWD/sentinel3/sentinel.conf:/usr/local/etc/redis/sentinel.conf \
           -d redis:5.0.3-alpine redis-sentinel /usr/local/etc/redis/sentinel.conf
