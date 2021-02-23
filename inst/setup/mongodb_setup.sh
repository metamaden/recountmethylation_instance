mkdir -pv mongodb/database

sudo docker-compose up -d


sudo docker exec -it metamaden/recountmethylation_docker bash

sudo docker-compose down
