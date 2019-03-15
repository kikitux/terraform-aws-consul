#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
set -x
#export DOMAIN="consul"

#export DCNAME="dc1"




var2=$(hostname)
mkdir -p /tmp/logs
mkdir -p /etc/consul.d


# Function used for initialize Consul. Requires 2 arguments: Log level and the hostname assigned by the respective variables.
# If no log level is specified in the Vagrantfile, then default "info" is used.
init_consul () {
    killall consul

    LOG_LEVEL=$1
    if [ -z "$1" ]; then
        LOG_LEVEL="info"
    fi

    if [ -d /tmp/logs ]; then
    mkdir /tmp/logs
    LOG="/tmp/logs/$2.log"
    else
    LOG="consul.log"
    fi

    IP=$(hostname -I)

    sudo useradd --system --home /etc/consul.d --shell /bin/false consul
    sudo chown --recursive consul:consul /etc/consul.d
    sudo chmod -R 755 /etc/consul.d/
    sudo mkdir --parents /tmp/consul
    sudo chown --recursive consul:consul /tmp/consul
    mkdir -p /tmp/consul_logs/
    sudo chown --recursive consul:consul /tmp/consul_logs/

    cat << EOF > /etc/systemd/system/consul.service
    [Unit]
    Description="HashiCorp Consul - A service mesh solution"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target

    [Service]
    User=consul
    Group=consul
    ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
    ExecReload=/usr/local/bin/consul reload
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536


    [Install]
    WantedBy=multi-user.target

EOF
}

# Function for creating the gossip encryption conf file. Requires 1 argument: the hostname . This function is always executed only once on the 1st server.

# Function that creates the conf file for the Consul servers. It requires 8 arguments. All of them are defined in the beginning of the script.
# Arguments 5 and 6 are the SOFIA_SERVERS and BTG_SERVERS and they are twisted depending in which DC you are creating the conf file.
create_server_conf () {
    cat << EOF > /etc/consul.d/config_${1}.json
    
    {
        
        "server": true,
        "node_name": "${2}",
        "bind_addr": "${3}",
        "client_addr": "0.0.0.0",
        "bootstrap_expect": ${4},
        "retry_join": ${5},
        "log_level": "${6}",
        "data_dir": "/tmp/consul",
        "enable_script_checks": true,
        "domain": "${7}",
        "datacenter": "${1}",
        "ui": true

    }
EOF
}

# Function that creates the conf file for Consul clients. It requires 6 arguments and they are defined in the beginning of the script.
# 3rd argument shall be the JOIN_SERVER as it points the client to which server contact for cluster join.
create_client_conf () {
    cat << EOF > /etc/consul.d/consul_client.json

        {
            "node_name": "${1}",
            "bind_addr": "${2}",
            "client_addr": "0.0.0.0",
            "retry_join": ${3},
            "log_level": "${4}",
            "data_dir": "/tmp/consul",
            "enable_script_checks": true,
            "domain": "${5}",
            "datacenter": "${6}",
            "ui": true
        }

EOF
}
# Starting consul
init_consul ${LOG_LEVEL} ${var2} 
if [[ "${var2}" =~ "ip-172-31-16" ]]; then
    killall consul

    create_server_conf ${DCNAME} ${var2} ${IP} ${SERVER_COUNT} ${SOFIA_SERVERS} ${LOG_LEVEL} ${DOMAIN}

    sudo systemctl enable consul >/dev/null
   
    sudo systemctl start consul >/dev/null
    sleep 5
else
    if [[ "${var2}" =~ "ip-172-31-17" ]]; then
        killall consul
        create_client_conf ${var2} ${IP} ${JOIN_SERVER} ${LOG_LEVEL} ${DOMAIN} ${DCNAME}
    fi
   
    sudo systemctl enable consul >/dev/null
    sudo systemctl start consul >/dev/null
    
fi


sleep 5
consul members
set +x