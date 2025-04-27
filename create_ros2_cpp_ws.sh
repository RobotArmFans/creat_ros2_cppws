#!/bin/bash

# ==== 可配置项 ====
WS_NAME=ros2_cpp_ws
PKG_NAME=$1
ROS_DISTRO=humble
DEPENDENCIES="rclcpp std_msgs"

# ==== 获取脚本所在目录 ====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==== 创建工作空间结构 ====
mkdir -p "$SCRIPT_DIR/$WS_NAME/src"
cd "$SCRIPT_DIR/$WS_NAME"

# ==== 创建包 ====
source /opt/ros/$ROS_DISTRO/setup.bash
cd src
ros2 pkg create  ${PKG_NAME} --build-type ament_cmake --dependencies ${DEPENDENCIES}


# ==== 编写示例 main.cpp ====
MAIN_CPP="$SCRIPT_DIR/$WS_NAME/src/$PKG_NAME/src/main.cpp"
mkdir -p "$(dirname $MAIN_CPP)"
cat << EOF > $MAIN_CPP
#include "rclcpp/rclcpp.hpp"

int main(int argc, char **argv)
{
    rclcpp::init(argc, argv);
    auto node = rclcpp::Node::make_shared("test_node");
    RCLCPP_INFO(node->get_logger(), "Hello from ROS2 C++ node!");
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
EOF

# ==== 修改 CMakeLists.txt ====
CMAKE_FILE="$SCRIPT_DIR/$WS_NAME/src/$PKG_NAME/CMakeLists.txt"
sed -i '/find_package.*rclcpp/a find_package(std_msgs REQUIRED)' $CMAKE_FILE
sed -i '/add_executable/i\
add_executable(main src/main.cpp)\
ament_target_dependencies(main rclcpp std_msgs)' $CMAKE_FILE
sed -i '/install(TARGETS/i\
install(TARGETS\
  main\
  DESTINATION lib/\${PROJECT_NAME})' $CMAKE_FILE

# ==== 构建工作空间 ====
cd "$SCRIPT_DIR/$WS_NAME"
colcon build --packages-select $PKG_NAME

# ==== Source 环境 ====
source install/setup.bash

echo "✅ 工作空间 '$WS_NAME' 创建并构建完成，位置：$SCRIPT_DIR/$WS_NAME，包名：$PKG_NAME"



    # 一键创建ros2工作空间的脚本
    # chmod +x create_ros2_cpp_ws.sh
    # ./create_ros2_cpp_ws 包的名字
    # 这个脚本会在当前文件加下创建工作空间