#!/bin/bash
set -e

echo "🧹 Cleaning up old/broken repositories..."
# ลบไฟล์ที่เคยสร้างผิดพลาดออกก่อน
sudo rm -f /etc/apt/sources.list.d/grafana.list

# แก้ไขปัญหา CD-ROM (เผื่อยังหลงเหลืออยู่)
sudo sed -i '/cdrom/d' /etc/apt/sources.list

echo "📦 Updating system..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget curl

echo "📊 Adding Official Grafana Repository..."
# สร้างโฟลเดอร์เก็บ Key ถ้ายังไม่มี
sudo mkdir -p /etc/apt/keyrings/

# โหลด GPG Key แบบมาตรฐานใหม่
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# เพิ่ม Repository (ใช้ URL ที่ถูกต้อง: https://packages.grafana.com/oss/deb)
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.>

echo "📥 Installing TIG Stack..."
sudo apt-get update -y
sudo apt-get install -y grafana telegraf

# ติดตั้ง InfluxDB 2.7.6 (ตัวเดิมที่คุณต้องการ)
cd /tmp
if [ ! -f "influxdb2_2.7.6-1_amd64.deb" ]; then
    curl -LO https://download.influxdata.com/influxdb/releases/influxdb2_2.7.6-1_amd64.deb
fi
sudo dpkg -i influxdb2_2.7.6-1_amd64.deb

echo "⚙️ Starting Services..."
sudo systemctl daemon-reload
sudo systemctl enable --now influxdb
sudo systemctl enable --now grafana-server
sudo systemctl enable --now telegraf

echo "🛡️ Opening Firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 8086/tcp
sudo ufw allow 3000/tcp
echo "y" | sudo ufw enable

echo "------------------------------------------"
echo "✅ ทุกอย่างติดตั้งเรียบร้อยแล้ว!"
echo "Grafana: พอร์ต 3000"
echo "InfluxDB: พอร์ต 8086"
echo "------------------------------------------"
