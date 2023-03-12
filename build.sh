#sudo dnf install -y docker xdotool
#sudo apt install -y --no-install-recommends xdotool
sudo apt install -y --no-install-recommends docker docker.io git
#while true; do xdotool key ctrl; sleep 60; done &
ROOT=~/Desktop
mkdir $ROOT
cd $ROOT
git clone https://github.com/mah92/nasirdocker.git 
cd nasirdocker
sudo chmod +x extract-qt-installer.sh
sudo chmod +x install-qt.sh
sudo docker build -t android-qt:10 --file ./Dockerfile .
