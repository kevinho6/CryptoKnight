wget -qO- "https://api.coindesk.com/v1/bpi/historical/close.json" > history.txt

cat history.json | sed s/"\""/""/g | sed s/" "/""/g | sed s/"},"/"}"/g | sed s/","/""/g > cleanHistory.txt



$SHELL
