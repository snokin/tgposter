#!/bin/bash

Bot_Token=<Your_Token>
Chat_id=<Chat_id>
media_dir="/path/to/directory"
cache="/path/to/cache"

# 广告内容，将显示在每个视频的下面描述中
ad="👉@lightrekt"

# 获取各种参数以及视频描述
function detect(){
	width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$media")
	height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$media")
	resolution=$(ffmpeg -i "$media" 2>&1 | grep Video: | grep -Po '\d{3,5}x\d{3,5}')
	filename=$(basename "$media" .mp4)
}

function send_video(){
	# 生成缩略图，上传完毕后需要删除掉这个缩略图文件
	video_thumb="$media.png"
	echo "视频尺寸：$resolution"

	# 缩略图竖向和横向视频最长边设置为 400 像素
	if [ $height != null ]; then
		if [ $height -ge $width ]; then
			ffmpeg -i "$media" -ss 00:00:01.000 -vframes 1 -filter:v scale="-1:400" "$video_thumb" -y > /dev/null 2>&1
		elif [ $width -gt $height ]; then
			ffmpeg -i "$media" -ss 00:00:01.000 -vframes 1 -filter:v scale="400:-1" "$video_thumb" -y > /dev/null 2>&1
		fi
	fi

	vwidth=$(identify -format '%w' "$video_thumb")
	vheight=$(identify -format '%h' "$video_thumb")

	# 发送视频
	curl -F thumb=@"$video_thumb" -F video=@"$media" -F caption="$caption" -F width="$vwidth" -F height="$vheight" https://api.telegram.org/bot$Bot_Token/sendVideo?chat_id=$Chat_id > /dev/null 2>&1
	
	echo "视频$filename已发送"
	rm -rf -- "$video_thumb"
}

OLDIFS=$IFS
IFS=$(echo -en "\n\b")

# 判断 $cache 目录是否存在
if [ ! -d "$cache" ]; then
	mkdir $cache
fi

cc=0
while [ $cc -lt 1 ] || [ $c -gt 100 ]
do
	c=0
	# 从 $media_dir 随机选取一个文件
	media=$(find "$media_dir" -type f -name '*.mp4' | shuf -n 1) 
	# 判断 .sent 文件是否存在，不存在就新建一个
	if [ ! -f "$cache/.sent" ]; then
		touch -- "$cache/.sent"
	fi
	# 判断如果文件尺寸太小就跳过
	detect
	if [ $height -lt 300 ] || [ $width -lt 400 ]; then
		c=$(( c + 1))
		echo "视频太小（$resolution），跳过"
	fi
	# 遍历 .sent 文件判断内容是否以前发过
	mapfile -t list < "$cache/.sent"
	for i in "${list[@]}"
	do
		if [[ "$media" == "$i" ]]; then
			c=$(( c + 1))
		fi
	done

	if [ $c -eq 0 ]; then
		# 判断视频方向
		if [ $width -lt $height ]; then
			caption="#$resolution #竖向 $ad $filename"
		elif [ $width -eq $height ]; then
			caption="#$resolution #正方形 $ad $filename"
		else
			caption="#$resolution #横向 $ad $filename"
		fi
		send_video
		echo "$media" >> "$cache/.sent"
		cc=$(( cc + 1))
	fi

done

IFS=$OLDIFS