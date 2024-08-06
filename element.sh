#! /usr/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

CHECK_INPUT() {
  # try to get the data from database
  if [[ $1 =~ ^[0-9]+$ ]] # check if argument input is a number
  then
    # argument input is a number, so try to get the data using atomic_number
    CHECK_FOR_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")
  else
    # argument input was not a number, so try to get the data using symbol
    CHECK_FOR_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1'")
    if [[ -z $CHECK_FOR_DATA ]]
    then
      # argument input was not a number, and not a symbol, so try to get the data using name
      CHECK_FOR_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name='$1'")
    fi
  fi

  # check result of trying to get the data, if not successful, "CHECK_FOR_DATA" is empty
  if [[ -z $CHECK_FOR_DATA ]]
  then
    # empty variable, return message
    echo "I could not find that element in the database."
  else
    # data was found, call function to generate correct output
    GET_OUTPUT
  fi
}

GET_OUTPUT() {
  echo $CHECK_FOR_DATA | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
}

# if no argument input exist, return message
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  else
    # argument input exist, call function
    CHECK_INPUT $1
fi
