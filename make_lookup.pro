:- use_module(bio(index_util)).
:- use_module(bio(ontol_db)).
:- use_module(bio(tabling)).


ix :-
        %materialize_index_to_file(allowed_path(1,1),'cache.pro').
        table_pred(nr/2),
        materialize_index(allowed_path(1,1)).


discriminating_class(C) :-
        class(C),
        \+ sample(C),
        is_discriminating_class(C).
non_discriminating_class(C) :-
        class(C),
        \+ sample(C),
        \+ is_discriminating_class(C).


is_discriminating_class(C) :-
        % C has different samples than one of it's children
        sample_type(S,C),
        parent(SubC,C),
        \+ sample(SubC),
        \+ sample_type(S,SubC),
        !.
is_discriminating_class(C) :-
        % C has sample and has no children
        sample_type(_,C),
        \+ ((parent(SubC,C),
             \+ sample(SubC))),
        !.
/*
is_discriminating_class(C) :-
        % C has different samples than one of it's parents
        parent(C,SupC),
        allowed_path(S,SupC),
        \+ allowed_path(S,C),
        !.
(  */
        


%allowed_path(S,C) :-        subclassT(S,C).
allowed_path(S,C) :-        parentT(S,subclass,C).
allowed_path(S,C) :-        parentT(S,part_of,C).

sample(S) :-
        class(S),
        id_idspace(S,'FF'),
        \+ subclass(_,S).

sample_type(S,C) :-
        sample(S),
        allowed_path(S,C).

category(X) :- subclass(X,'FF:0000102').
category(X) :- subclass(X,'FF:0000101').
category(X) :- subclass(X,'CL:0000548').
category(X) :- subclass(X,'UBERON:0000467').
category(X) :- entity_partition(X,major_organ).

catlist(L) :- findall(X,category(X),L).

catsub('sample_type', X, subclass(X,'FF:0000102')).
catsub('species',X, subclass(X,'FF:0000101')).
catsub('stage',X, (X='FF:0000999';X='FF:0000998')).
catsub('type',X, subclass(X,'CL:0000548')).
catsub('system',X, subclass(X,'UBERON:0000467')).
catsub('organ',X, entity_partition(X,major_organ)).

catsub(C,S) :- catsub(C,S,G),G.

sample_desc(S,D) :-
        solutions(N,(subclass(S,P),entity_label(P,N)),Ns),
        concat_atom(Ns,' & ',D).


grid_row('','',L2) :- catlist(L),maplist(entity_label,L,L2).
grid_row(ID,N,VL) :-
        catlist(CL),
        sample(ID),
        entity_label(ID,N),
        setof(C,allowed_path(ID,C),Cs),
        findall(V,(member(Cat,CL),
                   (   memberchk(Cat,Cs)
                   ->  V='YES'
                   ;   V=no)),
                VL).
grid_row('','',L2) :- catlist(L),maplist(entity_label,L,L2).

topcatlist(L) :- findall(C,catsub(C,_,_),L).

grid_row2(ID,N,L) :- grid_row(h,ID,N,L).
grid_row2(ID,N,L) :- grid_row(c,ID,N,L).
grid_row2(ID,N,L) :- grid_row(h,ID,N,L).


grid_row2(h,'ID','Name',L2) :- topcatlist(L2).
grid_row2(c,ID,N,VL) :-
        topcatlist(CL),
        sample(ID),
        entity_label(ID,N),
        findall(V,(member(Cat,CL),
                   (   solutions(T,(sample_type(ID,T),catsub(Cat,T)),Ts),
                       debug(sample,'full set(~w)[~w] = ~w',[ID,Cat,Ts]),
                       nr(Ts,Ts2),
                       V=Ts2)),
                VL).


sample_json(json([items=Items])) :-
        findall(Item,sample_json_item(Item),Items).

sample_json_item(json([id=ID,
                       label=Name,
                       transitive_type=TTs,
                       direct_type=DTs
                      |TagVals])) :-
        grid_row2(c,ID,Name,VL),
        topcatlist(CL),
        findall(C=Vs2,(nth1(Ix,CL,C),
                       nth1(Ix,VL,Vs),
                       maplist(entity_label,Vs,Vs2)),
                TagVals),
        findall(DTN,((subclass(ID,DT),
                      entity_label(DT,DTN),
                     \+catsub('sample_type',DT),
                     \+catsub('species',DT),
                     \+catsub('stage',DT))),
                DTs),
        findall(DTN,((sample_type(ID,DT),
                      entity_label(DT,DTN),
                     \+catsub('sample_type',DT),
                     \+catsub('species',DT),
                     \+catsub('stage',DT))),
                TTs).
                

write_json :-
        ensure_loaded(library(http/json)),
        sample_json(J),
        atom_json_term(A,J,[as(atom)]),
        writeln(A).

                       

ql(X,N2) :- entity_label(X,N),!,concat_atom(['"',N,'"'],N2).

nr([],[]) :- !.
nr(As,Bs) :-
        setof(B,nr_member(As,B),Bs).
nr_member(As,A) :-
        select(A,As,T),
        \+ ((member(A2,T),
             parent(A2,A))).


/*
grid_row2(RowSeed,ColSeed,Sample,Name,Vals) :-
        colseed_cols(ColSeed,Cols),
        rowseed_row2(RowSeed,Sample),
        entity_label(Sample,Name),
        findall(Val,(member(Col,Cols),
                     findall(allowed_path(Row,
*/                     
            
