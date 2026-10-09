package Crypter;

use 5.022;
use warnings;

use Strong::Random;
use POSIX qw(ceil);


sub new {
	my $class = shift;
	my %opts = (
		password	=> undef,
		salt	 	=> undef,
		obfuscate	=> undef,
		@_,
	);
		
	my $self  = {
		%opts,
	};

	return bless $self, $class;
}

sub _crypt_string {
	my $self = shift;
	my $str  = shift;
	
	my @input = split //, $str;

	my $out = '';
	for (my $i = 0 ; $i < scalar @input ; $i ++) {
		my $chr = $input[$i];
		my $ord = ord $chr;
		
		my $r = $self->{random}->[$self->{n}];
		$self->{n} = 0 if (++$self->{n} >= scalar @{$self->{random}});
		
		if ($self->{obfuscate}) {
			my $nr = $r->{generator}->rand($self->{obfuscate});
			for (1..$nr) {
				$out .= chr $r->{generator}->rand(256);
			}
		}
		
		my $s = $r->{generator}->rand(256);
		
		my $ord2 = $ord ^ $s;
		
		$out .= chr $ord2;
	}
	
	return $out;
}

sub _init_random_by_password {
	my $self = shift;
	
	my $password = $self->{password};
	my @random = ();
	
	for (1..ceil(length($password)/16)) {
		my $p = substr($self->{password}, 16*$_-16, 16);
		$p .= ' 'x (16 - length $p) if (length $p < 16);
		
		my $x = sprintf("%.22f", unpack('f', $p));
		$x = 1 / $x;
		

		my $rnd = new Strong::Random($x);
		$rnd->rand();
		
		$rnd->rand for 1..unpack('s', $p) % 256;
		
		my $seed = sprintf("%.8f", $rnd->{seed});
		
		push @random, {
			generator 	=> new Strong::Random($seed),
			seed		=> $seed,
		};
	}
	
	$self->{random} = \@random;
}

sub crypt {
	my $self = shift;
	my %opts = (
		input	 	=> undef,
		output	 	=> undef,
		@_,
	);
	
	my $password	= $self->{password};
	my $salt   		= $self->{salt};
	my $input  		= $opts{input};
	my $output 		= $opts{output};
	
	$$output = '' if ref $output eq 'SCALAR';
	
	# Init randomerz
	my @random;
	if (defined $password) {
		$self->_init_random_by_password;
	} else {
		for (1..ceil(length($salt)/2+.5)) {
			my $rnd = new Strong::Random;
			$rnd->rand();
			
			my $p = substr($salt, 2*$_-2, 2);
			$p .= ' ' if (length $p == 1);
			
			my $x = join '', map {ord} split //, $p;
			
			for (1..$x) {$rnd->rand()}
			
			my $seed = sprintf("%.8f", $rnd->{seed});
			push @random, {
				generator 	=> new Strong::Random($seed),
				seed		=> $seed,
			};
		}
		$self->{random} = \@random;
	}
	
	$self->{n} = 0;	

	if (ref $input eq 'GLOB') {
		while (my $str = <$input>) {
			my $out = $self->_crypt_string($str);			
			if (ref $output eq 'GLOB') {
				print $output $out;
			} else {
				$$output .= $out;
			}
		}
	} else {
		my $out = $self->_crypt_string($input);
		if (ref $output eq 'GLOB') {
			print $output $out;
		} else {
			$$output .= $out;
		}
	}
	
	unless (defined $password) {
		my $keys;
		my @out;
		for (map {$_->{seed}} @random) {
			my ($a, $b) = split /\./;
			push @out, sprintf("%Xx%X", $a, $b);
			
		}
		return join ' ', @out;
	}
	
	return;
}


sub uncrypt {
	my $self = shift;
	my %opts = (
		input	 	=> undef,
		output	 	=> undef,
		keys		=> undef,
		@_,
	);
	my $password	= $self->{password};
	my $input  		= $opts{input};
	my $output 		= $opts{output};
	my $key			= $opts{keys};
	
	$$output = '' if ref $output eq 'SCALAR';
	
	if ($password) {
		$self->_init_random_by_password;
	} else {
		my @random;
		if ($key =~ /x/) {
			for (split /\s+/, $key) {
				my ($a, $b) = split /x/, $_;
				my $seed = hex ($a) . '.' . hex ($b);
				push @random, {
					generator 	=> new Strong::Random($seed), 
					seed 		=> $seed, 
				};
			}
		} else {
			# Support old format of keyfile
			@random = map {{
				generator 	=> new Strong::Random($_), 
				seed 		=> $_ 
			}} split /,/, $key;
		}
		
		$self->{random} = \@random;
	}
	
	$self->{n} = 0;
	
	if (ref $input eq 'GLOB') {
		while (my $str = <$input>) {
			my @input = split //, $str;
			my $out = '';
			for (my $i = 0 ; $i < scalar @input ; $i ++) {
				my $chr = $input[$i];
				my $ord = ord $chr;
				
				
				my $r = $self->{random}->[$self->{n}];
				$self->{n} = 0 if (++$self->{n} >= scalar @{$self->{random}});

				if ($self->{obfuscate}) {
					my $nr = $r->{generator}->rand($self->{obfuscate});
					for (1..$nr) {
						$r->{generator}->rand(256);
						$i ++;
						if ($i >= scalar @input) {
							$str = <$input>;
							push @input, split //, $str;
						}
					}
					
					$chr = $input[$i];
					
					$ord = ord $chr;
				}
				
				my $s = $r->{generator}->rand(256);
				
				my $ord2 = $ord ^ $s;
				
				$out .= chr $ord2;
			}
			if (ref $output eq 'GLOB') {
				print $output $out;
			} else {
				$$output .= $out;
			}
		}
	} else {
		my @input = split //, $input;
		my $out = '';
		for (my $i = 0 ; $i < scalar @input ; $i ++) {
			my $chr = $input[$i];
			my $ord = ord $chr;
			
			
			my $r = $self->{random}->[$self->{n}];
			$self->{n} = 0 if (++$self->{n} >= scalar @{$self->{random}});

			if ($self->{obfuscate}) {
				my $nr = $r->{generator}->rand($self->{obfuscate});
				for (1..$nr) {
					$r->{generator}->rand(256);
					$i ++;
				}
				
				$chr = $input[$i];
				
				$ord = ord $chr;
			}
			
			my $s = $r->{generator}->rand(256);
			
			my $ord2 = $ord ^ $s;
			
			$out .= chr $ord2;
		}
		if (ref $output eq 'GLOB') {
			print $output $out;
		} else {
			$$output .= $out;
		}
	}
}

1;

