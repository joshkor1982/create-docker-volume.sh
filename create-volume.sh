#!/bin/bash

#COLOR
    cy=$(tput setaf 118)
    rst=$(tput sgr0)

create_volume() {
    read -p "ENTER VOLUME NAME: " VOLUME
        docker volume create ${VOLUME} >/dev/null
        EXISTS=$(docker volume ls | grep -oh "${VOLUME}")
    if [[ ${EXISTS} == ${VOLUME} ]] ; then
        echo
        echo "${cy}${VOLUME}${rst} HAS BEEN CREATED"
        echo
        VOLUME_PATH=$(docker volume inspect ${VOLUME} \
        | grep Mountpoint | awk -F : {'print $2'} \
        | \cut -c 3- | grep -Po '.*(?=..$)')
        echo "${cy}${VOLUME_PATH}${rst} IS THE HOST VOLUME PATH "
        echo
    else
        echo "${cy}${VOLUME}${rst} WAS NOT CREATED"
    fi
    }
create_dockerfile() {
    read -p "ENTER DOCKER IMAGE TO PULL (EX: alpine:latest): " IMAGE
        rm -f Dockerfile && touch Dockerfile && chmod 777 Dockerfile
        # echo content to a user defined Dockerfile
        echo "FROM ${IMAGE}" >> Dockerfile
    read -p "ENTER WORKING DIRECTORY (VOLUME MOUNT POINT): " APPDIR
        echo "WORKDIR /${APPDIR}" >> Dockerfile
    read -p "ENTER NAME OF BASH FILE TO RUN IN CONTAINER (EX: check_file.sh): " BASH_FILE
        echo "COPY ${BASH_FILE} . " >> Dockerfile
        echo "RUN chmod +x ${BASH_FILE}" >> Dockerfile
        echo "ENTRYPOINT [\"/bin/sh\", \"${BASH_FILE}\"]" >> Dockerfile
    }
create_bash_script() {

    rm -f ${BASH_FILE} && touch ${BASH_FILE} && chmod 777 ${BASH_FILE}
        # echo content to a user defined bash script
        echo "#!/bin/bash" >> "${BASH_FILE}"
        echo "read -p 'ENTER FILE NAME:' FILE" >> "${BASH_FILE}"
        echo "touch /${APPDIR}/\${FILE} " >> "${BASH_FILE}"
        echo "if [[ -e /${APPDIR}/\${FILE} ]] ; then" >> "${BASH_FILE}"
        echo "echo \"FILE EXISTS, CHECK OUT YOUR NEW FILES!\"" >> "${BASH_FILE}"
        echo "echo" >> ${BASH_FILE}
        echo "ls /${APPDIR}/" >> "${BASH_FILE}"
        echo "echo" >> ${BASH_FILE}
        echo "else" >> "${BASH_FILE}"
        echo "echo \"FILE DOES NOT EXIST\"" >> "${BASH_FILE}"
        echo "cat /${APPDIR}/\${FILE}" >> "${BASH_FILE}"
        echo "fi" >> "${BASH_FILE}"
        echo "sleep 5" >> "${BASH_FILE}"
    }

run_container() {
    echo "${cy}-----------------------------${rst}"
    echo "${cy}RUN THE CONTAINER${rst}"
    echo "${cy}-----------------------------${rst}"
    echo
        read -p 'ENTER CONTAINER NAME: ' CONTNAME
        clear
    echo "${cy}-----------------------------${rst}"
    echo "${cy}BUILDING IMAGE${rst}"
    echo "${cy}-----------------------------${rst}"
    echo
            docker build -t ${CONTNAME} .
            sleep 1
            clear
            docker run -it --mount source=${APPDIR},destination=/${VOLUME} ${CONTNAME}
    }
    clear

    echo "${cy}-----------------------------${rst}"
    echo "${cy}CREATE A VOLUME${rst}"
    echo "${cy}-----------------------------${rst}"
    echo
    create_volume;
    sleep 4
    clear

    echo "${cy}-----------------------------${rst}"
    echo "${cy}CREATE A DOCKERFILE${rst}"
    echo "${cy}-----------------------------${rst}"
    echo
    create_dockerfile;
    clear
    echo
    echo "${cy}-----------------------------${rst}"
    echo "${cy}BELOW IS THE NEW DOCKERFILE${rst}"
    echo "${cy}-----------------------------${rst}"
    echo
    cat Dockerfile;
    sleep 4
    clear

    echo "${cy}-----------------------------${rst}"
    echo "${cy}GENERATING A BASH SCRIPT${rst}"
    echo "${cy}-----------------------------${rst}"
    echo -ne '>                      [1%]\r'  ; sleep 0.3
    echo -ne '>>                     [10%]\r' ; sleep 0.3
    echo -ne '>>>>                   [20%]\r' ; sleep 0.3
    echo -ne '>>>>>>                 [30%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>              [40%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>             [50%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>>>           [60%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>>>>>>        [70%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>>>>>>>>>     [80%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>>>>>>>>>>>>  [90%]\r' ; sleep 0.3
    echo -ne '>>>>>>>>>>>>>>>>>>>>>>>[100%]\r' ; sleep 0.3
    echo -ne '\n'
    echo "${cy}COMPLETE!${rst}"
    echo
create_bash_script;
    echo "BELOW ARE THE CONTENTS OF THE BASH SCRIPT: "
    echo
    cat ${BASH_FILE}
    sleep 4

run_container;
    echo "BELOW ARE THE CONTENTS OF THE BASH SCRIPT: "
    clear
    ls ${VOLUME_PATH}
