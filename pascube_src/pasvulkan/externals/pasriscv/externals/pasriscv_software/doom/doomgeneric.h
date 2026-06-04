#ifndef DOOM_GENERIC
#define DOOM_GENERIC

#include <stdlib.h>
#include <stdint.h>

extern int DOOMGENERIC_RESX;
extern int DOOMGENERIC_RESY;
extern int DOOMGENERIC_CHANNELS;

extern uint8_t *DG_ScreenBuffer;

void DG_Init();
void DG_DrawFrame();
void DG_SleepMs(uint32_t ms);
uint32_t DG_GetTicksMs();
int DG_GetKey(int *pressed, unsigned char *key);
void DG_SetWindowTitle(const char *title);

#endif // DOOM_GENERIC
