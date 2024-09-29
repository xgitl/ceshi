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
# sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate
# IPv6 分配长度设置为62可支持4个子网，63可支持两个子网，
sed -i "s/ip6assign='.*'/ip6assign='62'/" package/base-files/files/bin/config_generate
# 修改主机名
sed -i "s/hostname='.*'/hostname='OpenWrt'/" package/base-files/files/bin/config_generate
# 更改时区，官方openwrt要更改
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 修改wan默认为pppoe拨号，官方openwrt有效，lean无效
# sed -i 's/-dhcp/-pppoe/g' package/base-files/files/lib/functions/uci-defaults.sh
# 开启 UPnP，官方openwrt，lean都要开启
sed -i '/enabled/s/0/1/' feeds/packages/net/miniupnpd/files/upnpd.config
# 默认开启Wifi，官方openwrt要开启
# sed -i 's/disabled=1/disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 修改wifi名称
sed -i "/ssid=/c\\\t\t\tset wireless.default_radio0.ssid=x\n\t\t\tset wireless.default_radio1.ssid=x_5G" package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 默认开启KV，lean
sed -i 's/ncryption=.*/ncryption=psk2+ccmp\n\t\t\tset wireless.default_radio${devidx}.ieee80211k=1\n\t\t\tset wireless.default_radio${devidx}.ieee80211v=1\n\t\t\tset wireless.default_radio${devidx}.wnm_sleep_mode=1\n\t\t\tset wireless.default_radio${devidx}.bss_transition=1/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# lean清除登录密码password
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' package/lean/default-settings/files/zzz-default-settings
# 默认关闭 全锥型NAT，luci-app-turboacc设置用
sed -i '/fullcone_nat/s/[0-9]/0/' feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc
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
add firewall rule
set firewall.@rule[-1].name='Download'
set firewall.@rule[-1].src='wan'
set firewall.@rule[-1].dest='lan'
set firewall.@rule[-1].family='ipv6'
set firewall.@rule[-1].dest_port='56681 56682 56683'
set firewall.@rule[-1].proto='tcp udp'
set firewall.@rule[-1].target='ACCEPT'
EOI
exit 0
EOF

# Clash配置
# 绕过服务器地址，绕过中国大陆 IP，WAN 接口名称，UDP 流量转发，绕过中国大陆 IPv6，自动更新大陆白名单
sed -i "/config openclash/a\\\toption skip_proxy_address '1'\n\toption china_ip_route '1'\n\tlist intranet_allowed_wan_name 'pppoe-wan'\n\toption enable_v6_udp_proxy '1'\n\toption china_ip6_route '1'\n\toption chnr_auto_update '1'" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# 使用 Redir-Host 模式
sed -i "/en_mode/s/'.*'/'redir-host'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
sed -i "/operation_mode/s/'.*'/'redir-host'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# 仅允许常用端口流量
sed -i "/common_ports/s/'.*'/'21 22 23 53 80 123 143 194 443 465 587 853 993 995 998 2052 2053 2082 2083 2086 2095 2096 5222 5228 5229 5230 8080 8443 8880 8888 8889'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# IPv6 流量代理
sed -i "/ipv6_enable/s/'.*'/'1'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# 允许 IPv6 类型 DNS 解析
sed -i "/ipv6_dns/s/'.*'/'1'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# 自定义上游 DNS 服务器
sed -i "/enable_custom_dns/s/'.*'/'1'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# Nameserver-Policy
sed -i "/custom_name_policy/s/'.*'/'1'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash
# 自定义规则
sed -i "/enable_custom_clash_rules/s/'.*'/'1'/" feeds/OpenClash/luci-app-openclash/root/etc/config/openclash

cat << EOF > feeds/OpenClash/luci-app-openclash/root/etc/uci-defaults/98-custom
uci -q batch << EOI
set openclash.config.enable='0'
set openclash.@dns_servers[6].enabled='1'
set openclash.@dns_servers[7].enabled='0'
set openclash.@dns_servers[8].enabled='0'
EOI
exit 0
EOF

echo -n "
config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name 'Proxy'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '1200'
	option tolerance '20'
	option old_name_cfg 'Proxy'
	option old_name 'Proxy'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name 'YouTube'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '1200'
	option tolerance '20'
	option policy_filter '^(?!.*(新加坡|SG|🇸🇬|Sing|马来西亚|MY|🇲🇾|Malaysia|澳大利亚|AU|🇦🇺|香港|HK|🇭🇰|Hong|澳门|MO|🇲🇴|Macao|日本|JP|🇯🇵|Japan|印度尼西亚|印尼|ID|🇮🇩|Indonesia|新西兰|NZ|🇳🇿|Zealand|越南|VN|🇻🇳|Viet)).*'
	option old_name_cfg 'YouTube'
	option old_name 'YouTube'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'zl'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/zl.yaml'
	option interval '864000'
	option position '1'
	option group 'DIRECT'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'Download'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/PrivateTracker/PrivateTracker_No_Resolve.yaml'
	option interval '86400'
	option position '1'
	option group 'DIRECT'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'dl'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/dl.yaml'
	option interval '864000'
	option position '1'
	option group 'Proxy'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'YouTube'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/YouTube/YouTube_No_Resolve.yaml'
	option interval '86400'
	option position '1'
	option group 'YouTube'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'gfw'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Global/Global_Classical_No_Resolve.yaml'
	option interval '86400'
	option position '1'
	option group 'Proxy'
" >> feeds/OpenClash/luci-app-openclash/root/etc/config/openclash

echo "
'＋.accounts.google.com': [114.114.114.114, 119.29.29.29, 223.5.5.5]
'rule-set:dl,YouTube,gfw': [1.1.1.1, 8.8.8.8, 208.67.222.222]" >> feeds/OpenClash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_domain_dns_policy.list

echo "- MATCH,DIRECT" >> feeds/OpenClash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_rules_2.list

rm -rf feeds/OpenClash/luci-app-openclash/root/usr/share/openclash/ui/*
curl -sL https://codeload.github.com/MetaCubeX/Razord-meta/zip/refs/heads/gh-pages -o /tmp/meta.zip && unzip /tmp/meta.zip -d feeds/OpenClash/luci-app-openclash/root/usr/share/openclash/ui
mv feeds/OpenClash/luci-app-openclash/root/usr/share/openclash/ui/Razord-meta-gh-pages feeds/OpenClash/luci-app-openclash/root/usr/share/openclash/ui/dashboard && rm -rf /tmp/meta.zip
rm -rf feeds/OpenClash/luci-app-openclash/root/etc/openclash/game_rules/*
rm -rf feeds/OpenClash/luci-app-openclash/root/etc/openclash/rule_provider/*
echo -n > feeds/OpenClash/luci-app-openclash/root/etc/openclash/accelerated-domains.china.conf
echo -n > feeds/OpenClash/luci-app-openclash/root/etc/openclash/Country.mmdb
echo -n > feeds/OpenClash/luci-app-openclash/root/etc/openclash/china_ip_route.ipset
echo -n > feeds/OpenClash/luci-app-openclash/root/etc/openclash/china_ip6_route.ipset
echo -n > feeds/OpenClash/luci-app-openclash/root/etc/openclash/GeoSite.dat

cat << EOF > feeds/OpenClash/luci-app-openclash/root/etc/openclash/rule_provider/gfw.yaml
payload:
- DOMAIN-SUFFIX,github.com
- DOMAIN-SUFFIX,githubusercontent.com
EOF

mkdir -p feeds/OpenClash/luci-app-openclash/root/etc/openclash/config && touch feeds/OpenClash/luci-app-openclash/root/etc/openclash/config/config.yaml
mkdir -p feeds/OpenClash/luci-app-openclash/root/etc/openclash/core
curl -sL https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-mipsle-softfloat.tar.gz | tar xOvz > feeds/OpenClash/luci-app-openclash/root/etc/openclash/core/clash_meta
chmod +x feeds/OpenClash/luci-app-openclash/root/etc/openclash/core/clash*
