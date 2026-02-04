#!/bin/bash

# หากมี Error ให้หยุดทำงานทันทีแต่ยังคงรันขั้นตอนถัดไปได้
set -e

echo "------------------------------------------"
echo "🗑️  เริ่มการถอนการติดตั้ง TIG Stack"
echo "------------------------------------------"

# 1. หยุดการทำงานของ Services
echo "🛑 Stopping services..."
sudo systemctl stop grafana-server || true
sudo systemctl stop influxdb || true
sudo systemctl stop telegraf || true

# 2. ลบโปรแกรมออกจากระบบ (Purge คือลบไฟล์คอนฟิกด้วย)
echo "📦 Removing packages..."
sudo apt-get purge -y grafana telegraf influxdb2
sudo apt-get autoremove -y

# 3. ลบไฟล์ข้อมูลและ Log ต่างๆ (Data & Logs)
echo "🧹 Cleaning up data directories..."
sudo rm -rf /var/lib/grafana
sudo rm -rf /var/lib/influxdb
sudo rm -rf /var/lib/telegraf
sudo rm -rf /etc/grafana
sudo rm -rf /etc/influxdb
sudo rm -rf /etc/telegraf
sudo rm -rf /var/log/grafana
sudo rm -rf /var/log/influxdb
sudo rm -rf /var/log/telegraf

# 4. ลบ Repository และ Key ที่เคยเพิ่มไว้
echo "🔗 Removing repositories and keys..."
sudo rm -f /etc/apt/sources.list.d/grafana.list
sudo rm -f /etc/apt/keyrings/grafana.gpg
sudo rm -f /usr/share/keyrings/grafana.key

# 5. ปิดพอร์ตใน Firewall (คืนค่าเดิม)
echo "🛡️  Cleaning up firewall rules..."
sudo ufw delete allow 8086/tcp || true
sudo ufw delete allow 3000/tcp || true

echo "------------------------------------------"
echo "✅ ถอนการติดตั้งเสร็จสิ้น!"
echo "เครื่องของคุณสะอาดพร้อมสำหรับการติดตั้งใหม่แล้วครับ"
echo "------------------------------------------"
