# Yolo Plugin Docker Image for Shinobi CCTV

Modified configs from Migoller - https://gitlab.com/MiGoller/ShinobiDocker

| Environment Var | Value (**default**) |
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
          "host" : "<localhost or ip of the docker host>",
          "port" : port_defined_in_YOLO_PORT,
          "key" : "Yolo123123 <or key defined in PLUGINKEY_YOLO>",
          "mode" : "host",
          "type" : "detector"
      }
  ],
```
