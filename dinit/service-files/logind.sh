#!/bin/bash
# DizzyoOS dinit service configuration

# Create dinit service directory
mkdir -p /etc/dinit.d

# Create elogind service (systemd-logind replacement)
cat > /etc/dinit.d/elogind << 'EOF'
type = process
description = "elogind Login Manager"
command = /usr/lib/elogind/elogind-daemon
command_args = ""
restart = true
restart_delay = 5
EOF

# Create dbus service
cat > /etc/dinit.d/dbus << 'EOF'
type = process
description = "D-Bus System Message Bus"
command = /usr/bin/dbus-daemon --system --nofork
socket_type = stream
socket_path = /run/dbus/system_bus_socket
restart = true
restart_delay = 5
EOF

# Create networkmanager service
cat > /etc/dinit.d/networkmanager << 'EOF'
type = process
description = "NetworkManager"
command = /usr/bin/NetworkManager --no-daemon
restart = true
restart_delay = 5
EOF

# Create pipewire service
cat > /etc/dinit.d/pipewire << 'EOF'
type = process
description = "PipeWire Multimedia Server"
command = /usr/bin/pipewire
restart = true
restart_delay = 5
EOF

# Create wireplumber service
cat > /etc/dinit.d/wireplumber << 'EOF'
type = process
description = "WirePlumber Session Manager"
command = /usr/bin/wireplumber
restart = true
restart_delay = 5
EOF

# Create sddm service
cat > /etc/dinit.d/sddm << 'EOF'
type = process
description = "SDDM Display Manager"
command = /usr/bin/sddm
restart = true
restart_delay = 5
EOF

echo "DizzyoOS dinit services created successfully!"
