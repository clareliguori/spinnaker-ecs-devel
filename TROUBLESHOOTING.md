# Troubleshooting/Common Issues

### Pool Not Open
#### Example Exception (Found in the clouddriver log file)
2019-08-14 19:30:34.381 ERROR 24799 --- [gentScheduler-1] c.n.s.c.r.c.ClusteredAgentScheduler      : Unable to run agents
redis.clients.jedis.exceptions.JedisConnectionException: Could not get a resource from the pool
	at redis.clients.util.Pool.getResource(Pool.java:53) ~[jedis-2.9.3.jar:na]
	at redis.clients.jedis.JedisPool.getResource(JedisPool.java:226) ~[jedis-2.9.3.jar:na]
	at com.netflix.spinnaker.kork.jedis.telemetry.InstrumentedJedisPool.getResource(InstrumentedJedisPool.java:60) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.kork.jedis.telemetry.InstrumentedJedisPool.getResource(InstrumentedJedisPool.java:26) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.kork.jedis.JedisClientDelegate.withCommandsClient(JedisClientDelegate.java:45) ~[kork-jedis-5.11.1.jar:5.11.1]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.acquireRunKey(ClusteredAgentScheduler.java:178) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.acquire(ClusteredAgentScheduler.java:131) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.runAgents(ClusteredAgentScheduler.java:158) ~[cats-redis.jar:na]
	at com.netflix.spinnaker.cats.redis.cluster.ClusteredAgentScheduler.run(ClusteredAgentScheduler.java:151) ~[cats-redis.jar:na]
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511) [na:1.8.0_222]
	at java.util.concurrent.FutureTask.runAndReset(FutureTask.java:308) [na:1.8.0_222]
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.access$301(ScheduledThreadPoolExecutor.java:180) [na:1.8.0_222]
	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:294) [na:1.8.0_222]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_222]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_222]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_222]
Caused by: java.lang.IllegalStateException: Pool not open
	at org.apache.commons.pool2.impl.BaseGenericObjectPool.assertOpen(BaseGenericObjectPool.java:759) ~[commons-pool2-2.6.2.jar:2.6.2]
	at org.apache.commons.pool2.impl.GenericObjectPool.borrowObject(GenericObjectPool.java:402) ~[commons-pool2-2.6.2.jar:2.6.2]
	at org.apache.commons.pool2.impl.GenericObjectPool.borrowObject(GenericObjectPool.java:349) ~[commons-pool2-2.6.2.jar:2.6.2]
	at redis.clients.util.Pool.getResource(Pool.java:49) ~[jedis-2.9.3.jar:na]
	... 15 common frames omitted

#### Issue and Debugging Steps
If you find this exception in the clouddriver log file, it's very likely that there is another exception that has occurred when clouddriver started up (that can be found near the top of the log file). This means that clouddriver failed to start up successfully, and you will see this stacktrace in the logs for every second (or the defined the polling frequency) that clouddriver is running with the initial exception.

* Check the top of the log file (if the file is too large, you can use the `head` command to check the top of the file):
```
head -{number of lines} {log file}
// For instance, if you're looking up the first 1000 lines of the clouddriver log file.
head -1000 dev/spinnaker/logs/clouddriver.log
```
* The first exception that you see is likely the cause of the issue.

### Address already in use 
#### Example Exception (Found in the clouddriver log file)
org.apache.catalina.LifecycleException: Protocol handler start failed
	at org.apache.catalina.connector.Connector.startInternal(Connector.java:1008) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:183) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.core.StandardService.addConnector(StandardService.java:227) [tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.springframework.boot.web.embedded.tomcat.TomcatWebServer.addPreviouslyRemovedConnectors(TomcatWebServer.java:263) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.embedded.tomcat.TomcatWebServer.start(TomcatWebServer.java:195) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.startWebServer(ServletWebServerApplicationContext.java:296) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.finishRefresh(ServletWebServerApplicationContext.java:162) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:552) [spring-context-5.1.8.RELEASE.jar:5.1.8.RELEASE]
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.refresh(ServletWebServerApplicationContext.java:140) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.SpringApplication.refresh(SpringApplication.java:742) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.SpringApplication.refreshContext(SpringApplication.java:389) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:311) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.builder.SpringApplicationBuilder.run(SpringApplicationBuilder.java:139) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.springframework.boot.builder.SpringApplicationBuilder$run$0.call(Unknown Source) [spring-boot-2.1.6.RELEASE.jar:2.1.6.RELEASE]
	at org.codehaus.groovy.runtime.callsite.CallSiteArray.defaultCall(CallSiteArray.java:47) [groovy-2.5.7.jar:2.5.7]
	at org.codehaus.groovy.runtime.callsite.AbstractCallSite.call(AbstractCallSite.java:115) [groovy-2.5.7.jar:2.5.7]
	at org.codehaus.groovy.runtime.callsite.AbstractCallSite.call(AbstractCallSite.java:127) [groovy-2.5.7.jar:2.5.7]
	at com.netflix.spinnaker.clouddriver.Main.main(Main.groovy:78) [main/:na]
Caused by: java.net.BindException: Address already in use
	at sun.nio.ch.Net.bind0(Native Method) ~[na:1.8.0_222]
	at sun.nio.ch.Net.bind(Net.java:433) ~[na:1.8.0_222]
	at sun.nio.ch.Net.bind(Net.java:425) ~[na:1.8.0_222]
	at sun.nio.ch.ServerSocketChannelImpl.bind(ServerSocketChannelImpl.java:223) ~[na:1.8.0_222]
	at sun.nio.ch.ServerSocketAdaptor.bind(ServerSocketAdaptor.java:74) ~[na:1.8.0_222]
	at org.apache.tomcat.util.net.NioEndpoint.initServerSocket(NioEndpoint.java:230) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.NioEndpoint.bind(NioEndpoint.java:213) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.AbstractEndpoint.bindWithCleanup(AbstractEndpoint.java:1124) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.tomcat.util.net.AbstractEndpoint.start(AbstractEndpoint.java:1210) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.coyote.AbstractProtocol.start(AbstractProtocol.java:585) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	at org.apache.catalina.connector.Connector.startInternal(Connector.java:1005) ~[tomcat-embed-core-9.0.21.jar:9.0.21]
	... 17 common frames omitted

#### Issue and Debugging Steps
If you get this exception when performing a `hal deploy apply`, check that you don't already have an instance of that microservice already running. It's possible that you may have specific spinnaker microservices already running as root or another user. Check that the [spinnaker microservice ports](https://www.spinnaker.io/reference/architecture/#port-mappings) are not already in use. 

The following would be an example of how to debug this exception for clouddriver(port 7002):
* Check if the port for the given microservice is in use, and make a note of the process id (pid) that is using it. For instance for clouddriver, you would do the following:
```
sudo netstat -plnt | grep {port}
// For CloudDriver
sudo netstat -plnt | grep 7002 
```
* Using the process id (pid) determined above, check what process is using the open port:
```
ps -ef | grep {pid}
// For instance, if the process id was 12345
ps -ef | grep 12345
```
* If the process is another instance of the spinnaker microservice that you're trying to start, you can kill the process
```
kill -9 {pid}
// For instance, if the process id was 12345
kill -9 12345
```
* Try re-running `hal deploy apply` 
