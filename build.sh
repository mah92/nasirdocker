sudo apt install -qq -y --no-install-recommends docker xdotool
while true; do xdotool key ctrl; sleep 60; done &
ROOT=~/Programming
mkdir $ROOT
cd $ROOT
git clone https://github.com/mah92/nasirdocker.git
cd nasirdocker
sudo docker build --file ./Dockerfile .
