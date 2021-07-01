#!/bin/bash

describe() {
    cat << EOF

    Usage:
        bash $0 [-a] [-p] [-n] [-m] [-h]

    Options:
        a   统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
        p   统计不同场上位置的球员数量、百分比
        n   名字最长的球员与名字最短的球员
        m   年龄最大的球员与年龄最小的球员
        h   脚本帮助
EOF
}

CheckFile(){
    if [[ ! -f "worldcupplayerinfo.tsv" ]];then
        wget https://raw.githubusercontent.com/EddieXu1125/LinuxSysAdmin/master/exp/chap0x04/worldcupplayerinfo.tsv
    fi
}


CountAge(){
    awk -F '\t' 'BEGIN { small=0; middle=0; high=0 }
    NR>1 {
        if ($6<20) {small++;}
        else if ($6<=30) {middle++;}
        else {high++;}
    }
    END {
        total=small+middle+high;
        printf("------------------------------------------\n")
        printf("| 年龄范围\t | 人数\t | 所占比例\t | \n")
        printf("------------------------------------------\n")
        printf("| 小于20岁\t | %d\t | %.6f\t | \n",small,small/total);
        printf("| 20~30之间\t | %d\t | %.6f\t | \n",middle,middle/total);
        printf("| 大于30岁\t | %d\t | %.6f\t | \n",high,high/total);
    }
    ' worldcupplayerinfo.tsv
    exit 0
}


CountPosition(){
    awk -F '\t'  '
    BEGIN { total=0 }
    NR>1 {
        positions[$5]++;total++;
    }
    END{
        printf("------------------------------------------\n")
        printf("| 所处位置\t | 数量\t | 所占比例\t | \n")
        printf("------------------------------------------\n")       
        for (position in positions){
            printf("| %s\t | %d\t | %.6f\t | \n",position,positions[position],positions[position]/total);
        }
    }'  worldcupplayerinfo.tsv
    exit 0
}


FindName(){
    awk -F '\t' 'BEGIN{ max=0; min=100; }
    NR>1 { 
        let=length($9);
        names[$9]=let;
        max=let>max?let:max;
        min=let<min?let:min; 
    }        
    END{
        for(i in names){            
            if(names[i]==max){
                print " 拥有最长名字的运动员:\t "i
            }
            else if(names[i]==min){
                print " 拥有最短名字的运动员:\t "i 
            }
        }
    } ' worldcupplayerinfo.tsv
}


FindAge(){
    awk -F '\t' 'BEGIN{ max=0; min=100; }
    NR>1 {
        ages[$9]=$6;
        max=$6>max?$6:max;
        min=$6<min?$6:min;
    }
    END{
        for(i in ages){
            if(ages[i]==max){
                print "最年长的球员: "ages[i]"\t name: " i "\t";
            }
            else if(ages[i]==min){
                print "最年轻的球员: "ages[i]"\t name: " i "\t";
            }
        }
    }' worldcupplayerinfo.tsv
    exit 0
}

# 先检查文件有没有，没有就下载
CheckFile
# 什么都不输入的时候输出使用方法
[[ $# -eq 0 ]] && describe

while getopts 'apnmh' OPT; do
    case $OPT in
        a)  
            CountAge 
            ;;
        p)
            CountPosition
            ;;
        n)
            FindName
            ;;
        m)
            FindAge
            ;;
        h | *) 
            describe 
            ;;
    esac
done