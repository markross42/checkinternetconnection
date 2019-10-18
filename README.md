# check internet connection
Check internet connection by one ping to host and use resultcode ($?) and roundtrip time to decide, 
if the connection seems up.

* When the ping failes (resultcode > 0), the internet connection seems down. A timestamp is written to a log file - start of failue.
* When the ping succeeds afterwards, the internet connection seems to be up again. A timestamp is written to a log file - end of failue.
* When the ping roundtrip is less than 10ms - the answer seems to come from the internal router
(My ISP does so). A timestamp is written to the log file - failue.

## Operation systems
The bash shell script runs on linux based os and Mac OSX.

## Depencencies
basic calulator (bc) and curl

Install opn Debian based linux:
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
reachable by the broadband router. So ping times less than 10ms are internal -> FAILURE

```
WAITING=5
```
How long - in seconds - should be waited between pings

## Start in background
In the checkinternetconnection directory start script in backgound

```
nohup ./checkinternetconnection.sh &
```
Result of standard out is written to `nohup.out

##log file 
a semicolon separated file is generated: initial checkinternetconnection.log

Format: `dd.mm.yyyy;hh:mm:ss;fail state;roundtrip time;fail name;result code`
* dd.mm.yyyy: date
* hh:mm:ss: time
* fail state: Start failure, End failure, Failure exists, End failure
* roundtrip time: ping time time (in milliseconds)
* fail name: PING_OK, PING_FAILED, TOO_QUICKLY
```
ddmmyyyy;hh:mm:ss
```