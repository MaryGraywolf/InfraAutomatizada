# Infraestrutura Automatizada

Guia completo para configurar o ambiente de desenvolvimento para trabalhar com Terraform, Ansible e AWS CLI.

## 📋 Pré-requisitos

- Sistema operacional: Ubuntu/Debian
- Acesso sudo no servidor
- Conexão com internet
- Arquivo de chave privada AWS (.pem)

## 🚀 Passo a Passo de Configuração

### 1. Atualizar o Sistema

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Instalar Ansible

```bash
sudo apt install ansible -y
```

Verifique a instalação:
```bash
ansible --version
```

### 3. Configurar Chave SSH

Substitua `~/rota/para/guardar/o/pem` pelo caminho correto da sua chave:

```bash
chmod 400 ~/rota/para/guardar/o/pem
```

> **Nota**: A permissão 400 garante que apenas o proprietário pode ler a chave.

### 4. Instalar Terraform

Primeiro, adicione o repositório HashiCorp:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Atualize e instale:

```bash
sudo apt update
sudo apt install terraform -y
```

Verifique a instalação:
```bash
terraform --version
```

### 5. Instalar AWS CLI v2

Primeiro, remova a versão antiga (se houver):

```bash
sudo apt remove awscli -y
```

Instale as dependências necessárias:

```bash
sudo apt install unzip -y
```

Baixe e instale o AWS CLI v2:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Limpe os arquivos temporários:

```bash
rm awscliv2.zip
rm -rf aws/
```

### 6. Configurar Credenciais AWS

Execute o comando:

```bash
aws configure
```

Você será solicitado a informar:
- **AWS Access Key ID**: Sua chave de acesso
- **AWS Secret Access Key**: Sua chave secreta
- **Default region name**: Região AWS (ex: us-east-1)
- **Default output format**: Formato de saída (ex: json)

Verifique a configuração:
```bash
aws sts get-caller-identity
```

## 📁 Estrutura do Projeto

- `terraform/` - Configuração de infraestrutura com Terraform
- `ansible/` - Playbooks de automação com Ansible

## ✅ Verificação Final

Após seguir todos os passos, verifique a instalação de todas as ferramentas:

```bash
ansible --version
terraform --version
aws --version
```

Se todos os comandos retornarem as versões instaladas, o ambiente está configurado com sucesso!

## 🤝 Próximos Passos

1. Configure suas credenciais AWS
2. Navegue até a pasta `terraform/` e execute `terraform init`
3. Revise os arquivos de configuração antes de aplicar mudanças
4. Use os playbooks Ansible para automatizar tarefas

## 📝 Notas Importantes

- Sempre mantenha suas chaves privadas seguras
- Nunca commite arquivos `.pem` ou credenciais no repositório
- Use `terraform plan` antes de `terraform apply` para revisar mudanças
- Teste os playbooks Ansible em um ambiente de desenvolvimento primeiro

---

**Última atualização**: 29 de janeiro de 2026