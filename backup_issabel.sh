#!/bin/bash

##########################################################################
#                                                                        #
#      Script de Sincronização de Gravações do Issabel para AWS S3       #
#                 Criado em 2025 - Rafael Valnásio                       #
#           esse script foi pensado para rodar dentro da EC2             #
#         A ec2 e o Bucket deve ter regras que permitam a comunicação    #
#                                                                        #
#       Funcionalidades:                                                 #
#        1. Envia arquivos .wav e .mp3 para S3                           #
#        2. Logging completo                                             #
#        3. Deleta arquivos locais mais antigos que 90 dias              #
#                                                                        #
##########################################################################

# --- VARIAVEIS ---
S3_BUCKET_NAME="issabel-backup-gavacoes-mc"  # Nome do bucket S3
S3_PATH="gravacoes/"                         # Subpasta dentro do bucket
LOCAL_PATH="/var/spool/asterisk/monitor/"   # Caminho das gravações
LOG_FILE="/var/log/sync_s3.log"             # Arquivo de log do script

# --- FUNÇÃO DE LOG ---
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# --- INÍCIO ---
log "========================================================"
log "Iniciando a sincronização das gravações..."
log "Caminho local: $LOCAL_PATH"
log "Bucket S3 de destino: s3://$S3_BUCKET_NAME/$S3_PATH"
log "========================================================"

# ---  Enviando os arquivos para o S3 ---
log "Sincronizando arquivos para o S3..."
aws s3 sync "$LOCAL_PATH" "s3://$S3_BUCKET_NAME/$S3_PATH" \
    --storage-class INTELLIGENT_TIERING \
    --exclude "*" --include "*.wav" --include "*.mp3"

if [ $? -eq 0 ]; then
    log "Sincronização para o S3 concluída com sucesso."
else
    log "ERRO: A sincronização para o S3 falhou. Arquivos locais não serão deletados."
    exit 1
fi

# --- 2. Deleta arquivos locais antigos (mais de 90 dias) ---
log "Iniciando exclusão de arquivos locais com mais de 90 dias..."
log "Data atual: $(date)"



find "$LOCAL_PATH" \( -name "*.wav" -o -name "*.mp3" \) -type f -mtime +90 | while IFS= read -r file; do
    if [ -f "$file" ]; then
        file_date=$(stat -c %y "$file" 2>/dev/null || ls -la "$file")
        log "Deletando arquivo: $(basename "$file") - Última modificação: $file_date"
        
        if rm -f "$file"; then
            log "SUCESSO: Arquivo deletado: $(basename "$file")"
        else
            log "ERRO: Não foi possível deletar: $(basename "$file")"
        fi
    fi
done

#  contador para melhor logging
log "Verificando novamente se há arquivos antigos restantes..."
count=$(find "$LOCAL_PATH" \( -name "*.wav" -o -name "*.mp3" \) -type f -mtime +90 | wc -l)
if [ "$count" -eq 0 ]; then
    log "Todos os arquivos com mais de 90 dias foram removidos."
else
    log "ATENÇÃO: Ainda existem $count arquivos com mais de 90 dias."
    # Listar os arquivos remanescentes para debug
    find "$LOCAL_PATH" \( -name "*.wav" -o -name "*.mp3" \) -type f -mtime +90 -exec ls -la {} \;
fi

# Log de espaço liberado
log "Espaço em disco após limpeza:"
df -h "$LOCAL_PATH" | tail -1

log "Processo concluído."
log "========================================================"
