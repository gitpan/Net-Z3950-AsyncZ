use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::Z3950::AsyncZ',
    'VERSION_FROM'	=> 'AsyncZ.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                              MARC::Record =>1.15,
                              MARC::Base => 0.0, 
			      Net::Z3950 => 0.31,	
			      Event => 0.86,
			      IPC::ShareLite => 0.09		
                           }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'doc/AsyncZ.pod', 
       AUTHOR     => 'Myron Turner <turnermm@shaw.ca>') : ()),
);
