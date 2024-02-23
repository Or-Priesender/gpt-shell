# gpt-shell

## Introduction

This repository contains a shell function named `gpt` designed to act as an in-line terminal assistant. It utilizes the OpenAI API to provide code or general answers to questions based on the user's input. The function is tailored for use in terminal environments and is intended to be simple and efficient.

## Prerequisites

Before using this function, ensure you have the following installed:
- `curl` for making HTTP requests.
- `jq` for processing JSON data.
- An OpenAI API key, which you can obtain from the OpenAI website.

## Installation

1. Clone this repository to your local machine:
    ```bash
      git clone https://github.com/Or-Priesender/gpt-shell.git
    ```
2. cd into the cloned directory:
    ```bash
      cd gpt-shell
    ``` 
3. Add the following line to your `.bashrc` or `.zshrc` file:
    ```bash
      source /path/to/gpt-shell/install.sh
    ```
4. Set your OpenAI API key as an environment variable in your shell profile (`.bashrc` or `.zshrc`):
    ```bash
      export OPENAI_API_KEY="your-api-key"
    ```
5. Reload your shell:
    ```bash
      source ~/.bashrc # or ~/.zshrc
    ```
6. You're all set! You can now use the `gpt` function in your terminal.


## Usage

To use the `gpt` function, simply call it in your terminal with the desired options and arguments.
```bash
  gpt --help
  Options:
     -h, --help           display this help message
     -q, --question_mode  if set, the input will be treated as a general question, otherwise the output will be a single command. default: false 
     -m, --model <model>  specify the GPT model to use (gpt-3.5-turbo-0125, gpt-4-0125-preview, gpt-4-turbo-preview, gpt-4). default: gpt-3.5-turbo
```

## Examples
```bash
  $ gpt -q "What is the capital of France?"
  Paris
  
  $ gpt --model gpt-4 "Find files that contain the word 'gpt' in the current directory"
  grep -l 'gpt' * 
```