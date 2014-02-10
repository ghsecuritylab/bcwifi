#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
 .name = KBUILD_MODNAME,
 .init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
 .exit = cleanup_module,
#endif
 .arch = MODULE_ARCH_INIT,
};

static const char __module_depends[]
__attribute_used__
__attribute__((section(".modinfo"))) =
"depends=gspca_main,usbcore";

MODULE_ALIAS("usb:v0130p0130d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v041Ep4018d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0461p0815d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0733p0110d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0AF9p0010d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0AF9p0011d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v8086p0110d*dc*dsc*dp*ic*isc*ip*");
