# /bin/sh

LOCATION=canadacentral
SCOPE=/providers/Microsoft.Management/managementGroups/rzand-li

# Get all non-deprecated policy set definitions (initiatives) names in Azure
INITIATIVE_NAMES=$(az policy set-definition list --query "[?!(contains(displayName, 'Deprecated'))].name" -o tsv)

NUMBER_OF_INITIATIVES=$(echo "$INITIATIVE_NAMES" | wc -l)
#for ((i=1; i<=NUMBER_OF_INITIATIVES; i++)); do 
for ((i=1; i<=5; i++)); do 
  INITIATIVE_NAME=$(echo $INITIATIVE_NAMES | cut -d " " -f  "$i")
  echo "Name: $INITIATIVE_NAME"
  INITIATIVE_DISPLAYNAME=$(az policy set-definition show --name "$INITIATIVE_NAME" --query displayName -o tsv)
  echo "Displayname: $INITIATIVE_DISPLAYNAME"
  INITIATIVE_DESCRIPTION=$(az policy set-definition show --name "$INITIATIVE_NAME" --query description -o tsv)
  echo "Description: $INITIATIVE_DESCRIPTION"
  PARAMETERS_NAMES=$(az policy set-definition show --name "$INITIATIVE_NAME" --query "parameters | keys(@)" -o tsv)
  PARAMETERS_DEFAULTS=$(az policy set-definition show --name "$INITIATIVE_NAME" --query "parameters.*.defaultValue" -o tsv)
  PARAMETERS_TYPES=$(az policy set-definition show --name "$INITIATIVE_NAME" --query "parameters.*.type" -o tsv)
  echo "PARAMETER_TYPES: $PARAMETERS_TYPES"
# policysetparam='{"dcrResourceId": {"value": "Microsoft.Insights/dataCollectionRules"}}'
    PARAMETERS_NUMBER=$(echo "$PARAMETERS_NAMES" | wc -l)
    INITIATIVE_PARAMETER="{"
    # for ((p=1; p<= $PARAMETERS_NUMBER; p++)); do
    #     INITIATIVE_PARAMETER+=\"$(echo "$PARAMETERS_NAMES" | cut -d " " -f  "$p")\"
    #     # INITIATIVE_PARAMETER+=": {\"value\": \"$(echo "$PARAMETERS_DEFAULTS" | cut -d " " -f  "$p")\"},"
    #     INITIATIVE_PARAMETER+=": {\"value\": }"
    # done
    for ((p=1; p<= $PARAMETERS_NUMBER; p++)); do
        if [ $p -lt $PARAMETERS_NUMBER ]; then
            INITIATIVE_PARAMETER+="\""
            INITIATIVE_PARAMETER+=$(echo $PARAMETERS_NAMES | cut -d " " -f  "$p")
            INITIATIVE_PARAMETER+="\": {\"value\": \""
            if [ "$(echo $PARAMETERS_TYPES | cut -d " " -f  "$p")" = "Array" ]; then
                # For Array type, we need to format the default value properly
                DEFAULT_VALUE=$(echo $PARAMETERS_DEFAULTS | cut -d " " -f  "$p")
                # Remove leading and trailing brackets if present
                DEFAULT_VALUE="${DEFAULT_VALUE#[}"
                DEFAULT_VALUE="${DEFAULT_VALUE%]}"
                # Split by comma and reformat
                IFS=',' read -ra ADDR <<< "$DEFAULT_VALUE"
                FORMATTED_VALUE="["
                for j in "${ADDR[@]}"; do
                    FORMATTED_VALUE+="\"$j\","
                done
                FORMATTED_VALUE="${FORMATTED_VALUE%,}]"
                INITIATIVE_PARAMETER+=$FORMATTED_VALUE
                echo "============================================="
                echo "$(echo $PARAMETERS_TYPES | cut -d " " -f  "$p")"
                #echo "$(echo "$PARAMETERS_DEFAULTS" | cut -d " " -f  "$p")"
                echo $INITIATIVE_PARAMETER
                echo "============================================="
            else
                INITIATIVE_PARAMETER+=$(echo $PARAMETERS_DEFAULTS | cut -d " " -f  "$p")
            fi
            INITIATIVE_PARAMETER+=$(echo $PARAMETERS_DEFAULTS | cut -d " " -f  "$p")
            INITIATIVE_PARAMETER+="\"},"
        fi
    done
    INITIATIVE_PARAMETER+="\""
    INITIATIVE_PARAMETER+=$(echo $PARAMETERS_NAMES | cut -d " " -f  "1")
    INITIATIVE_PARAMETER+="\": {\"value\": \""
    INITIATIVE_PARAMETER+=$(echo $PARAMETERS_DEFAULTS | cut -d " " -f  "1")
    INITIATIVE_PARAMETER+="\"}"   
    INITIATIVE_PARAMETER+="}"
    echo "INITIATIVE_PARAMETER: $INITIATIVE_PARAMETER"
    




cat << EOF > ~/initiatives_assignments/"$INITIATIVE_DISPLAYNAME".sh
#!/bin/sh   
az policy assignment create --name "Initiative_$i" \
  --display-name "$INITIATIVE_DISPLAYNAME" \
  --scope $SCOPE \
  --policy-set-definition $INITIATIVE_NAME \
  --mi-system-assigned --location $LOCATION \
  --params $INITIATIVE_PARAMETER \
  --description "$INITIATIVE_DESCRIPTION"
EOF
chmod +x ~/initiatives_assignments/"$INITIATIVE_DISPLAYNAME".sh
done  