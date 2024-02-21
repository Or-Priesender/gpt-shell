#!/bin/bash


# TODO: maintain a configuration in the user's home folder that saves preferences
# TODO: argument - which prompt code or regular?
# TODO: argument - gpt model








gpt() {
  if [[ ! $+commands[curl] ]]; then echo "Curl must be installed."; return 1; fi
  if [[ ! $+commands[jq] ]]; then echo "Jq must be installed."; return 1; fi
  if [[ ! -v OPENAI_API_KEY ]]; then echo "Must set OPENAI_API_KEY to your API key"; return 1; fi

  curl https://api.openai.com/v1/chat/completions -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "system", "content": "you''re an in-line zsh assistant running on linux. Your task is to answer the questions without any commentation at all, providing only the code to run on terminal. You can assume that the user understands that they need to fill in placeholders like <PORT>. You''re not allowed to explain anything and you''re not a chatbot. You only provide shell commands or code. Keep the responses to one-liner answers as much as possible. Do not decorate the answer with tickmarks"}, {"role": "user", "content": "'"$*"'"}]
  }' | jq -r '.choices[0].message.content'
}
