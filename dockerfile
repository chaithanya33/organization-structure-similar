# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set the working directory in the container
WORKDIR /app

# Copy the rest of the application code into the container
COPY app /app/app
COPY k8s /app/k8s
COPY .env /app/.env
COPY pw_api_utils ./pw_api_utils

# Copy and set up entrypoint script (must be done as root before switching user)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chown -R appuser:appgroup /app

# Copy the requirements.txt file into the container
COPY requirements.txt /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir ./pw_api_utils

# Switch to the non-root user
USER appuser

# Expose the port that the app runs on
EXPOSE 8080

# Entrypoint patches .env with runtime K8s env vars, then starts the app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
