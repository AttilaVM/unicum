
# SSH

## Get SSH attack statistics in CSV

Get the count and geolocation data of the 10 most aggresive IP addresses, which tried to brute-force our ssh service

```shell
ssh-attack-summary.sh 10
```

```
count;country;region_name;city;isp;lat;lon;ip
26;Germany;Hesse;Frankfurt;Aceville Pte.ltd;50.1109;8.6821;43.131.59.246
22;Japan;Tokyo;Tokyo;Shenzhen Tencent Computer Systems Company Limited;35.6761;139.6503;43.163.215.247
22;Hong Kong;Central and Western District;Central;PCCW IMSBiz;22.2908;114.1501;42.200.155.72
21;Singapore;North West;Singapore;Shenzhen Tencent Computer Systems Company Limited;1.352;103.8198;43.134.111.171
19;Brazil;Maranhao;Imperatriz;Isotelco Ltda;-5.3867;-47.5382;177.185.137.78
18;United States;California;Santa Clara;Shenzhen Tencent Computer Systems Company Limited;37.3541;-121.9552;43.153.98.47
15;Hong Kong;Central and Western District;Hong Kong;Shenzhen Tencent Computer Systems Company Limited;22.3193;114.1693;43.154.134.119
14;United States;California;Santa Clara;Shenzhen Tencent Computer Systems Company Limited;37.3541;-121.9552;43.153.108.167
14;Hong Kong;Central and Western District;Hong Kong;Google LLC;22.3193;114.1693;34.92.18.55
1;Germany;Bavaria;Nuremberg;Contabo GmbH;49.405;11.1617;213.136.81.246
```

## Get geolocation data for one IP address

```shell
ip2loc.sh 43.131.59.246
```

```json
{
  "status": "success",
  "country": "Germany",
  "countryCode": "DE",
  "region": "HE",
  "regionName": "Hesse",
  "city": "Frankfurt",
  "zip": "",
  "lat": 50.1109,
  "lon": 8.6821,
  "timezone": "Europe/Berlin",
  "isp": "Aceville Pte.ltd",
  "org": "",
  "as": "AS132203 Tencent Building, Kejizhongyi Avenue",
  "query": "43.131.59.246"
}
```

# fail2ban

## Check active jails

```shell
fail2ban-client status
```

```text
Status
|- Number of jail:      1
`- Jail list:   sshd
```

# Manage OpenVPN certificates

## Set up certificate authority

This step is already done, only documented for reproducibality.

easy-rsa must be installed

Create certificate authority directory. It must be readable only for the admin user. Set umask to 077.

```shell
make-cadir ~/openvpn-ca
```

```shell
cd ~/openvpn-ca

export EASYRSA="$(pwd)"
export EASYRSA_VARS_FILE="$(pwd)/vars"
```

modify the `vars` file

```conf
...
# Choices for crypto alg are: (each in lower-case)
#  * rsa
#  * ec
#  * ed

set_var EASYRSA_ALGO            ed

# Define the named curve, used in ec & ed modes:

set_var EASYRSA_CURVE           ed25519

# In how many days should the root CA key expire?

set_var EASYRSA_CA_EXPIRE       3650

# In how many days should certificates expire?

set_var EASYRSA_CERT_EXPIRE     3650
...
```

```shell
./easyrsa --use-algo=ed --curve=ed25519 init-pki
```


## Create OpnVPN server certificate

```shell
./easyrsa gen-req unicumvpn nopass
```


## Create client certificates

```shell
./easyrsa gen-req <client name> nopass
```

```shell
./easyrsa sign-req client <client name>
```

# debug routing erros

# On linux server

```shell
tcpdump -i any dst port 5432
```

## Windows

```shell
route print
```

