#include "doomkeys.h"
#include "m_argv.h"
#include "doomgeneric.h"

#include <stdio.h>
#include <unistd.h>
#include <ctype.h>

#include <stdbool.h>
#include "pasriscv_config.h"

#if LINUX_TARGET
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/select.h>
#include <termios.h>

static struct termios old_term;
#endif

#define TARGET_RESX 320
#define TARGET_RESY 200
#define TARGET_CHANNELS 3

#define RESET_RESX 640
#define RESET_RESY 400
#define RESET_CHANNELS 3

int DOOMGENERIC_RESX;
int DOOMGENERIC_RESY;
int DOOMGENERIC_CHANNELS;
volatile unsigned char *DOOMGENERIC_FB;

static int old_resx;
static int old_resy;

static volatile unsigned char *fb_active;
static volatile unsigned char *fb_dimensions;
static volatile unsigned char *fb_channels;
//static volatile unsigned char *term_dimensions;
static volatile unsigned char *fb_render;
static volatile unsigned char *uart_read;
static volatile uint32_t *rawkeyboard;

//static int term_cols;
//static int term_rows;

void set_fb_active(uint64_t state){
  *(uint32_t *)fb_active = state;
}

void get_fb_info()
{
  uint32_t resolution = *(uint32_t *)fb_dimensions;

  DOOMGENERIC_RESX = resolution & 0xffff;
  DOOMGENERIC_RESY = (resolution >> 16) & 0xffff;
  DOOMGENERIC_CHANNELS = *fb_channels;
}

/*
void set_terminal_resolution(uint64_t cols, uint64_t rows)
{
  *(uint32_t *)term_dimensions = (rows << 16) | cols;
}

void get_terminal_resolution(void)
{
  uint32_t dimensions = *(uint32_t *)term_dimensions;
  term_cols = dimensions & 0xffff;
  term_rows = (dimensions >> 16) & 0xffff;
}
*/

void set_resolution(uint64_t width, uint64_t height)
{
  *(uint32_t *)fb_dimensions = (height << 16) | width;
}

#if LINUX_TARGET
void cleanup(void)
{
  tcsetattr(0, TCSAFLUSH, &old_term);
  set_resolution(old_resx, old_resy);
//set_terminal_resolution(term_cols, term_rows);
  set_fb_active(7);
  printf("\033[2J\033[H");
}
#endif

void DG_Init()
{
#if LINUX_TARGET
  int fd = open("/dev/mem", O_RDWR | O_SYNC);
  if (fd < 0) {
    perror("Failed to open /dev/mem");
    exit(1);
  }

  void *fb_render_addr_ptr = (void *)((off_t)(fb_render_addr));
  printf("Opened /dev/mem at address %p\n", fb_render_addr_ptr);
  
  fb_render = mmap(NULL, 0x1000 + TARGET_RESX * TARGET_RESY * 4, PROT_READ | PROT_WRITE, MAP_SHARED, fd, ((off_t)(fb_render_addr)));
  if (fb_dimensions == MAP_FAILED) {
    perror("Failed to mmap fb_dimensions");
    exit(1);
  }

  uart_read = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_SHARED, fd, ((off_t)(uart_read_addr)));
  if (fb_dimensions == MAP_FAILED) {
    perror("Failed to mmap uart_read");
    exit(1);
  }

  rawkeyboard = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_SHARED, fd, ((off_t)(0x10008000)));
  if (rawkeyboard == MAP_FAILED) {
    perror("Failed to mmap rawkeyboard");
    exit(1);
  }

  fb_active = fb_render + 1 * sizeof(uint32_t);
  fb_dimensions = fb_render + 2 * sizeof(uint32_t);
  fb_channels = fb_render + 3 * sizeof(uint32_t);
  DOOMGENERIC_FB = fb_render + 0x1000;

  close(fd);

  struct termios term;
  tcgetattr(0, &term);
  tcgetattr(0, &old_term);
  term.c_lflag &= ~(ECHO | ICANON);
  tcsetattr(0, TCSAFLUSH, &term);

  get_fb_info();

  old_resx = DOOMGENERIC_RESX;
  old_resy = DOOMGENERIC_RESY;

//get_terminal_resolution();

  atexit(cleanup);
  at_quick_exit(cleanup);
#else
  fb_active = fb_active_addr;
  fb_dimensions = fb_dimensions_addr;
  fb_channels = fb_channels_addr;
  fb_render = fb_render_addr;
  uart_read = uart_read_addr;
  rawkeyboard = (uint32_t *)0x10008000;
  DOOMGENERIC_FB = framebuffer_start_addr;
#endif

  set_resolution(TARGET_RESX, TARGET_RESY);
  get_fb_info();
  set_fb_active(1);
//set_terminal_resolution(40, 16);
}

void DG_DrawFrame()
{
  *fb_render = 1;
}

void DG_SleepMs(uint32_t ms)
{
  uint32_t start = DG_GetTicksMs();

  while (DG_GetTicksMs() < start + ms)
  {
  }
}

uint32_t DG_GetTicksMs()
{
  uint64_t result;
  asm volatile("rdtime %0;"
               : "=r"(result));
  return result / 1000;
}

typedef struct
{
  int host_key;
  int doom_key;
  int state;
} key;

key keys[] = {
    {.host_key = 302,
     .doom_key = KEY_HOME},

    {.host_key = 303,
     .doom_key = KEY_END},

    {.host_key = 304,
      .doom_key = KEY_PGUP},
  
    {.host_key = 305,
      .doom_key = KEY_PGDN},

    {.host_key = 306,
      .doom_key = KEY_CAPSLOCK},

    {.host_key = 307,
    .doom_key = KEY_NUMLOCK},

    {.host_key = 308,
    .doom_key = KEY_SCRLCK},

    {.host_key = 317,
    .doom_key = KEY_PRTSCR},

    {.host_key = 291,
    .doom_key = '/'},

    {.host_key = 292,
    .doom_key = '*'},

    {.host_key = 293,
    .doom_key = '-'},

    {.host_key = 294,
    .doom_key = '+'},

    {.host_key = 102,
    .doom_key = 'f'},

    {.host_key = 109,
    .doom_key = 'm'},    

    {.host_key = 295,
    .doom_key = KEY_ENTER},

    {.host_key = 296,
    .doom_key = KEY_EQUALS},

    {.host_key = 61,
    .doom_key = KEY_EQUALS},

    {.host_key = 43,
    .doom_key = '+'},

    {.host_key = 45,
    .doom_key = '-'},

    {.host_key = 9,
    .doom_key = KEY_TAB},

    {.host_key = 177,
    .doom_key = KEY_DEL},

    {.host_key = 301,
    .doom_key = KEY_INS},

    {.host_key = 256,
    .doom_key = KEY_F1},

    {.host_key = 257,
    .doom_key = KEY_F2},

    {.host_key = 258,
    .doom_key = KEY_F3},

    {.host_key = 259,
    .doom_key = KEY_F4},

    {.host_key = 260,
     .doom_key = KEY_F5},

    {.host_key = 262,
     .doom_key = KEY_F6},

    {.host_key = 263,
      .doom_key = KEY_F7},
  
      {.host_key = 264,
      .doom_key = KEY_F8},
  
      {.host_key = 265,
      .doom_key = KEY_F9},
  
      {.host_key = 266,
      .doom_key = KEY_F10},
  
      {.host_key = 267,
      .doom_key = KEY_F11},
  
      {.host_key = 268,
      .doom_key = KEY_F12},

    {.host_key = 119,//'W',
     .doom_key = KEY_UPARROW},

    {.host_key = 297,
     .doom_key = KEY_UPARROW},

    {.host_key = 97,//'A',
     .doom_key = KEY_LEFTARROW},

    {.host_key = 300,
     .doom_key = KEY_LEFTARROW},

    {.host_key = 115,//'S',
     .doom_key = KEY_DOWNARROW},

    {.host_key = 298,
      .doom_key = KEY_DOWNARROW},

    {.host_key = 100,//'D',
     .doom_key = KEY_RIGHTARROW},

    {.host_key = 299,
     .doom_key = KEY_RIGHTARROW},

    {.host_key = 284, // KP_4
     .doom_key = KEY_STRAFE_L},

    { .host_key = 286, // KP_6
     .doom_key = KEY_STRAFE_R}, 
        
    {.host_key = 111,//'O',
     .doom_key = KEY_ENTER},

    {.host_key = 13,//'O',
     .doom_key = KEY_ENTER},

    {.host_key = 32,//' ',
     .doom_key = KEY_USE},

    {.host_key = 311,// CTRL
     .doom_key = KEY_FIRE},

    {.host_key = 98, // B
     .doom_key = KEY_FIRE},

    {.host_key = 101,//'E',
     .doom_key = KEY_USE},

    {.host_key = 113,//'Q',
     .doom_key = KEY_ESCAPE},

    {.host_key = 27,//'Q',
     .doom_key = KEY_ESCAPE},

    {.host_key = 121,//'Y',
     .doom_key = 'y'},

    {.host_key = 110,//'N',
     .doom_key = 'n'},

    {.host_key = 112, // P
     .doom_key = -1},

    {.host_key = 19,
     .doom_key = -1},

    {.host_key = 48, // 0
     .doom_key = '0'}, 

    {.host_key = 49, // 1
      .doom_key = '1'}, 
  
    {.host_key = 50, // 2
     .doom_key = '2'},

    {.host_key = 51, // 3
      .doom_key = '3'},
  
    {.host_key = 52, // 4
    .doom_key = '4'},

    {.host_key = 53, // 5
    .doom_key = '5'},

    {.host_key = 54, // 6
    .doom_key = '6'},

    {.host_key = 309,
    .doom_key = KEY_RSHIFT},

    {.host_key = 310,
    .doom_key = KEY_RSHIFT}, // actually LSHIFT, but doom doesn't care

    {.host_key = 311,
    .doom_key = KEY_RCTRL},

    {.host_key = 312,
    .doom_key = KEY_RCTRL}, // actually LCTRL, but doom doesn't care

    {.host_key = 313,
    .doom_key = KEY_RALT},

    {.host_key = 314,
    .doom_key = KEY_RALT } // actually LALT, but doom doesn't care

   

    
};
const int keys_size = sizeof(keys) / sizeof(keys[0]);

int speed_toggle = 0;

int DG_GetKey(int *pressed, unsigned char *doomKey)
{
  for (int i = 0; i < keys_size; i++){
    uint32_t keyCode = keys[i].host_key;
    uint32_t k = rawkeyboard[keyCode >> 5u];
    uint32_t mask = 1u << (keyCode & 0x1fu);
    if(((k & mask) != 0) && (keys[i].state == 0)){
      if (keys[i].doom_key == -1){
        speed_toggle = !speed_toggle;
        return 0;
      }
      *doomKey = keys[i].doom_key;  
      *pressed = 1;
      keys[i].state = 1;
      return 1;
    }else if (((k & mask) == 0) && (keys[i].state == 1)){
      if (keys[i].doom_key == -1){
        return 0;
      }
      *doomKey = keys[i].doom_key;
      *pressed = 0;
      keys[i].state = 0;
      return 1;
    }
  }

/*  
  char c;

  c = *uart_read;

  c = toupper(c);

  for (int i = 0; i < keys_size; i++)
  {
    if (keys[i].state == 1)
    {
      if (keys[i].host_key == c)
      {
        continue;
      }
      else
      {
        keys[i].state = 0;
        if (c == 'P')
        {
          return 0;
        }
        else
        {
          *doomKey = keys[i].doom_key;
          *pressed = 0;
          return 1;
        }
      }
    }
    else if (keys[i].host_key == c)
    {
      keys[i].state = 1;
      if (c == 'P')
      {
        speed_toggle = !speed_toggle;
        return 0;
      }
      else
      {
        *doomKey = keys[i].doom_key;
        *pressed = 1;
        return 1;
      }
    }
  }

*/
  return 0;
}

void DG_SetWindowTitle(const char *title)
{
}
