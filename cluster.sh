#!/bin/bash

# Bring the services up
function startServices {
  docker start nodemaster node2 node3 node4
  sleep 5
  echo ">> Starting hdfs ..."
  docker exec -u hadoop -it nodemaster hadoop/sbin/start-dfs.sh
  sleep 5
  echo ">> Starting yarn ..."
  docker exec -u hadoop -d nodemaster hadoop/sbin/start-yarn.sh
  sleep 5
  echo ">> Starting Spark ..."
  docker exec -u hadoop -d nodemaster /home/hadoop/sparkcmd.sh start
  docker exec -u hadoop -d node2 /home/hadoop/sparkcmd.sh start
  docker exec -u hadoop -d node3 /home/hadoop/sparkcmd.sh start
  docker exec -u hadoop -d node4 /home/hadoop/sparkcmd.sh start
  show_info
}

function show_info {
  masterIp=`docker inspect -f "{{ .NetworkSettings.Networks.sparknet.IPAddress }}" nodemaster`
  echo "Hadoop Namenode @ nodemaster:  http://$masterIp:8088/cluster"
  echo "Spark Master    @ nodemaster:  http://$masterIp:8080/"
  echo "DFS Health      @ nodemaster:  http://$masterIp:9870/dfshealth.html"
}

if [[ $1 == "start" ]]; then
  startServices
  # exit

elif [[ $1 == "stop" ]]; then
  docker exec -u hadoop -d nodemaster /home/hadoop/sparkcmd.sh stop
  docker exec -u hadoop -d node2 /home/hadoop/sparkcmd.sh stop
  docker exec -u hadoop -d node3 /home/hadoop/sparkcmd.sh stop
  docker exec -u hadoop -d node4 /home/hadoop/sparkcmd.sh stop
  docker stop nodemaster node2 node3 node4
  # exit

elif [[ $1 == "init" ]]; then
  output=$( docker ps -a | grep sparkbase | awk '{ print $1 }' 2> /dev/null )
  if [[ -z ${output} ]]; then
    echo "No containers found ..."
  else
    docker rm -f `docker ps -a | grep sparkbase | awk '{ print $1 }'` # delete old containers
  fi
  output=$( docker network ls | grep sparknet | awk '{ print $1 }' 2> /dev/null )
  if [[ -z ${output} ]]; then
    echo "sparknet not found ..."
  else 
    docker network rm sparknet
  fi
  echo "Creating docker network"
  docker network create --driver bridge sparknet # create custom network

  # 3 nodes
  echo ">> Starting nodes master and worker nodes ..."
  docker run -dP --network sparknet --name nodemaster -h nodemaster -it sparkbase
  docker run -dP --network sparknet --name node2 -it -h node2 sparkbase
  docker run -dP --network sparknet --name node3 -it -h node3 sparkbase
  docker run -dP --network sparknet --name node4 -it -h node4 sparkbase

  # Format nodemaster
  echo ">> Formatting hdfs ..."
  docker exec -u hadoop -it nodemaster hadoop/bin/hdfs namenode -format
  startServices
  # exit

elif [[ $1 == "show" ]]; then
  show_info
  # exit

elif [[ $1 == "destroy" ]]; then
  output=$( docker ps -a | grep node* | awk '{ print $1 }' 2> /dev/null )
  if [[ -z ${output} ]]; then
    echo "No containers found ..."
  else
    docker rm -f `docker ps -a | grep node* | awk '{ print $1 }'` # delete old containers
  fi
  output=$( docker network ls | grep sparknet | awk '{ print $1 }' 2> /dev/null )
  if [[ -z ${output} ]]; then
    echo "sparknet not found ..."
  else 
    docker network rm sparknet
  fi
  # exit

else 
  echo "Usage: cluster.sh init|start|stop|show|destroy"
  echo "                 init  - create a new Docker network"
  echo "                 start   - start the existing containers"
  echo "                 stop    - stop the running containers" 
  echo "                 show    - useful URLs" 
  echo "                 destroy - destroy containers and docker network"
fi