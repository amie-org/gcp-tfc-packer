#!/bin/bash

# agent config
tee agent-config.hcl <<EOF
pid_file = "./pidfile"

vault {
   address = "$VAULT_ADDR"
   tls_skip_verify = true
}

auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "./role_id"
      secret_id_file_path = "./secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

   sink "file" {
      config = {
            path = "$PWD/vault-token-via-agent"
      }
   }
}
EOF


# vault proxy
tee agent-listener-config.hcl <<EOF
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

# # Start a Vault API proxy -- cannot start the vault agent/proxy in an image
# vault proxy -config=agent-config.hcl \
#    -config=agent-listener-config.hcl