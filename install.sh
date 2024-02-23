#!/bin/bash

# Function to copy the output of a command to the clipboard
copy_to_clipboard_and_echo() {
    # Command whose output you want to copy
    local command="$1"
		local success_message="# copied to clipboard!"
    # Determine the OS
    case "$OSTYPE" in
        linux*)
            # Linux
            eval "$command" | tee >(xclip -selection clipboard) && echo "$success_message"
            ;;
        darwin*)
            # macOS
            eval "$command" | tee >(pbcopy) && echo "$success_message"
            ;;
        cygwin*|msys*|mingw*|win32*)
            # Windows
            eval "$command" | tee >(clip) && echo "$success_message"
            ;;
        *)
            eval "$command"
            ;;
    esac
}

gpt() {
	code_role="You are an in-line terminal assistant running on ${OSTYPE}.
  Your task is to answer the question_modes without any commentation at all, providing only the code to run on terminal.
  You can assume that the user understands that they need to fill in placeholders like <PORT>. You are not allowed to explain anything and you are not a chatbot.
  You only provide shell commands or code. Keep the responses to one-liner answers as much as possible. Do not decorate the answer with tickmarks."

	general_role="You are an in-line terminal assistant running on ${OSTYPE}.
  Your task is to answer whatever question_mode the user asks.
  You can assume that the user understands that they need to fill in placeholders like <PORT>. You're not a chatbot.
  Keep the responses as short as possible. Do not decorate the answer with tickmarks."

	hash curl 2>/dev/null || {
		echo >&2 "curl dependency is missing"
		return 1
	}
	hash jq 2>/dev/null || {
		echo >&2 "jq dependency is missing"
		return 1
	}

	if [[ -z "${OPENAI_API_KEY}" ]]; then
		echo "OpenAI API key is not set. Please set it in your environment variables:"
		echo "  export OPENAI_API_KEY=your-api-key"
		return 1
	fi

	# Initialize variables
	question_mode=false
	gpt_model="gpt-3.5-turbo"

	# Loop through arguments
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-h | --help)
			echo "Usage: $0 [OPTIONS]"
			echo "Options:"
			echo " -h, --help
			display this help message"

			echo " -q, --question_mode
			if set, the input will be treated as a general question,
			otherwise the output will be a single command which is automatically copied to your clipboard.
			default: false"

			echo " -m, --model <model>
			specify the GPT model to use (gpt-3.5-turbo-0125, gpt-4-0125-preview, gpt-4-turbo-preview, gpt-4).
			default: gpt-3.5-turbo"

			return 0
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
					return 1
					;;
				esac
			else
				echo "-m flag requires a value"
				return 1
			fi
			;;
		*)
			if [[ ${1:0:1} != "-" ]]; then
				user_input="$1"
			else
				echo "Invalid argument: $1"
				return 1
			fi
			;;
		esac
		shift
	done

	# Ensure that the positional argument is provided
	if [[ -z $user_input ]]; then
		echo "No user input provided"
		return 1
	fi

	role="$code_role"
	if [ "$question_mode" = true ]; then
		role="$general_role"
	fi

	data=$(jq -n --arg gpt_model "$gpt_model" --arg role "$role" --arg user_input "$user_input" \
		'{ "model": $gpt_model,
         "messages": [
           { "role": "system", "content": $role },
           { "role": "user", "content": $user_input }
         ]
       }')

	command="curl https://api.openai.com/v1/chat/completions -s \
		-H \"Content-Type: application/json\" \
		-H \"Authorization: Bearer ${OPENAI_API_KEY}\" \
		-d '$data' | jq -r '.choices[0].message.content'"

	if [ "$question_mode" = false ]; then
  	copy_to_clipboard_and_echo "$command"
  else
  	eval "$command"
  fi
}
