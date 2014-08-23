#include <LOL.h>

#define DELAY 100

static const uint16_t alljoynBitmap[] = {
    0x0488, //  |   @  @   @   |
    0x0a88, //  |  @ @ @   @   |
    0x0e88, //  |  @@@ @   @   |
    0x0aee, //  |  @ @ @@@ @@@ |
    0x0000, //  |              |
    0x12a9, //  | @  @ @ @ @  @|
    0x154d, //  | @ @ @ @  @@ @|
    0x154b, //  | @ @ @ @  @ @@|
    0x2249  //  |@   @  @  @  @|
};

uint16_t testBitmap[9];

void (*getScrollFunc(int direction))(uint16_t*, uint16_t)
{
  switch (direction) {
    case 0: return scrollDown;
    case 1: return scrollRight;
    case 2: return scrollUp;
    case 3: return scrollLeft;
  }
}

int getMaxScroll(int direction)
{
  switch (direction) {
    case 0: return 9;
    case 1: return 14;
    case 2: return 9;
    case 3: return 14;
  }
}

int getMaxPattern(int direction)
{
  switch (direction) {
    case 0: return 1 << 14;
    case 1: return 1 << 9;
    case 2: return 1 << 14;
    case 3: return 1 << 9;
  }
}

void scrollDown(uint16_t* bitmap, uint16_t pattern)
{
    int i;
    for (i = 8; i > 0; --i) {
        bitmap[i] = bitmap[i - 1];
    }
    bitmap[0] = pattern;
    LOL.render(bitmap);
}

void scrollUp(uint16_t* bitmap, uint16_t pattern)
{
    int i;
    for (i = 0; i < 8; ++i) {
        bitmap[i] = bitmap[i + 1];
    }
    bitmap[8] = pattern;
    LOL.render(bitmap);
}

void scrollRight(uint16_t* bitmap, uint16_t pattern)
{
  int i;
  for (i = 0; i < 9; ++i) {
    bitmap[i] >>= 1;
    bitmap[i] |= bitRead(pattern, 8 - i) << 13;
  }
  LOL.render(bitmap);
}

void scrollLeft(uint16_t* bitmap, uint16_t pattern)
{
    int i;
    for (i = 0; i < 9; ++i) {
        bitmap[i] <<= 1;
        bitmap[i] &= 0x3fff;
        bitmap[i] |= bitRead(pattern, 8 - i);
    }
    LOL.render(bitmap);
}


void setup() {
  memset(testBitmap, 0, sizeof(testBitmap));
  LOL.begin();
}

int direction = 0;

void loop() {
  uint16_t pattern;
  int i;
  int maxPattern = getMaxPattern(direction);
  int maxScroll = getMaxScroll(direction);
  void (*scroll)(uint16_t*, uint16_t) = getScrollFunc(direction);

  /* ALLJOYN bitmap */
  memcpy(testBitmap, alljoynBitmap, sizeof(testBitmap));
  LOL.render(testBitmap);
  delay(3000);
  for (i = 0; i < maxScroll; ++i) {
    scroll(testBitmap, 0);
    delay(DELAY);
  }

  /* Single pixel sweep */
  for (int x = 0; x < 14; ++x) {
    for (int y = 0; y < 9; ++y) {
      testBitmap[y] |= 1 << (13 - x);
      LOL.render(testBitmap);
      delay(DELAY);
      testBitmap[y] &= ~(1 << (13 - x));
      LOL.render(testBitmap);
    }
  }

  /* Line sweep */
  for (int d = 0; d < 4; ++d) {
    void (*s)(uint16_t*, uint16_t) = getScrollFunc(d);
    s(testBitmap, getMaxPattern(d) - 1);
    delay(DELAY * 5);
    for (i = 0; i < getMaxScroll(d); ++i) {
      s(testBitmap, 0);
      delay(DELAY * 5);
    }
  }
  delay(3000);

  /* Counter pattern scroll */
  for (pattern = 0x0; pattern < maxPattern; ++pattern) {
    scroll(testBitmap, pattern);
    delay(DELAY / 10);
  }
  for (i = 0; i < maxScroll; ++i) {
    scroll(testBitmap, maxPattern - 1);
    delay(DELAY / 10);
  }
  delay(3000);

  ++direction;
  direction %= 4;
}



