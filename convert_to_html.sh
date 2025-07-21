#!/bin/bash

# Simple script to convert a txt file into a basic HTML file.
# Usage: ./convert_to_html.sh input.txt output.html

input="$1"
output="$2"

{
  echo "<html>"
  echo "<body>"
  echo "<pre>"
  cat "$input"
  echo "</pre>"
  echo "</body>"
  echo "</html>"
} > "$output"

# This script wraps the txt file content within <pre> tags for preserved formatting in HTML.
# Example: ./convert_to_html.sh iplist.txt iplist.html
