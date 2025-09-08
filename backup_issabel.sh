#!/bin/bash

# --- Variáveis de Configuração ---
# Substitua com os seus valores
S3_BUCKET_NAME="inserir apenas o nome do bucket"
S3_PATH="gravacoes/" # nome da pasta dentro do s3 (a pasta já deve existir)
LOCAL_PATH="/var/spool/asterisk/monitor/" # Caminho padrão das gravações do Issabel
LOG_FILE="/var/log/sync_s3.log" # Caminho para o arquivo de log do script

# --- Função para registrar logs ---
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# --- Início do Script ---
log "Iniciando a sincronização das gravações..."
log "Caminho local: $LOCAL_PATH"
log "Bucket S3 de destino: s3://$S3_BUCKET_NAME/$S3_PATH"

# 1. Sincroniza os arquivos com o S3
# Usamos o 'aws s3 sync' para copiar novos arquivos e atualizar os existentes.
aws s3 sync "$LOCAL_PATH" "s3://$S3_BUCKET_NAME/$S3_PATH" --storage-class INTELLIGENT_TIERING --exclude "*" --include "*.wav" --include "*.mp3"

# Verifica o código de saída do comando anterior
if [ $? -eq 0 ]; then
    log "Sincronização para o S3 concluída com sucesso."
    
    echo "" # Linha em branco para melhor leitura
    echo "========================================================"
    echo "       VALIDAÇÃO: SINCRONIZAÇÃO COMPLETA NO S3"
    echo "========================================================"
    echo "As gravações foram enviadas com sucesso para o S3."
    echo "Deseja continuar e deletar os arquivos locais mais antigos que 3 meses?"
    echo "Digite 'sim' para continuar ou qualquer outra coisa para cancelar."
    read -p "Sua confirmação: " CONFIRMATION
    
    if [[ "$CONFIRMATION" == "sim" || "$CONFIRMATION" == "SIM" ]]; then
        log "Confirmação recebida. Prosseguindo com a exclusão dos arquivos locais."
        
        # 2. Deleta arquivos locais mais antigos que 3 meses
        find "$LOCAL_PATH" -type f -mtime +90 -exec rm -f {} \;
        
        # Verifica o código de saída do comando find
        if [ $? -eq 0 ]; then
            log "Arquivos locais antigos deletados com sucesso."
        else
            log "Erro ao deletar arquivos locais antigos."
        fi
    else
        log "Operação cancelada pelo usuário. Arquivos locais não foram deletados."
    fi

else
    log "ERRO: A sincronização para o S3 falhou. Arquivos locais não foram deletados."
    exit 1
fi

log "Processo concluído."
