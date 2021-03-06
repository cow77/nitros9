include ../port.mak

vpath %.asm $(LEVEL1)/modules

AFLAGS		+= --includedir=$(LEVEL1)/modules

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= boot_zm boot_dw_sc6551 boot_dw_mc6821

BOOTTRACK	= rel init0_cms $(BOOTERS)

KERNEL		= krn krnp2
SYSMODS		= ioman init_cms sysgo sysgo_rom
CLOCKS	        = clock clock2_cms #clock2_soft

RBF		= rbf.mn \
		rbdw.dr dwio.sb dwio_sc6551.sb dwio_mc6821.sb \
		ddx0.dd x0.dd x1.dd x2.dd x3.dd


SCF		= scf.mn \
		vrn.dr \
		nil.dd \
		sc6551_cms.dr t0_sc6551_cms.dd t1_sc6551_cms.dd term_sc6551_cms.dt

PIPE		= pipeman.mn \
		piper.dr \
		pipe.dd


ALLOBJS		= $(BOOTTRACK) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(DW)
AUTOGEN		= sc6551_cms.asm term_sc6551_cms.asm t0_sc6551_cms.asm t1_sc6551_cms.asm\
		init_cms.asm boot_dw_sc6551.asm

# Putting $(AUTOGEN) here keeps those files beyond the build.
all:	$(ALLOBJS) $(AUTOGEN)


# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

sysgo_rom: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DROM=1


# Generate terminals based on output file name prefix
%_sc6551_cms.asm: term_sc6551.asm
	$(ECHO) "** Generated by makefile from $<" > $@
	sed -e 's/nam   Term/nam   $*/' -e 's/nam   t/nam   T/' \
		-e 's/\/Term\//\/$*\//' \
		-e 's/.FF68/$*Base/' \
		-e 's/B9600/B19200/' \
		$< >> $@

# Make minor changes to some of the standard modules.
%_cms.asm: %.asm
	$(ECHO) "** Generated by makefile from $<" > $@
	# I think this was supposed to be a preprocessor flag, not a hard equate.
	sed -e 's/^MPIFlag/* MPIFlag/' \
	    -e 's/Unknown Machine/$(MACHINE)/' $< >> $@

# DriveWire on ACIA0 Booter. Changes needed b/c no ACIA Init included
boot_dw_sc6551:	boot_dw.asm
	$(ECHO) "** Generated by makefile from $<" > $@.asm
	sed -e 's/use       dwinit.asm/use       dwinit_cms.asm/' $< >> $@.asm
	$(AS) -l$@.lst $@.asm $(ASOUT)$@ $(AFLAGS) -DSY6551N=1
	

# DriveWire on PIA1 with TTL to RS232 or USB adapter Booter
boot_dw_mc6821:	boot_dw.asm
	$(AS) -l$@.lst $< $(ASOUT)$@ $(AFLAGS) 
	#-DBAUD38400=1 -DDW_DBAUD38400=1


# DriveWire on ACIA0 Submodule
dwio_sc6551.sb:	dwio.asm
	$(AS) -l$@.lst $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1


# DriveWire on PIA1 with TTL to RS232 or USB adapter Submodule
dwio_mc6821.sb:	dwio.asm
	$(AS) -l$@.lst $< $(ASOUT)$@ $(AFLAGS)


# DriveWire 3 RBF descriptors
ddx%.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=$*


x%.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=$*


clean:
	$(RM) $(ALLOBJS) $(AUTOGEN)
	$(CD) kernel; make $@
	$(RM) *lst

showobjs:
	@$(ECHO) $(ALLOBJS)

showkernel:
	@$(ECHO) $(KERNEL)

showsysmods:
	@$(ECHO) $(SYSMODS)

showclocks:
	@$(ECHO) $(CLOCKS)

showrbf:
	@$(ECHO) $(RBF)

showscf:
	@$(ECHO) $(SCF)

showpipe:
	@$(ECHO) $(PIPE)

identify:
	$(IDENT_SHORT) $(ALLOBJS)


