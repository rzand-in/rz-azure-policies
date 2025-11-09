# /bin/sh

# path where to store the files
INITIATIVES_ASSIGNMENT_FILES_PATH=~/initiatives_assignments

# set the Azure region
LOCATION=canadacentral

# set the policy scope
SCOPE=/providers/Microsoft.Management/managementGroups/rzand-li

# get all non-deprecated policy set definitions (initiatives) names in Azure
INITIATIVE_NAMES=$(az policy set-definition list --query "[?!(contains(displayName, 'Deprecated'))].name" -o tsv)

# count the number of initiatives collected 
NUMBER_OF_INITIATIVES=$(echo "$INITIATIVE_NAMES" | wc -l)


#for ((i=1; i<=NUMBER_OF_INITIATIVES; i++)); do 
for ((i=1; i<=5; i++)); do 
  POLICY_SET_NAME=$(echo $INITIATIVE_NAMES | cut -d " " -f  "$i")
  # get the policy definition json
  POLICY_SET_DEFINITION=$(az policy set-definition show --name $POLICY_SET_NAME)
  # get the policy set name - already have it above
  # POLICY_SET_NAME=$(echo $POLICY_SET_DEFINITION | jq -r .name)
  # get the policy set displayname
  POLICY_SET_DISPLAYNAME=$(echo $POLICY_SET_DEFINITION | jq -r .displayName)
  # get the policy set description
  POLICY_SET_DESCRIPTION=$(echo $POLICY_SET_DEFINITION | jq -r .description)
  # get the policy set parameters' keys
  POLICY_SET_PARAMETERS_KEYS=$(echo $POLICY_SET_DEFINITION | jq -r '.parameters | keys')
  #   POLICY_SET_PARAMETERS_KEYS=$(az policy set-definition show --name $POLICY_SET_NAME --query "parameters.keys(@)[*]")
  # remove last square bracket
  POLICY_SET_PARAMETERS_KEYS="${POLICY_SET_PARAMETERS_KEYS%]}"
  # remove first square bracket
  POLICY_SET_PARAMETERS_KEYS="${POLICY_SET_PARAMETERS_KEYS#[}"
  # get the policy set parameters' type
  POLICY_SET_PARAMETERS_TYPE=$(echo $POLICY_SET_DEFINITION | jq -r '.parameters[].type')
  # get the policy set parameters' default values
  #POLICY_SET_PARAMETERS_DEFAULT_VALUES=$(az policy set-definition show --name $POLICY_SET_NAME --query "parameters.*.defaultValue")
  POLICY_SET_PARAMETERS_DEFAULT_VALUES=$(echo $POLICY_SET_DEFINITION | jq -r '.parameters[].defaultValue')
  # distinguish between array values and single values (thanks)
  tokens=()
  in_bracket=false
  current=""
  for PARAMETER_VALUE in $POLICY_SET_PARAMETERS_DEFAULT_VALUES; do
    if [[ $PARAMETER_VALUE == "[" ]]; then
      in_bracket=true
      current="["
    elif $in_bracket == true; then
      current="$current $PARAMETER_VALUE"
      if [[ $PARAMETER_VALUE == "]" ]]; then
        tokens+=("$current")
        in_bracket=false
        current=""
      fi
    else
      tokens+=("$PARAMETER_VALUE")
    fi
  done
  # count the number of parameters for the policy set
  PARAMETERS_NUMBER=$(echo $POLICY_SET_PARAMETERS_KEYS | tr -cd , | wc -c)
  PARAMETERS_NUMBER=$((PARAMETERS_NUMBER + 1))
  # create the policy set parameter
  POLICY_SET_PARAMETER="{"
  for ((P=1; P<$PARAMETERS_NUMBER; P++)); do
    POLICY_SET_PARAMETER+=$(echo $POLICY_SET_PARAMETERS_KEYS | cut -d "," -f  "$P")
    POLICY_SET_PARAMETER+=": {\"value\": "
    #POLICY_SET_PARAMETER+=$(echo $POLICY_SET_PARAMETERS_DEFAULT_VALUES | cut -d " " -f  "$P")
  if [[ $(echo $POLICY_SET_PARAMETERS_TYPE | cut -d " " -f  "$P") != "String" ]]; then 
      echo $POLICY_SET_PARAMETERS_TYPE | cut -d " " -f  "$P"
      echo ${tokens[$P-1]}
      POLICY_SET_PARAMETER+=${tokens[$P-1]}
    elif [[ ${tokens[$P-1]} == "null" ]]; then 
      POLICY_SET_PARAMETER+="\"\""
    else
      POLICY_SET_PARAMETER+="\"${tokens[$P-1]}\""
    fi
    POLICY_SET_PARAMETER+="},"
  done
  POLICY_SET_PARAMETER+=$(echo $POLICY_SET_PARAMETERS_KEYS | cut -d "," -f  "$PARAMETERS_NUMBER")
  POLICY_SET_PARAMETER+=": {\"value\": "
  #POLICY_SET_PARAMETER+=$(echo $POLICY_SET_PARAMETERS_DEFAULT_VALUES | cut -d " " -f  "$PARAMETERS_NUMBER")
  # if [[ ${tokens[$P-1]} = "null" ]]; then 
  #   ${tokens[$P-1]} = "\"\""
  # fi
  if [[ $(echo $POLICY_SET_PARAMETERS_TYPE | cut -d " " -f  "$P") != "String" ]]; then 
    POLICY_SET_PARAMETER+=${tokens[$P-1]}
  elif [[ ${tokens[$P-1]} == "null" ]]; then 
    POLICY_SET_PARAMETER+="\"\""
  else
    POLICY_SET_PARAMETER+="\"${tokens[$P-1]}\""
  fi
  POLICY_SET_PARAMETER+="}}"
# create the file to assign the POLICY_SET
# cat << EOF > $HOME$INITIATIVES_ASSIGNMENT_FILES_PATH/$POLICY_SET_DISPLAYNAME".sh
cat << EOF > "$POLICY_SET_DISPLAYNAME.sh"
#!/bin/sh   
az policy assignment create --name "Initiative_$i" \
    --display-name "$POLICY_SET_DISPLAYNAME" \
    --scope $SCOPE \
    --policy-set-definition $POLICY_SET_NAME \
    --mi-system-assigned --location $LOCATION \
    --params $POLICY_SET_PARAMETER \
    --description "$POLICY_SET_DESCRIPTION"
EOF
  chmod +x $INITIATIVES_ASSIGNMENT_FILES_PATH/"$POLICY_SET_DISPLAYNAME".sh
done


# Cannot simply divide the parameters by space because 
# the arrays have a space after and before the square bracket

# booleans values do not need quotes so I need to catch the param type and add quotes to strings and array


# Parameter type	Example in JSON	Notes
# String	"eastus"	Always quoted
# Boolean	true / false	Never quoted
# Integer	10	Never quoted
# Array	["eastus","westus2"]	JSON array, quoted as part of the JSON string
# Object	{ "tagName": "env", "tagValue": "prod" }	JSON object, quoted as part of the JSON string
