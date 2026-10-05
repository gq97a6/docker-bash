cd /sync/docker/compose;
for f in *.yml; do docker compose -f $f up -d; done;
