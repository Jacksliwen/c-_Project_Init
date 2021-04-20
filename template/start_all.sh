PWD=`pwd`
ConsulIp="127.0.0.1"
ProcessNum=32
temp=`getopt -o c::p:: --long consul::,process:: \
     -n 'example.bash' -- "$@"`

if [ $? != 0 ] ; then 
echo "terminating..." >&2 ; exit 1 ; 
fi

eval set -- "$temp"
while true ; do
    case "$1" in
        -c|--consul)
            case "$2" in
                "") echo "-c no arg"; shift 2 ;;
                *)  ConsulIp=$2 ; shift 2 ;;
            esac ;;
        -p|--process)
            case "$2" in
                "") echo "-p no arg"; shift 2 ;;
                *)  ProcessNum=$2 ; shift 2 ;;
            esac ;;
                --) shift ; break ;;
                *) echo "internal error!" ; exit 1 ;;
    esac
done

echo "consul Ip $ConsulIp Process Num $ProcessNum"
sum=1 
for line in `find ./ -name start.sh |xargs dirname` 
do                                                        
  cd $line 
  sed -i "s/127.0.0.1/$ConsulIp/g" start.sh                                                                                                                                       
  ./start.sh                                              
  cd ..
  ((++sum))
  if [[ $sum > $ProcessNum ]]; then 
    break    
  fi                                                
done

sed -i "s/127.0.0.1/$ConsulIp/g" $PWD/start_all.sh                                                                                                                                        

