# Docker based Hadoop & Spark Cluster

Build your own Hadoop & Spark cluster setup in Docker. 
A multinode setup where each node of the network runs in its own separated Docker container. The installation takes care of the Hadoop & Spark configuration with following images & containers:
1) A Ubuntu-20.04 image with java & python3 (javabase image)
2) Four fully configured Spark nodes running on Hadoop (sparkbase image):
    * nodemaster (master node)
    * node2      (slave)
    * node3      (slave)
    * node4      (slave)

## What Next?
* You can experiment with a more realistic network setup
* Tweak nodes configuration
* Simulate scalability, downtimes and rebalance by adding/removing nodes to the network automagically   

## Installation
1) Clone this repository
2) Change Directory to checked out folder then to javabase
```bash
cd javabase
```
3) This builds the base java Ubuntu container from openjdk11 & Python3
```bash
. ./build.sh 
```
    
4) change directory to final image build folder
```bash
cd ../spark
```
5) This builds the sparkbase image with hadoop-3.2.3 & spark-3.1.3
```bash
. ./build.sh
```
6) To build the cluster
```bash
. ./cluster.sh deploy
```

The script will create the cluster & display Hadoop and Spark admin URLs:
```css
    Hadoop Namenode @ nodemaster:  http://nodemaster:8088/cluster
    Spark Master    @ nodemaster:  http://nodemaster:8080/
    DFS Health      @ nodemaster:  http://nodemaster:9870/dfshealth.html
```

## Cluster.sh Switches
```bash
cluster.sh stop   # Stop the cluster
cluster.sh start  # Start the cluster
cluster.sh show   # Shows handy URLs of running cluster

# Warning! This will remove everything from HDFS
cluster.sh init # Format the cluster and deploy images again

# Warning! This will destroy the cluster and docker network completely
cluster.sh destroy
```

### Quick reference
```bash
docker images # List images
docker container ls # List docker containers

docker rm -f `docker ps -a | awk '{ print $1 }'` # Remove all containers
docker system prune  # delete dangling images

docker build -t <tag> . # Build image from current directory containing Dockerfile

docker run -d -i <image_id> # Run container from image in detached mode

# Bash into container
docker exec -i -t <container_id> bash
```
