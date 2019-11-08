bash "slots" do
    user 'root'
    cwd '/etc/redis/'
    code <<-EOH
    for i in {0..5400}; do redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER ADDSLOTS $i; done
    for i in {5401..10800}; do redis-cli -h #{node['redisio']['node2hostname']} -p 6379 CLUSTER ADDSLOTS $i; done
    for i in {10801..16383}; do redis-cli -h #{node['redisio']['node1hostname']} -p 6379 CLUSTER ADDSLOTS $i; done
    
    redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER MEET #{node['redisio']['node3hostname']} 6380
    redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER MEET #{node['redisio']['node2hostname']} 6379
    redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER MEET #{node['redisio']['node2hostname']} 6380
    redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER MEET #{node['redisio']['node1hostname']} 6379
    redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER MEET #{node['redisio']['node1hostname']} 6380

    redis-cli -h #{node['redisio']['node3hostname']} -p 6380 CLUSTER REPLICATE $(redis-cli -h #{node['redisio']['node2hostname']} -p 6379 CLUSTER NODES | grep myself | cut -d" " -f1)
    redis-cli -h #{node['redisio']['node2hostname']} -p 6380 CLUSTER REPLICATE $(redis-cli -h #{node['redisio']['node1hostname']} -p 6379 CLUSTER NODES | grep myself | cut -d" " -f1)
    redis-cli -h #{node['redisio']['node1hostname']} -p 6380 CLUSTER REPLICATE $(redis-cli -h #{node['redisio']['node3hostname']} -p 6379 CLUSTER NODES | grep myself | cut -d" " -f1)

    EOH
end