:- use_module(bio(index_util)).
:- use_module(bio(ontol_db)).


ix :-
        %materialize_index_to_file(allowed_path(1,1),'cache.pro').
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
        id_idspace(S,'FF').

sample_type(S,C) :-
        sample(S),
        allowed_path(S,C),
        \+ id_idspace(C,'FF').

category(X) :- subclass(X,'FF:0000102').
category(X) :- subclass(X,'FF:0000101').
category(X) :- subclass(X,'CL:0000548').
category(X) :- subclass(X,'UBERON:0000467').
category(X) :- entity_partition(X,major_organ).

catlist(L) :- findall(X,category(X),L).

catsub('sample type', X) :- subclass(X,'FF:0000102').
catsub('species',X) :- subclass(X,'FF:0000101').
catsub('cell type',X) :- subclass(X,'CL:0000548').
catsub('system',X) :- subclass(X,'UBERON:0000467').
catsub('organ',X) :- entity_partition(X,major_organ).

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

%topcatlist(L) :- setof(C,S^catsub(C,S),L).
%topcatlist(L) :- findall(C,S^catsub(C,S),L).


grid_row2('','',L2) :- topcatlist(L2).
grid_row2(ID,N,VL) :-
        topcatlist(CL),
        sample(ID),
        entity_label(ID,N),
         findall(V,(member(Cat,CL),
                    (   solutions(T,(sample_type(ID,T),catsub(Cat,T)),Ts),
                        nr(Ts,Ts2),
                        maplist(ql,Ts2,Ts3),
                        concat_atom(Ts3,' ',V))),
                 VL).
grid_row2('','',L2) :- topcatlist(L2).

ql(X,N2) :- entity_label(X,N),!,concat_atom(['"',N,'"'],N2).

nr(As,Bs) :-
        setof(B,member(B,As),Bs).
nr_member(As,A) :-
        select(A,As,T),
        \+ ((member(A2,T),
             parentT(A2,A))).


/*
grid_row2(RowSeed,ColSeed,Sample,Name,Vals) :-
        colseed_cols(ColSeed,Cols),
        rowseed_row2(RowSeed,Sample),
        entity_label(Sample,Name),
        findall(Val,(member(Col,Cols),
                     findall(allowed_path(Row,
*/                     
            
