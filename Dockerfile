FROM python:3.10-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --upgrade setuptools wheel
RUN apt-get -y update && apt-get -y install curl
RUN pip install --no-cache-dir --upgrade -r requirements.txt
COPY . .
RUN rm requirements.txt

FROM builder
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app/* .
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]