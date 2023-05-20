#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

# add each unique team (from both the winner and opponent columns) to the "teams" table, total 24 teams. 
do
  # do not include the title row in games.csv
  if [[ $WINNER != "winner" ]]
  then
    # get team_id from winner col
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # print result
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then  
        echo "Inserted into teams, $WINNER"
      fi
      # get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get team_id from opponent col
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # print result
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then  
        echo "Inserted into teams, $OPPONENT"
      fi
      # get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
done


# add all 32 games to the games table (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
# do not include the title line
  if [[ $WINNER != "winner" ]]
  then
    # get winner_id & opponent_id, & game_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID'")
    # if game_id not found
    if [[ -z $GAME_ID ]]
    then
      # insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
      VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      # print result
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Insert into games: $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
      fi
      # get new game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID'")
    fi
  fi
done

