### 高可用redis集群部署方案

利用redis主从+sentinel实现高可用的redis服务 

测试场景： 
- 1、主节点挂了，从节点自动变成主节点（因为主从同步，此时获取的redis数据不会有异常） 
- 2、单个主节点运行了一段时间，期间新增了一些key（test1，test2） 
- 3、挂掉的节点恢复，sentinel自动将恢复的节点作为当前主节点的从节点（现在上从节点读取key：test1，test2， 是否能获取到？） 
- 4、redis主节点和其中一个sentinel同时宕机 
- 5、redis 订阅问题


#### 配置说明
版本：
1、redis2.6版本发布了sentinel 1(因为bug较多官方已经弃用)
2、redis2.8版本发布了sentinel 2（推荐使用sentinel 2）

##### redis 配置
redis conf:
```
daemonize yes
pidfile /var/run/redis_7501.pid
port 7501
bind 10.10.172.191  #可选，默认就处理所有请求。
logfile "./redis-7501.log"
dir "/usr/local/redis-sentinel/7501"
redis配置密码的话，需要以下配置
masterauth "123456"
requirepass "123456"
appendonly yes
```

重点（容易出错）:
- 1、protected-mode no
是否开启保护模式，默认开启。要是配置里没有指定bind和密码。开启该参数后，redis只会本地进行访问，拒绝外部访问。要是开启了密码和bind，可以设为yes。否则最好关闭，设置为no。
- 2、bind
网上很多解释是错误的，并不是允许哪些ip可以访问redis服务的意思！！！
通俗易懂的理解：bind配置了什么ip，别人就得访问bind里面配置的ip才访问到redis服务。


##### 哨兵配置
sentinel conf:
```
daemonize yes 
port 7505
#指定工作目录
dir "/usr/local/redis-sentinel/7505"
logfile "./sentinel.log"

#指定别名  主节点地址  端口  哨兵个数（有几个哨兵监控到主节点宕机执行转移）
sentinel monitor mymaster 10.10.172.191 7501 2

#如果哨兵3s内没有收到主节点的心跳，哨兵就认为主节点宕机了，默认是30秒
sentinel down-after-milliseconds mymaster 3000

#选举出新的主节点之后，可以同时连接从节点的个数
sentinel parallel-syncs mymaster 1

#如果10秒后,master仍没活过来，则启动failover,默认180s
sentinel failover-timeout mymaster 10000

#配置连接redis主节点密码
sentinel auth-pass mymaster 123456
```
#### 方案目录结构
<pre>
.
├── README.md
├── redis1
│   └── redis.conf
├── redis2
│   └── redis.conf
├── redis3
│   └── redis.conf
├── redis4
│   └── redis.conf
├── redis5
│   └── redis.conf
├── run.sh
├── sentinel1
│   └── sentinel.conf
├── sentinel2
│   └── sentinel.conf
└── sentinel3
    └── sentinel.conf
</pre>

### sentinel 使用
Sentinel API
Sentinel默认运行在26379端口上，sentinel支持redis协议，所以可以使用redis-cli客户端或者其他可用的客户端来与sentinel通信。

有两种方式能够与sentinel通信：

一种是直接使用客户端向它发消息

另外一种是使用发布/订阅模式来订阅sentinel事件，比如说failover，或者某个redis实例运行出错，等等。

[Sentinel命令](http://redisdoc.com/topic/sentinel.html#sentinel-api "Sentinel命令")

sentinel支持的合法命令如下：

- PING sentinel回复PING.

- SENTINEL masters 显示被监控的所有master以及它们的状态.

- SENTINEL master <master name> 显示指定master的信息和状态；

- SENTINEL slaves <master name> 显示指定master的所有slave以及它们的状态；

- SENTINEL get-master-addr-by-name <master name> 返回指定master的ip和端口，如果正在进行failover或者failover已经完成，将会显示被提升为master的slave的ip和端口。

- SENTINEL reset <pattern> 重置名字匹配该正则表达式的所有的master的状态信息，清楚其之前的状态信息，以及slaves信息。

- SENTINEL failover <master name> 强制sentinel执行failover，并且不需要得到其他sentinel的同意。但是failover后会将最新的配置发送给其他sentinel。
