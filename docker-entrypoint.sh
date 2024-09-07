#!/usr/bin/env bash
set -Eeo pipefail

# Check if the first arg is an executable
if [ -x "${1}" ]; then
    exec "$@"
fi

add_to_haproxy() {
    if [ -n "${API_KEY}" ] && [ -n "${API_BASE_URL}" ] && [ -n "${VAST_CONTAINERLABEL}" ] && [ -n "${VAST_TCP_PORT_9000}" ] && [ -n "${PUBLIC_IPADDR}" ]; then
        echo "Adding service to load balancer" | tee -a /onstart.log
        curl -fSs -H "Authorization: Bearer ${API_KEY}" "${API_BASE_URL}/haproxy" -d name=${VAST_CONTAINERLABEL} -d server=${PUBLIC_IPADDR} -d port=${VAST_TCP_PORT_9000} --connect-timeout 5 2>&1 | tee -a /onstart.log
    fi
}

remove_from_haproxy() {
    if [ -n "${API_KEY}" ] && [ -n "${API_BASE_URL}" ] && [ -n "${VAST_CONTAINERLABEL}" ] && [ -n "${VAST_TCP_PORT_9000}" ] && [ -n "${PUBLIC_IPADDR}" ]; then
        echo "Removing service from load balancer" | tee -a /onstart.log
        curl -fSs -H "Authorization: Bearer ${API_KEY}" -X DELETE "${API_BASE_URL}/haproxy" -d name=${VAST_CONTAINERLABEL} --connect-timeout 5 2>&1 | tee -a /onstart.log
    fi
}

export ASR_MODEL_PATH="$(realpath ~/.cache/whisper)"
cd /app
# if not a directory or directory is empty, download the model
if [ ! -d "$ASR_MODEL_PATH" ] || [ -z "$(ls -A $ASR_MODEL_PATH)" ];
then
    echo "Starting model download to $ASR_MODEL_PATH"
    $POETRY_VENV/bin/python3 app/download_model.py 2>&1 | tee -a /onstart.log
fi

set -m
gunicorn --bind 0.0.0.0:9000 --workers ${ASR_WORKERS:-1} --timeout 0 app.webservice:app -k uvicorn.workers.UvicornWorker $@ &

# Wait for the server to start
sleep 5

add_to_haproxy

trap 'remove_from_haproxy' SIGINT SIGTERM EXIT

fg %1
