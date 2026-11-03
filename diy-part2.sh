#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 修改固件内核版本
# sed -i '/KERNEL_PATCHVER:=/c\KERNEL_PATCHVER:=5.4' target/linux/x86/Makefile
# 修改固件名显示内核版本
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(LINUX_VERSION)-/g' include/image.mk
# 修改默认IP
# sed -i '/lan) ipad/s/".*"/"192.168.0.1"/' package/base-files/files/bin/config_generate
# 修改默认IP，lean默认用luci2配置路径不一样
sed -i '/lan) ipad/s/".*"/"192.168.0.1"/' package/base-files/luci/bin/config_generate
# IPv6 分配长度设置为62可支持4个子网，63可支持两个子网
# sed -i "s/ip6assign='.*'/ip6assign='62'/" package/base-files/files/bin/config_generate
# IPv6 分配长度设置为62可支持4个子网，63可支持两个子网，lean默认用luci2配置路径不一样
sed -i "s/ip6assign='.*'/ip6assign='62'/" package/base-files/luci/bin/config_generate
# 修改主机名
# sed -i "s/hostname='.*'/hostname='OpenWrt'/" package/base-files/files/bin/config_generate
# 修改主机名，lean默认用luci2配置路径不一样
sed -i "s/hostname='.*'/hostname='OpenWrt'/" package/base-files/luci/bin/config_generate
# 更改时区，官方openwrt要更改
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 开启 UPnP，官方openwrt，lean都要开启
sed -i '/enabled/s/0/1/' feeds/packages/net/miniupnpd/files/upnpd.config
# 默认关闭 全锥型NAT，luci-app-turboacc设置用
sed -i '/fullcone_nat/s/[0-9]/0/' feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc
# lean清除登录密码password
sed -i '/99999/d' package/lean/default-settings/files/zzz-default-settings
# 默认开启Wifi，官方openwrt-23.05和旧的版本要开启
# sed -i 's/disabled=1/disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 默认开启Wifi，官方openwrt-24.10和新的版本要开启
# sed -i "s/disabled='.*'/disabled='0'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改wifi名称，官方openwrt-23.05和旧的版本要开启，lean要开启
# sed -i "s/ssid=.*/ssid=x\n\t\t\tset wireless.default_radio1.ssid=x_5G/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 修改wifi名称，官方openwrt-24.10和新的版本要开启
# sed -i "s/ssid='.*'/ssid='x'\nset wireless.default_radio1.ssid='x_5G'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 默认开启KV，lean要开启,
#  sed -i 's/ncryption=.*/ncryption=psk2+ccmp\n\t\t\tset wireless.default_radio${devidx}.key=12345678\n\t\t\tset wireless.default_radio${devidx}.ieee80211k=1\n\t\t\tset wireless.default_radio${devidx}.ieee80211v=1\n\t\t\tset wireless.default_radio${devidx}.wnm_sleep_mode=1\n\t\t\tset wireless.default_radio${devidx}.bss_transition=1/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 默认开启KV，官方openwrt-23.05和旧的版本要开启
# sed -i 's/ncryption=.*/ncryption=psk2+ccmp\n\t\t\tset wireless.default_${name}.key=12345678\n\t\t\tset wireless.default_${name}.ieee80211k=1\n\t\t\tset wireless.default_${name}.wnm_sleep_mode=1\n\t\t\tset wireless.default_${name}.wnm_sleep_mode_no_keys=1\n\t\t\tset wireless.default_${name}.bss_transition=1/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 默认开启kv，官方openwrt-24.10和新的版本要开启
# sed -i "s/key='.*'/key='12345678'\nset \${si}.ieee80211k='1'\nset \${si}.wnm_sleep_mode='1'\nset \${si}.wnm_sleep_mode_no_keys='1'\nset \${si}.bss_transition='1'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# kv开启的话wifi要设置密码要不然wifi不能启动，官方openwrt-24.10和新的版本要开启
# sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# WatchCat，lean设置，这个周期要比ping周期时间长才行，要不然会报错
# sed -i "/forcedelay/s/'.*'/'0'/" feeds/packages/utils/watchcat/files/watchcat.config
# sed -i "/period/s/'.*'/'4h'/" feeds/packages/utils/watchcat/files/watchcat.config
# sed -i "/pinghosts/s/'.*'/'qq.com'\n\toption pingperiod '2h'/" feeds/packages/utils/watchcat/files/watchcat.config
# WiFi访客插件设置
sed -i 's/Guest-WiFi/访客/' feeds/luci/applications/luci-app-guest-wifi/root/etc/config/guest-wifi
sed -i "/encryption/s/'.*'/'none'/" feeds/luci/applications/luci-app-guest-wifi/root/etc/config/guest-wifi

# 删除插件
# rm -rf feeds/packages/multimedia/UnblockNeteaseMusic

cat << EOF > package/base-files/files/etc/uci-defaults/99-custom
uci -q batch << EOI
set dhcp.lan.start='50'
set dhcp.lan.limit='205'
set network.wan.proto=pppoe
set network.wan.keepalive='2 120'
# delete network.wan6
# set network.wan6.proto='static'
# set network.wan6.ipaddr='192.168.1.11/24'
set firewall.Download='rule'
set firewall.Download.src='wan'
set firewall.Download.dest='lan'
set firewall.Download.name='Download'
set firewall.Download.dest_port='56681 56682 56683'
set firewall.Download.family='ipv6'
set firewall.Download.target='ACCEPT'
EOI
exit 0
EOF

# Clash配置
# 绕过服务器地址，绕过指定区域 IP，UDP 流量转发，绕过指定区域 IPv6，自动更新 GeoIP MMDB 数据库，自动更新 GeoSite 数据库，自动更新大陆白名单，启用 TCP 并发，启用统一延迟
sed -i "/config openclash/a\\\toption skip_proxy_address '1'\n\toption china_ip_route '1'\n\toption enable_v6_udp_proxy '1'\n\toption china_ip6_route '1'\n\toption geo_auto_update '1'\n\toption geo_update_week_time '1'\n\toption geo_update_day_time '5'\n\toption geosite_auto_update '1'\n\toption geosite_update_week_time '1'\n\toption geosite_update_day_time '5'\n\toption chnr_auto_update '1'\n\toption chnr_update_week_time '1'\n\toption chnr_update_day_time '5'\n\toption enable_tcp_concurrent '1'\n\toption enable_unified_delay '1'" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 使用 Redir-Host 模式
sed -i "s/fake-ip/redir-host/g" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 仅允许常用端口流量，Redir-Host 模式才有
sed -i "/common_ports/s/'.*'/'21 22 23 53 80 123 143 194 443 465 587 853 993 995 998 2052 2053 2082 2083 2086 2095 2096 2197 5222 5223 5228 5229 5230 8080 8443 8880 8888 8889'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 中国大陆域名数据源，Fake-IP 模式才有
sed -i "/china_ip_route_domain_source/s/'.*'/'geosite'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 设置默认面板
sed -i "/default_dashboard/s/'.*'/'zashboard'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# IPv6 流量代理
sed -i "/ipv6_enable/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 允许 IPv6 类型 DNS 解析
sed -i "/ipv6_dns/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 自定义GeoIP MMDB 数据库更新地址
sed -i "/geo_custom/s/'.*'/'https:\/\/raw.githubusercontent.com\/Loyalsoldier\/geoip\/release\/Country-asn.mmdb'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 自定义GeoSite 数据库更新地址
sed -i "/geosite_custom/s/'.*'/'https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat\/releases\/latest\/download\/geosite.dat'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 开启 Smart 内核
sed -i "/smart_enable/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 自定义上游 DNS 服务器
sed -i "/enable_custom_dns/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 与 DNS 服务器的连接遵循配置文件中的规则
# sed -i "/respect_rules/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# Fake-IP-Filter，Fake-IP 模式才有
# sed -i "s/fakeip_filter '.*'/fakeip_filter '1'\n\toption custom_fakeip_filter_mode 'whitelist'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# Nameserver-Policy
sed -i "/custom_name_policy/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 自定义规则
sed -i "/enable_custom_clash_rules/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash

cat << EOF > feeds/openclash/luci-app-openclash/root/etc/uci-defaults/97-custom
uci -q batch << EOI
set openclash.config.enable='0'
set openclash.@dns_servers[6].enabled='1'
set openclash.@dns_servers[7].enabled='0'
set openclash.@dns_servers[8].enabled='0'
set openclash.@dns_servers[24].enabled='0'
set openclash.@dns_servers[25].enabled='0'
EOI
exit 0
EOF

echo -n "
[YAML]
dns:
  proxy-server-nameserver:
  - https://1.12.12.12/dns-query
  - https://223.5.5.5/dns-query
rule-providers:
  zl: {type: http, interval: 3000000, path: "./zl.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1butd66v2_DIo1a7jQtulrjQtGzqtQP0e}
  us: {type: http, interval: 3000000, path: "./us.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1Uy5stkch5asKQKRYcXn4l7G_B5_DmlLD}
  sg: {type: http, interval: 3000000, path: "./sg.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1TaAQ-AX1vcKFzJgBwlk3nWUpRyX45Qjo}
  tw: {type: http, interval: 3000000, path: "./tw.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1KkGmwtpONKaE2no6RqiTzCnR39IG-1NH}
  hk: {type: http, interval: 3000000, path: "./hk.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=16amTfllSThooGG0QHdsxYzrvQNo_88kN}
  dll: {type: http, interval: 3000000, path: "./dll.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1LoGqcs5T8E8fpQzpmfp_5SWPOtgAquNM}
  dl: {type: http, interval: 3000000, path: "./dl.yaml", behavior: classical, format: yaml, url: https://drive.google.com/uc?export=download&id=1s4uRnhGYqfbVUOjEuUR0wsOdJ_0M6Tk3}
" >> feeds/openclash/luci-app-openclash/root/etc/openclash/overwrite/rule

echo '
"rule-set:us,sg,tw,hk,dll,dl": [https://1.12.12.12/dns-query, https://223.5.5.5/dns-query]
"geosite:gfw": [https://1.12.12.12/dns-query, https://223.5.5.5/dns-query]' >> feeds/openclash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_domain_dns_policy.list

echo 'rule-set:us,sg,tw,hk,dll,dl
geosite:gfw' > feeds/openclash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_fake_filter.list

echo '
- RULE-SET,zl,DIRECT
- RULE-SET,us,美国
- RULE-SET,sg,新加坡
- RULE-SET,tw,台湾
- RULE-SET,hk,香港
- RULE-SET,dll,大流量
- RULE-SET,dl,Proxy
- GEOSITE,youtube,YouTube
- GEOSITE,gfw,Proxy
- GEOIP,twitter,Proxy,no-resolve
- GEOIP,telegram,Proxy,no-resolve
- MATCH,DIRECT' >> feeds/openclash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_rules_2.list

# find feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/ -mindepth 1 -maxdepth 1 ! -iname "*meta*" -exec rm -rf {} + && find feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/metacubexd/ -mindepth 1 ! -iname "*index*" -exec rm -rf {} +
rm -rf feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/*
curl -sLo /tmp/meta.zip https://github.com/Zephyruso/zashboard/releases/latest/download/dist-no-fonts.zip && unzip /tmp/meta.zip -d feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui
mv feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/dist feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/zashboard && rm -rf /tmp/meta.zip
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/game_rules/*
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/rule_provider/*
curl -sLo feeds/openclash/luci-app-openclash/root/etc/openclash/Country.mmdb https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country-asn.mmdb
# echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/GeoSite.dat

# cat << EOF > feeds/openclash/luci-app-openclash/root/etc/openclash/rule_provider/gfw.yaml
# payload:
# - '+.github.com'
# - '+.githubusercontent.com'
# EOF

mkdir -p feeds/openclash/luci-app-openclash/root/etc/openclash/config && touch feeds/openclash/luci-app-openclash/root/etc/openclash/config/config.yaml
mkdir -p feeds/openclash/luci-app-openclash/root/etc/openclash/core
curl -sL https://raw.githubusercontent.com/vernesong/openclash/core/master/smart/clash-linux-mipsle-softfloat.tar.gz | tar xOvz > feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_meta
chmod +x feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash*
