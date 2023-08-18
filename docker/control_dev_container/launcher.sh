#!/bin/bash

# Path where the runtime-injected script should be
TARGET_SCRIPT_PATH="/entrypoint.sh"

# Check if the target script exists and is executable
if [ -x "$TARGET_SCRIPT_PATH" ]; then
    exec "$TARGET_SCRIPT_PATH" "$@"
else
    # Fall back to the default script
    exec /default_entrypoint.sh "$@"
fi
