MARC Perl Modules

The MARC Perl modules are a simple set of modules designed to convert
MARC 21 bibliographic records into various formats. These include:

     MARC::Base.pm converts a MARC 21 bibliographic record into an array
format, which may then be further processed. (This is used by
     the marc.pl script to convert to/from plain text.) 
     MARC::HTML.pm converts a MARC 21 bibliographic record (in the array
format) into an HTML table. 
     MARC::META.pm converts a MARC 21 bibliographic record (in the array
format) into Dublin Core Metadata. 

Download an installation package from
http://www.library.adelaide.edu.au/~sthomas/scripts/MARC/MARC.tar 

Contact:
Steve Thomas
The University of Adelaide Library
South Australia 5005
Australia
Internet e-mail address:  stephen.thomas@adelaide.edu.au
Telephone:  +61-8-8303-5190
FAX: +61-8-8303-4369



From: Mike Sosteric <mikes@athabascau.ca>
Date: 17-Jul-00 3:27 AM
Subject: make modules
To: stephen.thomas@adelaide.edu.au


in preparation for putting to use your MARC::* libraries, I put
together a Make installer that automates the installation of these
modules. 

To install these modules, all you have to do is 

1) untar the distribution into an empty directory
2) type 'perl Makefile.PL'
3) type 'make install'

the modules will be copied to system directories and then be available
for use using the 

use Marc::Base

directives.

mike
