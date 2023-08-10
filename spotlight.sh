#!/bin/sh

LANG=$1

MODELFOLDER=/opt/spotlight
cd $MODELFOLDER

DIRECTORY=/opt/spotlight/models/$LANG
echo "Selected language: $LANG"
if [ -d "$DIRECTORY" ]
then
     echo "/opt/spotlight/$LANG http://0.0.0.0:80/rest/"
     if [[ $LANG == "en" ]]
     then
	 java -Dfile.encoding=UTF-8 -Xmx15G -jar /opt/spotlight/dbpedia-spotlight.jar /opt/spotlight/models/$LANG http://0.0.0.0:80/rest
     else
	 java -Dfile.encoding=UTF-8 -Xmx10G -jar /opt/spotlight/dbpedia-spotlight.jar /opt/spotlight/models/$LANG http://0.0.0.0:80/rest
     fi

else
      QUERY="PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcat:   <http://www.w3.org/ns/dcat#>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX dcv: <https://dataid.dbpedia.org/databus-cv#>
PREFIX databus: <https://dataid.dbpedia.org/databus#>
SELECT ?file WHERE
{
	GRAPH ?g
	{
		?dataset databus:artifact <https://databus.dbpedia.org/dbpedia/spotlight/spotlight-model> .
		{
			?distribution dct:hasVersion ?version {
				SELECT (?v as ?version) { 
					GRAPH ?g2 { 
						?dataset databus:artifact <https://databus.dbpedia.org/dbpedia/spotlight/spotlight-model> . 
						?dataset dct:hasVersion ?v . 
					}
				} ORDER BY DESC (STR(?version)) LIMIT 1 
			}
		}
		{ ?distribution <https://dataid.dbpedia.org/databus-cv#lang> '$LANG' . }
		?dataset dcat:distribution ?distribution .
		?distribution databus:file ?file .
	}
}"
      

      RESULT=`curl --data-urlencode query="$QUERY" -H 'accept:text/tab-separated-values' https://databus.dbpedia.org/sparql | sed 's/"//g' | grep -v "^file$" | head -n 1`
      echo $RESULT
      curl -O  $RESULT
      tar -C /opt/spotlight/models -xvf spotlight-model_lang=$LANG.tar.gz
      rm spotlight-model_lang=$LANG.tar.gz
      echo "/opt/spotlight/models/$LANG http://0.0.0.0:80/rest/"
      if [[ $LANG == "en" ]]
      then
	java -Dfile.encoding=UTF-8 -Xmx15G -jar /opt/spotlight/dbpedia-spotlight.jar /opt/spotlight/models/$LANG http://0.0.0.0:80/rest
       else
	 java -Dfile.encoding=UTF-8 -Xmx10G -jar /opt/spotlight/dbpedia-spotlight.jar /opt/spotlight/models/$LANG http://0.0.0.0:80/rest
      fi

fi
