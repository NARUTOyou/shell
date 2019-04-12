weChatPid=`ps -ef | grep WeChat | grep Applications | awk '{print $2}'`

#若进程不存在则不处理
if [ "$weChatPid" != "" ];then
  kill -9 $weChatPid
fi
