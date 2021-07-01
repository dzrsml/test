#!/bin/bash

describe() {
    cat << EOF

    Usage:
        bash $0 [-t] [-i] [-u] [-s] [-c] [-f <URL>] [-h]
    
    Options:
        t   统计访问来源主机TOP 100和分别对应出现的总次数
        i   统计访问来源主机TOP 100 IP和分别对应出现的总次数
        u   统计最频繁被访问的URL TOP 100
        s   统计不同响应状态码的出现次数和对应百分比
        c   分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
        f   给定URL输出TOP 100访问来源主机
        h   帮助信息

EOF
}

CheckFile(){
    if [[ ! -f "web_log.tsv.7z" ]];then
        wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z
        7z x web_log.tsv.7z
    elif [[ ! -f "web_log.tsv" ]];then
        7z x web_log.tsv.7z
    fi
}


CountHost(){
    printf "+++++++++++++++++++++++\n"
    printf "|出现次数|来源主机名称|\n"
    printf "+++++++++++++++++++++++\n"
    awk -F '\t' '
    NR>1{hosts[$1]++;}
    END{      
        for( host in hosts ){
            print hosts[host] "\t|" host "\t\n";
        }
    }
    ' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}
    

CountIp(){
    printf "+++++++++++++++++++++++\n"
    printf "|出现次数|来源主机ip|\n"
    printf "+++++++++++++++++++++++\n"
    awk -F '\t' '
    NR>1 { 
        if(match($1,/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/)){
            hosts[$1]++; 
        }          
    }
    END{ 
        for(host in hosts){
            print hosts[host] "\t" host "\t\n";
        }
    }' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}

MostFrequent(){    
    printf "+++++++++++++++++++++++\n"
    printf "|被访问次数|被访问URL|\n"
    printf "+++++++++++++++++++++++\n"
    awk -F '\t' '
    NR>1{
        print $5
    }
    ' web_log.tsv | sort | uniq -c | sort -nr | head -100
    # # sort按照数值来排序(倒序)
    exit 0
}


CountState(){
    printf "++++++++++++++++++++++++++++\n"
    printf "|状态码|出现次数|所占百分比|\n"
    printf "++++++++++++++++++++++++++++\n"
    awk -F '\t' 'BEGIN{total=0}
    NR>1{
        state[$6]++;
        total++;
    }
    END{
        for( s in state ){
            printf("%s\t%d\t%.6f\t\n",s,state[s],state[s]/total) 
        }
    }' web_log.tsv 
    exit 0
}

Count4XX(){
    printf "+++++++++++++++++++++++++++++++++++++\n"
    printf "|4XX状态码|出现次数|出现该现象的网址|\n"
    printf "+++++++++++++++++++++++++++++++++++++\n"
    awk -F '\t' '
    NR>1{
        if(match($6,/^4[0-9]{2}$/)){
            urls[$6][$5]++;
        }
    }
    END{ 
        for(k1 in urls){
            for(k2 in urls[k1]){
                print k1, urls[k1][k2], k2;
            }
        }
    }' web_log.tsv | sort -k1,1 -k2,2gr | head -10
    awk -F '\t' '
    NR>1{
        if(match($6,/^4[0-9]{2}$/)){
            urls[$6][$5]++;
        }
    }
    END{ 
        for(k1 in urls){
            for(k2 in urls[k1]){
                print k1, urls[k1][k2], k2;
            }
        }
    }' web_log.tsv | sort -k1,1r -k2,2gr | head -10
    exit 0
}

FindHost(){ 
    printf "+++++++++++++++++++\n"
    printf "|访问次数|来源主机|\n"
    printf "+++++++++++++++++++\n"
    awk -F '\t' -v url="$1" '
    NR>1{
        if(url==$5){
            print $1 
        }
    }
    ' web_log.tsv | sort | uniq -c | sort -nr | head -100
    exit 0
}



# 先检查文件有没有，没有就下载
CheckFile
# 什么都不输入的时候输出使用方法
[[ $# -eq 0 ]] && describe

while getopts 'tiuscf:h' OPT; do
    case $OPT in
        t)  
            CountHost
            ;;
        i)
            CountIp
            ;;
        u)
            MostFrequent
            ;;
        s)
            CountState
            ;;
        c)
            Count4XX
            ;;
        f)
            FindHost "$2"
            ;;
        h | *) 
            describe 
            ;;
    esac
done