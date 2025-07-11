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
sed -i '/lan) ipad/s/".*"/"192.168.0.1"/' package/base-files/files/bin/config_generate
# IPv6 分配长度设置为62可支持4个子网，63可支持两个子网
sed -i "s/ip6assign='.*'/ip6assign='62'/" package/base-files/files/bin/config_generate
# IPv6 分配长度设置为62可支持4个子网，63可支持两个子网，lean默认用luci2配置路径不一样
# sed -i "s/ip6assign='.*'/ip6assign='62'/" package/base-files/luci2/bin/config_generate
# 修改主机名
sed -i "s/hostname='.*'/hostname='OpenWrt'/" package/base-files/files/bin/config_generate
# 修改主机名，lean默认用luci2配置路径不一样
# sed -i "s/hostname='.*'/hostname='OpenWrt'/" package/base-files/luci2/bin/config_generate
# 更改时区，官方openwrt要更改
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 修改wan默认为pppoe拨号，官方openwrt有效，lean无效，已在uci中设置
# sed -i 's/-dhcp/-pppoe/g' package/base-files/files/lib/functions/uci-defaults.sh
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
sed -i "s/ssid=.*/ssid=x\n\t\t\tset wireless.default_radio1.ssid=x_5G/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 修改wifi名称，官方openwrt-24.10和新的版本要开启
# sed -i "s/ssid='.*'/ssid='x'\nset wireless.default_radio1.ssid='x_5G'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 默认开启KV，lean要开启,
sed -i 's/ncryption=.*/ncryption=psk2+ccmp\n\t\t\tset wireless.default_radio${devidx}.key=12345678\n\t\t\tset wireless.default_radio${devidx}.ieee80211k=1\n\t\t\tset wireless.default_radio${devidx}.ieee80211v=1\n\t\t\tset wireless.default_radio${devidx}.wnm_sleep_mode=1\n\t\t\tset wireless.default_radio${devidx}.bss_transition=1/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
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
# set network.wan6.proto='static'
# set network.wan6.ipaddr='192.168.2.11/24'
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
# 绕过服务器地址，绕过中国大陆 IP，WAN 接口名称，UDP 流量转发，绕过中国大陆 IPv6，自动更新大陆白名单，启用统一延迟
sed -i "/config openclash/a\\\toption skip_proxy_address '1'\n\toption china_ip_route '1'\n\tlist intranet_allowed_wan_name 'pppoe-wan'\n\toption enable_v6_udp_proxy '1'\n\toption china_ip6_route '1'\n\toption chnr_auto_update '1'\n\toption enable_unified_delay '1'" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 使用 Redir-Host 模式
sed -i "/en_mode/s/'.*'/'redir-host'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
sed -i "/operation_mode/s/'.*'/'redir-host'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 仅允许常用端口流量
sed -i "/common_ports/s/'.*'/'21 22 23 53 80 123 143 194 443 465 587 853 993 995 998 2052 2053 2082 2083 2086 2095 2096 5222 5228 5229 5230 8080 8443 8880 8888 8889'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# IPv6 流量代理
sed -i "/ipv6_enable/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 允许 IPv6 类型 DNS 解析
sed -i "/ipv6_dns/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 自定义上游 DNS 服务器
sed -i "/enable_custom_dns/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
# 与 DNS 服务器的连接遵循配置文件中的规则
sed -i "/respect_rules/s/'.*'/'1'/" feeds/openclash/luci-app-openclash/root/etc/config/openclash
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
EOI
exit 0
EOF

echo -n "
config groups
	option enabled '1'
	option config 'all'
	option type 'select'
	option name 'Proxy'
	option disable_udp 'false'
	option old_name_cfg 'Proxy'
	option old_name 'Proxy'
	list other_group '自动'
	list other_group '美国'
	list other_group '新加坡'
	list other_group '台湾'
	list other_group '香港'
	list other_group '冲冲冲'

config groups
	option enabled '1'
	option config 'all'
	option type 'select'
	option name 'YouTube'
	option disable_udp 'false'
	option old_name_cfg 'YouTube'
	option old_name 'YouTube'
	list other_group '自动'
	list other_group '美国'
	list other_group '新加坡'
	list other_group '台湾'
	list other_group '香港'
	list other_group '冲冲冲'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '自动'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option old_name_cfg '自动'
	option old_name '自动'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '美国'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option policy_filter '(?i)(美国|U.?S|🇺🇸|America|States)'
	option old_name_cfg '美国'
	option old_name '美国'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '新加坡'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option policy_filter '(?i)(新加坡|SG|🇸🇬|Sing)'
	option old_name_cfg '新加坡'
	option old_name '新加坡'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '台湾'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option policy_filter '(?i)(台|TW|🇹🇼|Tai)'
	option old_name_cfg '台湾'
	option old_name '台湾'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '香港'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option policy_filter '(?i)(港|HK|🇭🇰|Hong)'
	option old_name_cfg '香港'
	option old_name '香港'

config groups
	option enabled '1'
	option config 'all'
	option type 'url-test'
	option name '冲冲冲'
	option disable_udp 'false'
	option test_url 'http://www.gstatic.com/generate_204'
	option test_interval '5000'
	option tolerance '30'
	option policy_filter '(?i)^(?!.*(坡|SG|🇸🇬|Sing|马来西亚|MY|🇲🇾|Malaysia|澳|AU|🇦🇺|MO|🇲🇴|Macao|港|HK|🇭🇰|Hong|日本|JP|🇯🇵|Japan|印度尼西亚|印尼|ID|🇮🇩|Indonesia|新西兰|NZ|🇳🇿|Zealand|越|VN|🇻🇳|Viet)).*'
	option old_name_cfg '冲冲冲'
	option old_name '冲冲冲'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'Download'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/PrivateTracker/PrivateTracker_No_Resolve.yaml'
	option interval '300000'
	option position '1'
	option group 'DIRECT'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'zl'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/zl.yaml'
	option interval '3000000'
	option position '1'
	option group 'DIRECT'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'us'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/us.yaml'
	option interval '3000000'
	option position '1'
	option group '美国'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'sg'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/sg.yaml'
	option interval '3000000'
	option position '1'
	option group '新加坡'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'tw'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/tw.yaml'
	option interval '3000000'
	option position '1'
	option group '台湾'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'hk'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/hk.yaml'
	option interval '3000000'
	option position '1'
	option group '香港'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'YouTube'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/YouTube/YouTube_No_Resolve.yaml'
	option interval '300000'
	option position '1'
	option group 'YouTube'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'dl2'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/dl2.yaml'
	option interval '3000000'
	option position '1'
	option group 'Proxy'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'dl'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/xgitl/gz/main/dl.yaml'
	option interval '3000000'
	option position '1'
	option group 'Proxy'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'gfw'
	option type 'http'
	option behavior 'domain'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Clash/Global/Global_Domain.yaml'
	option interval '300000'
	option position '1'
	option group 'Proxy'

config rule_providers
	option enabled '1'
	option config 'all'
	option name 'ip'
	option type 'http'
	option behavior 'classical'
	option format 'yaml'
	option url 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Clash/Global/Global_No_Resolve.yaml'
	option interval '300000'
	option position '1'
	option group 'Proxy'
" >> feeds/openclash/luci-app-openclash/root/etc/config/openclash

echo "
'rule-set:dl2': [114.114.114.114, 119.29.29.29, 223.5.5.5]
'rule-set:us,sg,tw,hk,YouTube,dl,gfw': [https://dns.google/dns-query, https://cloudflare-dns.com/dns-query, https://doh.opendns.com/dns-query]" >> feeds/openclash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_domain_dns_policy.list

echo "- MATCH,DIRECT" >> feeds/openclash/luci-app-openclash/root/etc/openclash/custom/openclash_custom_rules_2.list

rm -rf feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/*
curl -sL https://github.com/Zephyruso/zashboard/releases/latest/download/dist-cdn-fonts.zip -o /tmp/meta.zip && unzip /tmp/meta.zip -d feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui
mv feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/dist feeds/openclash/luci-app-openclash/root/usr/share/openclash/ui/zashboard && rm -rf /tmp/meta.zip
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/game_rules/*
rm -rf feeds/openclash/luci-app-openclash/root/etc/openclash/rule_provider/*
echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/accelerated-domains.china.conf
echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/Country.mmdb
echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/china_ip_route.ipset
echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/china_ip6_route.ipset
echo -n > feeds/openclash/luci-app-openclash/root/etc/openclash/GeoSite.dat

cat << EOF > feeds/openclash/luci-app-openclash/root/etc/openclash/rule_provider/gfw.yaml
payload:
- '+.github.com'
- '+.githubusercontent.com'
EOF

mkdir -p feeds/openclash/luci-app-openclash/root/etc/openclash/config && touch feeds/openclash/luci-app-openclash/root/etc/openclash/config/config.yaml
mkdir -p feeds/openclash/luci-app-openclash/root/etc/openclash/core
curl -sL https://raw.githubusercontent.com/vernesong/openclash/core/master/smart/clash-linux-mipsle-softfloat.tar.gz | tar xOvz > feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash_meta
chmod +x feeds/openclash/luci-app-openclash/root/etc/openclash/core/clash*
