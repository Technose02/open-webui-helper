param (
    [string]$Command
)

$CONTAINER_ENGINE="podman" # chose docker or podman
$OPEN_WEBUI_PORT=8181
$OPEN_WEBUI_MOUNT_DIR=".\open-webui-data"
$OLLAMA_PORT=11434
$OLLAMA_HOST="192.168.178.77" # THIS MUST BE THE IP OF THE HOST-MACHINE AND OLLAMA MUST SERVE ON http://0.0.0.0:${OLLAMA_PORT}!!!

$CONTAINER_NAME = "open-webui"

$CMD_CREATE = "$CONTAINER_ENGINE run -d " +
              "--network=host " +
              "--volume ${OPEN_WEBUI_MOUNT_DIR}:/app/backend/data " +
              "--env WEBUI_AUTH=false " +
              "--env WEBUI_SECRET_KEY=openwebui " +
              "--env PORT=$OPEN_WEBUI_PORT " +
              "--env OLLAMA_BASE_URL=http://${OLLAMA_HOST}:$OLLAMA_PORT " +
              "--env ENABLE_OPENAI_API=false " +
              "--name $CONTAINER_NAME " +
              "--restart always " +
              "ghcr.io/open-webui/open-webui:latest"

$CMD_UPDATE = "$CONTAINER_ENGINE run " +
              "--rm " +
              "--volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower " +
              "--run-once " +
              "$CONTAINER_NAME"

$CMD_STOP   = "$CONTAINER_ENGINE stop $CONTAINER_NAME"

$CMD_RM     = "$CONTAINER_ENGINE rm $CONTAINER_NAME"
              
# Remove whitespace and convert to lowercase
$Command = $Command.Trim().ToLower()

# Check for empty or whitespace-only input
if (-not $Command) {
    Write-Host "nothing to do"
    return
}

if ($Command -eq "create") {
    New-Item  $OPEN_WEBUI_MOUNT_DIR -ItemType Directory -ea 0  > $null
    Invoke-Expression "$CMD_CREATE"  > $null
    Write-Host "$CONTAINER_NAME created and started"
}
elseif ($Command -eq "remove") {
    Invoke-Expression "$CMD_STOP" > $null
    Invoke-Expression "$CMD_RM"  > $null
    Write-Host "$CONTAINER_NAME removed"
}
elseif ($Command -eq "update") {
    Invoke-Expression "$CMD_UPDATE" > $null
    Write-Host "$CONTAINER_NAME updated"
}
else {
    Write-Host "invalid command: '$Command'"
}
