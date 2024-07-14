#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# get user name
echo "Enter your username:"
read USERNAME

# check existing user
EXISTING_USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")
if [[ -z $EXISTING_USER ]]; then
	echo "Welcome, $USERNAME! It looks like this is your first time here."
	# add new user
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 0);"
else
	GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
	BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
	echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
	# update total of game play
  $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';"
fi

# get user number
echo "Guess the secret number between 1 and 1000:"
read GUESS

GUESSES=0
# until guess number and secret number is matched
while [[ $GUESS -ne $SECRET_NUMBER ]]; do
	if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
		echo "That is not an integer, guess again:"
	else
		if [ $GUESS -gt $SECRET_NUMBER ]; then
			echo "It's lower than that, guess again:"
		else
			echo "It's higher than that, guess again:"
		fi
	fi
	read GUESS
  # count number of guesses
	(( GUESSES++ ))
done

# update user best game
$PSQL "UPDATE users SET best_game = LEAST(best_game, $GUESSES) WHERE username = '$USERNAME';"
echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"


