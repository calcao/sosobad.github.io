```bash
#!/bin/sh
#---------------
#1)在windows下编写，在linux中可能无法执行,k可以尝试vi targetFile,然后:set fileformat=unix然后:x退出
#2)没有执行权限 chmod 755 xxx.sh  

#未设置系统变量需手动设置jdk路劲
#JAVA_HOME=

#JVM启动参数   
JAVA_OPTS="-Xms56m -Xmx128m"

#当前文件路劲
APP_HOME_BIN=$(cd "$(dirname "$0")"; pwd)

#程序名
APP_NAME="test"

#程序主目录
APP_HOME=$APP_HOME_BIN/..

#Java主程序 main方法所在类
APP_MAIN=com.xx.xx.xx.Test

cd $APP_HOME

#classpath参数 
#制定当前程序jar
CLASSPATH="$APP_HOME_BIN/xxx.jar"
#制定lib目录下所有依赖jar
for testJar in "$APP_HOME"/lib/*.jar;  
do  
   CLASSPATH="$CLASSPATH":"$testJar"  
done

#定义pid
testPID=0


#同过java jps命令获取程序pid
getTestPID(){  
    javaps=`$JAVA_HOME/bin/jps -l | grep $APP_MAIN`  
    if [ -n "$javaps" ]; then  
        testPID=`echo $javaps | awk '{print $1}'`  
    else  
        testPID=0  
    fi  
}

#启动方法
#调用getTestPID方法给全局变量testPID赋值
#判断是否启动 如果pid 不等于0则已启动 -ne shell为不等于
#未启动则nohup启动java程序
#启动后调用getTestPID刷新全局变量testPID
start(){  

    getTestPID  
    if [ $testPID -ne 0 ]; then  
        echo "$APP_NAME already started (PID=$testPID) "  
    else  
        echo -n "Starting $APP_NAME "  
        nohup $JAVA_HOME/bin/java $JAVA_OPTS -classpath $CLASSPATH $APP_MAIN &  
        getTestPID  
        if [ $testPID -ne 0 ]; then  
            echo "(PID=$testPID)...[Success]"  
        else  
            echo "[Failed]"  
        fi  
    fi  
}
#关闭方法
#通过testPID判断是否启动
#已启动则使用kill -9 命令关闭
#使用[$?]获取上一句命令的返回值,若其为0,表示程序已停止运行,则打印[Success],反之则打印[Failed] 
#为防止Java程序被启动多次,这里增加了反复检查程序进程的功能,通过递归调用stop()函数的方式,反复kill  
stop(){  
    getTestPID  
    if [ $testPID -ne 0 ]; then  
        echo -n "Stopping $APP_NAME(PID=$testPID)..."  
        kill -9 $testPID  
        if [ $? -eq 0 ]; then  
            echo "[Success]"  
        else  
            echo "[Failed]"  
        fi  
        getTestPID  
        if [ $testPID -ne 0 ]; then  
            stop  
        fi  
    else  
        echo "$APP_NAME is not running"  
    fi  
}

# $1 为执行脚本时的第一个参数
case "$1" in
   'start')
     start
     ;;
   'stop')
     stop
     ;;
  *)
     echo "Usage: $0 {start|stop}"
     exit 1
     ;;
esac

exit 0
```