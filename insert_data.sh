#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty database 
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER_NAME OPPONENT_NAME WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != 'year' ]]
then
  # get winner and opponent team ids
  TEAM_ID_WINNER="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_NAME'")"
  TEAM_ID_OPPONENT="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_NAME'")"

  # if winner team not found 
  if [[ -z $TEAM_ID_WINNER ]]
  then
    # insert team
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER_NAME')")
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $WINNER_NAME
    fi
    # get new winner team id
    TEAM_ID_WINNER="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_NAME'")"
  fi

  # if opponent team not found
  if [[ -z $TEAM_ID_OPPONENT ]]
  then
    # insert team
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT_NAME')")
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $OPPONENT_NAME
    fi
    # get new opponent team id
    TEAM_ID_OPPONENT="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_NAME'")"
  fi

  # insert game
  INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")"
  if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
  then
    echo Insert into games: $YEAR, $ROUND, $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS
  fi
fi 
done
