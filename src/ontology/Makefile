# ----------------------------------------
# OORT
# ----------------------------------------
OBO = http://purl.obolibrary.org/obo
EFO = http://www.ebi.ac.uk/efo/
EFO_LOCAL = ../../external/efo-core.obo
TAX_LOCAL = ../../external/taxslim.obo
CHEBI_LOCAL = ../../external/chebi.owl
TAXSLIM = $(OBO)/ncbitaxon/subsets/taxslim.obo
USECAT = --catalog-xml catalog-v001.xml

IMPORTS = cl_import.owl uberon_import.owl doid_import.owl pato_import.owl uo_import.owl efo_import.owl  chebi_import.owl ncbitaxon_import.owl
IMPORTS_DECL = $(IMPORTS) pr_import.owl

all: ff.obo

quickcheck: fantom5-edit.obo 
	owltools $< --run-reasoner -r elk -u 

$(EFO_LOCAL):
	owltools $(EFO)/efo.owl --extract-mingraph --set-ontology-id $(OBO)/ff/efo-core.owl -o -f obo --no-check $@
$(TAX_LOCAL):
	owltools $(TAXSLIM) --extract-mingraph --set-ontology-id $(OBO)/ff/taxslim.owl -o -f obo --no-check $@
$(CHEBI_LOCAL):
	owltools $(OBO)/chebi.owl --extract-mingraph --set-ontology-id $(OBO)/chebi.owl -o file://`pwd`/$@

imports: $(IMPORTS)

#efo_import.owl: fantom5-edit.obo
#	owltools $(USECAT) $< $(EFO)/efo.owl --add-imports-from-supports --extract-module -c -s $(EFO) --extract-mingraph --set-ontology-id $(OBO)/ff/$@ -o file://`pwd`/$@
efo_import.owl: fantom5-edit.obo
	owltools $(USECAT) $< $(EFO_LOCAL) --add-imports-from-supports --extract-module -c -s $(OBO)/ff/efo-core.owl --extract-mingraph --set-ontology-id $(OBO)/ff/$@ -o file://`pwd`/$@

chebi_import.owl: fantom5-edit.obo
	owltools $(USECAT) $< $(CHEBI_LOCAL) --add-imports-from-supports --extract-module -c -s $(OBO)/chebi.owl --extract-mingraph --set-ontology-id $(OBO)/ff/$@ -o file://`pwd`/$@

ncbitaxon_import.owl: fantom5-edit.obo
	owltools $(USECAT) $< $(TAX_LOCAL) --add-imports-from-supports --extract-module -c -s $(OBO)/ff/taxslim.owl --extract-mingraph --set-ontology-id $(OBO)/ff/$@ -o file://`pwd`/$@

%_import.owl: fantom5-edit.obo
	owltools $(USECAT) $< $(OBO)/$*.owl --add-imports-from-supports --extract-module -c -s $(OBO)/$*.owl --extract-mingraph --set-ontology-id $(OBO)/ff/$@ -o file://`pwd`/$@

fantom5-edit.owl: fantom5-edit.obo imports
	owltools $(USECAT) $< --add-imports-declarations $(patsubst %, $(OBO)/ff/%, $(IMPORTS_DECL)) // -o file://`pwd`/$@

#mod.obo: fantom5-edit.obo 
#	owltools $(USECAT) $<  ../../external/efo-core.obo  ../../external/cl/bridge/cl-bridge-to-uberon.owl $(OBO)/cl-basic.owl $(OBO)/uberon/basic.owl $(OBO)/doid.owl $(OBO)/pato.owl $(OBO)/uo.obo --add-imports-from-supports --extract-module -c -s $(OBO)/cl/cl-basic.owl -n $(OBO)/ff/uberon_imports.owl --extract-mingraph -o -f obo $@

fantom5-merged.owl: fantom5-edit.owl
	owltools $(USECAT) $< --merge-import-closure -o file://`pwd`/$@

ff.owl: fantom5-edit.owl
	cp $< $@

# this is a bit confusing - the version of ff in the build dir is pre-merged, as oort doesn't play well with imports yet
build/ff.owl: fantom5-merged.owl
	ontology-release-runner --allow-equivalent-pairs --repair-cardinality --skip-format obo --allow-overwrite $(USECAT) --reasoner elk --outdir build --skip-format owx --no-subsets --asserted --simple $<
build/ff.obo: build/ff.owl
	owltools $< -o -f obo --no-check $@

ff.obo: build/ff.obo 
	perl -npe 's/ontology: ff/ontology: ff-merged/' $< >  $@


## SUBSET

phase%-seed.obo: fantom5-edit.obo 
	obo-grep.pl -r 'subset: phase$*' fantom5-edit.obo > $@.tmp && mv $@.tmp $@

ff-basic.obo: ff.obo
	owltools $< --make-subset-by-properties BFO:0000050 RO:0002202 immediate_transformation_of RO:0001000 is_model_for treated_with -o -f obo $@
#ff-phase%-unf.obo: ff-basic.obo
#	blip ontol-query -i $< -query "entity_partition(X,phase$*),parentRT(X,ID)" -to obo > $@
#ff-phase%.obo: ff-phase%-unf.obo
#	owltools $<  --remove-dangling --set-ontology-id $(OBO)/ff/subsets/ff-phase$*.owl -o -f obo $@

ff-phase%.obo: ff-basic.obo
	owltools $< --extract-ontology-subset -s phase$* --fill-gaps  --set-ontology-id $(OBO)/ff/subsets/ff-phase$*.owl -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@

ff-basic-cycles.txt: ff-basic.obo
	blip-findall -i $< "parent_cycle/2" -label > $@

#ff-phase1.obo: phase1-seed.obo ff.obo
#	owltools $(USECAT) $< ff.obo --add-imports-from-supports --extract-module -s $(OBO)/ff.owl -n $(OBO)/ff/ff-phase1.owl -c --merge-import-closure -o -f obo --no-check $@

#ff-phase1.obo: ff.obo
#	blip ontol-query -i $< -query "class(X),entity_partition(X,phase1),concat_atom([_,_],-,X),bf_parentRT(X,ID)" -to obo > $@
# See issue #6 - don't use OWLAPI

ff-phase1.owl: ff-phase1.obo
	obolib-obo2owl $< -o $@

