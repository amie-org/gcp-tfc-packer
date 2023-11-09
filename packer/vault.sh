#!/bin/bash


# Install jq
echo 'Installing jq...'
sudo apt update && sudo apt-get install -y jq

jq --version

# store VAULT_ADDR
echo "storing Vault addr in env var"
echo "export VAULT_ADDR=$VAULT_ADDR" >> /etc/profile
echo "$VAULT_ADDR"

# store VAULT_NAMESPACE
echo "storing Vault namespace in env var"
echo "export VAULT_NAMESPACE=$VAULT_NAMESPACE" >> /etc/profile
echo "$VAULT_NAMESPACE"

# Store role_id
echo 'storing role_id from vault'
echo "$VAULT_ROLE_ID" > /etc/vault.d/role_id



# Install Vault
echo 'Installing Vault...'
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

vault --version


# agent config
tee /etc/vault.d/agent-config.hcl <<EOF
pid_file = "./pidfile"

vault {
   address = "$VAULT_ADDR"
   tls_skip_verify = true
}

auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/etc/vault.d/role_id"
      secret_id_file_path = "/etc/vault.d/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

   sink "file" {
      config = {
            path = "etc/vault.d/vault-token-via-agent"
      }
   }
}
EOF


# vault proxy
tee /etc/vault.d/agent-listener-config.hcl <<EOF
listener "tcp" {
   address     = "127.0.0.1:8100"
   tls_disable = true
}

listener "tcp" {
   address     = "127.0.0.1:3000"
   tls_disable = true
   role        = "metrics_only"
}

api_proxy {
   use_auto_auth_token = true
}
EOF

# print PWD
echo "current dir"
pwd

echo "role_id stored at /etc/vault.d/role_id"
cat /etc/vault.d/role_id


cat /etc/profile
# # Start a Vault API proxy -- cannot start the vault agent/proxy in an image
# vault proxy -config=agent-config.hcl \
#    -config=agent-listener-config.hcl