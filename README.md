# check internet connection
Check internet connection by one ping to host and use resultcode ($?) and roundtrip time to descide, if the connection is up

When the ping failes, the internet connection seems down. 
A timestamp is written to a log file - start of failue.
When the ping succeds afterwards, the internet connection seems to be up again.
A timestamp is written to a log file - end of failue.

When the ping roundtrip is less than (configurable): 10ms, my internal router answers the ping. 
(My ISP does so).
A timestamp is written to a log file - failue.

## Operation systems
The bash shell script runs on linux based os and Mac OSX.

## Depencencies
basic calulator and curl

```
sudo apt install bc
sudo apt install curl
```

## Configuration
In the script you find some variables, you could set - but you don´t need to.

```
HOST_TO_PING=8.8.8.8
```
This is the host for the ping. I configured google DNS (8.8.8.8). When this host is down and can´t respond. 
I think, my internet connection is the lesser evil. 

```
LOG_FILE=checkinternetconnection.log
```

```
MIN_TIME=10.0
```
Minimum ping time - my isp responds every ping. Even if the network is not
reachable by the bradband router. So ping times less than 10ms are internal -> FAILURE


```
WAITING=5
```
How long - in seconds - should be waited between pings