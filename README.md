# Isaac-Dockerizer

Tools for dockerizing package on Isaac Sim  
(including port mapping, X11 forwarding)  

Convention from: [IsaacLab v1.0.0](https://github.com/isaac-sim/IsaacLab/tree/v1.0.0/docker)  

For more details on isaac-sim docker installation,  
refer to: [[link]](https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_container.html)  

**Note) This package only provides dockerizing kit, not python package itself!**  

# Usage: Native (with X11)
## Purpose
**Use on workstation**  
The workstation should have good performance in terms of GPU utilizations.  
See the requiremens: [[link]](https://docs.omniverse.nvidia.com/isaacsim/latest/installation/requirements.html)

## Issue
Prepared X11 forwarding only works when all gpus are given.  
Find your own way if you need to designate some GPUs...  

## Profiles
default profile: `base`  
available profiles: `[base, ros2]`  

## Usage
1. Launch below script on workstation.
```bash
# To use w/o ROS2:
./docker/container.sh start base
./docker/container.sh enter base

# To use with ROS2:
./docker/container.sh start ros2
./docker/container.sh enter ros2
```

2. Launch below script on attached docker session.
```bash
/isaac-sim/runheadless.native.sh
```

3. Stop container when ended
```bash
# To use w/o ROS2:
./docker/container.sh stop base

# To use with ROS2:
./docker/container.sh stop ros2
```

# Usage : Streaming
## Purpose
**Launch simulator on server & streaming on client PC**  
If you want to use Isaac Sim on server, it would require port mappings and streamings to access GUI.  
If you don't need to use GUI attached, just run on headless mode without port mapping.  

## Requirements
- Server: [[link]](https://docs.omniverse.nvidia.com/isaacsim/latest/installation/requirements.html)
- Client: 

## Using docker
### Server-side
1. Modify values on `docker/.env.base`.
2. Launch below script on server.
```bash
# To use w/o ROS2:
./docker/container.sh start base-mapped
./docker/container.sh enter base-mapped

# To use with ROS2:
./docker/container.sh start ros2-mapped
./docker/container.sh enter ros2-mapped
```
3. Launch below script on attached docker session.
```bash
/isaac-sim/runheadless.native.sh
```
4. Stop container when ended
```bash
# To use w/o ROS2:
./docker/container.sh stop base-mapped

# To use with ROS2:
./docker/container.sh stop ros2-mapped
```

### Client-side
1. Download & Execute omniverse launcher: [[link]](https://developer.nvidia.com/omniverse#section-getting-started).
2. On 'Exchange' tab, install `omniverse streaming client`.
3. Modify & execute port-forwarding script.
    - on Windows: `client/port_forward.ps1`
    - on Linux: `client/port_forward.sh`
4. Launch streaming client on localhost.

## Using singularity
Request to [Sungwoong Kim](sukim96@yonsei.ac.kr)!

# Initialize your own package
`pyproject.toml`, `README.md`,`src/`, `tests/`, `scripts/` are bind-mounted so that users can develop their own package based on poetry-convention.  
## Modifications
To initialize your own package, modify following files:  
- `pyproject.toml`
- `docker/.env.base` -> `DOCKER_PACKAGE_PATH` (path to your package on container)
- `README.md`: **Modify this README file to your own package's README!**
- `src/`: locate your package here!
- `tests/`: for test codes
- `scripts/`: for shell scripts

## Installation (on docker)
```bash
${DOCKER_PACKAGE_PATH}/scripts/install_package.sh
```

# Additional volumes mounting  
To use your local data, add volumes on `docker-compose.yaml`.  
You can add your volume on "Manual volumes" section.  

# FAQ
feel free to leave issues on github / taiga / slack / wherever!