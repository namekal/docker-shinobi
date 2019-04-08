#!/bin/sh
set -e

# Update Shinobi to latest version on container start?
if [ "$APP_UPDATE" = "auto" ]; then
    echo "Checking for Shinobi updates ..."
    git reset --hard
    git pull
    npm install
fi

# Copy existing custom configuration files
echo "Copy custom configuration files ..."
if [ -d /config ]; then
    cp -R -f "/config/"* /opt/shinobi || echo "No custom config files found." 
fi

if [ ! -f /opt/shinobi/plugins/yolo/conf.json ]; then
    echo "Create default config file /opt/shinobi/plugins/yolo/conf.json ..."
    cp /opt/shinobi/plugins/yolo/conf.sample.json /opt/shinobi/plugins/yolo/conf.json
fi

# Set keys for PLUGIN ...
echo "- Set keys for PLUGIN from environment variables ..."
sed -i -e 's/"host":"localhost"/"host":"'"${YOLO_HOST}"'"/g' \
       -e 's/"port":8080/"port":"'"${YOLO_PORT}"'"/g' \
       -e 's/"key":"Yolo123123"/"key":"'"${PLUGINKEY_YOLO}"'"/g' \
       "/opt/shinobi/plugins/yolo/conf.json"

fi


if [ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ]; then \
   weightNameExtension="-tiny"
   else \
   weightNameExtension=""
fi

cd /opt/shinobi/plugins/yolo
if [ ! -d "models" ]; then \
    mkdir models
fi
if [ ! -f "models/cfg/coco.data" ]; then \
    mkdir models/cfg &&\
    wget -O models/cfg/coco.data https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/coco.data 
    else \
        echo "yolov3 coco.data found..."; 
fi

if [ ! -f "models/data/coco.names" ]; then \
    mkdir -p models/data &&\
    wget -O models/data/coco.names https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names; \
	else \
		echo "yolov3 coco.names found..."; \
fi

if [ -f ".weights${weightNameExtension}" ] then \
    if [ -f "models/yolov3.weights" ] || [ -f "models/cfg/yolov3.cfg" ] then \
        echo "yolov3 weights or cfg found..."; \
    fi
    else
    rm -f .weights* &&\
    echo "Downloading new yolov3 weights..." &&\
    wget -O models/yolov3.weights https://pjreddie.com/media/files/yolov3$weightNameExtension.weights &&\
    wget -O models/cfg/yolov3.cfg https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3$weightNameExtension.cfg &&\
    touch .weights${weightNameExtension}
fi

fi


# Change the uid/gid of the node user
if [ -n "${GID}" ]; then
    if [ -n "${UID}" ]; then
        echo " - Set the uid:gid of the node user to ${UID}:${GID}"
        groupmod -g ${GID} node && usermod -u ${UID} -g ${GID} node
    fi
fi

# Execute Command
echo "Starting Yolo Plugin for Shinobi ..."
exec "$@"
