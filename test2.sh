#!/bin/bash
podman pull docker.io/akito13/nim
podman stop mycontainer
podman rm mycontainer
podman run -dit --name mycontainer akito13/nim sh
podman cp ./test.sh "mycontainer":/root/script.sh
podman exec "mycontainer" sh -c "chmod +x /root/script.sh && sh /root/script.sh" >output.txt 2>&1
cat output.txt
