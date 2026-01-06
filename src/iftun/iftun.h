#ifndef IFTUN_H
#define IFTUN_H

#include <stddef.h>

// flags typiques: IFF_TUN | IFF_NO_PI
int iftun_alloc(char devname[16], int flags);

// copie infinie: read(src) -> write(dst)
int iftun_copy_forever(int src_fd, int dst_fd);

#endif
