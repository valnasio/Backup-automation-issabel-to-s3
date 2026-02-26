# ☁️ Sincronização de Gravações Issabel para AWS S3

Script em **Bash** para automatizar a sincronização de gravações do Issabel/Asterisk com um bucket **AWS S3**, incluindo limpeza automática de arquivos antigos e sistema completo de logging.

Desenvolvido para execução em instâncias **EC2**, com permissões adequadas de comunicação entre a instância e o bucket S3.

---

## 🚀 Funcionalidades

- 📤 Envio automático de arquivos `.wav` e `.mp3` para o Amazon S3
- 💰 Utilização da classe de armazenamento `INTELLIGENT_TIERING` (otimização de custos)
- 🗑️ Exclusão automática de arquivos locais com mais de 90 dias
- 📝 Logging detalhado de todas as operações
- 🔎 Verificação final de arquivos remanescentes
- 💾 Exibição de espaço em disco após a limpeza

---

## 🛠️ Tecnologias Utilizadas

- Bash Script
- Linux
- AWS CLI
- Amazon S3
- Amazon EC2
- Issabel / Asterisk

---

## 📂 Estrutura do Script

O script executa as seguintes etapas:

1. Inicializa o log
2. Sincroniza arquivos `.wav` e `.mp3` com o S3
3. Valida se a sincronização foi concluída com sucesso
4. Remove arquivos locais com mais de 90 dias
5. Verifica se ainda existem arquivos antigos
6. Exibe o espaço em disco após a limpeza
7. Finaliza o processo com log detalhado

---

## ⚙️ Configuração

### Variáveis do Script

```bash
S3_BUCKET_NAME="issabel-backup-gavacoes-mc"
S3_PATH="gravacoes/"
LOCAL_PATH="/var/spool/asterisk/monitor/"
LOG_FILE="/var/log/sync_s3.log"
```

### Requisitos

- AWS CLI instalada e configurada (`aws configure`)
- Permissões IAM adequadas para:
  - `s3:PutObject`
  - `s3:ListBucket`
  - `s3:GetObject`
- Comunicação liberada entre EC2 e S3
- Permissão de escrita no diretório de log

---

## ▶️ Como Executar

1. Torne o script executável:

```bash
chmod +x sync_s3.sh
```

2. Execute manualmente:

```bash
./sync_s3.sh
```

Ou configure no **crontab** para execução automática:

```bash
crontab -e
```

Exemplo para rodar diariamente às 2h da manhã:

```bash
0 2 * * * /caminho/para/sync_s3.sh
```

---

## 📝 Exemplo de Log

```
2025-01-10 02:00:01 - Iniciando a sincronização das gravações...
2025-01-10 02:00:05 - Sincronização para o S3 concluída com sucesso.
2025-01-10 02:00:06 - Deletando arquivo: chamada123.wav
2025-01-10 02:00:06 - SUCESSO: Arquivo deletado: chamada123.wav
2025-01-10 02:00:07 - Processo concluído.
```

---

## 🔐 Segurança

- O script só remove arquivos locais se a sincronização for concluída com sucesso.
- Permissões IAM devem ser configuradas com o princípio do menor privilégio.
- Pode ser utilizado com Role IAM anexada à EC2 (recomendado).

---

## 📈 Benefícios da Solução

- Redução de uso de armazenamento local
- Backup automatizado em nuvem
- Otimização de custos com Intelligent-Tiering
- Monitoramento detalhado por log
- Solução adequada para ambientes produtivos

---

## 📌 Melhorias Futuras

- Envio de alerta por e-mail em caso de erro
- Integração com CloudWatch Logs
- Versionamento no bucket
- Compactação automática antes do envio
- Parametrização via arquivo `.env`

---

## 👨‍💻 Autor

Criado em 2025 — Rafael Valnásio  
Projeto voltado para automação e otimização de infraestrutura de telefonia IP em ambiente AWS.

---
