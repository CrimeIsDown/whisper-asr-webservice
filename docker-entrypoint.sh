#!/usr/bin/env bash
set -Eeo pipefail

# Check if the first arg is an executable
if [ -x "${1}" ]; then
    exec "$@"
fi

export ASR_MODEL_PATH="$(realpath ~/.cache/whisper)"
cd /app
# if not a directory or directory is empty, download the model
if [ ! -d "$ASR_MODEL_PATH" ] || [ -z "$(ls -A $ASR_MODEL_PATH)" ];
then
    echo "Starting model download to $ASR_MODEL_PATH"
    $POETRY_VENV/bin/python3 app/download_model.py 2>&1 | tee -a /onstart.log
fi

if [ -n "${WEBHOOK_SECRET}" ] && [ -n "${WEBHOOK_URL}" ]; then
    SERVER_NAME=${SERVER_NAME:-${VAST_CONTAINERLABEL:-$(hostname)}}
    SERVER_IP=${SERVER_IP:-${PUBLIC_IPADDR:-$(curl -s "https://ipinfo.io/ip")}}
    SERVER_PORT=${SERVER_PORT:-${VAST_TCP_PORT_9000:-9000}}

    set -m
    gunicorn --bind 0.0.0.0:9000 --workers ${ASR_WORKERS:-1} --timeout 0 app.webservice:app -k uvicorn.workers.UvicornWorker $@ &

    # Wait for the server to start
    sleep 5

    add_to_haproxy() {
        echo "Adding service to load balancer" | tee -a /onstart.log
        curl -fSs -H "Authorization: Bearer ${WEBHOOK_SECRET}" "${WEBHOOK_URL}" -d name=${SERVER_NAME} -d server=${SERVER_IP} -d port=${SERVER_PORT} --connect-timeout 5 2>&1 | tee -a /onstart.log
    }

    remove_from_haproxy() {
        echo "Removing service from load balancer" | tee -a /onstart.log
        curl -fSs -H "Authorization: Bearer ${WEBHOOK_SECRET}" -X DELETE "${WEBHOOK_URL}" -d name=${SERVER_NAME} --connect-timeout 5 2>&1 | tee -a /onstart.log
    }

    add_to_haproxy

    trap 'remove_from_haproxy' SIGINT SIGTERM EXIT

    fg %1
else
    gunicorn --bind 0.0.0.0:9000 --workers ${ASR_WORKERS:-1} --timeout 0 app.webservice:app -k uvicorn.workers.UvicornWorker $@
fi
