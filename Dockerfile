# Use uma imagem base leve do Python
FROM python:3.11-slim

# Define diretório de trabalho
WORKDIR /app

# Copia o script principal
COPY main.py .

# Comando para executar o script
CMD ["python", "main.py"]