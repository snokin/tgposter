# Telegram 频道自动视频发布机器人
## 准备工作
- 准备一个有网络的 VPS 或者 Linux 系统
- 准备一个满是视频文件的目录
- 从 Telegram 的 @botfather 出申请一个机器人
- 准备一个频道（或群组）并获取 Chat_id  
*频道只需要频道id（例如：@channel）*

## 然后
将机器人的 Token 和频道（群组）的 Chat_id 填入脚本内替换 `<Your_Token>` 和 `<Chat_id>` 内，并将满是视频文件的目录地址填写到 `media_dir=` 后面，以及随便指定一个缓存目录填写到 `cache=` 后面。（脚本会自动在缓存目录内写入一个 .sent 文件以记录每一个发送过的文件，以便于避免重复发送相同文件）  
## 再然后
给脚本执行权限，并加入到 crontab 任务内。
`crontab -e`
