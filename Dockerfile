#FROM migoller/shinobidocker:debian
FROM node:8

ARG ARG_APP_VERSION 

# The channel or branch triggering the build.
ARG ARG_APP_CHANNEL

# The commit sha triggering the build.
ARG ARG_APP_COMMIT

# Update Shinobi on every container start?
#   manual:     Update Shinobi manually. New Docker images will always retrieve the latest version.
#   auto:       Update Shinobi on every container start.
ARG ARG_APP_UPDATE=manual

# Build data
ARG ARG_BUILD_DATE

ARG GIT_BRANCH="master"

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=${ARG_BUILD_DATE} \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="GPLv3" \
    org.label-schema.name="MiGoller" \
    org.label-schema.vendor="MiGoller" \
    org.label-schema.version=${ARG_APP_VERSION} \
    org.label-schema.description="Shinobi Pro - The Next Generation in Open-Source Video Management Software" \
    org.label-schema.url="https://gitlab.com/users/MiGoller/projects" \
    org.label-schema.vcs-ref=${ARG_APP_COMMIT} \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://gitlab.com/MiGoller/ShinobiDocker.git" \
    maintainer="MiGoller" \
    Author="MiGoller, mrproper, pschmitt & moeiscool"

# Persist app-related build arguments
ENV APP_VERSION=$ARG_APP_VERSION \
    APP_CHANNEL=$ARG_APP_CHANNEL \
    APP_COMMIT=$ARG_APP_COMMIT \
    APP_UPDATE=$ARG_APP_UPDATE \
    GIT_BRANCH=$GIT_BRANCH

VOLUME ["/opencv"]

# Set environment variables to default values
ENV	PLUGINKEY_YOLO=Yolo123123 \
	YOLO_TINY=true \
	YOLO_HOST=localhost \
	YOLO_PORT="8080" \
	YOLO_MODE="client" \
	#leave these ENVs alone unless you know what you are doing
	APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
	# CURRENTLY NOT SUPPORTED
	# ENABLE ONLY FOR ATTEMPTING TO HELP PROVIDE A SOLUTION
	NVIDIA_GPU=false

RUN \
	mkdir -p \
        /config \
        /opt/shinobi 

WORKDIR /opt/shinobi

#RUN echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
#RUN export DEBIAN_FRONTEND="noninteractive"

# Install package dependencies
RUN \
	apt-get update && \
	apt-get install -y \
	        libfreetype6-dev \
	        libgnutls28-dev \
	        libmp3lame-dev \
	        libass-dev \
	        libogg-dev \
	        libtheora-dev \
	        libvorbis-dev \
	        libvpx-dev \
	        libwebp-dev \
	        libssh2-1-dev \
	        libopus-dev \
	        librtmp-dev \
	        libx264-dev \
	        libx265-dev \
	        yasm && \
	apt-get install -y \
		build-essential \
		bzip2 \
		coreutils \
		gnutls-bin \
		nasm \
		tar \
		x264

# Install additional packages

RUN \
	apt-get install -y \
		ffmpeg \
	        git \
	        libsqlite3-dev \
	        make \
	        mariadb-client \
	        openrc \
	        pkg-config \
	        python \
	        socat \
	        sqlite \
	        wget \
	        xz-utils


# Clone the Shinobi CCTV PRO repo and install Shinobi app including NodeJS dependencies
RUN \
	git clone https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi && \
	npm i npm@latest -g && \
	npm install pm2 -g && \
	npm install jsonfile && \
	npm install --unsafe-perm && \
	npm audit fix --force


RUN \
	apt-get install -y \
		libjpeg-dev \
		libpango1.0-dev \
		libgif-dev \
		gcc-6 \
		g++-6 \
		libxvidcore-dev \
		libatlas-base-dev \
		gfortran

RUN \
	apt install -y \
		cmake \
		unzip \
		qtbase5-dev \
		python-dev \
		python3-dev \
		python-numpy \
		python3-numpy \
		libhdf5-dev \
		libgtk-3-dev \
		libdc1394-22 \
		libdc1394-22-dev \
		libtiff5-dev \
		libtesseract-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libxine2-dev \
		libgstreamer-plugins-base1.0-0 \
		libgstreamer-plugins-base1.0-dev \
		libpng16-16 \
		libpng-dev \
		libv4l-dev \
		libtbb-dev \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		v4l-utils \
		nano \
		libleptonica-dev
	

RUN	\
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
	rm -rf /opencv/*

#Install Cuda Toolkit
 RUN \
	echo "------------------------------------------" && \
	echo "-- Installing CUDA Toolkit and CUDA DNN --" && \
	echo "------------------------------------------" && \
	wget https://cdn.shinobi.video/installers/cuda-repo-ubuntu1710_9.2.148-1_amd64.deb -O cuda.deb && \
	wget https://developer.nvidia.com/compute/cuda/9.2/Prod2/local_installers/cuda-repo-ubuntu1710-9-2-local_9.2.148-1_amd64 -O cuda9.2.deb && \
	apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1710/x86_64/7fa2af80.pub && \
	apt-get -o Dpkg::Options::="--force-overwrite" install --fix-broken -y && \
	apt install -y aptitude &&\
	dpkg --configure -a && \
	dpkg -i cuda9.2.deb && \
	dpkg -i cuda.deb && \
	apt-get install -f && \
	apt-get clean && \
	apt-get update -y && \
	aptitude install cuda -y && \
	wget https://cdn.shinobi.video/installers/libcudnn7_7.2.1.38-1+cuda9.2_amd64.deb -O cuda-dnn.deb && \
	dpkg -i cuda-dnn.deb && \
	wget https://cdn.shinobi.video/installers/libcudnn7-dev_7.2.1.38-1+cuda9.2_amd64.deb -O cuda-dnn-dev.deb && \
	dpkg -i cuda-dnn-dev.deb && \
	echo "-- Cleaning Up --" && \
	rm -f *.deb


## Set up Yolo if Variable is set
WORKDIR /opt/shinobi/plugins/yolo
RUN \
	weightNameExtension="" && \
	cp conf.sample.json conf.json ; \
	if [ "${YOLO_TINY}" = "true" ] || [ "${YOLO_TINY}" = "TRUE" ]; then \
		weightNameExtension="-tiny"; \
	fi;\
	if [ ! -d "models" ]; then \
		echo "Downloading yolov3 weights..." && \
		mkdir models && \
		wget -O models/yolov3.weights https://pjreddie.com/media/files/yolov3$weightNameExtension.weights &&\
		touch ".weights${weightNameExtension}"; \
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
##	echo "Set configuration for plugin from environment variables ..." && \
##	sed -i -e 's/"host":"localhost"/"host":"'"${YOLO_HOST}"'"/g' \
##		   -e 's/"port":8080/"port":"'"${YOLO_PORT}"'"/g' \
##           -e 's/"key":"Yolo123123"/"key":"'"${PLUGINKEY_YOLO}"'"/g' \
##           "/opt/shinobi/plugins/yolo/conf.json" && \
##    sed -i -e 's/"Motion":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"Yolo":"'"${PLUGINKEY_YOLO}"'"/g' \
##		"/opt/shinobi/conf.sample.json" && \
	npm install node-gyp -g --unsafe-perm && \
	npm install --unsafe-perm && \
	npm install node-yolo-shinobi --unsafe-perm && \
	npm install imagickal --unsafe-perm && \
	npm audit fix --force

WORKDIR /opt/shinobi
COPY config/* /opt/shinobi/
COPY pm2yolo.yml docker-entrypoint.sh /opt/shinobi/
RUN chmod -f +x ./*.sh

VOLUME ["/config"]

EXPOSE ${YOLO_PORT}

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2yolo.yml"]
