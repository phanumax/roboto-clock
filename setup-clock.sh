#!/bin/bash

# ==========================================================
# 🕒 Datacenter Clock Setup Script (for Raspberry Pi OS)
# - Uses default 'pi' user (no custom user required)
# - Creates a full-screen digital clock using Roboto font
# - Auto-starts on boot with Chromium (newer versions)
# - Disables translate prompts, hides mouse, prevents screen blanking
# - Uses a clean Chromium profile to avoid "Restore pages?" pop-up
# ==========================================================

HTML_PATH="/home/pi/roboto-clock.html"

# 1. Create the HTML clock file
echo "📝 Creating clock HTML file..."
cat > "$HTML_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Clock</title>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@700&display=swap" rel="stylesheet">
  <style>
    body {
      background: #000;
      color: #0f0;
      font-family: 'Roboto', sans-serif;
      margin: 0;
      padding: 0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      overflow: hidden;
      letter-spacing: 2px;
    }
    #clock {
      font-size: 22vw;
      font-weight: 700;
      text-align: center;
      line-height: 1;
    }
  </style>
</head>
<body>
  <div id="clock">--:--:--</div>
  <script>
    function updateClock() {
      const now = new Date();
      const timeStr = now.toLocaleTimeString('th-TH', {
        hour12: false,
        timeZone: 'Asia/Bangkok'
      });
      document.getElementById('clock').textContent = timeStr;
    }
    setInterval(updateClock, 1000);
    updateClock();
  </script>
</body>
</html>
EOF

# 2. Install required packages
echo "📦 Installing Chromium, unclutter, and xscreensaver..."
sudo apt update
sudo apt install -y chromium unclutter xscreensaver

# 3. Remove existing Chromium profile to prevent "Restore pages?" prompt
echo "🧹 Clearing existing Chromium profile..."
rm -rf /home/pi/.config/chromium

# 4. Create autostart directories
mkdir -p /home/pi/.config/autostart
mkdir -p /home/pi/.config/lxsession/LXDE-pi

# 5. Create .desktop file to launch Chromium in fullscreen mode
cat > /home/pi/.config/autostart/roboto-clock.desktop << EOF
[Desktop Entry]
Type=Application
Name=Datacenter Clock
Exec=chromium --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-features=Translate --start-fullscreen --user-data-dir=/home/pi/.chromium-clean file://$HTML_PATH
StartupNotify=false
Terminal=false
EOF

# 6. Configure LXDE autostart to disable screen blanking and hide mouse
cat > /home/pi/.config/lxsession/LXDE-pi/autostart << EOF
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.1 -root
EOF

# 7. Set proper ownership (in case run with sudo)
chown -R pi:pi /home/pi/.config
chown pi:pi "$HTML_PATH"

echo ""
echo "🎉 Setup completed!"
echo "✅ Rebooting in 5 seconds to apply changes..."
sleep 5
sudo reboot