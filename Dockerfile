FROM migoller/shinobidocker:debian

VOLUME /opencv

ENV NVIDIA_GPU=false \
	OPENCV=false \
	OPENALPR=false \
	YOLO=false \
	YOLO_TINY=true \
	YOLO_HOST=localhost \
	YOLO_PORT=8080 \
	APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
	PLUGINKEY_YOLO=574e44c1-dbff-3dc0-0f94-9d4a3dc0f194

#ADMIN_USER=admin@shinobi.video \
#ADMIN_PASSWORD=admin \
#CRON_KEY=fd6c7849-904d-47ea-922b-5143358ba0de \
#PLUGINKEY_MOTION=b7502fd9-506c-4dda-9b56-8e699a6bc41c \
#PLUGINKEY_OPENCV=f078bcfe-c39a-4eb5-bd52-9382ca828e8a \
#PLUGINKEY_OPENALPR=dbff574e-9d4a-44c1-b578-3dc0f1944a3c \
##leave these ENVs alone unless you know what you are doing
#MYSQL_USER=majesticflame \
#MYSQL_PASSWORD=password \
#MYSQL_HOST=localhost \
#MYSQL_DATABASE=ccio \
#MYSQL_ROOT_PASSWORD=blubsblawoot \
#MYSQL_ROOT_USER=root

RUN \
 if [ "${OPENCV}" = "true" ] || [ "${OPENCV}" = "TRUE" ] || \
	[ "${OPENALPR}" = "true" ] || [ "${OPENALPR}" = "TRUE" ] || \
	[ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ] || \
	[ "${YOLO}" = "true" ] || [ "${YOLO}" = "TRUE" ]; then \
 	apt-get update && \
 	apt-get install -y \
 		libjpeg-dev libpango1.0-dev libgif-dev build-essential gcc-6 g++-6 \
 		libxvidcore-dev libx264-dev \
 		libatlas-base-dev gfortran \
 		&& \
 	apt install -y \
	 	build-essential cmake pkg-config unzip ffmpeg qtbase5-dev \
	 	python-dev python3-dev python-numpy python3-numpy libhdf5-dev \
	 	libgtk-3-dev libdc1394-22 libdc1394-22-dev libjpeg-dev libtiff5-dev \
	 	libtesseract-dev libavcodec-dev libavformat-dev libswscale-dev \
	 	libxine2-dev libgstreamer-plugins-base1.0-0 \
	 	libgstreamer-plugins-base1.0-dev libpng16-16 libpng-dev libv4l-dev \
	 	libtbb-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
	 	libtheora-dev libvorbis-dev libxvidcore-dev v4l-utils libleptonica-dev ; \
	fi

RUN	\
 if [ "${OPENCV}" = "true" ] || [ "${OPENCV}" = "TRUE" ] || \
	[ "${OPENALPR}" = "true" ] || [ "${OPENALPR}" = "TRUE" ] || \
	[ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ] || \
	[ "${YOLO}" = "true" ] || [ "${YOLO}" = "TRUE" ]; then \
	echo "Downloading OpenCV..." && \
    cd /opencv && \
    git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 3.4.0 && \
    cd .. && \
    if [ ! -e "/opencv/opencv_contrib" ]; then \
        echo "Downloading OpenCV Modules..." && \
        cd /opencv && \
        git clone https://github.com/opencv/opencv_contrib.git && \
        cd opencv_contrib && \
        git checkout 3.4.0 && \
        cd .. ;\
	fi; \
	LD_LIBRARY_PATH=/usr/local/cuda/lib && \
	PATH=$PATH:/usr/local/cuda/bin && \
	cmake -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_NVCUVID=ON -D FORCE_VTK=ON -D WITH_XINE=ON \
		-D WITH_CUDA=ON -D WITH_OPENGL=ON -D WITH_TBB=ON -D WITH_OPENCL=ON -D CMAKE_BUILD_TYPE=RELEASE \
		-D CUDA_NVCC_FLAGS="-D_FORCE_INLINES --expt-relaxed-constexpr" -D WITH_GDAL=ON \
		-D OPENCV_EXTRA_MODULES_PATH=./opencv_contrib/modules/ \
		-D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 -D CXXFLAGS="-std=c++11" \
		-DCMAKE_CXX_COMPILER=g++-6 -DCMAKE_C_COMPILER=gcc-6 ./opencv && \
	make -j "$(nproc)" && \
	make install && \
	echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf && \
	ldconfig && \
	apt-get update && \
	cd / && \
	rm -rf /opencv/* ; \
 fi

#Install Cuda Toolkit
 RUN \
 if [ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ] || \
	[ "${YOLO}" = "true" ] || [ "${YOLO}" = "TRUE" ]; then \
 	echo "------------------------------------------" && \
 	echo "-- Installing CUDA Toolkit and CUDA DNN --" && \
 	echo "------------------------------------------" && \
 	wget https://cdn.shinobi.video/installers/cuda-repo-ubuntu1710_9.2.148-1_amd64.deb -O cuda.deb && \
 	apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1710/x86_64/7fa2af80.pub && \
 	dpkg -i cuda.deb && \
	apt-get install -f && \
 	apt-get update -y && \
 	apt-get -o Dpkg::Options::="--force-overwrite" install cuda -y && \
 	apt-get -o Dpkg::Options::="--force-overwrite" install --fix-broken -y && \
 	wget https://cdn.shinobi.video/installers/libcudnn7_7.2.1.38-1+cuda9.2_amd64.deb -O cuda-dnn.deb && \
 	dpkg -i cuda-dnn.deb && \
 	wget https://cdn.shinobi.video/installers/libcudnn7-dev_7.2.1.38-1+cuda9.2_amd64.deb -O cuda-dnn-dev.deb && \
 	dpkg -i cuda-dnn-dev.deb && \
 	echo "-- Cleaning Up --" && \
 	rm -f *.deb; \
 fi 

WORKDIR /opt/shinobi
COPY pm2Shinobi-yolo.yml ./

## Set up Yolo if Variable is set
WORKDIR /opt/shinobi/plugins/yolo
RUN \
 if [ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ] || \
	[ "${YOLO}" = "true" ] || [ "${YOLO}" = "TRUE" ]; then \
		weightNameExtension="" && \
		cp conf.sample.json conf.json ; \
	if [ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ]; then \
    	weightNameExtension="-tiny"; \
    fi;\
    if [ ! -d "models" ]; then \
		echo "Downloading yolov3 weights..." && \
   		mkdir models && \
    	wget -O models/yolov3.weights https://pjreddie.com/media/files/yolov3$weightNameExtension.weights; \
	else \
    	echo "yolov3 weights found..."; \
	fi; \
	echo "-----------------------------------"; \
	if [ ! -d "models/cfg" ]; then \
    	echo "Downloading yolov3 cfg" && \
    	mkdir models/cfg && \
    	wget -O models/cfg/coco.data https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/coco.data && \
    	wget -O models/cfg/yolov3.cfg https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3$weightNameExtension.cfg;\
	else \
		echo "yolov3 cfg found..."; \
	fi; \
	echo "-----------------------------------"; \
	if [ ! -d "models/data" ]; then \
		echo "Downloading yolov3 data" && \
		mkdir models/data && \
		wget -O models/data/coco.names https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names; \
	else \
		echo "yolov3 data found..."; \
	fi; \
	# Set configuration for plugin ...
	echo "Set configuration for plugin from environment variables ..." && \
	sed -i -e 's/"host":"localhost"/"host":"'"${YOLO_HOST}"'"/g' \
		   -e 's/"port":8080/"port":"'"${YOLO_PORT}"'"/g' \
           -e 's/"key":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"key":"'"${PLUGINKEY_YOLO}"'"/g' \
           "/opt/shinobi/plugins/yolo/conf.json" && \
    sed -i -e 's/"Motion":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"Yolo":"'"${PLUGINKEY_YOLO}"'"/g' \
    		"/opt/shinobi/conf.json" && \
	npm install node-gyp -g --unsafe-perm && \
	npm install --unsafe-perm && \
	npm install node-yolo-shinobi --unsafe-perm && \
	npm install imagickal --unsafe-perm && \
	npm audit fix --force && \
	mv pm2Shinobi.yml pm2Shinobi.yml.bak && \
	mv pm2Shinobi-yolo.yml pm2Shinobi.yml ;\
fi

WORKDIR /opt/shinobi

VOLUME ["/opt/shinobi/videos"]
VOLUME ["/config"]
VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2Shinobi.yml"]
