use strict;
use warnings;

# computer generate a random number and store
# you generate a random number and if the same then you win elso you lose


print "Please a guess between 1 and 10: ";

my $userGuess = <STDIN>;
my $computerGuess = (int rand 10) + 1;

if ( $userGuess == $computerGuess ) {

	print "Your correct! The computer had guessed $computerGuess";

} else {

	print "Have another go your current guess was $userGuess";
	
}


#-- Using an infinite loop to keep asking until the user has guessed correctly. Probably not the best way to do it!

# while (44) {

# 	print "  Guess a number between 1 and 10:\n";

# 	my $computerGuess = (int rand 10) + 1;
# 	my $userGuess = <STDIN>;

# 	if ($userGuess == $computerGuess) {
# 		last;
# 	}

# 	print "Not quite, try again!";

# }

# print "Yes you got it!";
