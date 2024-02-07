#!/bin/bash
while IFS= read -r line
do
  export "$line"
done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' appsettings.json)
