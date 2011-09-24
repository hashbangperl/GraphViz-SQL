use Test::More;
use strict;

use GraphViz::SQL;

use Data::Dumper;

my $viz = GraphViz::SQL->new();

my $test_sql = <<SQL;
select a.foo as f1, b.bar as b1
from table_a a left join table_b b on a.id = b.a_id
where a.quuz = 2
SQL

my $data = $viz->parse($test_sql);

warn Dumper(sql => $data);

$viz->visualise('test.png');

ok(1);

done_testing;
