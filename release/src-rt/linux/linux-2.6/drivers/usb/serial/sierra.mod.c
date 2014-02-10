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
"depends=usbserial,usbcore";

MODULE_ALIAS("usb:v0F3Dp0112d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v03F0p1B1Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v03F0p211Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v03F0p1E1Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0017d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0018d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0218d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0020d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0024d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0220d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0019d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0021d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0112d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0120d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0301d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0023d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p0025d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p0026d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0027d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p0028d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6802d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6804d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6803d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6812d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6813d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6815d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v03F0p1E1Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6820d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6821d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6832d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6833d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p683Ad*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p683Bd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p683Cd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p683Dd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p683Ed*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6850d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6851d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6852d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6853d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6855d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6856d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6859d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p685Ad*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p6880d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p6890d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p6891d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p6892d*dc*dsc*dp*icFFiscFFipFF*");
MODULE_ALIAS("usb:v1199p0FFFd*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v1199p68A3d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v0F3Dp68A3d*dc*dsc*dp*ic*isc*ip*");
MODULE_ALIAS("usb:v413Cp8133d*dc*dsc*dp*ic*isc*ip*");

MODULE_INFO(srcversion, "BF895BFBF38723B27C57730");
