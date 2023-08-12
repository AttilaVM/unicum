# Minecraft server administration

## API

### Start server

```
curl -X POST -H "Content-Type: application/json" -d '{"command": "start"}' http://172.20.0.21/command
```

### Stop server

```
curl -X POST -H "Content-Type: application/json" -d '{"command": "stop"}' http://172.20.0.21/command
```