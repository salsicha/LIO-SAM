FROM ubuntu:bionic

# docker build -t lio_sam lio_sam/
# docker run -ti lio_sam

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=melodic \
    DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y gnupg2 git wget vim unzip

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt update && apt install -y ros-melodic-ros-base libopencv-dev libboost-all-dev cmake ros-melodic-navigation ros-melodic-robot-localization ros-melodic-robot-state-publisher ros-melodic-cv-bridge ros-melodic-pcl-conversions ros-melodic-xacro ninja-build python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential libmetis-dev

RUN wget -O ~/gtsam.zip https://github.com/borglab/gtsam/archive/4.0.2.zip
RUN unzip ~/gtsam.zip -d ~/
RUN mkdir ~/gtsam-4.0.2/build
WORKDIR /root/gtsam-4.0.2/build
RUN cmake -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF ..
RUN make install -j8

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN rosdep init
RUN rosdep update --rosdistro $ROS_DISTRO

RUN mkdir -p ~/catkin_ws/src

WORKDIR /root/catkin_ws/src
RUN git clone https://github.com/salsicha/LIO-SAM.git
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && cd ~/catkin_ws/ && catkin_make"

RUN echo "source /root/catkin_ws/devel/setup.bash" >> ~/.bashrc

CMD ["/bin/bash"]
