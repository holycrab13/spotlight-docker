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
  echo "$DIRECTORY exists. Reusing existing model from volume."
else
  
  # Fetch the model file 
  RESULT=`curl --data-urlencode query="$QUERY" --data-urlencode format="text/tab-separated-values" https://databus.dbpedia.org/repo/sparql | sed 's/"//g' | grep -v "^file$" | head -n 1 `
  
  echo "Query Result: $RESULT"
  FILENAME=`echo "${RESULT##*/}"`
  echo "Downloading to local file $FILENAME"

  # Run model download and extraction
  wget $RESULT

  # Create directory
  mkdir $DIRECTORY;

  echo "Decompressing model"
  tar -C $DIRECTORY -xf $MODEL_PATH/$FILENAME

  # Remove extra folder
  TMP=`ls $DIRECTORY`
  mv $DIRECTORY/$TMP/* $DIRECTORY
  rm -r $DIRECTORY/$TMP

  # Remove the downloaded compressed model
  rm $FILENAME
fi

echo "java -Dfile.encoding=UTF-8 $JAVA_PARAMS -jar /opt/spotlight/dbpedia-spotlight.jar $DIRECTORY http://0.0.0.0:80/rest"
java -Dfile.encoding=UTF-8 $JAVA_PARAMS -jar /opt/spotlight/dbpedia-spotlight.jar $DIRECTORY http://0.0.0.0:80/rest
