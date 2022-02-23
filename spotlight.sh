if [ -z ${NAME+x} ]; then NAME='en'; fi
if [ -z ${MODEL_PATH+x} ]; then MODEL_PATH='/opt/spotlight/models'; fi
if [ -z ${QUERY+x} ]; then QUERY='NONE'; fi
if [ -z ${JAVA_PARAMS+x} ]; then JAVA_PARAMS=-Xmx15G; fi

echo "========================================="
echo "NAME is set to '$NAME'"; 
echo "MODEL_PATH is set to '$MODEL_PATH'"; 
echo "QUERY is set to '$QUERY'"; 
echo "JAVA_PARAMS is set to '$JAVA_PARAMS'"; 
echo "========================================="

cd $MODEL_PATH

DIRECTORY=$MODEL_PATH/$NAME

if [ -d "$DIRECTORY" ]
then
else
  # Create directory
  mkdir $DIRECTORY;
  
  # Fetch the model file 
  RESULT=`curl --data-urlencode query="$QUERY" --data-urlencode format="text/tab-separated-values" https://databus.dbpedia.org/repo/sparql | sed 's/"//g' | grep -v "^file$" | head -n 1 `
  FILENAME=`echo "${RESULT##*/}"`

  # Run model download and extraction
  wget $RESULT
  mkdir $DIRECTORY;
  tar -C $DIRECTORY -xvf $FILENAME

  # Remove extra folder
  TMP=`ls $DIRECTORY`
  mv $TMP/* .
  rm -r $TMP

  # Remove the downloaded compressed model
  rm $FILENAME
fi

echo "java -Dfile.encoding=UTF-8 $JAVA_PARAMS -jar /opt/spotlight/dbpedia-spotlight.jar $DIRECTORY http://0.0.0.0:80/rest"
java -Dfile.encoding=UTF-8 $JAVA_PARAMS -jar /opt/spotlight/dbpedia-spotlight.jar $DIRECTORY http://0.0.0.0:80/rest
