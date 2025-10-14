#!/bin/bash

# ==========================================================
# 🕒 Datacenter Clock Setup Script (for Raspberry Pi OS)
# - Uses default 'thadmin' user (no custom user required)
# - Creates a full-screen digital clock using Roboto font
# - Auto-starts on boot with Chromium (newer versions)
# - Disables translate prompts, hides mouse, prevents screen blanking
# - Starts Chromium in incognito mode to avoid "Restore pages?" pop-up
# ==========================================================

HTML_PATH="/home/thadmin/roboto-clock.html"

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

# 3. Create autostart directories
mkdir -p /home/thadmin/.config/autostart
mkdir -p /home/thadmin/.config/lxsession/LXDE-pi

# 4. Create .desktop file to launch Chromium in fullscreen incognito mode
cat > /home/thadmin/.config/autostart/roboto-clock.desktop << EOF
[Desktop Entry]
Type=Application
Name=Datacenter Clock
Exec=chromium --password-store=basic --incognito --no-first-run --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-features=Translate --kiosk file://$HTML_PATH
StartupNotify=false
Terminal=false
EOF

# 5. Configure LXDE autostart to disable screen blanking and hide mouse
cat > /home/thadmin/.config/lxsession/LXDE-pi/autostart << EOF
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.1 -root
EOF

# 6. Set proper ownership (in case run with sudo)
chown -R thadmin:thadmin /home/thadmin/.config
chown thadmin:thadmin "$HTML_PATH"

echo ""
echo "🎉 Setup completed!"
echo "✅ Rebooting in 5 seconds to apply changes..."
sleep 5
sudo reboot