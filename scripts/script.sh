#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Get inputs from the environment
GITHUB_TOKEN="$1"
REPOSITORY="$2"
ISSUE_NUMBER="$3"
OPENAI_API_KEY="$4"

# Function to fetch issue details from GitHub API
fetch_issue_details() {
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         "https://api.github.com/repos/$REPOSITORY/issues/$ISSUE_NUMBER"
}

# Function to send prompt to the ChatGPT model (OpenAI API)
send_prompt_to_chatgpt() {
curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"gpt-3.5-turbo\", \"messages\": $MESSAGES_JSON, \"max_tokens\": 500}"
}


# Function to save code snippet to file
save_to_file() {
    #  the script will save the code snippets to files in a directory named "autocoder-bot" with the filename specified in the JSON object.
    local filename="autocoder-bot/$1"
    local code_snippet="$2"

    mkdir -p "$(dirname "$filename")"
    echo -e "$code_snippet" > "$filename"
    echo "The code has been written to $filename"
}

# Fetch and process issue details
RESPONSE=$(fetch_issue_details)
ISSUE_BODY=$(echo "$RESPONSE" | jq -r .body)

if [[ -z "$ISSUE_BODY" ]]; then
    echo 'Issue body is empty or not found in the response.'
    exit 1
fi

# Define clear, additional instructions for GPT regarding the response format
INSTRUCTIONS="Based on the description below, please generate a JSON object where the keys represent file paths and the values are the corresponding code snippets for a production-ready application. The response should be a valid strictly JSON object without any additional formatting, markdown, or characters outside the JSON structure."

# Combine the instructions with the issue body to form the full prompt
FULL_PROMPT="$INSTRUCTIONS\n\n$ISSUE_BODY"

# Prepare the messages array for the ChatGPT API, including the instructions
MESSAGES_JSON=$(jq -n --arg body "$FULL_PROMPT" '[{"role": "user", "content": $body}]')

# Send the prompt to the ChatGPT model
RESPONSE=$(send_prompt_to_chatgpt)

if [[ -z "$RESPONSE" ]]; then
    echo "No response received from the OpenAI API."
    exit 1
fi

# Extract the JSON dictionary from the response
# Make sure that the extracted content is valid JSON
FILES_JSON=$(echo "$RESPONSE" | jq -e '.choices[0].message.content | fromjson' 2> /dev/null)

if [[ -z "$FILES_JSON" ]]; then
    echo "No valid JSON dictionary found in the response or the response was not valid JSON. Please rerun the job."
    exit 1
fi

# Iterate over each key-value pair in the JSON dictionary
for key in $(echo "$FILES_JSON" | jq -r 'keys[]'); do
    FILENAME=$key
    CODE_SNIPPET=$(echo "$FILES_JSON" | jq -r --arg key "$key" '.[$key]')
    CODE_SNIPPET=$(echo "$CODE_SNIPPET" | sed 's/\r$//') # Normalize line endings
    save_to_file "$FILENAME" "$CODE_SNIPPET"
done

echo "All files have been processed successfully."
