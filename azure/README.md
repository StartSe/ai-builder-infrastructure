# Documentação AI Builder Azure

Iremos provisionar: 
- Um resource group separado para a solução
- Um container environment para provisionar o container da solução
- Um container app para o AI BUilder
- Um banco de dados postgresql para resiliência do ambiente


Para criar o serviço do AI Builder vamos precisar da CLI do Azure. Para instalá-la podemos seguir a própria documentação da Microsoft como esta no seguinte link: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli. Após fazer a instalação precisamos fazer o login com o seguinte comando:
```markdown
az login
```

# Precisamos clonar o projeto do github
```markdown
git clone https://github.com/StartSe/ai-builder-infrastructure.git
cd azure
```

# Criar um arquivo terraform.tfvars com as seguintes environments, na pasta Azure
As variáveis com prefixo `your_` devem ser substituídas pelos valores de interesse.


```markdown
resource_group_name = "your_resource_group_name"
container_environment_name = "your_container_environment_name"
container_app_name = "your_container_app_name"
location                    = "your_location"
postgres_admin              = "your_postgres_admin"
postgres_password           = "your_postgres_password"
subscription_id             = "your_subscription_id"
passphrase                  = "your_passphrase"
flowise_username            = "your_flowise_username"
flowise_password            = "your_flowise_password"
database_server_name        = "your_database_server_name"
database_container_app_host = "your_database_container_app_host"
database_name               = "your_database_name"
database_port               = 5432
flowise_secretkey_overwrite = "your_flowise_secretkey_overwrite"
subscription_name           = "your_subscription_name"
project_name                = "your_project_name"
webapp_ip_rules = [
  {
    name                      = "AllowedIP"
    ip_address                = "0.0.0.0"
    headers                   = null
    virtual_network_subnet_id = null
    subnet_id                 = null
    service_tag               = null
    priority                  = 300
    action                    = "Allow"
  }
]
source_image = "startse/ai-builder:5628e4e84b48056c823505300350aaef3a45de20"
```
# Iniciar o terraform
```markdown
terraform init
```

# Provisionar a infraestrutura
```markdown
terraform apply
```
