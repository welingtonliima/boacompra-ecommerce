FROM python:3.11-slim

WORKDIR /app

ENV DB_USER=boacompra_adm
ENV DB_PASSWORD=123456
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_NAME=boacompra_adm

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY csv/ csv/
COPY boa_compra_carga.py .

# Define o comando padrão
CMD ["python", "boa_compra_carga.py"]