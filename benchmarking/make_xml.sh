XML_DATA_DIR=juggling-xml-data
EVAL_XML=${XML_DATA_DIR}/juggling-eval.xml
mkdir -p $XML_DATA_DIR
beval juggling-runscript.xml > ${EVAL_XML}
#beval juggling-runscript-small.xml > ${EVAL_XML}
#beval juggling-runscript-nowalk.xml > ${EVAL_XML}
