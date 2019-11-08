# Chef Cookbook to deploy Highly Available Redis Cluster with Replication and Sharding enabled

After complete setup, Redis cluster will be setup in three servers. Each server will have two Redis instances, so there will be a total of six Redis instances in three servers. Three of the six instances will be replicated as slaves to the other three instances which will behave as Master nodes. No same Master and slave would be on the same server to ensure high availability of the cluster.

![Image](https://i1.wp.com/codeflex.co/wp-content/uploads/2016/09/redis-cluster-failover-3-servers.jpg?w=592&ssl=1)

## Pre-requisites

1. Download ChefDK from [here](https://downloads.chef.io/chefdk/) to setup Chef workstation.
2. To setup a Chef server, follow the instructions given in this guide [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-chef-12-configuration-management-system-on-ubuntu-14-04-servers). 
3. Make sure the Workstation and Chef Server can communicate with eachother through the **knife** tool.
4. Upload all the required cookbooks to the Chef server with the knife tool.
5. Spin up three ubuntu instances (on AWS EC2 within a same VPC) that will work as nodes for Redis Cluster.
6. Update the Private IPs (hostnames) of the instances in the `chef-repo/cookbooks/redisio/attributes/default.rb` file.
   The attributes to be updated are:
   `default['redisio']['node1hostname']`
   `default['redisio']['node2hostname']`
   `default['redisio']['node3hostname']`

Now you're ready to bootstrap nodes and apply configurations to those nodes.

## Configuration

Apply the following commands from the Chef workstation strictly in the following order.

```sh
$ cd cookbooks/redisio
$ berks install -b Berksfile
$ berks upload -b Berksfile
$ knife cookbook upload redisio
$ cd <path-to-roles-directory>
$ knife role from file redisiorole.rb
$ knife bootstrap <private-ip-of-server> -U ubuntu -i <path-to-ssh-key> -p 22 -N node1 --sudo -y -r "role[redisiorole]"
$ knife bootstrap <private-ip-of-server> -U ubuntu -i <path-to-ssh-key> -p 22 -N node2 --sudo -y -r "role[redisiorole]"
$ knife bootstrap <private-ip-of-server> -U ubuntu -i <path-to-ssh-key> -p 22 -N node3 --sudo -y -r "role[redisiorole],recipe[redisio::sharding]"
```

