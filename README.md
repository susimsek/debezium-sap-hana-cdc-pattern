# Debezium Sap Hana Cdc Pattern
> Debezium Sap Hana Cdc Pattern Example
>
<img src="https://github.com/susimsek/debezium-sap-hana-cdc-pattern/blob/main/images/debezium-sap-hana-cdc-pattern.png" alt="Debezium Hana Cdc Pattern" width="100%" height="100%"/> 

## Prerequisites

* SAP HANA
* Docker 19.03+
* Docker Compose 1.25+

## Hana Connection

Edit connection.url in json files connect-hana-source-1.json and connect-hana-sink-1.json.these json files are inside the connector folder.

```sh
"connection.url": "jdbc:sap://<host>/"
```


Edit connection1-user and connection1-password in hana-secrets.properties inside the connector folder.

```sh
connection1-user=<username>
connection1-password=<password>
```

Create a table named PERSONS1 with the following SQL schema (PersonID int primary key, LastName varchar(255), FirstName varchar(255)).

## Installation

```sh
docker build -f debezium/Dockerfile -t debezium-connector-hana-min:1.2 debezium
```

```sh
docker-compose up -d 
```

```sh
cd debezium-connector
```

```sh
sudo chmod +x connector.sh
```

```sh
./connector.sh
```

## Installation Using Vagrant

<img src="https://github.com/susimsek/debezium-sap-hana-cdc-pattern/blob/main/images/vagrant-installation.png" alt="Debezium Sap Hana Cdc Pattern Vagrant Installation" width="100%" height="100%"/> 

### Prerequisites

* SAP HANA
* Vagrant 2.2+
* Virtualbox or Hyperv

```sh
vagrant up
```

```sh
vagrant ssh
```

```sh
cd vagrant/docker-compose-setup
```

```sh
sudo chmod u+x *.sh
```

```sh
./install-prereqs.sh
```

```sh
exit
```

```sh
vagrant ssh
```

```sh
docker build -f debezium/Dockerfile -t debezium-connector-hana-min:1.2 debezium
```

```sh
docker-compose up -d 
```

```sh
cd debezium-connector
```

```sh
sudo chmod +x connector.sh
```

```sh
./connector.sh
```

You can access the Kafdrop from the following url.

http://localhost:9000

## Kafdrop
Kafdrop is a web UI for viewing Kafka topics and browsing consumer groups.

You can access the Kafdrop from the following url.

http://localhost:9000

<img src="https://github.com/susimsek/debezium-sap-hana-cdc-pattern/blob/main/images/kafdrop.png" alt="Debezium Hana Cdc Kafdrop" width="100%" height="100%"/> 
