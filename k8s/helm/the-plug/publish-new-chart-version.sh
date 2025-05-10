#!/bin/bash -i
# run with version as argument
source ~/.bashrc
helm package .
if [ -n "$2" ]; then
    git clone https://$2@github.com/WallyS02/The-Plug-Charts.git
else
    git clone https://github.com/WallyS02/The-Plug-Charts.git
fi
git clone https://github.com/WallyS02/The-Plug-Charts
mv the-plug-0.0.1.tgz the-plug-"$1".tgz
find The-Plug-Charts -type f -name 'the-plug-*' -delete
mv the-plug-"$1".tgz The-Plug-Charts/
helm repo index The-Plug-Charts/ --url https://wallys02.github.io/The-Plug-Charts
cd The-Plug-Charts
git add .
git commit -m "Added new Helm Chart $1 version for The Plug application"
git push origin main
cd ..
rm -rf The-Plug-Charts