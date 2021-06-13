curl -i -X POST -H 'content-type:application/json' -d @connect-hana-source-1.json http://localhost:8083/connectors
curl -i -X POST -H 'content-type:application/json' -d @connect-hana-sink-1.json http://localhost:8083/connectors
curl -i http://localhost:8083/connectors