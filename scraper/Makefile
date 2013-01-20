BASE=FANTOM5v1
%_no_u.obo: %.obo
	obo-grep.pl --neg -r 'id: UBER' $< > $@

%_m_u.obo: %_no_u.obo
	blip ontol-query -i $< -r uberons -mireot FF -to obo > $@.tmp && obo-grep.pl -r 'id: U' $@.tmp > $@

%_nu.obo: %_m_u.obo
	blip -i $*_no_u.obo -i $< io-convert -to obo > $@

# ----------------------------------------
# NLP ANNOTATION
# ----------------------------------------

R_ONT = -r uberonp -r cell -r disease

%_labels.pro: %.obo
	blip-findall -i $< "entity_label(A,B),id_idspace(A,'FF')" -select "s(A,B)" -write_prolog > $@

%-ann.pro: %_labels.pro
	obol -debug sim -ff pro^$< -u annotator $(R_ONT) -u ontol_db -u metadata_db -goal initialize_annotator findall "s(C,N),sentence_annotate(N,A)" -select "a(C,N,A)" -write_prolog > $@

%-newlink.txt: %-ann.pro
	blip-findall -debug foo -ff pro^$< -i $*.obo $(R_ONT) "a(X,N,L),member(m(ML,MN,_),L),member(C,ML),debug(foo,'tetsing ~w',[X-C]),\+parentRT(X,subclass,C)" -select "a(X,N,C,MN)" > $@

# ----------------------------------------
# REPORTS
# ----------------------------------------
%-grid.txt: %_nu.obo
	blip-findall -i $< -consult make_lookup.pro grid_row/3 -grid -no_pred > $@

%-grid2.txt: %_nu.obo
	blip-findall  -i $< -consult make_lookup.pro -goal ix grid_row2/3  -grid -label -noid -use_tabs -no_pred > $@


%-mapping.txt: %_nu.obo
	blip-findall -i $< -consult make_lookup.pro sample_type/2 -label -use_tabs -labels -no_pred > $@

%-mapping.gmt: %_nu.obo
	blip-findall -i $< -consult make_lookup.pro "setof(Y,sample_type(X,Y),Ys)" -select X-Ys -label -grid -no_pred > $@

%-mapping-transposed.gmt: %_nu.obo
	blip-findall -i $< -consult make_lookup.pro "setof(X,sample_type(X,Y),Xs)" -select Y-Xs -label -grid -no_pred > $@

# for simile - use solr instead now..
sample.js: $(BASE)_nu.obo
	blip  -i $< -consult make_lookup.pro -goal ix,write_json,halt > $@


OUT = $(BASE)*.gmt $(BASE)*.txt README
dist:
	cd .. && tar zcvf fantom.tar.gz $(patsubst %,fantom/%,$(OUT)) && mv fantom.tar.gz fantom

