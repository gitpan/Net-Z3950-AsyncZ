use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	   => 'Marc',
    'PM'           => {'Base.pm' => '$(INST_LIBDIR)/MARC/Base.pm', 
		       'HTML.pm' => '$(INST_LIBDIR)/MARC/HTML.pm', 
		       'META.pm' =>'$(INST_LIBDIR)/MARC/META.pm' },
    'MAN3PODS'     => {'Base.pm' => '$(INST_MAN3DIR)/MARC::Base.$(MAN3EXT)', 
		       'HTML.pm' => '$(INST_MAN3DIR)/MARC::HTML.$(MAN3EXT)', 
		       'META.pm' => '$(INST_MAN3DIR)/MARC::META.$(MAN3EXT)'
}
  );
