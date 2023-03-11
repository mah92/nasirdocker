sudo dnf install -y docker xdotool
sudo apt install -y --no-install-recommends docker docker.io xdotool git
while true; do xdotool key ctrl; sleep 60; done &
ROOT=~/Desktop
mkdir $ROOT
cd $ROOT
git clone https://github.com/mah92/nasirdocker.git 
cd nasirdocker
sudo docker build -t android-qt:10 --file ./Dockerfile .
