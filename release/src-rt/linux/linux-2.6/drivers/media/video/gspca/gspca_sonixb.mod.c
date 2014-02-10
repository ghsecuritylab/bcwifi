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

MODULE_ALIAS("usb:v0C45p6001d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6005d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6007d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6009d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p600Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6011d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6019d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6024d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6025d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6028d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p6029d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p602Cd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p602Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p602Ed*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p608Fd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p60AFd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0C45p60B0d*dc*dsc*dp*ic*isc*ip*");
