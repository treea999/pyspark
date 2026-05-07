# Notes

## ทำไมต้องมี Spark History

Spark Master UI จะเห็นเฉพาะ application ที่กำลังรันหรือข้อมูล runtime บางส่วน  
Spark History Server ใช้ดู job ที่รันจบแล้ว โดยอ่านจาก event log

## Driver อยู่ตรงไหน

ถ้าใช้ Airflow submit PySpark แบบ client mode:

```text
Airflow Worker = Spark Driver
Spark Master = ตัวรับ job และจัดสรร worker
Spark Worker = ตัว execute task
Spark History = อ่าน event logs หลัง job รัน
```

## Port ที่ใช้

| Port | ใช้ทำอะไร |
|---|---|
| 7077 | Spark Master RPC |
| 8080 | Spark Master UI |
| 8081 | Spark Worker UI |
| 18080 | Spark History UI |
| 4040 | Spark Driver UI ตอน job กำลังรัน |

## เรื่อง port 4040

Port 4040 เป็น UI ของ Driver เฉพาะตอน job กำลังรัน  
ถ้า Driver อยู่ที่ Airflow Worker, 4040 จะอยู่ที่ Airflow Worker ไม่ได้อยู่ที่ Spark Master

Production นิยมให้ทีม Data ดูผ่าน Spark History มากกว่าเปิด 4040 ทุกเครื่อง
