# Use Alpine Linux as the base image
FROM alpine:latest

# Install any dependencies your script may need
# For example, to install curl, uncomment the next line:
RUN apk add --no-cache curl bash

# Copy the checker.sh script into the container
COPY checker.sh /checker.sh

# Make the script executable
RUN chmod +x /checker.sh

# Set the script as the entry point
ENTRYPOINT ["/checker.sh"]