framework_dir = $(abspath ./dsp-framework)
base_dir = $(abspath .)

ROCKETCHIP_DIR=$(framework_dir)/rocket-chip

include $(framework_dir)/Makefrag

FIRRTL_JAR ?= $(ROCKETCHIP_DIR)/firrtl/utils/bin/firrtl.jar
FIRRTL ?= java -Xmx2G -Xss8M -cp $(FIRRTL_JAR) firrtl.Driver

CHISEL_ARGS ?= 
build_dir ?= generated-src
PROJECT ?= craft
MODEL ?= DspTop
CFG_PROJECT ?= pfb
CONFIG ?= DefaultStandaloneRealPFBConfig


$(build_dir)/$(PROJECT).$(MODEL).$(CONFIG).fir: $(call lookup_scala_srcs, $(base_dir)/src) $(all_stamps)
	mkdir -p $(build_dir)
	cd $(base_dir) && $(SBT) "run-main $(PROJECT).DspBlockGenerator $(CHISEL_ARGS) $(build_dir) $(PROJECT) $(MODEL) $(CFG_PROJECT) $(CONFIG)"

$(build_dir)/$(PROJECT).$(MODEL).$(CONFIG).v: $(build_dir)/$(PROJECT).$(MODEL).$(CONFIG).fir
	$(FIRRTL) -i $< -o $@ -X verilog

verilog: $(build_dir)/$(PROJECT).$(MODEL).$(CONFIG).v

test: $(all_stamps)
	$(SBT) test

travis: $(all_stamps)
	$(SBT) travis:test

pages: $(all_stamps)
	$(SBT) ghpagesPushSite
