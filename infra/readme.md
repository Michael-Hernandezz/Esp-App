#comando para ejecutar mosquito
docker exec -it mosquitto mosquitto_sub -h localhost -p 1883 -u admin -P admin12345 -t "microgrid/#" -v

