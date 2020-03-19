cd ~/rom/kernel/samsung/universal9810/security/selinux/
sed -i 's/selinux_enforcing = enforcing ? 1 : 0;/selinux_enforcing = 0;\/\/ enforcing ? 1 : 0;/' hooks.c
sed -i '183i\new_value = 0;' selinuxfs.c
