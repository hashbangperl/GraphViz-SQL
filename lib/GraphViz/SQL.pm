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
    my $raw_data = $self->{parser}->structure;
    $self->{parsed_structure} = { tables => {}, table_aliases => { }, relations => [] };
    foreach my $table_name (@{$raw_data->{org_table_names}}) {
	my $table = { name => $table_name, columns => [ ], aliases => [] };
	if ($raw_data->{table_alias}{$table_name}) {
	    foreach my $alias (@{$raw_data->{table_alias}{$table_name}}) {
		push(@{$table->{aliases}}, $alias);
		$self->{parsed_structure}{table_aliases}{$alias} = $table_name;
	    }
	}
	$self->{parsed_structure}{tables}{$table_name} =  $table;
    }

    foreach my $column (@{$raw_data->{column_defs}}) {
	my ($column_name, $table, $schema) = reverse split (/\./, $column->{value});

	$column->{name} = $column_name;
	push (@{$self->{parsed_structure}{tables}{$table}{columns}}, $column);
    }

    foreach my $join ($raw_data->{join}) {
	push(@{$self->{parsed_structure}{relations}}, {
						       from => $join->{table_order}[0],
						       to => $join->{table_order}[1],
						       label => join(' ', $join->{type}, 'join',  $join->{clause}, $join->{keycols}[0], '=', $join->{keycols}[0])
						      });
    }

    return $self->{parsed_structure};
}

my %dot_filetypes = (
                     gif => 'as_gif',
                     png => 'as_png',
                     jpg => 'as_jpeg',
                     jpeg => 'as_jpeg',
                     dot => 'as_canon',
                     svg => 'as_svg',
                     fig => 'as_fig',
                    );


sub visualise {
    my $self = shift;
    my $filename = shift;

    my %nodes;

    my $g = GraphViz->new();

    foreach my $table (values %{$self->tables}) {
        my $node = '{'.$table->{name}." aliases (" . join (',', @{$table->{aliases}}) . " ) |";
	foreach my $table_column ( @{$table->{columns}} ) {
            $node .= $table_column->{name}.'\l';
	}
	$node .= '}';
	$nodes{$table->{name}} = $node;
        $g->add_node($node,shape=>'record');
    }

    foreach my $join (@{$self->joins}) {
	$g->add_edge($nodes{$join->{from}} => $nodes{$join->{to}}, label => $join->{label} );
    }
    my ($extension) = reverse split(/\./, $filename);

    open (FILE,">$filename") or die "couldn't open $filename file for output : $!\n";
    binmode FILE;
    eval 'print FILE $g->'. $dot_filetypes{$extension};
    close FILE;

    return;
}

sub tables {
    return shift->{parsed_structure}{tables};
}

sub joins {
    return shift->{parsed_structure}{relations};
}



#           'where_cols' => {
#                             'a.quuz' => [
#                                           '2'
#                                         ]

#           'where_clause' => {
#                               'arg2' => {
#                                           'value' => '2',
#                                           'type' => 'number',
#                                           'fullorg' => '2'
#                                         },
#                               'arg1' => {
#                                           'value' => 'table_a.quuz',
#                                           'type' => 'column',
#                                           'fullorg' => 'a.quuz'
#                                         },
#                               'nots' => {},
#                               'neg' => 0,
#                               'op' => '='
#                             },
#           'list_ids' => [],



#           'column_defs' => [
#                              {
#                                'value' => 'table_a.foo',
#                                'type' => 'column',
#                                'alias' => 'f1',
#                                'fullorg' => 'a.foo'
#                              },
#                              {
#                                'value' => 'table_b.bar',
#                                'type' => 'column',
#                                'alias' => 'b1',
#                                'fullorg' => 'b.bar'
#                              }
#                            ],



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
