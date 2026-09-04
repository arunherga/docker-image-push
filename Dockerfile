FROM python:3.13-slim

# Run as a non-root user.
RUN useradd --create-home --uid 10001 app
WORKDIR /app

COPY --chown=app:app app.py .

USER app
CMD ["python", "app.py"]
