# Load Config
. ./config

# Create GCP Firewall Rule to allow UDP traffic on specified ports
gcloud compute firewall-rules create gcgs-quickstart-firewall \
--allow udp:7000-8000 \
--target-tags game-server \
--description "Firewall to allow game server udp traffic"

# Get IP Address of Game Server
echo "Use the IP and port of the Game Server (shown below):"
kubectl get gameserver

echo "Run the following command to connect to the game server:"
echo "nc -u <IP_ADDRESS> <PORT>



