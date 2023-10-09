# Introduction

This is a simple Dockerfile I've created to consolidate various tools for Kubernetes and OpenShift audits and pentests.

## Key Tools Included

- [Kubeaudit](https://github.com/Shopify/kubeaudit/)
- [Kubescape](https://github.com/kubescape/kubescape)
- [Popeye](https://github.com/derailed/popeye)
- [Trivy](https://github.com/aquasecurity/trivy/)
- [Peirates](https://github.com/inguardians/peirates)

Other common tools such as nuclei, nmap, nikto, or tcpdump are also included.

## Usage:
### From docker hub:

```bash
# Pull
docker pull jcarabantes/intense-security-audit-utils:1.1.3
# Mount your K8s config file and interact
docker run -v $(pwd)/config:/home/pentester/.kube/config --rm -it jcarabantes/intense-security-audit-utils:1.1.3 bash
```

### From this repo

```bash
docker build -t intense-security/k8s-audit-utils:latest .
docker run -v $(pwd)/config:/home/pentester/.kube/config --rm -it intense-security/k8s-audit-utils:latest bash
```

## References

- [OWASP Kubernetes Top 10 Overview](https://cloudnativenow.com/features/owasp-kubernetes-top-10-overview/)
- [Kubernetes Security - HackTricks](https://cloud.hacktricks.xyz/pentesting-cloud/kubernetes-security)

