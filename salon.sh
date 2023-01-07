#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to our salon ~~~~~\n"
 
MAIN_MENU() {
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # display available services
  echo "here is the available services:"
  SERVICE_LIST=$($PSQL"SELECT * FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do  
    echo "$SERVICE_ID) $NAME"
  done
  #ask for the service
  echo -e "\nWhich one would you like?"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a service."
  else
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
  # if not available
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      # send to main menu
      MAIN_MENU "That service is not available."
      
    else 
      # get customer info
      echo -e "\nWhat's your phone number"
      read CUSTOMER_PHONE
      PHONE_AVAILABILITY=$($PSQL "SELECT name FROM customers WHERE phone ='$CUSTOMER_PHONE' ")
      if [[ -z $PHONE_AVAILABILITY ]]
      then 
        echo -e "\nYou're a new customer please enter your information"
        echo -e "\nEnter your name"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_INFO=$($PSQL"INSERT INTO customers (phone,name)VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
      
      echo -e "\nEnter your time"
      read SERVICE_TIME
      
      #get customer_id
      
      GET_CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")      
      
      #insert appo

      INSERT_APPO_INFO=$($PSQL"INSERT INTO appointments(customer_id,service_id,time)VALUES($GET_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      
      echo "I have put you down for a cut$NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    
          
    fi
  fi
}

MAIN_MENU

