FROM python:3.12-slim AS dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt


FROM python:3.12-slim AS build
WORKDIR /app
COPY --from=dependencies /root/.local /root/.local
COPY . .
RUN python -m compileall app.py


FROM python:3.12-slim AS prod
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/home/app/.local/bin:$PATH
WORKDIR /app
RUN useradd --create-home --uid 1000 app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
COPY --from=build --chown=app:app /app/app.py ./
EXPOSE 8000
USER app
CMD ["python", "app.py"]
