# General rules for Makefile(s) subsystem.
# In this file we will put everything that need to be
# shared betweek all the Makefile(s).
# This file must be included at the beginning of every Makefile
#
# Copyright (C) 1999-2002 Riccardo Facchetti <riccardo@master.oasi.gpa.it>

#
# package version
PACKAGE = apcupsd
DISTNAME = debian
DISTVER = wheezy/sid
VERSION = 3.14.10

#
# programs needed by compilation
CP = /bin/cp
MV = /bin/mv
ECHO = /bin/echo
RM = /bin/rm
RMF = $(RM) -rf
LN = /bin/ln
SED = /bin/sed
MAKE = make
SHELL = /bin/sh
RANLIB = /usr/bin/ranlib
AR = /usr/bin/ar
INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL}
MKINSTALLDIRS = /home/forgotfun/project/Rainbow/shibby_110/release/src/router/apcupsd/autoconf/mkinstalldirs
CHKCONFIG = /sbin/chkconfig
RST2HTML := 
RST2PDF := 

# Files and directories (paths)
prefix = /usr
exec_prefix = ${prefix}
sysconfdir = /usr/local/apcupsd
cgibin = /www/apcupsd
VPATH = /usr/lib:/usr/local/lib
srcdir = .
abstopdir = /home/forgotfun/project/Rainbow/shibby_110/release/src/router/apcupsd
sbindir = /sbin
piddir = /var/run
mandir=${prefix}/share/man
bindir = /bin
datadir = ${prefix}/share
HALPOLICYDIR = /usr/share/hal/fdi/policy/20thirdparty
DISTDIR = debian
PWRFAILDIR = /usr/local/apcupsd
LOCKDIR = /var/lock

# Compilation macros.
CC = mipsel-uclibc-gcc
CXX = mipsel-linux-g++
OBJC = $(CC) -x objective-c++
NIB = ibtool
LD = mipsel-uclibc-gcc
DEFS =  $(LOCALDEFS)

# Libraries
APCLIBS = $(topdir)/src/lib/libapc.a
APCDRVLIBS = $(topdir)/src/drivers/libdrivers.a 
DRVLIBS = -lpthread 
X_LIBS = 
X_EXTRA_LIBS = 

CPPFLAGS =  -I$(topdir)/include $(EXTRAINCS)
CFLAGS = $(CPPFLAGS) -Os -Wall -DLINUX26 -DCONFIG_BCMWL5 -pipe -DBCMWPA2 -funit-at-a-time -Wno-pointer-sign -mtune=mips32 -mips32   -Wall 
CXXFLAGS = $(CPPFLAGS) -g -O2 -fno-exceptions -fno-rtti -Wall 
OBJCFLAGS = $(CPPFLAGS) $(CFLAGS)
LDFLAGS = -L/opt/brcm/K26/hndtools-mipsel-uclibc-4.2.4/lib -ffunction-sections -fdata-sections
LIBS =  -lsupc++
LIBGD = 
POWERLIBS = 
GAPCMON_CFLAGS =  -DHAVE_FUNC_GETHOSTBYNAME_R_6
GAPCMON_LIBS = 
LIBEXTRAOBJ = 
RST2HTMLOPTS = --field-name-limit=0 --generator --time --no-footnote-backlinks --record-dependencies=$(df).d
RST2PDFOPTS = --no-footnote-backlinks --real-footnotes
NIBFLAGS = 

# Driver and package enable flags
SMARTDRV   := apcsmart
DUMBDRV    := 
USBDRV     := usb
NETDRV     := net
PCNETDRV   := 
SNMPDRV    := 
SNMPLTDRV  := 
TESTDRV    := 
USBTYPE    := linux
CGIDIR     := cgi
USBHIDDIR  := 
GAPCMON    := 
APCAGENT   := 

OBJDIR = .obj
DEPDIR = .deps
df = $(DEPDIR)/$(*F)
DEVNULL := >/dev/null 2>&1
