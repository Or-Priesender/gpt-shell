#!/bin/bash

gpt() {
	code_role="You're an in-line terminal assistant running on ${OSTYPE}.
  Your task is to answer the question_modes without any commentation at all, providing only the code to run on terminal.
  You can assume that the user understands that they need to fill in placeholders like <PORT>. You''re not allowed to explain anything and you''re not a chatbot.
  You only provide shell commands or code. Keep the responses to one-liner answers as much as possible. Do not decorate the answer with tickmarks.
  "

  general_role="You're an in-line terminal assistant running on ${OSTYPE}.
  Your task is to answer whatever question_mode the user asks.
  You can assume that the user understands that they need to fill in placeholders like <PORT>. You're not a chatbot.
  Keep the responses as short as possible. Do not decorate the answer with tickmarks.
  "

	hash curl 2>/dev/null || { echo >&2 "curl dependency is missing"; exit 1; }
	hash jq 2>/dev/null || { echo >&2 "jq dependency is missing"; exit 1; }

	if [[ -z "${OPENAI_API_KEY}" ]]; then
		echo "OpenAI API key is not set. Please set it in your environment variables:"
		echo "  export OPENAI_API_KEY=your-api-key"
		exit 1
	fi

	    # Initialize variables
      question_mode=false
      gpt_model="gpt-3.5-turbo"
  
      # Loop through arguments
      while [[ $# -gt 0 ]]; do
          case "$1" in
              -q)
                  # Set question_mode flag to true
                  question_mode=true
                  ;;
              -m)
                  # Check if the next argument exists and is not another flag
                  if [[ -n $2 && ${2:0:1} != "-" ]]; then
                      # Check if the value is one of the allowed options
                      case "$2" in
                          "gpt-3.5-turbo-0125" | "gpt-3.5-turbo" | "gpt-4-0125-preview" | "gpt-4-turbo-preview" | "gpt-4")
                              gpt_model="$2"
                              shift # Consume the value
                              ;;
                          *)
                              echo "Error: Invalid value for -m flag"
                              exit 1
                              ;;
                      esac
                  else
                      echo "Error: Missing value for -m flag"
                      exit 1
                  fi
                  ;;
              *)
                  # Set the positional argument
                  user_input="$1"
                  ;;
          esac
          shift # Move to the next argument
      done
  
      # Ensure that the positional argument is provided
      if [[ -z $user_input ]]; then
          echo "Please provide user input"
          exit 1
      fi

	role="$code_role"
  if [ "$question_mode" = true ]; then
  	echo "The -q flag is true."
  	role="$general_role"
  fi

	data=$(jq -n --arg gpt_model "$gpt_model" --arg role "$role" --arg user_input "$user_input" \
      '{ "model": $gpt_model,
         "messages": [
           { "role": "system", "content": $role },
           { "role": "user", "content": $user_input }
         ]
       }')

	curl https://api.openai.com/v1/chat/completions -vvv -s \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "$data" | jq -r '.choices[0].message.content'
}