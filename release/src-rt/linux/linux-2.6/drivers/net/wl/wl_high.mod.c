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
"depends=dnsmq,usbcore,emf,igs";

MODULE_ALIAS("usb:v0A5Cp0000d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0A5CpBD12d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0A5CpBD13d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0A5CpBD16d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0A5CpBD17d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0A5Cp0BDCd*dc*dsc*dp*ic*isc*ip*");
