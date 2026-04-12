#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# lean新版本batman-adv不支持旧版本内核，替换为旧版本的batman-adv，luci-app-guest-wifi依赖这个
# sed -i '/routing/c\src-git routing https://github.com/coolsnowwolf/routing^160eae1216c166153f1c0d303f41f33ca0032c2c' feeds.conf.default

# 切换为 lua
sed -i '/luci/s/.*src-git/src-git/' feeds.conf.default
sed -i '/luci.git;/s/^/#/' feeds.conf.default

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Add a feed source
# echo 'src-git openclash https://github.com/vernesong/OpenClash' >>feeds.conf.default
# echo 'src-git diskman https://github.com/lisaac/luci-app-diskman' >>feeds.conf.default
# echo 'src-git partexp https://github.com/sirpdboy/luci-app-partexp' >>feeds.conf.default
# 有旧版包可以用新版包添加到第一行
sed -i '1i src-git openclash https://github.com/vernesong/openclash' feeds.conf.default
# sed -i '1i src-git openclash https://github.com/vernesong/openclash;dev' feeds.conf.default
# sed -i '1i src-git openclash https://github.com/vernesong/openclash^fc741a805883d6105c989af9bb6688e0edd7ab32' feeds.conf.default
# sed -i '1i src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default
# sed -i '1i src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' feeds.conf.default
# sed -i '1i src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
# git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy.git package/luci-app-ikoolproxy
# git clone --depth=1 https://github.com/cnsilvan/luci-app-unblockneteasemusic.git package/neteasemusic
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-control-timewol
