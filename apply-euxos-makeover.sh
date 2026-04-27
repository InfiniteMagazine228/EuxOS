cat > /home/tc/euxos/apply-euxos-makeover.sh <<'EOF'
#!/bin/sh

mkdir -p /home/tc/euxos
mkdir -p /home/tc/.X.d

cat > /home/tc/euxos/euxos-welcome.txt <<'WELCOME'
========================================
              EuxOS
        Private. Smart. Fluid.
========================================

Welcome to EuxOS Visual Preview.

This system is a lightweight GUI concept build.

Core principles:
- Minimal but powerful
- Privacy first
- AI-native experience
- Fast and lightweight
- Friendly for users and developers
WELCOME

cat > /home/tc/euxos/about-euxos.txt <<'ABOUT'
EuxOS Visual Preview 0.1

Codename: Aurora
Base: Tiny GUI
Theme: EuxOS Dark
Identity: Private. Smart. Fluid.

This is a concept operating system focused on:
- minimal design
- performance
- privacy
- AI-native experience
ABOUT

cat > /home/tc/euxos/eux-welcome.sh <<'WELCOMEAPP'
#!/bin/sh
xterm -T "Welcome to EuxOS" -e sh -c "cat /home/tc/euxos/euxos-welcome.txt; echo; echo 'Press ENTER to close'; read x"
WELCOMEAPP
chmod +x /home/tc/euxos/eux-welcome.sh

cat > /home/tc/euxos/eux-about.sh <<'ABOUTAPP'
#!/bin/sh
xterm -T "About EuxOS" -e sh -c "cat /home/tc/euxos/about-euxos.txt; echo; echo 'Press ENTER to close'; read x"
ABOUTAPP
chmod +x /home/tc/euxos/eux-about.sh

cat > /home/tc/euxos/eux-terminal.sh <<'TERMAPP'
#!/bin/sh
exec xterm -T "Eux Terminal"
TERMAPP
chmod +x /home/tc/euxos/eux-terminal.sh

cat > /home/tc/euxos/euxos-menu.sh <<'MENUAPP'
#!/bin/sh
xterm -T "EuxOS Menu" -e sh -c '
clear
echo "=============================="
echo "          EUXOS MENU"
echo "=============================="
echo "1. About EuxOS"
echo "2. Welcome"
echo "3. System Info"
echo ""
echo "This is EuxOS Visual Preview."
echo ""
echo "Press ENTER to close."
read x
'
MENUAPP
chmod +x /home/tc/euxos/euxos-menu.sh

cat > /home/tc/.X.d/euxos-startup <<'STARTUP'
#!/bin/sh
/home/tc/euxos/eux-welcome.sh &
STARTUP
chmod +x /home/tc/.X.d/euxos-startup

sudo hostname euxos 2>/dev/null
echo "euxos" | sudo tee /etc/hostname >/dev/null 2>&1

grep -q "home/tc/euxos" /opt/.filetool.lst 2>/dev/null || echo "home/tc/euxos" | sudo tee -a /opt/.filetool.lst >/dev/null
grep -q "home/tc/.X.d" /opt/.filetool.lst 2>/dev/null || echo "home/tc/.X.d" | sudo tee -a /opt/.filetool.lst >/dev/null
grep -q "etc/hostname" /opt/.filetool.lst 2>/dev/null || echo "etc/hostname" | sudo tee -a /opt/.filetool.lst >/dev/null

filetool.sh -b 2>/dev/null

echo ""
echo "========================================"
echo "EuxOS makeover installed!"
echo "Run this to open welcome:"
echo "  /home/tc/euxos/eux-welcome.sh"
echo ""
echo "Run this to open about:"
echo "  /home/tc/euxos/eux-about.sh"
echo "========================================"
EOF

chmod +x /home/tc/euxos/apply-euxos-makeover.sh
/home/tc/euxos/apply-euxos-makeover.sh
