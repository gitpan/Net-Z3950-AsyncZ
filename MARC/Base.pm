package MARC::Base;

=head1 NAME

MARC.pm

=head1 SYNOPSIS

    @marc_array = &marc2array ($marc_record);
    $marc_record = &array2marc (@marc_array);

    $MARC::Base::REC_SEP (MARC Record Separator: 0x1d)

=head1 DESCRIPTION

MARC::Base.pm contains a set of utilities for encoding and decoding MARC
format records.

A MARC record is simply an ASCII string of arbitrary length.

=head2 MARC record structure

    Leader: start: 0 length: 24
	Base Address (start of data): start: 12 length: 5
    Directory: start: 24, length: (base - 24)
	Tag number: 3 bytes
	data length: 4 bytes
	data offset: 5 bytes

    Subfields begin with 0x1f
    Fields end with 0x1e
    Records end with 0x1d

=head2 Array element structure

The encoding/decoding routines make use of a simple array structure,
where each array element contains the tag and data for a single MARC
field, separated by a single space.

	cols. 0-2 : tag number
	col.  3   : blank
	cols. 4-5 : indicators
	cols. 6-  : tag data

e.g.

	245 10|aSome title|h[GMD]

The '|' character is used to represent MARC subfield separators (0x1f).

If it is desired to provide particular Leader codes, a template MARC
record Leader can be provided using 'LDR' as Tag, e.g.

	LDR 00000nas  2200000uu 4500

This will be replaced in the output record with a leader reflecting the
correct record and directory lengths.

=head1 VERSION

Version 2.001 (1999-Mar-29)

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
@EXPORT = qw(marc2array array2marc $REC_SEP);

# MARC record separator (0x1d)
$REC_SEP = chr(29);

sub marc2array {
    $_ = shift;

    my @marc = ();
    my ($base, $ntags, $j, $k, $tag, $len, $off, $field);

    $marc[0] = 'LDR ' . substr($_, 0, 24);

    # get the base address of the data portion
    $base = substr($_, 12, 5);

    # compute the number of tags (allow for trailing field sep. in DIR)
    $ntags = ($base - 25) / 12;

    # step thru directory and print each tag and its data
    for ( $j = 0; $j < $ntags; $j++ ) {
	$k = ($j * 12) + 24;		# dir start for this tag
	$tag = substr($_, $k, 3);	# the tag
	$len = substr($_, $k + 3, 4);	# the field length
	$off = substr($_, $k + 7, 5);	# the field start relative to base

	# extract the field data
	$field = substr($_, $base + $off, $len);

	# convert subfield, field and record delimiters
	$field =~ tr/\037\036\035/|/d;

	# print out the field tag and data!
	push (@marc, $tag . ' ' . $field);
    }

    return @marc;

}

sub array2marc {
    my @trec = @_;

    # initialise stuff
    my $offset = 0;
    my $dir = '';
    my $data = '';

    # default pattern for leader
    my $ldrpat = "%05dnas  22%05duu 4500";

    # if a leader is included, build the pattern from that ...
    if ( $trec[0] =~ /^LDR/ ) { # leader codes
	$line = shift(@trec);
	# use the leader to create a pattern for building the leader later on
	# only the RS, MC, BLC, EL, DCC and Linked are used
	$ldrpat = '%05d'.substr($line,9,3).'  22%05d'.substr($line,21,3).'4500';
    }

    # process all the tags in sequence
    foreach $line ( @trec ) {

	# build the directory and data portions
	$tag = substr($line, 0, 3);
	$field = substr($line, 4);		# get the data for the tag
	unless ($tag lt '010') {
	    $field =~ tr/\|/\037/s;	# change subfield delimiter(s)
	}
	$field =~ s/$/\036/;	# append a field terminator
	$fldlen = length($field);
	$dir .= sprintf("%3s%04d%05d",$tag,$fldlen,$offset);
	$offset += $fldlen;
	$data .= $field;
    }

    # append a field terminator to the directory
    $dir =~ s/$/\036/;

    # append the record terminator
    $data =~ s/$/\035/;

    # compute lengths
    $base = length($dir) + 24;	# base address of data
    $lrl = $base + length($data);	# logical record length

    # return the complete MARC record
    return (sprintf $ldrpat,$lrl,$base)			# leader
	    . $dir					# directory
	    . $data;					# data

}

1;
