# HTMLCOIN wallet for docker

Docker image that runs the HTML wallet.

If you like this image, buy me a coffee ;) 1GuggerownoWdKkMUA8C2ySkA8AK7Ucn7n (BTC)

## Quick Start (daemon)

```bash
docker run \
  -d \
  -v /some/directory:/htmlcoin \
  --name=htmlcoin \
  guggero/htmlcoin
```

## Run QT GUI

```bash
docker run \
  -ti \
  --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /some/directorya:/htmlcoin \
  guggero/htmlcoin /opt/htmlcoin/bin/htmlcoin-qt
```
