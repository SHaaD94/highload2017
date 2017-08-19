docker build -t latest_one . 
docker rmi -f stor.highloadcup.ru/travels/fluffy_coral 
docker tag latest_one stor.highloadcup.ru/travels/fluffy_coral
docker push stor.highloadcup.ru/travels/fluffy_coral
