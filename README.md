# Pull fresh from DockerHub (like your friends would)
docker pull tejasmr/gns3-server:latest

# Run it
docker run -d --name gns3-final --cap-add NET_ADMIN -p 3080:3080 tejasmr/gns3-server:latest

# Check it's working
docker logs gns3-final
```

You should see:
```
GNS3 Server - Docker Edition
College Lab Ready | No VM Required
[INFO] Starting GNS3 Server on port 3080...
```

---

## Connect GNS3 GUI To Your Container
```
Open GNS3 GUI on your laptop
→ Edit → Preferences
→ Server → Remote Servers
→ Add: Host: localhost  Port: 3080
→ OK