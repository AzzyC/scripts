#!/sbin/sh
cp /system/system/build.prop /system/system/build.prop.bak
cp /vendor/build.prop /vendor/build.prop.bak
sed -i '/^ro.product.system.mode.*/s/=.*/=google/g' /system/system/build.prop
sed -i '/^ro.product.system.bra.*/s/=.*/=google/g' /system/system/build.prop
sed -i '/^ro.product.system.man.*/s/=.*/=google/g' /system/system/build.prop
sed -i '/^ro.product.vendor.mode.*/s/=.*/=google/g' /vendor/build.prop
sed -i '/^ro.product.vendor.bra.*/s/=.*/=google/g' /vendor/build.prop
sed -i '/^ro.product.vendor.man.*/s/=.*/=google/g' /vendor/build.prop
