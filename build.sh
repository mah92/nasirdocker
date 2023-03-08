sudo apt install -qq -y --no-install-recommends docker xdotool
while true; do xdotool key ctrl; sleep 60; done &
cd nasirdocker
docker build --file ./Dockerfile .
