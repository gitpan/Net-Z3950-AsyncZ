package MARC::META;

=head1 NAME

MARC::META.pm

=head1 SYNOPSIS

    $meta = &marc2meta (@marc_array);

=head1 DESCRIPTION

MARC::META.pm takes as input a MARC array structure (as output by
MARC::Base::marc2array) and returns META data formatted as a string.

The metadata is formatted as HTML META tags, using the Dublin Core
schema.

=head1 VERSION

Version 1.000 (2000-Mar-22)

The latest version of this script should be found at:
http://www.library.adelaide.edu.au/~sthomas/scripts/

=head1 AUTHOR

Steve Thomas <sthomas@library.adelaide.edu.au>

=head1 LICENCE

Copyright (C) 2000  Steve Thomas

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
@EXPORT = qw(marc2meta);


# A printf pattern for URLs
$urlpattern = '<A HREF="%s">%s</A>';

sub marc2meta {

    my ($tag, $field);

    $creator = $title = $uniform = $rights = $publisher = 
    $pubyear = $series = $seriesno = $lang = "";
    $description = $contents = $summary = "";
    @subject = ();
    @contributor = ();
    @url = ();

    $copydate = 0;
    $first740 = 1;

    $meta = qq|<link rel="schema.DC" href="http://purl.org/dc">\n|; 

    # step thru directory and extract data for each required tag
    foreach ( @_ ) {
        $tag = substr($_, 0, 3);

	next if ($tag =~ /LDR|9../);

        $field = substr($_, 4);		# skip the blank separator
	$indic1 = substr($_, 4, 1);
	$indic2 = substr($_, 5, 1);

        if ($tag eq '008') {
	    $lang = substr($field, 35, 3);
	    $meta .= qq|<meta name="DC.Language" scheme="MARC21-lang" content="$lang">\n| if $lang;
	    next;
	}

	# convert special chars. likely to conflict with HTML
	$field =~ s/"/\&#034;/g;
	$field =~ s/\&/\&amp;/g;
	$field =~ s/\</\&lt;/g;
	$field =~ s/\>/\&gt;/g;

	(undef,@sfs) = split /\|/, $field;

        if ($tag eq '856') {
            undef $url;
            undef $format;
            undef $note;
            foreach (@sfs) {
                $sf = substr $_, 0, 1;
                if ($sf eq 'u') {$url = substr $_, 1; next; }
                if ($sf eq 'q') {$format = substr $_, 1; next; }
                if ($sf eq 'z') {$note .= substr $_, 1; next; }
            }
	    &add_meta ("Format", $format);
	    &add_meta ("Identifier", $url);
            next;
        }

        if ($tag eq '260') {
            undef $publisher;
            undef $pubyear;
            foreach (@sfs) {
                $sf = substr $_, 0, 1;
                if ($sf eq 'b') {$publisher = substr $_, 1; next; }
                if ($sf eq 'c') {$pubyear = substr $_, 1; next; }
            }
	    &add_meta ("Publisher", $publisher);
	    &add_meta ("Date.Published", $pubyear);
            next;
        }
        if ( ($tag eq '440') or ($tag eq '830') ) {
            undef $series;
            undef $seriesno;
            foreach (@sfs) {
                $sf = substr $_, 0, 1;
                if ($sf eq 'a') {$series = substr $_, 1; next; }
                if ($sf eq 'v') {$seriesno = substr $_, 1; next; }
            }
	    if ($seriesno) {
		&add_meta ("Relation.IsPartOf", "$series; v.$seriesno");
	    } else {
		&add_meta ("Relation.IsPartOf", "$series");
	    }
            next;
        }

	# other fields don't need subfield separation
        $field =~ s/^....//;        # throw out the indicators and 1st sf

        if ($tag =~ /6../) {
	    $field =~ s/\|./--/g;
	    &add_meta ("Subject", $subject);
	    next;
	}

        $field =~ s/\|./ /g;        # convert other sf delims to space

        if ( ($tag eq '100') or ($tag eq '110') ) {
	    &add_meta ("Creator", $field);
	    next;
	}
        if ( ($tag eq '130') or ($tag eq '240') ) { # uniform title
	    &add_meta ("Title.Uniform", $field);
	    next;
	}
        if ($tag eq '700') {
	    &add_meta ("Contributor", $field);
	    next;
	}
        if ($tag eq '500') {
	    $description .= "Note: $field ";
	    next;
	}
        if ($tag eq '505') {
	    &add_meta ("Description.Contents", $field);
	    next;
	}
        if ($tag eq '520') {
	    &add_meta ("Description.Summary", $field);
	    next;
	}
        if ($tag eq '540') {
	    &add_meta ("Rights", $field);
	    next;
	}
        if ($tag eq '740') {
	    &add_meta ("Description.Includes", $field);
	    next;
	}
        if ($tag eq '245') {
	    ($title,$resp) = split / \/ /, $field;
	    $title =~ s/\s*\[electronic text\]//i;
	    $description = "$resp. " if $resp;
	    &add_meta ("Title", $title);
	    next;
	}

    }

    # ... and return the string
    return $meta;
}

sub add_meta {
    # adds a metadata entry for the name specified, if there's content
    my ($name, $content) = @_;
    $meta .= qq|<meta name="DC.$name"
      content="$content">\n| if $content;
}

sub strip_field {
    my ($field, $sfreplace) = @_;
    $field =~ s/^....//;        	# throw out the indicators and 1st sf
    $field =~ s/\|./$sfreplace/g;	# convert other sf delims to string
    $field =~ s#/AN\d{3}/##g;		# strip diacritics
    return $field;
}

1
