package Error::Pure::Die;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Error::Pure::Utils qw(err_helper);
use List::MoreUtils qw(none);
use Readonly;

# Version.
our $VERSION = 0.22;

# Constants.
Readonly::Array our @EXPORT_OK => qw(err);
Readonly::Scalar my $EVAL => 'eval {...}';
Readonly::Scalar my $EMPTY_STR => q{};

# Process error.
sub err {
	my @msg = @_;

	# Get errors structure.
	my @errors = err_helper(@msg);

	# Finalize in main on last err.
	my $stack_ar = $errors[-1]->{'stack'};
	if ($stack_ar->[-1]->{'class'} eq 'main'
		&& none { $_ eq $EVAL || $_ =~ /^eval '/ms }
		map { $_->{'sub'} } @{$stack_ar}) {

		my $die = (join $EMPTY_STR, @{$errors[-1]->{'msg'}}).
			" at $stack_ar->[0]->{'prog'} line ".
			"$stack_ar->[0]->{'line'}.";
		die "$die\n";

	# Die for eval.
	} else {
		die "$errors[-1]->{'msg'}->[0]\n";
	}

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Error::Pure::Die - Error::Pure module with classic die.

=head1 SYNOPSIS

 use Error::Pure::Die qw(err);
 err 'This is a fatal error', 'name', 'value';

=head1 SUBROUTINES

=over 8

=item C<err(@messages)>

 Process error with messages @messages.

=back

=head1 EXAMPLE1

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Error::Pure::Die qw(err);

 # Error.
 err '1';

 # Output:
 # 1 at example1.pl line 9.

=head1 EXAMPLE2

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Error::Pure::Die qw(err);

 # Error.
 err '1', '2', '3';

 # Output:
 # 1 at example2.pl line 9.

=head1 EXAMPLE3

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Dumpvalue;
 use Error::Pure::Die qw(err);
 use Error::Pure::Utils qw(err_get);

 # Error in eval.
 eval { err '1', '2', '3'; };

 # Error structure.
 my @err = err_get();

 # Dump.
 my $dump = Dumpvalue->new;
 $dump->dumpValues(\@err);

 # In \@err:
 # [
 #         {
 #                 'msg' => [
 #                         '1',
 #                         '2',
 #                         '3',
 #                 ],
 #                 'stack' => [
 #                         {
 #                                 'args' => '(1)',
 #                                 'class' => 'main',
 #                                 'line' => '9',
 #                                 'prog' => 'script.pl',
 #                                 'sub' => 'err',
 #                         },
 #                         {
 #                                 'args' => '',
 #                                 'class' => 'main',
 #                                 'line' => '9',
 #                                 'prog' => 'script.pl',
 #                                 'sub' => 'eval {...}',
 #                         },
 #                 ],
 #         },
 # ],

=head1 DEPENDENCIES

L<Exporter>,
L<List::MoreUtils>,
L<Readonly>.

=head1 SEE ALSO

L<Error::Pure>,
L<Error::Pure::AllError>,
L<Error::Pure::Error>,
L<Error::Pure::ErrorList>,
L<Error::Pure::HTTP::AllError>,
L<Error::Pure::HTTP::Error>,
L<Error::Pure::HTTP::ErrorList>,
L<Error::Pure::HTTP::Print>,
L<Error::Pure::Output::Text>,
L<Error::Pure::Print>,
L<Error::Pure::PrintVar>.

=head1 REPOSITORY

L<https://github.com/tupinek/Error-Pure>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

 © 2008-2014 Michal Špaček
 BSD 2-Clause License

=head1 VERSION

0.22

=cut
