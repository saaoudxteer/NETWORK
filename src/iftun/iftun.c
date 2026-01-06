#include "iftun.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/if.h>
#include <linux/if_tun.h>

int iftun_alloc(char devname[16], int flags)
{
    struct ifreq ifr;

    int fd = open("/dev/net/tun", O_RDWR);
    if (fd < 0) {
        perror("open(/dev/net/tun)");
        return -1;
    }

    memset(&ifr, 0, sizeof(ifr));
    ifr.ifr_flags = flags; // ex: IFF_TUN | IFF_NO_PI

    if (devname && devname[0] != '\0') {
        strncpy(ifr.ifr_name, devname, IFNAMSIZ - 1);
        ifr.ifr_name[IFNAMSIZ - 1] = '\0';
    }

    if (ioctl(fd, TUNSETIFF, (void*)&ifr) < 0) {
        perror("ioctl(TUNSETIFF)");
        close(fd);
        return -1;
    }

    strncpy(devname, ifr.ifr_name, 16 - 1);
    devname[16 - 1] = '\0';
    return fd;
}

int iftun_copy_forever(int src_fd, int dst_fd)
{
    unsigned char buf[2000];
    for (;;) {
        ssize_t n = read(src_fd, buf, sizeof(buf));
        if (n < 0) {
            perror("read(tun)");
            return -1;
        }
        ssize_t off = 0;
        while (off < n) {
            ssize_t w = write(dst_fd, buf + off, (size_t)(n - off));
            if (w < 0) {
                perror("write(dst)");
                return -1;
            }
            off += w;
        }
    }
}
