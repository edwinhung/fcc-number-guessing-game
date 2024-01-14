#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read INPUT
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$INPUT'")
if [[ -z $USERNAME ]]
then
  # add username to database first
  INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$INPUT')")
  USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$INPUT'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
ANSWER=$(($RANDOM % 1000 + 1))
GAME () {
  # print prompt if given
  if [[ $1 ]]
  then
    echo $1
  else
    echo Guess the secret number between 1 and 1000:
  fi
  # keep track of number of tries
  if [[ $2 ]]
  then
    TRIES=$2
  else
    TRIES=1
  fi
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $ANSWER ]]
    then
      (( TRIES++ ))
      GAME "It's lower than that, guess again:" $TRIES
    elif [[ $GUESS -lt $ANSWER ]]
    then
      (( TRIES++ ))
      GAME "It's higher than that, guess again:" $TRIES
    else
      echo "You guessed it in $TRIES tries. The secret number was $ANSWER. Nice job!"
      # set games played = 0 for new user
      if [[ -z $GAMES_PLAYED ]]
      then
        GAMES_PLAYED=0
      fi
      (( GAMES_PLAYED++ ))
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
      # set best game to current tries for new user
      if [[ -z $BEST_GAME ]]
      then
        BEST_GAME=$TRIES
      fi
      if [[ $TRIES -lt $BEST_GAME ]]
      then
        BEST_GAME=$TRIES
      fi
      UPDATE_RESULT=$($PSQL "UPDATE users SET best_game = $BEST_GAME WHERE username = '$USERNAME'")
    fi
  else
    GAME "That is not an integer, guess again:" $TRIES
  fi
}

GAME


