#!/sbin/sh
cp /system/build.prop /system/build.prop.bak
cp /vendor/build.prop /vendor/build.prop.bak
sed -i '/^ro.product.mode.*/s/=.*/=google/g' /system/build.prop
sed -i '/^ro.product.bra.*/s/=.*/=google/g' /system/build.prop
sed -i '/^ro.product.man.*/s/=.*/=google/g' /system/build.prop
sed -i '/^ro.product.vendor.mode.*/s/=.*/=google/g' /vendor/build.prop
sed -i '/^ro.product.vendor.bra.*/s/=.*/=google/g' /vendor/build.prop
sed -i '/^ro.product.vendor.man.*/s/=.*/=google/g' /vendor/build.prop
