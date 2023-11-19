# Use an official Python base image
FROM python:3.8

# Install Pandoc
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

# Copy the static dir
COPY static /app/static

# Expose the port the app runs on
EXPOSE 8000

# Define the command to run your application
# This should start the NiceGUI server
CMD ["python", "your_app_script.py"]
