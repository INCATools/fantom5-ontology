# ----------------------------------------
# OORT
# ----------------------------------------
OBO = http://purl.obolibrary.org/obo

fantom5.obo: fantom5-edit.obo 
	ontology-release-runner --allow-overwrite --catalog-xml catalog-v001.xml --reasoner elk --outdir build --skip-format owx --no-subsets --asserted --simple $< ../../external/efo-core.obo  ../../external/cl/bridge/cl-bridge-to-uberon.owl $(OBO)/cl-basic.owl $(OBO)/uberon/basic.owl $(OBO)/doid.owl $(OBO)/pato.owl $(OBO)/uo.obo  --re-mireot

