### create GKE cluster with A100 
```
gcloud container node-pools create gpu-pool-2 \
  --cluster cluster-2 \
  --region us-central1 \
  --machine-type a2-highgpu-1g \
  --num-nodes 1 \
  --accelerator type=nvidia-tesla-a100,count=1,gpu-driver-version=default
```

### login to GKE node over ssh
```
gcloud compute ssh NODE_NAME
```
### PCI connection?
```
sudo lspci | grep NVIDIA
00:04.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)

```
### Driver installed?
```
cat /proc/driver/nvidia/version
#NVRM version: NVIDIA UNIX x86_64 Kernel Module  470.223.02  Sat Oct  7 15:39:11 UTC 2023
#GCC version:  Selected multilib: .;@m64
```

### tab complete `nvidia-c*`
```
nvidia-container-runtime       nvidia-container-runtime.cdi   
nvidia-container-runtime-hook  nvidia-ctk
```

### Where is nvidia-smi?
```
sudo find / -type f -name "nvidia-smi" 2>/dev/null
/home/kubernetes/bin/nvidia/bin/nvidia-smi
```

### Runtime?
```
sudo cat /etc/containerd/config.toml | grep "containerd.runtimes.nvidia."
sudo cat /etc/containerd/config.toml  | grep bin
```
OUTPUT:
bin_dir = "/home/kubernetes/bin"

```
ls /home/kubernetes/bin/nvidia/bin/
```
OUTPUT:
```
nvidia-bug-report.sh     nvidia-debugdump  nvidia-ngx-updater   nvidia-sleep.sh   nvidia-xconfig
nvidia-cuda-mps-control  nvidia-installer  nvidia-persistenced  nvidia-smi
nvidia-cuda-mps-server   nvidia-modprobe   nvidia-settings      nvidia-uninstall
```

### check nvidia containers running
```
crictl ps | grep nvidia-gpu
```

## Additional reading
* https://developer.nvidia.com/blog/gpu-containers-runtime/
* https://github.com/NVIDIA/k8s-device-plugin#quick-start
* https://www.jimangel.io/posts/nvidia-rtx-gpu-kubernetes-setup/
* https://cloud.google.com/kubernetes-engine/docs/how-to/gpus
