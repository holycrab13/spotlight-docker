# DBpedia Spotlight Docker for Databus

Fork for more Databus interoperability


## What is DBpedia Spotlight?

[DBpedia Spotlight](http://wikipedia.org/wiki/DBpedia#DBpedia_Spotlight) is a tool for automatically annotating mentions of DBpedia resources in text, providing a solution for linking unstructured information sources to the Linked Open Data cloud through DBpedia.

The dbpedia/spotlight-multilingual-databus is a docker image to run the DBpedia Spotlight server with the most recent language models, downloaded from the [DBpedia Databus repository](https://databus.dbpedia.org/dbpedia/spotlight/spotlight-model/) (as shown in Figure 1)., e.g., English (en), German (nl), Italian (it), etc. 

<p align="center">
<img src="multilingual-databus/images/spotlight-databus.png" alt="databus & spotlight" width="600" height="400"  />
<p align="center">Figure 1. DBpedia Databus and DBpedia Spotlight</p>
</p>

The following are the instructions to run a DBpedia Spotlight service for one or more language models and to deploy a web page to annotate text with any of the running services.

## Run DBpedia Spotlight as a single Docker container

Use the following compose 

```
version: '3.5'    
services:
  spotlight.en:
    image: dbpedia/spotlight-for-databus
    container_name: dbpedia-spotlight.en
    environment:
      NAME: en
      MODEL_PATH: /opt/spotlight/models
      QUERY: >
        PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>

        PREFIX dct:    <http://purl.org/dc/terms/>

        PREFIX dcat:   <http://www.w3.org/ns/dcat#>

        PREFIX db:     <https://databus.dbpedia.org/>

        PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

        PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>

        SELECT DISTINCT ?file WHERE {
          GRAPH ?g {
            ?dataset dcat:distribution ?distribution .
            ?distribution dcat:downloadURL ?file .
            ?dataset dataid:artifact <https://databus.dbpedia.org/dbpedia/spotlight/spotlight-model> .
            {
              ?distribution dct:hasVersion ?version {
                SELECT (?v as ?version) { 
                  ?dataset dataid:artifact <https://databus.dbpedia.org/dbpedia/spotlight/spotlight-model> . 
                  ?dataset dct:hasVersion ?v . 
                } ORDER BY DESC (?version) LIMIT 1 
              }
            }
            { ?distribution <http://dataid.dbpedia.org/ns/cv#lang> 'en'^^<http://www.w3.org/2001/XMLSchema#string> . }
          }
        }
    volumes:
      - ./models:/opt/spotlight/models
    restart: unless-stopped   
    ports:
      - "0.0.0.0:2222:80"  
    command: /bin/spotlight.sh

```


To run more than one DBpedia Spotlight service, add more containers to the compose
The QUERY env variable of each container should select only its respective model file

It is possible to monitor each DBpedia Spotlight service through docker tool such as:
       * `docker logs dbpedia-spotlight.[LANG]` : Displays the log information for the corresponding service
       * `docker stats dbpedia-spotlight.[LANG]`:  Shows the statistics (e.g., the amount of memory and CPU) for the corresponding service


## Example query

```
curl http://localhost:2222/rest/annotate \
        --data-urlencode "text=President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance." \
        --data "confidence=0.35" \
        -H "Accept: text/turtle"
```
        

 The "Accept: text/turtle" returns a NIF output but this option could be changed by "Accept: application/json" to returns a JSON output format.


## Stop the Docker container

An option to stop the DBpedia Spotlight server is by the commands:

     docker stop dbpedia-spotlight.[LANG]
     docker rm dbpedia-spotlight.[LANG]

The `docker stop` command will stop the running container and the `docker rm` command will remove the container. The `dbpedia-spotlight` corresponds to the name given with the `--name` option of the docker run command. 


## Documentation

Documentation for this image is stored in [GitHub repo](http://github.com/dbpedia-spotlight/dbpedia-spotlight/wiki).

