#!/bin/bash

# หากมี Error ให้หยุดทำงานทันที
set -e

echo "------------------------------------------"
echo "🚀 เริ่มการติดตั้ง TIG Stack (v2.7.6)"
echo "------------------------------------------"

# 1. แก้ไขปัญหา APT Repository (ลบ CD-ROM และล้างของเก่าที่เสีย)
echo "🧹 Cleaning up APT sources..."
sudo sed -i '/cdrom/d' /etc/apt/sources.list
sudo rm -f /etc/apt/sources.list.d/grafana.list

# 2. Update และติดตั้งเครื่องมือพื้นฐาน
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget curl gnupg2

# 3. ติดตั้ง InfluxDB 2.7.6 (จากไฟล์ .deb)
echo "📥 Installing InfluxDB 2.7.6..."
mkdir -p ~/tig_install
cd ~/tig_install
if [ ! -f "influxdb2_2.7.6-1_amd64.deb" ]; then
    wget https://download.influxdata.com/influxdb/releases/influxdb2_2.7.6-1_amd64.deb
fi
sudo dpkg -i influxdb2_2.7.6-1_amd64.deb

# 4. ติดตั้ง Grafana (ใช้ Repository ล่าสุด)
echo "📊 Installing Grafana..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# 5. ติดตั้ง Telegraf และ Grafana ผ่าน APT
sudo apt-get update -y
sudo apt-get install -y grafana telegraf

# 6. ตั้งค่าให้ Services เริ่มทำงานอัตโนมัติ
echo "⚙️  Enabling and Starting Services..."
sudo systemctl daemon-reload
sudo systemctl enable --now influxdb
sudo systemctl enable --now grafana-server
sudo systemctl enable --now telegraf

# 7. ตั้งค่า Firewall (UFW)
echo "🛡️  Configuring Firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 8086/tcp
sudo ufw allow 3000/tcp
echo "y" | sudo ufw enable

echo "------------------------------------------"
echo "✅ ติดตั้งเสร็จสมบูรณ์!"
echo "🔗 Grafana: http://$(hostname -I | awk '{print $1}'):3000 (User: admin / Pass: admin)"
echo "🔗 InfluxDB: http://$(hostname -I | awk '{print $1}'):8086"
echo "------------------------------------------"

# ตรวจสอบสถานะ InfluxDB
sudo service influxdb status