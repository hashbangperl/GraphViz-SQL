use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'GraphViz::SQL',
    VERSION_FROM      => 'lib/GraphViz/SQL.pm', # finds $VERSION
    PREREQ_PM         => {
			GraphViz => 0,
			SQL::Statement => 1.10,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
       (AUTHOR         => 'Aaron Trevena <teejay@(none)>') : ()),
);
