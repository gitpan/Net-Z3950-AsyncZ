package MARC::HTML;

=head1 NAME

MARC::HTML.pm

=head1 SYNOPSIS

    $html = &array2html (@marc_array);

These variables are also accessible:

    @MARC::HTML::html_fields
    %MARC::HTML::html_names
    %MARC::HTML::html_hash
    %MARC::HTML::html_map

=head1 DESCRIPTION

MARC::HTML.pm takes as input a MARC array structure (as output by
MARC::Base::marc2array) and returns an HTML formatted version of the
MARC content, as a string.

The input record is formatted as an HTML TABLE, with two columns: the
left column contains a field description ('Title', 'Subject', ...) while
the right column contains the actual record data.

MARC fields are minimally converted to text fields. In some cases,
multiple MARC fields are combined into a single output field, e.g.
'Subject' combines all instances of 6xx MARC fields into a single text
field, with multiples separated by a line break.

Several data structures are also available if needed:

=over 4

=item *

@html_fields is a list of fields required for output, defining the order
of output.

=item *

%html_names is a hash of fields containing the name (description) to be
used for each field in the output.

=item *

%html_hash is a hash of fields containing the data for each output field,
as a string. This may be useful if you wish to do some post-processing
of the data.

=item *

%html_map is a hash mapping each required MARC tag to an output field
name, and specifying whether multiple values are allowed, and a
replacement string for the subfield delimiter and subfield code.

=back

=head1 VERSION

Version 2.004 (2000-Jun-14)

Added titles (730 & 740) are mapped separately.
Suppress 24x subfield i.

Version 2.003 (1999-Nov-11)

The latest version of this script should be found at:
http://www.library.adelaide.edu.au/~sthomas/scripts/

=head1 AUTHOR

Steve Thomas <sthomas@library.adelaide.edu.au>

=head1 LICENCE

Copyright (C) 1998,1999  Steve Thomas

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut


require Exporter;
@ISA = Exporter;
@EXPORT = qw(array2html @html_fields %html_names %html_hash %html_map);


# A printf pattern for URLs
$urlpattern = '<A HREF="%s">%s</A>';

@html_fields = ( 'author','corpauth','title','vartitle','utitle',
    'edition','publisher','frequency','subjects',
    'contents','summary','access','note',
    'category','resource_type',
    'series','related','added_title','includes','isbn','issn');

%html_names = (
	isbn		=> 'ISBN',
	issn		=> 'ISSN',
	author		=> 'Author',
	corpauth	=> 'Corpauth',
	title		=> 'Title',
	vartitle	=> 'Title Var.',
	added_title	=> 'Added Title',
	edition		=> 'Edition',
	publisher	=> 'Publisher',
	timespan	=> 'Timespan',
	frequency	=> 'Frequency',
	subjects	=> 'Subjects',
	contents	=> 'Contents',
	note		=> 'Note',
	summary		=> 'Summary',
	series		=> 'Series',
	related		=> 'Related',
	includes	=> 'Includes',
	category	=> 'Category',
	resource_type	=> 'Resource Type',
	access		=> 'Access',
    );

%html_map = (
	'001'	=> [ 'id', 'n', ' ' ],
	'020'	=> [ 'isbn', 'n', ' ' ],
	'022'	=> [ 'issn', 'n', ' ' ],
	'100'	=> [ 'author', 'n', ' ' ],
	'110'	=> [ 'corpauth', 'n', ' ' ],
	'130'	=> [ 'utitle', 'n', ' ' ],
	'245'	=> [ 'title', 'n', ' ' ],
	'246'	=> [ 'vartitle', 'n', ' ' ],
	'250'	=> [ 'edition', 'n', ' ' ],
	'260'	=> [ 'publisher', 'n', ' ' ],
	'310'	=> [ 'frequency', 'n', ' ' ],
	'362'	=> [ 'timespan', 'n', ' ' ],
	'440'	=> [ 'series', 'y', ' ' ],
	'505'	=> [ 'contents', 'y', ' ' ],
	'516'	=> [ 'note', 'y', ' ' ],
	'520'	=> [ 'summary', 'y', ' ' ],
	'540'	=> [ 'note', 'y', ' ' ],
	'561'	=> [ 'note', 'y', ' ' ],
	'594'	=> [ 'access', 'y', ' ' ],
	'600'	=> [ 'subjects', 'y', ' : ' ],
	'610'	=> [ 'subjects', 'y', ' : ' ],
	'611'	=> [ 'subjects', 'y', ' : ' ],
	'630'	=> [ 'subjects', 'y', ' : ' ],
	'650'	=> [ 'subjects', 'y', ' : ' ],
	'651'	=> [ 'subjects', 'y', ' : ' ],
	'695'	=> [ 'category', 'y', '<BR>' ],
	'696'	=> [ 'resource_type', 'n', ' ' ],
	'700'	=> [ 'related', 'y', ' ' ],
	'710'	=> [ 'related', 'y', ' ' ],
	'720'	=> [ 'related', 'y', ' ' ],
	'730'	=> [ 'added_title', 'y', ' ' ],
	'740'	=> [ 'added_title', 'y', ' ' ],
	'753'	=> [ 'access', 'y', ' ' ],
	'830'	=> [ 'series', 'y', ' ' ],
	'856'	=> [ 'access', 'y', ' ' ],
    );

sub array2html {

    %html_hash = ();

    # step thru directory and extract data for each required tag
    foreach ( @_ ) {
        $tag = substr($_, 0, 3);
        $field = substr($_, 4);		# skip the blank separator
	$indic1 = substr($_, 4, 1);
	$indic2 = substr($_, 5, 1);

	next if ($tag =~ /LDR|9../);

        if ($tag eq '035' and $field =~ /\(SUA\)(\d+)/) {
	    #$field =~ s/adl//;	# remove the leading 'adl' string
	    #$html_hash{id} = $field;
	    $html_hash{id} = $1;
            next;
	}

	# suppress subfield i (label) if present
        if ($tag =~ /24[56]/) {
	    $field =~ s/\|i.*?\|/|/;
	}

        if ($tag eq '856') {
            (undef,@sfs) = split /\|/, $field;
            undef $url;
            undef $format;
            undef $note;
            foreach (@sfs) {
                $sf = substr $_, 0, 1;
                if ($sf eq 'u') {$url = substr $_, 1; next; }
                if ($sf eq 'q') {$format = substr $_, 1; next; }
                if ($sf eq 'z') {$note = substr $_, 1; next; }
            }
	    $field = '';
	    if (defined $url) {
		$field = sprintf $urlpattern,$url,$url;
		if (defined $note) { $field .= " [$note]"; }
		&append_field('access',$field);
	    }
            next;
        }

        if (defined $html_map{$tag}) {
	    my ($name, $append, $sfreplace) = @{ $html_map{$tag} };
	    # Special case: 700-740, indicator 2 = 2 changes output field
	    if ($tag =~ /7[0-4]0/) {
		if ($indic2 eq '2') { $name = 'includes'; }
	    }
	    if ($append eq 'n') {
		$html_hash{ $name } = &strip_field($field, $sfreplace);
	    } else {
		&append_field($name,&strip_field($field,$sfreplace));
	    }
            next;
        }

    }

    # now format the extracted data as a string of HTML ...

    $html = qq|<TABLE BORDER=0>\n|;

    foreach $name (@html_fields) {
	if (defined $html_hash{$name}) {
	    $html .= qq|<TR><TD VALIGN="top"><B>|;
	    if (defined $html_names{$name}) {
		$html .= qq|$html_names{$name}:|;
	    }
	    $html .= qq|</B></TD>|;
	    $html .= qq|<TD>$html_hash{$name}</TD></TR>\n|;
	}
    }
    $html .= qq|</TABLE>\n|;

    # ... and return the string
    return $html;
}

sub strip_field {
    my ($field, $sfreplace) = @_;
    $field =~ s/^....//;        	# throw out the indicators and 1st sf
    $field =~ s/\|./$sfreplace/g;	# convert other sf delims to string
    $field =~ s#/AN\d{3}/##g;		# strip diacritics
    return $field;
}

sub append_field {
    my ($name, $value) = @_;
    if (defined $html_hash{$name}) {
	$html_hash{$name} .= '<BR>';
    } else {
	$html_hash{$name} = '';
    }
    $html_hash{$name} .= $value;
}

1
