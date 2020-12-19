#! /bin/sh
# Winbox Installer
# Print error messages and defining error status with non-zero value
errMsg() {
  echo "USAGE:
To install
sudo bash winbox-setup install

To remove
sudo bash winbox-setup remove"
  exit 1
}

# Installing dependencies
depInst() {
  DISTRIBUTION=`sed "/^ID/s/ID=//gp" -n /etc/os-release`
  echo -n "Installing dependencies..."
  case $DISTRIBUTION in
    'fedora' | '"rhel"' | '"centos"' | '"IGN"' )
      dnf -q -y install wine wget > /dev/null 2>&1
      echo "DONE"
    ;;
    'ubuntu' | 'debian' | '"elementary"' | 'linuxmint' | 'kali' )
      apt-get -q -y install wine wget > /dev/null 2>&1
      echo "DONE"
    ;;
    *)
      echo "FAILED"
      exit 1
    ;;
  esac
}

# Downloading latest version of Winbox from Mikrotik's website.
# The URL of the file is parsed from https://mikrotik.com/download
wbDl() {

  if [[ $(ls -al | grep winbox.exe) ]]
  then
    echo "Using previously downloaded winbox.exe"
  else
    echo -n "Downloading Winbox..."
    URL="http:"$(curl -s https://mt.lv/winbox64 | grep -o //.*winbox.exe)
    URLlenght=${#URL}
    if [[ $URLlenght<3 ]]; then
      echo "FAILED"
      exit 1
    else
      wget -q -c -O winbox.exe $URL
      echo "DONE"
    fi
  fi
}

filesCp() {
  echo -n "Copying files..."
  if [[ !$(mkdir -p /opt/winbox) ]]
  then
    if [[ !$(cp -f winbox.exe /opt/winbox/winbox.exe) ]]
    then
      cp -f icons/winbox-128x128.png /usr/share/icons/hicolor/128x128/apps/winbox.png
      cp -f icons/winbox-16x16.png /usr/share/icons/hicolor/16x16/apps/winbox.png
      cp -f icons/winbox-192x192.png /usr/share/icons/hicolor/192x192/apps/winbox.png
      cp -f icons/winbox-20x20.png /usr/share/icons/hicolor/20x20/apps/winbox.png
      cp -f icons/winbox-22x22.png /usr/share/icons/hicolor/22x22/apps/winbox.png
      cp -f icons/winbox-24x24.png /usr/share/icons/hicolor/24x24/apps/winbox.png
      cp -f icons/winbox-256x256.png /usr/share/icons/hicolor/256x256/apps/winbox.png
      cp -f icons/winbox-32x32.png /usr/share/icons/hicolor/32x32/apps/winbox.png
      cp -f icons/winbox-36x36.png /usr/share/icons/hicolor/36x36/apps/winbox.png
      cp -f icons/winbox-40x40.png /usr/share/icons/hicolor/40x40/apps/winbox.png
      cp -f icons/winbox-48x48.png /usr/share/icons/hicolor/48x48/apps/winbox.png
      cp -f icons/winbox-64x64.png /usr/share/icons/hicolor/64x64/apps/winbox.png
      cp -f icons/winbox-72x72.png /usr/share/icons/hicolor/72x72/apps/winbox.png
      cp -f icons/winbox-8x8.png /usr/share/icons/hicolor/8x8/apps/winbox.png
      cp -f icons/winbox-96x96.png /usr/share/icons/hicolor/96x96/apps/winbox.png
      echo "DONE"
    else
      echo "FAILED"
      exit 1
    fi
  else
    echo "FAILED"
    exit 1
  fi
}

lncCrt() {
  echo -n "Creating application launcher..."
  if touch /usr/share/applications/winbox.desktop
  then
    echo "[Desktop Entry]" > /usr/share/applications/winbox.desktop
    echo "Name=Winbox" >> /usr/share/applications/winbox.desktop
    echo "GenericName=Configuration tool for RouterOS" >> /usr/share/applications/winbox.desktop
    echo "Comment=Configuration tool for RouterOS" >> /usr/share/applications/winbox.desktop
    echo "Exec=wine /opt/winbox/winbox.exe" >> /usr/share/applications/winbox.desktop
    echo "Icon=winbox" >> /usr/share/applications/winbox.desktop
    echo "Terminal=false" >> /usr/share/applications/winbox.desktop
    echo "Type=Application" >> /usr/share/applications/winbox.desktop
    echo "StartupNotify=true" >> /usr/share/applications/winbox.desktop
    echo "Categories=Network;RemoteAccess;" >> /usr/share/applications/winbox.desktop
    echo "Keywords=winbox;mikrotik;" >> /usr/share/applications/winbox.desktop
    echo "DONE"
  else
    echo "FAILED"
    exit 1
  fi
}

filesRm() {
  echo -n "Removing launcher..."
  find /usr/share/applications/ -name "winbox.desktop" -delete
  echo "DONE"

  echo -n "Removing icons..."
  find /usr/share/icons -name "winbox.png" -delete
  echo "DONE"

  echo -n "Removing files..."
  rm -rf /opt/winbox/
  echo "DONE"
}

if [ -z "$1" ]; then
  errMsg;
fi
case $1 in
  'install' )
    depInst
    if wbDl
    then
      if filesCp
      then
        lncCrt
      else
        echo "FAILED"
        exit 1
      fi
    else
      echo "FAILED"
      exit 1
    fi
  ;;

  'remove' )
    filesRm
  ;;

  * )
    errMsg
  ;;
esac
