#!/bin/bash

i=1
pic_w=-1
pic_h=-1
folder_name=${PWD##*/}

echo -e "\033[36m=======================================================================\033[0m"
echo -e "\033[36m=                           自动剪裁脚本 V1.0                         =\033[0m"
echo -e "\033[36m=======================================================================\033[0m"
echo -e "\033[36m=                                                                     =\033[0m"
echo -e "\033[36m=  1.按照图片中心剪裁  (坐标）                                        =\033[0m"
echo -e "\033[36m=  2.自定义剪裁位置    (坐标）                                        =\033[0m"
echo -e "\033[36m=  3.自定义剪裁位置   （块数）                                        =\033[0m"
echo -e "\033[36m=  4.从配置文件中读取                                                 =\033[0m"
echo -e "\033[36m=                                                                     =\033[0m"
echo -e "\033[36m=======================================================================\033[0m"
echo ""
path=$1
if [ $path ];then
    cd $path
fi
read -p "请输入选择的功能，按回车键确认  :  " choose

if [ $choose == 2 ];then
    read -p "请输入裁剪过后的图片宽度坐标  :  " crop_w
    read -p "请输入裁剪过后的图片高度坐标  :  " crop_h
    read -p "请输入裁剪区域左边的起点坐标  :  " crop_x
    read -p "请输入裁剪区域顶边的起点坐标  :  " crop_y
elif [ $choose == 3 ];then
    read -p "请输入裁剪过后的图片宽度块数  :  " crop_w
    read -p "请输入裁剪过后的图片高度块数  :  " crop_h
    read -p "请输入裁剪区域左边的起点块数  :  " crop_x
    read -p "请输入裁剪区域顶边的起点块数  :  " crop_y
    crop_w=$(echo "288 * $crop_w" | bc)
    crop_w=${crop_w%%.*}
    crop_h=$(echo "288 * $crop_h" | bc)
    crop_h=${crop_h%%.*} 
    crop_x=$(echo "288 * $crop_x" | bc)
    crop_x=${crop_x%%.*}
    crop_y=$(echo "288 * $crop_y" | bc)
    crop_y=${crop_y%%.*}
elif [ $choose == 4 ];then
    config=`cat ./$folder_name.conf`
    crop_w=${config%x*}
    config=${config#*x}
    crop_h=${config%%+*}
    config=${config#*+}
    crop_x=${config%+*}
    crop_y=${config#*+}
fi

echo $crop_w  $crop_h  $crop_x  $crop_y

if [ ! -d ./$folder_name ];then
    mkdir $folder_name
else
    echo -e "\033[31mYou will clean all files in ./$folder_name ?   (Y/N) \033[0m"
    read -p "input : " check
    if [ $check == "Y" ];then
        rm -rf ./$folder_name/*
    else
        exit
    fi
fi

for file in `ls |grep -E ".JPG|.JPEG|.jpg|.jpeg|.PNG|.png"`
do
    if [ $choose == 1 ];then
        if [ $pic_w == -1 ];then
            pic_info=`identify $file`
            pic_info=${pic_info#* }
            pic_info=${pic_info#* }
            pic_info=${pic_info%% *}
            pic_w=${pic_info%x*}
            pic_h=${pic_info#*x}
        fi
        let crop_x=($pic_w-$crop_w)/2
        let crop_y=($pic_h-$crop_h)/2
    fi
    echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b""正在裁剪第"$i"张"
    convert $file -crop $crop_w"x"$crop_h"+"$crop_x"+"$crop_y ./$folder_name/crop$file
    let i=$i+1
done

echo ""
file_number=`ls $folder_name |wc -l`
if [ $file_number != 0 ];then
    zip -r $folder_name.zip ./$folder_name
    echo $crop_w"x"$crop_h"+"$crop_x"+"$crop_y > ./$folder_name.conf
fi
