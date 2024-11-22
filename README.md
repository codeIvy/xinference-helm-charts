# Kubernetes helm charts for xinference
# add repo
helm repo add xinference https://xorbitsai.github.io/xinference-helm-charts

# update indexes and query xinference versions
helm repo update
helm search repo xinference/xinference --devel --versions

# install xinference
helm install xinference xinference/xinference -n xinference --version 0.0.1-v<xinference_release_version>

## If you are having troubles with missing libcuda
```
# Create nvidia-runtime.yaml at the root level
cat > nvidia-runtime.yaml <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: nvidia
handler: nvidia
EOF

# Apply it to the cluster
kubectl apply -f nvidia-runtime.yaml
```
## How to find out NVIDIA_DRIVER_VERSION and TORCH_CUDA_ARCH_LIST
```
#find gpu nodes
kubectl get nodes -L node.kubernetes.io/instance-type
#get detailed info about node
kubectl get node NODENAME -o wide
## Create a debug pod on your GPU node
kubectl debug node/NODENAME -it --image=nvidia/cuda:12.0.0-base-ubuntu20.04

# Once inside the pod, run:
chroot /host
nvidia-smi
In this example Driver Version is 535 (take major version)
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.05    Driver Version: 535.104.05    CUDA Version: 12.2    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla T4            Off  | 00000000:00:04.0 Off |                    0 |
...

#TORCH_CUDA_ARCH_LIST can be one from the list, named Compute Capability:
GPU Family        Architecture    Compute Capability
T4               Turing          7.5
A100             Ampere          8.0 #this is the one
P100             Pascal          6.0
V100             Volta           7.0
P4               Pascal          6.1
L4               Ada             8.9
H100             Hopper          9.0
Source: https://en.wikipedia.org/wiki/CUDA "GPUs supported"
```
## Example of helm command using all of the above:
```
helm upgrade --install xinference ./xinference \
  --set nvidia.runtimeClass.create=true \
  --set config.gpu_per_worker=1 \
  --set-string config.xinference_image=xprobe/xinference:latest-cuda \
  --set-string config.extra_envs.NVIDIA_DRIVER_VERSION=535 \
  --set-string config.extra_envs.TORCH_CUDA_ARCH_LIST=8.0
  ```

## Custom Install
By default, the installation is similar to a local single-machine deployment of Xinference, 
meaning there is only one worker, and all other parameters remain at their default settings.

Below are some common custom installation configurations.

1. I need to download models from `ModelScope`.
    ```
    helm install xinference xinference/xinference -n xinference --version 0.0.1-v<xinference_release_version> --set config.model_src="modelscope"
    ```
2. I want to use cpu image of xinference (or use any version of xinference images).
    ```
    helm install xinference xinference/xinference -n xinference --version 0.0.1-v<xinference_release_version> --set config.xinference_image="<xinference_docker_image>"
    ```
3. I want to have 4 Xinference workers, with each worker managing 4 GPUs.
    ```
    helm install xinference xinference/xinference -n xinference --version 0.0.1-v<xinference_release_version> --set config.worker_num=4 --set config.gpu_per_worker="4"
    ```

The above installation is based on the `--set` option of `Helm`. 
For more complex custom installations, such as configuring shared storage between workers, it is recommended to provide your own `values.yaml` file using the `-f` option. 
The default `values.yaml` is located at `charts/xinference/values.yaml`. 
For some examples, please refer to `examples/`.
