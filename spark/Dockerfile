FROM javabase:latest

EXPOSE 8081
EXPOSE 8080
EXPOSE 8088
EXPOSE 7077
EXPOSE 9870
EXPOSE 4040

RUN useradd -m -s /bin/bash hadoop

WORKDIR /home/hadoop

USER hadoop
ENV SPARK_VERSION=3.1.3 \
  HADOOP_VERSION=3.2.3 \
  SPARK_HADOOP_VERSION=3.2
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz

RUN tar -zxf hadoop-${HADOOP_VERSION}.tar.gz && \
  mv hadoop-${HADOOP_VERSION} hadoop
RUN tar -zxf spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz && \
  mv spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION} spark &&  rm *gz

RUN mkdir -p /home/hadoop/.ssh /home/hadoop/hadoop/logs \
    /home/hadoop/data/nameNode /home/hadoop/data/dataNode \
    /home/hadoop/data/namesecondary /home/hadoop/data/tmp && \
    touch /home/hadoop/hadoop/logs/fairscheduler-statedump.log

# We don't care about the skeleton rc files, so overwrite
COPY config/shellrc /home/hadoop/.bashrc
COPY config/shellrc /home/hadoop/.profile
COPY config/id_rsa* /home/hadoop/.ssh/
COPY config/id_rsa.pub  /home/hadoop/.ssh/authorized_keys
COPY config/workers /home/hadoop/spark/conf/slaves
COPY config/sparkcmd.sh /home/hadoop/
COPY config/hadoop-env.sh /home/hadoop/

COPY config/core-site.xml config/hdfs-site.xml config/mapred-site.xml \
    config/yarn-site.xml config/workers /home/hadoop/hadoop/etc/hadoop/

USER hadoop
RUN cat /home/hadoop/hadoop-env.sh >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh

USER root
RUN chown -R hadoop /home/hadoop/.ssh /home/hadoop/.bashrc /home/hadoop/.profile \
    /home/hadoop/data /home/hadoop/hadoop-env.sh
#ENTRYPOINT ["/home/hadoop/sparkcmd.sh","start"]
CMD service ssh start && sleep infinity
