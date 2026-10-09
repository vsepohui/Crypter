package Strong::Random;

use 5.022;
use warnings;

use Time::HiRes;


sub new {
	my $class = shift;
	my $seed  = shift;
	
	my $self = {
		seed => $seed // $class->_shuffle_seed(),
	};
	
	return bless $self, $class;
}


sub _shuffle_seed {
	my $class = shift;
	return (join '.', reverse Time::HiRes::gettimeofday) . $$;
}

sub _harmonic {
	my $self = shift;
	my $x = $self->{seed};
	
	state $half_freq = 2/7.0;

	my $step = int ($x / $half_freq);
	$x -= $step * $half_freq;

	return ($step % 2 ? -1 : 1)*sqrt (1 - $x*$x);
}

sub srand {
	my $self = shift;
	my $seed = shift // $self->_shuffle_seed();
	$self->{seed} = $seed;
}

sub rand {
	my $self = shift;
	my $num = shift;
	
	my $r = ($self->_harmonic()+1)/2.0;
	$self->{seed} *= $r+1.5;
	$self->{seed} /= 2 if ($self->{seed} >= 100000000);

	my $s = $r;
	$s =~ s/\.//;
	$r *= substr($s, -5, -1) || 0;
	$r = substr($r, 0, 22);
	$r =~ s/\.//;
	$r = '0.'.$r;

	return $num ? int $num * $r : $r;
}

1;
