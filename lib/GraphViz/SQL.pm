package GraphViz::SQL;

use strict;
use warnings;

=head1 NAME

GraphViz::SQL - SQL Query/Table visualisation using GraphViz

=head1 SYNOPSIS

  use GraphViz::SQL;


=head1 DESCRIPTION

SQL Query/Table visualisation using GraphViz

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

use SQL::Parser;

use GraphViz;

sub new {
    my ($class, $args) = @_;
    my $parser = SQL::Parser->new();
    my $self = { dialect => $args->{dialect} || 'ansi', parser => $parser };
    bless ($self, $class);
    return $self;
}

sub parse {
    my ($self, $sql) = @_;
    my $success = $self->{parser}->parse($sql);
    return 0 unless $success;
    $self->{parsed_structure} = $self->{parser}->structure;
    return $self->{parsed_structure};
}

sub visualise {
    my $self = shift;
    my $filename = shift;

    my %nodes;

    my $g = GraphViz->new();

    foreach my $table (@$tables) {
	
        my $node = '{'.$table."|";
	foreach my $table_column ( grep {$_->{table} eq $table } @$columns ) {
            $node .= $table_column->{name}.'\l';
	}
	$node .= '}';
	$nodes{$table} = $node;
        $g->add_node($node,shape=>'record');
    }

    foreach my $join (@joins) {
	$g->add_edge($nodes{$left_table} => $nodes{$right_table} );
    }

    open (FILE,">$output_filename") or die "couldn't open $output_filename file for output : $!\n";
    binmode FILE;
    eval 'print FILE $g->'. $dot_filetypes{$extension};

    close FILE;

    return;
}
 

my $example_structure = {
    'table_alias' => {
	'table_a' => [
	    'a'
	    ],
	    'table_b' => [
		'b'
	    ]
    },
	    'ALIASES' => {
		'f1' => 'a.foo',
		'b1' => 'b.bar'
                       },
          'original_string' => 'select a.foo as f1, b.bar as b1
from table_a a left join table_b b on a.id = b.a_id
where a.quuz = 2',
          'org_table_names' => [
                                 'table_a',
                                 'table_b'
                               ],
          'where_cols' => {
                            'a.quuz' => [
                                          '2'
                                        ]
                          },
          'ORG_NAME' => {
                          'b.bar' => 'b1',
                          'a.foo' => 'f1'
                        },
          'column_aliases' => {
                                'b.bar' => 'b1',
                                'a.foo' => 'f1'
                              },
          'where_clause' => {
                              'arg2' => {
                                          'value' => '2',
                                          'type' => 'number',
                                          'fullorg' => '2'
                                        },
                              'arg1' => {
                                          'value' => 'table_a.quuz',
                                          'type' => 'column',
                                          'fullorg' => 'a.quuz'
                                        },
                              'nots' => {},
                              'neg' => 0,
                              'op' => '='
                            },
          'list_ids' => [],
          'join' => {
                      'keycols' => [
                                     'table_a.id',
                                     'table_b.a_id'
                                   ],
                      'clause' => 'ON',
                      'table_order' => [
                                         'table_a',
                                         'table_b'
                                       ],
                      'type' => 'LEFT OUTER'
                    },
          'org_col_names' => [
                               'f1',
                               'b1'
                             ],
          'dialect' => 'ANSI',
          'table_names' => [
                             'table_a',
                             'table_b'
                           ],
          'column_defs' => [
                             {
                               'value' => 'table_a.foo',
                               'type' => 'column',
                               'alias' => 'f1',
                               'fullorg' => 'a.foo'
                             },
                             {
                               'value' => 'table_b.bar',
                               'type' => 'column',
                               'alias' => 'b1',
                               'fullorg' => 'b.bar'
                             }
                           ],
          'command' => 'SELECT'
        };



=head1 SEE ALSO

GraphViz

GraphViz::DBI

SQL::Statement

=head1 AUTHOR

Aaron Trevena, E<lt>teejay@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Aaron Trevena

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut

1;
