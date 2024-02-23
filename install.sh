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
        while [[ $# -gt  0 ]]; do
          case "$1" in
            -h | --help)
              echo "Usage: $0 [OPTIONS]"
              echo "Options:"
              echo " -h, --help           display this help message"
              echo " -q, --question_mode  if set, the input will be treated as a general question, otherwise the output will be a single command. default: false"
              echo " -m, --model <model>  specify the GPT model to use (gpt-3.5-turbo-0125, gpt-4-0125-preview, gpt-4-turbo-preview, gpt-4). default: gpt-3.5-turbo"
              exit  0
              ;;
            -q | --question_mode)
              question_mode=true
              ;;
            -m | --model)
              if [[ -n $2 && ${2:0:1} != "-" ]]; then
                case "$2" in
                  "gpt-3.5-turbo-0125" | "gpt-3.5-turbo" | "gpt-4-0125-preview" | "gpt-4-turbo-preview" | "gpt-4")
                    gpt_model="$2"
                    shift
                    ;;
                  *)
                    echo "Invalid model, please choose one of gpt-3.5-turbo-0125, gpt-3.5-turbo, gpt-4-0125-preview, gpt-4-turbo-preview, gpt-4"
                    exit  1
                    ;;
                esac
              else
                echo "-m flag requires a value"
                exit  1
              fi
              ;;
            *)
            	if [[ ${1:0:1} != "-" ]]; then
								user_input="$1"
							else
								echo "Invalid argument: $1"
								exit  1
							fi
              ;;
          esac
          shift
        done
  
      # Ensure that the positional argument is provided
      if [[ -z $user_input ]]; then
          echo "No user input provided"
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

	curl https://api.openai.com/v1/chat/completions -s \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "$data" | jq -r '.choices[0].message.content'
}

gpt "$@"
