#!/usr/bin/perl

while (<>) {
    chomp;
    next if m@\.fq\.gz$@;
    next if m@_sdrf\.txt$@;
    my ($sp, $type, $tech);
    if (m@f5pipeline/(\w+)\.(\w+)\.(\w+)/@) {
        ($sp, $type, $tech) = ($1,$2,$3);

        if ($sp eq 'dog') {
            $sp = 'FF:0000016 ! canine sample';
        }
        elsif ($sp eq 'chicken') {
            $sp = 'FF:0000032 ! chicken sample';
        }
        elsif ($sp eq 'mouse') {
            $sp = 'FF:0000103 ! mouse sample';
        }
        elsif ($sp eq 'rat') {
            $sp = 'FF:0000147 ! rat sample';
        }
        elsif ($sp eq 'human') {
            $sp = 'FF:0000210 ! human sample';
        }
        else {
            die $sp;
        }

        if ($type eq 'cell_line') {
            $type = 'FF:0000003 ! cell line sample';
        }
        elsif ($type eq 'tissue') {
            $type = 'FF:0000004 ! tissue sample';
        }
        elsif ($type eq 'primary_cell') {
            $type = 'FF:0000002 ! in vivo cell sample';
        }
        else {
            $type = '';
        }

    }
    else {
        print STDERR "NO SPECIES: $_\n";
    }
    s@.*/@@;
    s@\.\w+\.(\d+\-[\dA-Z]+)\..*@@;
    $id = $1;
    s/\%20/ /g;
    s/\%2c/\,/g;
    s/\%3a/\:/g;
    s/\%([a-f0-9][a-f0-9])/chr( hex( $1 ) )/eig;
    if ($id) {
        print "FF:$id\t$_\t$sp\t$type\n";
    }
    else  {
        print STDERR "No parse: $_\n";
    }
}
