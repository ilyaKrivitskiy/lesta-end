FROM python:3.10-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --upgrade setuptools wheel
RUN pip install --no-cache-dir --upgrade -r requirements.txt
COPY . .
RUN rm requirements.txt

FROM builder
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app/* .
EXPOSE 5000
CMD ["python","routes.py"]