BUSYBOX_TOOLS_VERSION:=1.15.3
BUSYBOX_TOOLS_MAKE_DIR:=$(TOOLS_DIR)/make
BUSYBOX_TOOLS_DIR:=$(TOOLS_SOURCE_DIR)/busybox-$(BUSYBOX_TOOLS_VERSION)
BUSYBOX_TOOLS_BINARY:=$(BUSYBOX_TOOLS_DIR)/busybox
BUSYBOX_TOOLS_CONFIG_FILE:=$(BUSYBOX_TOOLS_MAKE_DIR)/Config.busybox
BUSYBOX_TOOLS_SOURCE:=busybox-$(BUSYBOX_TOOLS_VERSION).tar.bz2
BUSYBOX_TOOLS_SOURCE_MD5:=6059ac9456de6fb18dc8ee4cd0ec9240
BUSYBOX_TOOLS_SITE:=http://www.busybox.net/downloads
BUSYBOX_TOOLS_TARGET_DIR:=$(TOOLS_DIR)
BUSYBOX_TOOLS_TARGET_BINARY:=$(TOOLS_DIR)/busybox

# Activate on demand to avoid collision with identical target for regular
# busybox package
ifneq ($(strip $(FREETZ_HAVE_DOT_CONFIG)),y)
$(DL_DIR)/$(BUSYBOX_TOOLS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(BUSYBOX_TOOLS_SOURCE) $(BUSYBOX_TOOLS_SITE) $(BUSYBOX_TOOLS_SOURCE_MD5)
endif

$(BUSYBOX_TOOLS_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_TOOLS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BUSYBOX_TOOLS_SOURCE)
	shopt -s nullglob; for i in $(BUSYBOX_TOOLS_MAKE_DIR)/patches/*.busybox.patch; do \
		$(PATCH_TOOL) $(BUSYBOX_TOOLS_DIR) $$i; \
	done
	touch $@

$(BUSYBOX_TOOLS_DIR)/.configured: $(BUSYBOX_TOOLS_DIR)/.unpacked $(BUSYBOX_TOOLS_CONFIG_FILE)
	cp $(BUSYBOX_TOOLS_CONFIG_FILE) $(BUSYBOX_TOOLS_DIR)/.config
	$(MAKE) -C $(BUSYBOX_TOOLS_DIR) oldconfig
	touch $@

$(BUSYBOX_TOOLS_BINARY): $(BUSYBOX_TOOLS_DIR)/.configured
	$(MAKE) -C $(BUSYBOX_TOOLS_DIR)

$(BUSYBOX_TOOLS_TARGET_BINARY): $(BUSYBOX_TOOLS_BINARY)
	cp $(BUSYBOX_TOOLS_BINARY) $(BUSYBOX_TOOLS_TARGET_BINARY)
	@ln -fs busybox $(BUSYBOX_TOOLS_TARGET_DIR)/makedevs
	@ln -fs busybox $(BUSYBOX_TOOLS_TARGET_DIR)/md5sum
	@ln -fs busybox $(BUSYBOX_TOOLS_TARGET_DIR)/tar

busybox-tools: $(BUSYBOX_TOOLS_TARGET_BINARY)

busybox-tools-clean:
	-$(MAKE) -C $(BUSYBOX_TOOLS_DIR) clean
	$(RM)  $(BUSYBOX_TOOLS_TARGET_BINARY)
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/makedevs
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/md5sum
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/tar

busybox-tools-dirclean:
	$(RM) -r $(BUSYBOX_TOOLS_DIR)

busybox-tools-distclean: busybox-tools-dirclean
	$(RM) $(BUSYBOX_TOOLS_TARGET_BINARY)
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/makedevs
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/md5sum
	$(RM) $(BUSYBOX_TOOLS_TARGET_DIR)/tar
