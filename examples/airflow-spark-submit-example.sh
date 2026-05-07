#!/usr/bin/env bash

# ตัวอย่างนี้ใช้เมื่อ Airflow Worker อยู่ใน Kubernetes และ mount PVC เดียวกับ Spark History ได้

spark-submit \
  --master spark://spark-master.spark.svc.cluster.local:7077 \
  --deploy-mode client \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=file:/opt/spark/spark-events \
  /opt/airflow/dags/jobs/example_job.py
