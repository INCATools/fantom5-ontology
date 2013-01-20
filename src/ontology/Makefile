# ----------------------------------------
# OORT
# ----------------------------------------
OBO = http://purl.obolibrary.org/obo

oort: fantom5.obo efo.obo
	ontology-release-runner --allow-overwrite --catalog-xml catalog-v001.xml --reasoner elk --outdir build --skip-format owx --no-subsets --asserted --simple $< cl-to-uberon.obo $(OBO)/cl-basic.owl $(OBO)/uberon/basic.owl $(OBO)/doid.owl $(OBO)/pato.owl efo.obo --re-mireot
