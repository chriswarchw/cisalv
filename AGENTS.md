# CISALV - Documentação Técnica do Projeto

## Visão Geral

Migração do site institucional CISALV de PHP para Ruby on Rails, com foco em:
- Facilitar colaboração entre desenvolvedores
- Código mais amigável e manutenível
- Estrutura padronizada para onboarding de novos contribuidores

## Stack Tecnológica

| Tecnologia | Decisão | Observação |
|------------|---------|------------|
| Framework | Ruby on Rails | Escolha principal |
| Frontend | ERB + Hotwire/Turbo | Padrão Rails, fácil de entender |
| JavaScript | Stimulus | Leve, integrado ao Hotwire |
| Banco de Dados | PostgreSQL | Recomendado para produção |
| Ambientes | WSL2 | Linux no Windows via WSL2 |
| Versionamento | GitHub | Fácil onboarding de devs |
| Estilização | CSS customizado | Sem frameworks CSS (Bootstrap/Tailwind) |

## Workflow de Desenvolvimento

### Princípios
- User quer autonomia para testar e aprovar mudanças
- Mobile deve ser testado separadamente
- Usar caminhos relativos para links (ex: `/compras/licitacoes`)
- Preferir animações CSS sobre bibliotecas externas
- Manter desktop e mobile separados quando necessário
- User fornece conteúdo/requisitos, assistant implementa

### Ao Iniciar Nova Sessão
1. Ler AGENTS.md para contexto do projeto
2. Verificar estado atual: `rails routes` e `git status`
3. Perguntar o que o usuário quer fazer ou continuar de onde parou

## Estrutura do Projeto

```
/siteia26/                    # Raiz do projeto Rails
  /app/
    /assets/
      /stylesheets/application.css  # CSS principal
      /images/                       # Logos, ícones de programas
    /controllers/
      pages_controller.rb            # Home, 404
      compras_controller.rb          # Página de compras
    /javascript/
      application.js                 # JS para menus e interações
    /views/
      /layouts/application.html.erb  # Layout base com Material Icons
      /pages/home.html.erb          # Página inicial
      /compras/index.html.erb       # Página de compras
      /shared/
        _header.html.erb            # Header com menu e compliance
        _footer.html.erb            # Footer com contato
    /models/
      diario.rb                      # Modelo para diários oficiais
    /services/
      google_drive_service.rb        # Integração com Google Drive
      ocr_service.rb                 # Extração de texto via OCR
    /jobs/
      sincronizar_diarios_job.rb     # Job de sincronização
  /config/
    schedule.rb                      # Agendamento (whenever)
  /lib/tasks/
    diarios.rake                     # Tasks de administração
  /public/
    /videos/                         # Videos do hero (fundo_0.mp4 a fundo_16.mp4)
    /icon.svg                        # Favicon
    404.html                         # Página de erro 404 customizada
  config/routes.rb                   # Rotas do site
```

## Páginas Implementadas

### ✅ Concluídas
1. [x] Home (/) - Video hero, notícias, programas, categorias, Instagram, estatísticas
2. [x] 404 (/404) - Página de erro customizada
3. [x] Compras (/compras) - Página de compras e licitações
4. [x] Sistema de Busca Diário Oficial - Indexação e pesquisa de PDFs

### 🔄 Em Andamento
- Mobile search bar (ajuste de largura)

### 📋 Pendentes
- Legislação (/legislacao)
- Municípios (/municipios)
- Transparência (/transparencia)
- Histórico
- Contato
- Galeria de Fotos
- Downloads

## Funcionalidades Implementadas

### Home Page
- **Video Hero**: 17 segmentos de vídeo, seleção aleatória ao carregar
- **Seção de Notícias**: Layout featured + lista
- **Seção de Programas**: Ícones Material Icons, hover com descrições (desktop) / cards expandíveis (mobile)
- **Contador de Estatísticas**: Animação exponencial acionada por scroll
- **Seção de Categorias**: 8 categorias com ícones Material Icons
- **Placeholder Instagram**: Estrutura pronta para integração (tokens expiram em 60 dias)

### Navegação
- **Desktop**: Menu dropdown com 11 itens de compliance
- **Mobile**: Botões hamburger + painel lateral para Menu e Compliance
- **Busca**: Toggle expansível no mobile

### Sistema de Busca Diário Oficial

#### Arquitetura
```
Google Drive (pasta PDF)
      │
      ▼ (Google Drive API)
┌─────────────────────────────────┐
│           Rails                 │
│  ├─ SincronizarDiariosJob      │
│  ├─ GoogleDriveService         │
│  └─ OcrService (Tesseract)     │
└─────────────────────────────────┘
      │
      ▼
PostgreSQL (texto extraído + busca full-text)
      │
      ▼
Resultados da busca (link Google Drive)
```

#### Funcionalidades
- **Google Drive API**: Lista e baixa PDFs automaticamente
- **OCR com Tesseract**: Extrai texto de imagens escaneadas
- **Full-text Search**: Busca em português com stemming
- **Fuzzy Matching**: Tolerância a erros de digitação (pg_trgm)
- **Agendamento**: Job roda todo dia às 3h da manhã

#### Tabela: diarios
| Campo | Descrição |
|-------|-----------|
| drive_file_id | ID único do arquivo no Google Drive |
| drive_web_view_link | Link para visualização |
| titulo | Título extraído do nome do arquivo |
| conteudo_texto | Texto original do PDF |
| conteudo_ocr | Texto extraído via OCR |
| data_publicacao | Data extraída do nome |
| search_vector | Índice para busca full-text |
| processado | Se foi processado com sucesso |
| ocr_pendente | Se precisa de OCR |

#### Comandos
```bash
# Sincronizar diários manualmente
rails diarios:sincronizar

# Processar apenas OCR pendente
rails diarios:processar_ocr

# Testar busca
rails diarios:buscar QUERY="contrato"

# Atualizar schedule do cron
whenever --update-crontab
```

### Design
- **Paleta de Cores**: Primary `#1C4587`, Secondary `#2E5A9E`
- **Ícones**: Material Icons via Google Fonts
- **Responsivo**: Breakpoint principal em 768px

## Configuração Necessária

### Variáveis de Ambiente
```bash
# Google Drive
GOOGLE_DRIVE_FOLDER_ID=  # ID da pasta no Google Drive
GOOGLE_SERVICE_ACCOUNT_JSON=  # JSON da conta de serviço

# Exemplo de JSON:
# {"type":"service_account","project_id":"...","private_key_id":"...","private_key":"-----BEGIN RSA PRIVATE KEY-----\n...","client_email":"...@....iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token"...}
```

### Instalação no Servidor
```bash
# Instalar dependências do sistema
sudo apt install tesseract-ocr tesseract-ocr-por poppler-utils

# Instalar gems
bundle install

# Migrar banco
rails db:migrate

# Configurar cron
whenever --update-crontab
```

## Decisões Técnicas Documentadas

### Layouts
- `application.html.erb` como layout base
- Partials para: header, footer, navigation
- Herança de layouts quando necessário

### Estilização
- CSS customizado (sem frameworks)
- Animações CSS para interações
- Media queries para responsividade

### Mobile
- Não há eventos hover - usar click/touch
- Panéis laterais para Menu/Compliance
- Cards expandíveis para programas

### Busca Diário Oficial
- PostgreSQL full-text search com `portuguese` dictionary
- Extensão pg_trgm para fuzzy matching
- Tesseract OCR para extração de texto de imagens
- Job agendado com whenever (cron)

## Fluxo de Dados

### Google API (Futuro)
- Manter Google Sheets como fonte de dados
- Service Objects para consumo da API
- Cache quando apropriado

## Comandos Úteis

```bash
# Servidor local
rails server -b 0.0.0.0

# Ver rotas
rails routes

# Status git
git status

# Linting
bundle exec rubocop

# Diário Oficial
rails diarios:sincronizar
rails diarios:buscar QUERY="licitação"
```

## Links do Projeto

- Site atual: https://cisalv.mg.gov.br/
- Repositório: [a configurar]

## Descobertas Técnicas

| Data | Descoberta | Observação |
|------|------------|------------|
| 2026-03 | WSL2 networking | Necessário port forwarding via PowerShell para testes mobile |
| 2026-03 | IP local | `ip -br addr` é mais limpo que `ifconfig` |
| 2026-03 | Favicon SVG | SVG não funciona renomeado para .ico - precisa PNG |
| 2026-03 | Imagemagick | Não disponível, ffmpeg está instalado |
| 2026-03 | Rails 404 | 404.html estático precisa de configuração separada das rotas |
| 2026-03 | Instagram API | Tokens expiram em 60 dias - preparar estrutura |
| 2026-03 | Google Custom Search | API fechada para novos clientes em 2026 |
| 2026-03 | PostgreSQL full-text | Busca com fuzzy matching e relevância |
| 2026-03 | Tesseract OCR | Extrai texto de imagens em PDFs escaneados |
| 2026-03 | Google Drive API | Acesso a PDFs via conta de serviço |

## Histórico de Decisões

| Data | Decisão | Motivo |
|------|---------|--------|
| 2026-03-25 | Ruby on Rails | Facilitar colaboração, código explícito |
| 2026-03-25 | Sem n8n | Não há necessidade de automação complexa |
| 2026-03-25 | GitHub | Onboarding mais fácil para novos devs |
| 2026-03-25 | WSL2 | Compatibilidade e performance |
| 2026-03-27 | CSS customizado | Sem frameworks, animações nativas |
| 2026-03-27 | PostgreSQL full-text | Sem dependência de serviços externos |
| 2026-03-27 | Tesseract OCR | Gratuito, funciona localmente |
| 2026-03-27 | Google Drive API | Acesso direto aos PDFs do Diário |

## Fluxo de Trabalho

1. Desenvolver em **feature branches**
2. **Code review** antes de merge
3. **Testes** para funcionalidades críticas
4. Commits com **Conventional Commits**
5. Testar desktop E mobile separadamente
