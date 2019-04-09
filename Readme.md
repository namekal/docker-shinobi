# Yolo Plugin Docker Image for Shinobi CCTV

Modified configs from Migoller - https://gitlab.com/MiGoller/ShinobiDocker

| Environment Var | Value (defaults are highlighted) |
| ------ | ------ |
| PLUGINKEY_YOLO | {random_string_of_characters} / **Yolo123123** |
| YOLO_TINY | **true** / false |
| YOLO_MODE | host / **client** |
| YOLO_HOST | {ip} / **localhost** |
| YOLO_PORT | {Port #} / **8080** |
| NVIDIA_GPU | true / **false** |



## Usage instructions:
> `--net=host`/`network_mode: host` is used so there are no network
> routing issues to/from the docker container, and ports are 
> directly exposed from the host


### To use the above default parameters:

```bash
docker run \
  -d \
  --name yolo \
  --net=host \
  -v </custom/configs>:/config \
  -v /dev/shm:/dev/shm \
  namekal/shinobi-docker:yolo-plugin
```

### To use different parameters:

```bash
docker run \
  -d \
  --name yolo \
  --net=host \
  -e PLUGINKEY_YOLO=newkeyabc123 \
  -e YOLO_TINY=false \
  -e YOLO_MODE=host \
  -e YOLO_PORT=8082 \
  -v </custom/configs>:/config \
  -v /dev/shm:/dev/shm \
  namekal/shinobi-docker:yolo-plugin
```

## Shinobi's **main configuration file** `conf.json` instructions:
#### As of [Shinobi dev commit:`9877ac48`](https://gitlab.com/Shinobi-Systems/Shinobi/commit/9877ac480f0388dea40b0e7dea6f1c3bfbd8e01b):
- `“oldPluginConnectionMethod”:true` must be defined in the configuration to allow object detection to work. (This will be temporarily needed until the new method is working)

### If `YOLO_MODE` is set as `client` (This is the default)
Modify the `"pluginKeys" : {}` to add the key to the array.

```json
  "pluginKeys":{
      "Yolo" : "Yolo123123"
   }
```

### If `YOLO_MODE` is set as `host`
Add the `plugins` array if you don't already have it. Add the following *object inside the array*.

```json
  "plugins":[
      {
          "id" : "Yolo",
          "https" : false,
          "host" : "localhost", <Or_ip_of_the_docker_host>
          "port" : 8082, <Must_be_port_defined_in_YOLO_PORT>
          "key" : "Yolo123123", <Or_key_defined_in_PLUGINKEY_YOLO>
          "mode" : "host",
          "type" : "detector"
      }
  ],
```
