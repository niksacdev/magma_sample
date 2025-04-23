#!/bin/bash

# Ultra-minimal robot simulation that creates end-effector misalignment images
# This version uses Python with Gazebo service API

# Check for Gazebo CLI (gz)
if ! command -v gz &> /dev/null; then
    echo "Error: 'gz' command not found. Please install Gazebo Garden and ensure 'gz' is in your PATH." >&2
    echo "You can install it using: brew install osrf/simulation/gz-garden" >&2
    exit 1
fi

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    pkill -f "gz sim"
    pkill -f "Xvfb"
    exit 0
}

# Trap Ctrl+C and other signals
trap cleanup SIGINT SIGTERM

# Start virtual X server
echo "Starting virtual X server..."
Xvfb :1 -screen 0 1280x1024x24 &
export DISPLAY=:1.0

# Create a simple world file
cat > /tmp/minimal_robot.sdf << 'EOF'
<?xml version="1.0" ?>
<sdf version="1.6">
  <world name="minimal_robot">
    <physics name="1ms" type="ignored">
      <max_step_size>0.001</max_step_size>
      <real_time_factor>1.0</real_time_factor>
    </physics>
    <model name="ground_plane">
      <static>true</static>
      <link name="link">
        <collision name="collision">
          <geometry>
            <plane>
              <normal>0 0 1</normal>
              <size>100 100</size>
            </plane>
          </geometry>
        </collision>
        <visual name="visual">
          <geometry>
            <plane>
              <normal>0 0 1</normal>
              <size>100 100</size>
            </plane>
          </geometry>
          <material>
            <ambient>0.8 0.8 0.8 1</ambient>
            <diffuse>0.8 0.8 0.8 1</diffuse>
            <specular>0.8 0.8 0.8 1</specular>
          </material>
        </visual>
      </link>
    </model>
    <model name="robot">
      <pose>0 0 0.5 0 0 0</pose>
      <link name="base_link">
        <visual name="visual">
          <geometry>
            <box>
              <size>0.1 0.1 0.1</size>
            </box>
          </geometry>
          <material>
            <ambient>0 0 1 1</ambient>
            <diffuse>0 0 1 1</diffuse>
            <specular>0 0 1 1</specular>
          </material>
        </visual>
      </link>
      <link name="effector_link">
        <pose>0 0 0.1 0 0 0</pose>
        <visual name="visual">
          <geometry>
            <box>
              <size>0.05 0.05 0.05</size>
            </box>
          </geometry>
          <material>
            <ambient>1 0 0 1</ambient>
            <diffuse>1 0 0 1</diffuse>
            <specular>1 0 0 1</specular>
          </material>
        </visual>
      </link>
      <joint name="base_effector_joint" type="prismatic">
        <parent>base_link</parent>
        <child>effector_link</child>
        <axis>
          <xyz>0 0 1</xyz>
          <limit>
            <lower>-0.1</lower>
            <upper>0.1</upper>
          </limit>
        </axis>
      </joint>
    </model>
    <model name="camera">
      <pose>0 0 1 0 0 0</pose>
      <link name="link">
        <visual name="visual">
          <geometry>
            <box>
              <size>0.05 0.05 0.05</size>
            </box>
          </geometry>
        </visual>
        <sensor name="camera" type="camera">
          <camera>
            <horizontal_fov>1.047</horizontal_fov>
            <image>
              <width>800</width>
              <height>600</height>
              <format>R8G8B8</format>
            </image>
            <clip>
              <near>0.1</near>
              <far>100</far>
            </clip>
          </camera>
          <always_on>1</always_on>
          <update_rate>30</update_rate>
          <visualize>true</visualize>
        </sensor>
      </link>
    </model>
  </world>
</sdf>
EOF

# Create directory for images if it doesn't exist
mkdir -p misalignment_images

# Start Gazebo simulation without headless mode
echo "Starting minimal robot simulation..."
unset GZ_HEADLESS
gz sim -r /tmp/minimal_robot.sdf &
sleep 5

# Function to move robot
move_robot() {
    local base=$1
    local effector=$2
    echo "Moving robot to: base=$base, effector=$effector"
    gz topic -t "/world/minimal_robot/model/robot/joint/base_effector_joint/0/cmd_pos" -m gz.msgs.Double -p "data: $effector"
}

# Function to take screenshot using service API
take_screenshot() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    echo "Taking screenshot at $timestamp"
    
    # Use service API to take snapshot
    gz service -s "/world/minimal_robot/model/camera/link/sensor/camera/snapshot" \
        --reqtype "gz.msgs.CmdCameraSnapshot" \
        --reptype "gz.msgs.CameraImageResponse" \
        --timeout 1000 \
        --req "{\"save_enabled\": true, \"save_path\": \"$(pwd)/misalignment_images\", \"save_filename\": \"misalignment_$timestamp\"}"
    
    # Save joint positions for reference
    echo "base=0, effector=0.1" > "misalignment_images/misalignment_$timestamp.txt"
}

# Main loop
for i in {1..5}; do
    move_robot 0 0.1
    sleep 1
    take_screenshot
    sleep 1
    echo "Completed $i misalignment cycles"
done

cleanup