#!/bin/bash

# 定义fun_1_Install安装脚本函数
fun_1_ScriptsStore() {

	#更新脚本函数fun_UpdateScripts
	#更新展示脚本情况fun_ShowScripts（显示已安装、可更新）
	#安装/更新脚本函数fun_InstallScripts



    # 提示用户输入GitHub的URL链接
    input_url="https://raw.githubusercontent.com/GHH10268/Farming_Tool_Box/refs/heads/master/scripts.json"

	
	# 从JSON文件中读取内容
	json_file="urls.json"  # 假设JSON文件名为urls.json
	urls=()
	while IFS= read -r line; do
	    # 解析每行的URL
	    url=$(echo "$line" | grep -oP '(?<=<url.*>).*?(?=</url>)')
	    if [[ -n "$url" ]]; then
	        urls+=("$url")
	    fi
	done < "$json_file"
	
	# 提示用户选择要下载的URL
	read -p "请选择要下载的URL编号（输入0返回主菜单）: " choice
	if [ "$choice" == "0" ]; then
	    return
	elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#urls[@]}" ]; then
	    selected_url=$(echo "${urls[$choice-1]}" | grep -oP '(?<=<url.*>).*?(?=</url>)')
	    project_name=$(echo "$selected_url" | grep -oP '(?<=://).*(?=/)' | sed 's/[^a-zA-Z]//g')
	
	    # 检查Scripts文件夹是否存在
	    scripts_dir="Scripts"
	    if [ ! -d "$scripts_dir" ]; then
	        mkdir -p "$scripts_dir"
	    fi
	
	    # 检查项目文件夹是否存在
	    project_dir="$scripts_dir/$project_name"
	    if [ -d "$project_dir" ]; then
	        read -p "本地已有脚本文件，是否覆盖？(y/n): " confirm
	        if [ "$confirm" == "y" ]; then
	            rm -rf "$project_dir"
	        else
	            echo "下载取消"
	            return
	        fi
	    fi
	
	    # 创建项目文件夹
	    mkdir -p "$project_dir"
	
	    # 下载项目
	    echo "正在下载项目 $project_name 到 $project_dir..."
	    if git clone "$selected_url" "$project_dir"; then
	        echo "项目 $project_name 下载成功"
	    else
	        echo "项目 $project_name 下载失败"
	        echo "可能的原因："
	        echo "1. 链接可能不正确或文件不存在"
	        echo "2. 网络连接问题"
	        echo "请检查链接的合法性和网络连接，适当重试。"
	    fi
	else
	    echo "无效的选项"
	fi
	
	# 提示用户输入选项0返回主菜单
	read -p "输入0返回主菜单: " choice
	if [ "$choice" == "0" ]; then
	    return
	fi

}

# 定义fun_2_RunningTmux函数
fun_2_Console() {
    while true; do
        # 获取正在运行的tmux会话列表
        sessions=$(tmux list-sessions -F "#{session_name}")
        if [ -z "$sessions" ]; then
            echo "没有正在运行的tmux会话"
            read -p "输入0返回主菜单：" choice
            if [ "$choice" == "0" ]; then
                return
            fi
            continue
        fi

        # 显示正在运行的tmux会话
        echo "目前正在运行的项目有："
        i=1
        for session in $sessions; do
            echo "$i. $session"
            ((i++))
        done

        # 提示用户输入选项进入查看或返回主菜单
        echo "返回主菜单请输入 0"
        echo "查看tmux会话请输入 s<编号> 或 <编号>"
        echo "杀死tmux会话请输入 k<编号>"
        read -p "请输入选项：" choice

        # 处理用户输入
        case $choice in
            0)
                return
                ;;
            s1|1)
                session_name=$(echo "$sessions" | sed -n '1p')
                if [ -n "$session_name" ]; then
                    tmux attach-session -t "$session_name"
                else
                    echo "无效的会话编号"
                fi
                ;;
            k1)
                session_name=$(echo "$sessions" | sed -n '1p')
                if [ -n "$session_name" ]; then
                    tmux kill-session -t "$session_name"
                    echo "会话 $session_name 已被杀死"
                else
                    echo "无效的会话编号"
                fi
                ;;
            *)
                echo "无效的选项"
                ;;
        esac
    done
}

# 主菜单函数
main_menu() {
    while true; do
        echo "主菜单"
        echo "1. 【脚本商店】-更新/查看/安装 最新的脚本"
        echo "2. 【监控台】-查看/终止 正在运行的脚本"
	echo "3. 【本地脚本】-查看/启动/配置 本地安装的脚本"
        echo "00. 退出程序"
        read -p "请选择一个选项：" choice

        case $choice in
            1)
                fun_1_ScriptsStore
                ;;
            2)
                fun_2_Console
                ;;
            00)
                echo "退出程序"
                exit 0
                ;;
            0)
                echo "无效的选项，请重新选择"
                ;;
            *)
                echo "无效的选项，请重新选择"
                ;;
        esac
    done
}

# 调用主菜单函数
main_menu
