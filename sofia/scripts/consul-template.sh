#!/usr/bin/env bash

export CT_VER="0.19.5"


mkdir -p /tmp/pkg/
curl -s https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip -o /tmp/pkg/consul-template_${CT_VER}_linux_amd64.zip
if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Installing consul-template version ${CT_VER} ..."
pushd /tmp
unzip /tmp/pkg/consul-template_${CT_VER}_linux_amd64.zip 
sudo chmod +x consul-template
mv consul-template /usr/local/bin/consul-template
mkdir -p /etc/ct/
cat << EOF >/etc/ct/config.hcl
template {
    source      = "/etc/ct/in.ctmpl"
    destination = "/var/www/html/index.nginx-debian.html"
}
EOF

cat << EOF >/etc/ct/in.ctmpl
{{printf "%s/site" (env "HN") | key}}
EOF