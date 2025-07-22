#include <assert.h>
#include <concord/discord.h>
#include <stdio.h>
#include <string.h>
#include <discord.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>

char* globalStr;
u64snowflake channel;
struct discord* client;
bool isSet;

enum verbs{
    PING = 0,
    IS_INIT = 1,
    SET_TOKEN = 2,
    SEND_MESSAGE = 3,
    ELSE = 4
};

bool successful = false;
void* done(struct discord *client, struct discord_response *resp){
    successful = true;
}

void* fail(struct discord *client, struct discord_response *resp){
    successful = false;
}

//TODO: maybe make this return a enum rather than a bool
bool handleRequest(enum verbs verb, uint64_t channel, char* payload){
    switch(verb){
        case PING: {
            return true;
        }
        case IS_INIT: {
            return isSet;
        }
        case SET_TOKEN: {
            if (!isSet){
                ccord_global_init();
                client = discord_init(payload);
                isSet = true;
                return true;
            }
            else{
                discord_shutdown(client);
                client = discord_init(payload);
                return true;
            };
        }
        case SEND_MESSAGE:{
            if (isSet){
                // printf("channel: %ld, message %s \n", channel, payload);
                struct discord_create_message params = { .content = payload };
                struct discord_ret_message returnCallback = {.done = (void*)&done, .fail = (void*)&fail, .sync = DISCORD_SYNC_FLAG };
                discord_create_message(client, channel, &params, &returnCallback);
                return successful;
            }
            else{
                // printf("nah didn't do it\n");
                return false;
            }
        }
        default: {
            return false;
        }

    }
};


int run_discord_server(uint16_t port) {
    // printf("port: %d\n", port);
    int server_fd, client_fd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t addr_len = sizeof(client_addr);
    char buffer[4096];

    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(port);

    struct linger linger_opt;
    linger_opt.l_onoff = 1;
    linger_opt.l_linger = 0;
    setsockopt(server_fd, SOL_SOCKET, SO_LINGER, &linger_opt, sizeof(linger_opt));

    int bindResult = bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr));
    int listenResult = listen(server_fd, 1);
    // printf("Discord Service Running: %d, %d -> %d\n", port, bindResult, listenResult);
    if (0 > listenResult || 0 > bindResult){
        return -1;
    };
    while (1) {
        // printf("waiting \n");
        client_fd = accept(server_fd, (struct sockaddr*)&client_addr, &addr_len);
        // printf("got connection\n");
        while (1){
            int len = read(client_fd, buffer, sizeof(buffer) - 1);
            if (8 > len){
                close(client_fd);
                break;
            }
            uint64_t* channelFromBuffer = (uint64_t*)buffer;
            enum verbs verb = (enum verbs)buffer[8];

            // printf("%ld\n", *channelFromBuffer);
            if (len <= 0) continue;
            buffer[len] = '\0';
            // printf("verb: %d\n", verb);
            bool requestResult = handleRequest(verb, *channelFromBuffer, &buffer[9]);
            int sent = send(client_fd, &requestResult, 1, 0);

            if (0 > sent){
                close(client_fd);
                break;
            }
        }
    }

    close(server_fd);

    return 0;
}

