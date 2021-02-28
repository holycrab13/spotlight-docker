FROM openjdk:8-jre-alpine

MAINTAINER  DBpedia Spotlight Team <dbp-spotlight-developers@lists.sourceforge.net>

#ENV SPOTLIGHT  https://sourceforge.net/projects/spotlight-multilingual-docker/files/dbpedia-spotlight-0.7.1.jar
ENV SPOTLIGHT  https://sourceforge.net/projects/spotlight-multilingual-docker/files/dbpedia-spotlight-1.1.jar

# adding required packages
RUN apk update && \
    apk add bash && \
    apk add tshark && \
    apk add --no-cache curl

# downloading spolight model and dbpedia spotlight
RUN mkdir -p /opt/spotlight/models && \ 
   #cd /opt/spotlight/models && \
   cd /opt/spotlight && \
   wget -O dbpedia-spotlight.jar $SPOTLIGHT && \
   mkdir -p src/main/resources/templates/
   #wget -O dbpedia-spotlight.jar $SPOTLIGHT
   #tar -xvf dbpedia-spotlight.tar.gz && \
   #rm dbpedia-spotlight.tar.gz

# adding the script to the container
ADD spotlight.sh /bin/spotlight.sh
ADD nif-21.vm /opt/spotlight/models/src/main/resources/templates/nif-21.vm
#ADD dbpedia-spotlight.jar /opt/spotlight/dbpedia-spotlight.jar
RUN chmod +x /bin/spotlight.sh 
#    chown root:root /opt/spotlight/models/dbpedia-spotlight.jar && \
#    chown -R root:root /opt/spotlight/models/src

#RUN chmod +x /opt/spotlight/dbpedia-spotlight.jar
EXPOSE 80
