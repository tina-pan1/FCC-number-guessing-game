#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:" 
read USERNAME

# asks for username until it is 22 characters or less
while [[ $USERNAME =~ ^*{23,}$ ]]
do
  echo -e "\nPlease enter a username up to 22 characters."
  read USERNAME
done

GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE name='$USERNAME'")

# checks if the user already exists
if [[ -z $GAMES_PLAYED ]]
then
  # for when the user is new
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  echo $($PSQL "INSERT INTO user_info(name, games_played, best_game) VALUES('$USERNAME', 0, 999)") > stdout.txt
else
  # for when the user is old
  BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE name='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generates a random number
NUMBER=$((($RANDOM % 1000) + 1))
  
# prompts for guess
echo -e "\nGuess the secret number between 1 and 1000:"

# keeps track of guess count
GUESS_COUNT=0

# cycles until the number is guessed
while [[ $GUESS -ne $NUMBER ]]
do
  # reads user input
  read GUESS

  # increments the guess count
  GUESS_COUNT=$(($GUESS_COUNT+1))

  # checks if guess is an integer
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    # checks if guess is greater than number
    if [[ GUESS -gt $NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    # checks if guess is less than number
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    fi
  else
    # asks for new guess when guess is not an integer
    echo -e "\nThat is not an integer, guess again:"
  fi
done

# finds best score
BEST_SCORE=$($PSQL "SELECT best_game FROM user_info WHERE name='$USERNAME'")
if [[ $BEST_SCORE -gt $GUESS_COUNT ]]
then 
  BEST_SCORE=$GUESS_COUNT
fi

# updates number of games played
NEW_GAMES_PLAYED=$(($GAMES_PLAYED + 1))

# inserts the game and updates the user info
echo $($PSQL "UPDATE user_info SET games_played = $NEW_GAMES_PLAYED WHERE name='$USERNAME'") > stdout.txt
echo $($PSQL "UPDATE user_info SET best_game = $BEST_SCORE WHERE name='$USERNAME'") > stdout.txt

# message when users guess correctly
echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
