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
# sed -i '/lan) ipad/s/".*"/"192.168.1.1"/' package/base-files/files/bin/config_generate
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

