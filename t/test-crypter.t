#!/usr/bin/perl

use 5.022;
use warnings;

use File::Temp qw(tempfile);
use FindBin qw($Bin);
use Test::Simple tests => 1;

use Strong::Random;

ok (test_crypted(), 'Test crypter success!');

sub test_crypted {
	my $rand = new Strong::Random;

	my $salt = join'', map +(0..9,'a'..'z','A'..'Z')[$rand->rand(10+26*2)], 1..32;

	my (undef, $filename) = tempfile();

	`cat /dev/random|head -n 10000 > $filename`;
	`$Bin/../crypter -i $filename -o $filename.crypted -s $salt`;
	`$Bin/../crypter -d $filename.crypted -o $filename.uncrypted`;
	my $diff = `diff $filename $filename.uncrypted`;

	unlink $filename;
	unlink $filename.'.crypted';
	unlink $filename.'.crypted.key';
	unlink $filename.'.uncrypted';


	if ($diff) {
		return 0;
	}

	return 1;
}


