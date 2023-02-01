TODAY=$(date '+%Y%m%d')
XML_DATA_DIR=juggling-xml-data
EVAL_XML=${XML_DATA_DIR}/juggling-eval-${TODAY}.xml
echo "Writing eval data to ${EVAL_XML}"
mkdir -p $XML_DATA_DIR
beval juggling-runscript.xml > ${EVAL_XML}.orig

# Fix badly generate xml
sed -e 's/"${H/'"'"'${H/g' -e 's/""/'"'"'"/g'   ${EVAL_XML}.orig > ${EVAL_XML}
