#!/bin/bash
set -e

source .env

create_instance() {
   export SERVICE_NAME=$1
   export PORT=$2
   export CONF_DIR=$3
   export ACCESS_LOG=$4
   export ERROR_LOG=$5
   export PID_FILE=$6
   export MESSAGE=$7

   CONFIG_FILE=${CONF_DIR}/nginx.conf
   export CONFIG_FILE

   echo "Creating ${SERVICE_NAME}"
   sudo mkdir -p "${CONF_DIR}"
   sudo mkdir -p /var/log/nginx
   sudo touch "${ACCESS_LOG}"
   sudo touch "${ERROR_LOG}"

   envsubst < nginx.conf.template | sudo tee "${CONFIG_FILE}" >/dev/null

   envsubst < nginx.service.template | sudo tee "/etc/systemd/system/${SERVICE_NAME}.service"  >/dev/null
}
create_instance \
"$INSTANCE1_NAME" \
"$INSTANCE1_PORT" \
"$INSTANCE1_CONF_DIR" \
"$INSTANCE1_ACCESS_LOG" \
"$INSTANCE1_ERROR_LOG" \
"$INSTANCE1_PID" \
"$INSTANCE1_MESSAGE"

create_instance \
"$INSTANCE2_NAME" \
"$INSTANCE2_PORT" \
"$INSTANCE2_CONF_DIR" \
"$INSTANCE2_ACCESS_LOG" \
"$INSTANCE2_ERROR_LOG" \
"$INSTANCE2_PID" \
"$INSTANCE2_MESSAGE"

sudo systemctl daemon-reload
echo "Reloading systemd..."

sudo systemctl enable "$INSTANCE1_NAME"
sudo systemctl start "$INSTANCE1_NAME"

sudo systemctl enable "$INSTANCE2_NAME"
sudo systemctl start "$INSTANCE2_NAME"

echo "Done."
