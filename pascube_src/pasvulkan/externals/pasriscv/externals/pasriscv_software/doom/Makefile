################################################################
#
# $Id:$
#
# $Log:$
#

ifeq ($(V),1)
	VB=''
else
	VB=@
endif

CCLINUX=riscv64-linux-gnu-gcc
CCBARE=riscv64-unknown-elf-gcc
OBJCOPY=riscv64-unknown-elf-objcopy
CFLAGS+= -O3 -mcmodel=medany -mabi=lp64d -march=rv64gc $(INCLUDES)
CFLAGS+= -Wall
LDFLAGS += -Wl,--no-warn-rwx-segments -flto

HOSTCC=gcc
HOSTCFLAGS = -O3
OBJDIR=build
BIN_TO_C=bin_to_c
SRC_BIN_TO_C=$(BIN_TO_C).c
OUTPUT=doomgeneric

SRC_DOOM = i_main.o dummy.o am_map.o doomdef.o doomstat.o dstrings.o d_event.o d_items.o d_iwad.o d_loop.o d_main.o d_mode.o d_net.o f_finale.o f_wipe.o g_game.o hu_lib.o hu_stuff.o info.o i_cdmus.o i_endoom.o i_joystick.o i_scale.o i_sound.o i_system.o i_timer.o memio.o m_argv.o m_bbox.o m_cheat.o m_config.o m_controls.o m_fixed.o m_menu.o m_misc.o m_random.o p_ceilng.o p_doors.o p_enemy.o p_floor.o p_inter.o p_lights.o p_map.o p_maputl.o p_mobj.o p_plats.o p_pspr.o p_saveg.o p_setup.o p_sight.o p_spec.o p_switch.o p_telept.o p_tick.o p_user.o r_bsp.o r_data.o r_draw.o r_main.o r_plane.o r_segs.o r_sky.o r_things.o sha1.o sounds.o statdump.o st_lib.o st_stuff.o s_sound.o tables.o v_video.o wi_stuff.o w_checksum.o w_file.o w_main.o w_wad.o z_zone.o w_file_stdc.o i_input.o i_video.o doomgeneric.o doomgeneric_pasriscv.o mus2mid.o doom_iwad.o

CC=$(CCLINUX)
CFLAGS += -DLINUX_TARGET=1 -DBAREMETAL_TARGET=0 -lm -lc -lgcc -lc -static

OBJS += $(addprefix $(OBJDIR)/, $(SRC_DOOM))


all: $(OUTPUT)

clean:
	-rm -rf $(OBJDIR)
	-rm $(OUTPUT)
	-rm $(OUTPUT).elf
	-rm doom_iwad.h
	-rm doom_iwad.c
	-rm $(BIN_TO_C)

$(OUTPUT):	$(OBJS)
	@echo [Linking $@]
	
        $(CCLINUX) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $(OUTPUT).elf; \

$(OBJS): | $(OBJDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o:	%.c
	@echo [Compiling $<]
	$(VB)$(CC) $(CFLAGS) -c $< -o $@

print:
	@echo OBJS: $(OBJS)

run:
	./$(EMULATOR) --bios $(OUTPUT).bin --font $(FONT)

IWAD := $(shell find . -iname '*.wad' | head -n 1 | tr '[:upper:]' '[:lower:]')

$(BIN_TO_C): $(BIN_TO_C).c
	@echo [Building $@]
	$(HOSTCC) $(HOSTCFLAGS) $(BIN_TO_C).c -o $(BIN_TO_C)

convert_iwad:
	./$(BIN_TO_C) $(IWAD) doom_iwad

iwad: $(BIN_TO_C) convert_iwad

makerun: all run

.PHONY: iwad
.PHONY: makerun