# ----------------------------------------------------------------------------------------------------------------------------------------------
# name:         diskMonitor.sh
# version:      1.0
# createTime:   2019-03-29
# title:        当前server磁盘占用率自动化脚本
# description:  脚本设定两个阈值，50% & 90%，当disk占用率超过第一个阈值则进行自动删除日志操作，日志路径支持扩展，当超过第二个阈值则进行告警，路径不支持递归
# author:       fengjingju
# ----------------------------------------------------------------------------------------------------------------------------------------------


#系统当前/data所在文件目录占用磁盘百分比
percent=`df | grep 'data' | tr "%" " " | awk '{print $5}'`

#七天前年月日
lastSevenYMD=`date -d "-7 days" +%Y%m%d`

OLD_IFS="$IFS" #默认的IFS值为换行符


# 要自动删除过期日志文件的url
message_proxy_path="/data/tomcat-9090/logs"
console_network_log_path="/data/tools/apache-tomcat-7.0.72/logs"


# function: 遍历日志文件夹中日志文件，获取带日期的文件，并与七天前日期对比，过期则进行删除操作，不支持递归
# 注意！！！: 仅支持日志文件中带日期的命名方式为年月日或者月日年，如果是奇葩的日月年命名方式就自求多福吧
# param1: 要删除日志的路径
deleteOvertimeLog()
{
  #匹配日志文件名中包含2xxx的文件，比如2019
  deleteLogFileList=`ls -a $1 | grep '^.*2[0-9]\{3\}'`

  #文件夹下日志格式有两种：***.年-月-日.log/txt;***.log.月-日-年
  for deleteLogFile in $deleteLogFileList; do
    #用.分割后，判断哪个包含2xxx，然后再对其年月日进行组合
    IFS="."
    splitStr=($deleteLogFile)
    fileDateFormat=""
    for str in ${splitStr[@]}; do 
      if [[ $str == *2???* ]]; then
        #用-分割年月日
        IFS="-"
        ss=($str)
        IFS="$OLD_IFS" #还原默认换行符
        for s in ${ss[@]}; do
          #如果是年放在最前面，否则往后拼接
          if [[ $s == 2??? ]]; then
            fileDateFormat=$s$fileDateFormat
          else
            fileDateFormat=$fileDateFormat$s
          fi
        done
      fi
    done
    #删除七天前的日志文件
    if [ $fileDateFormat -le $lastSevenYMD ]; then
      rm -f $1/$deleteLogFile
      echo $1/$deleteLogFile
    fi
  done
}


#greater than or equal 50 and less than or equal 90
if [ $percent -ge 50 ] && [ $percent -le 90 ]; then
  # !
  # !#########################################【Start】
  # 把所有要清理的日志文件目录放在这里即可，若有增加，则在下面增加一行: deleteOvertimeLog $新的日志文件路径 
  # !#########################################【Start】
  # !
  deleteOvertimeLog $console_network_log_path
  #deleteOvertimeLog $message_proxy_path
  # !
  # !#########################################【End】
  # 把所有要清理的日志文件目录放在这里即可，若有增加，则在下面增加一行: deleteOvertimeLog $新的日志文件路径 
  # !#########################################【End】
  # !

elif [ $percent > 90 ]; then
 告警！
fi
