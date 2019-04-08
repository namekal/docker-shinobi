### Yolo Plugin Docker Image for Shinobi CCTV

| Environment Var | Value (**default**) |
| ------ | ------ |
| PLUGINKEY_YOLO | {random_string_of_characters} / **Yolo123123** |
| YOLO_TINY | true / **false** |
| YOLO_MODE | host / **client** |
| YOLO_HOST | {ip} / **localhost** |
| YOLO_PORT | {Port #} / **8080** |
| NVIDIA_GPU | true / **false** |



#Docker run command:
```
docker run \
  -d \
  --name yolo \
  --net=host \
  -e PLUGINKEY_YOLO=Yolo123123 \
  -e YOLO_TINY=false \
  -e YOLO_MODE=client \
  -e YOLO_HOST=localhost \
  -e YOLO_PORT=8080 \
  -v </custom/configs>:/config \
  namekal/shinobi-docker:yolo-plugin
```
