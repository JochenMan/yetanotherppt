# Use an official Python base image
FROM python:3.8

# # Install Pandoc
RUN apt-get update && \
    apt-get install -y pandoc

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application's code
COPY src/ /app
