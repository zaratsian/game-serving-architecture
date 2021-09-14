# Game Serving Architecture

## Setup

Edit [config](./config)
```
vi config
```

Deploy [Agones](https://agones.dev/site/) on GKE
```
make deploy-agones
```

Deploy GCGS [Google Cloud Game Servers](https://cloud.google.com/game-servers)
```
make deploy-gcgs
```

