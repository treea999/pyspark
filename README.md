# Spark Standalone Cluster on MicroK8s with ArgoCD

Repo นี้ออกแบบสำหรับติดตั้ง Spark Standalone Cluster บน MicroK8s โดยให้ ArgoCD ดึง manifest จาก GitHub ไป deploy

## Topology

```text
namespace: spark

spark-master     1 pod
spark-worker     2 pods
spark-history    1 pod
```

## Folder structure

```text
spark-k8s-argocd-repo/
├── README.md
├── argocd/
│   └── application-dev.yaml
├── base/
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── serviceaccount.yaml
│   ├── configmap.yaml
│   ├── pvc.yaml
│   ├── spark-master.yaml
│   ├── spark-worker.yaml
│   ├── spark-history.yaml
│   ├── services.yaml
│   ├── ingress.yaml
│   └── networkpolicy.yaml
└── overlays/
    └── dev/
        ├── kustomization.yaml
        ├── patch-worker-replicas.yaml
        ├── patch-resources.yaml
        └── patch-ingress-host.yaml
```

## Deploy manual

```bash
kubectl apply -k overlays/dev
```

## Deploy via ArgoCD

แก้ไฟล์นี้ก่อน:

```text
argocd/application-dev.yaml
```

แก้ค่า:

```yaml
repoURL: https://github.com/YOUR_USER/YOUR_REPO.git
path: overlays/dev
```

แล้ว apply:

```bash
kubectl apply -f argocd/application-dev.yaml
```

## Check pods

```bash
kubectl get pod -n spark -o wide
kubectl get svc -n spark
kubectl get ingress -n spark
```

## Spark Master URL

ใช้ URL นี้สำหรับ submit job จาก pod ภายใน Kubernetes:

```bash
spark://spark-master.spark.svc.cluster.local:7077
```

ถ้า submit จากเครื่องนอก Kubernetes ต้อง expose port `7077` เพิ่ม เช่น NodePort หรือ LoadBalancer

## UI

Default host ใน overlay dev:

```text
spark-master.dev.local
spark-history.dev.local
```

แก้ได้ที่:

```text
overlays/dev/patch-ingress-host.yaml
```

## Spark History

Spark History อ่าน event logs จาก:

```bash
file:/opt/spark/spark-events
```

ตัวอย่าง spark-submit:

```bash
spark-submit \
  --master spark://spark-master.spark.svc.cluster.local:7077 \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=file:/opt/spark/spark-events \
  your_job.py
```

## สำคัญมากเรื่อง Spark History

ถ้า Driver อยู่ใน Kubernetes และ mount PVC เดียวกับ History Server ได้ แบบนี้ใช้งานได้ตรง ๆ

แต่ถ้า Driver อยู่บน Airflow VM ภายนอก Kubernetes:

```text
Airflow VM เป็น Driver
Spark Master/Worker อยู่ใน Kubernetes
Spark History อยู่ใน Kubernetes
```

ต้องใช้ shared storage ที่ทั้ง Airflow VM และ Spark History เห็นร่วมกัน เช่น:

- NFS
- MinIO/S3
- Storage ที่ mount ได้ทั้งสองฝั่ง

เพราะ Spark History ไม่ได้ดึง log จาก Worker โดยตรง แต่จะอ่าน event log ที่ Driver เขียนไว้
