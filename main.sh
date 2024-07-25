#!/bin/bash

clear

re() {
    local text=$1
    for ((i=0; i<${#text}; i++)); do
        echo -e -n "${text:i:1}"
        sleep 0.001
    done
    echo
}

re '

                              -     -                            
                            .+       +.                          
                           :#         #:                         
                          =%           %-                        
                              VPNexus                     
                        #@:             -@#                      
                     :  #@:             :@*  :                   
                    -=  *@:             -@*  =-                  
                   -%   *@-             =@+   %-                 
                  -@=  .*@+             +@+.  =@-                
                 =@%   .+@%-    :.:    -@@+.   #@:               
                =@@#:     =%%-+@@@@@+-%%=     .#@@=              
                 .+%@%+:.   -#@@@@@@@#-   .:=#@%=                
                    -##%%%%%#*@@@@@@@*#%%%%%##-                  
                  .*#######%@@@@@@@@@@@%#######*.                
               .=#@%*+=--#@@@@@@@@@@@@@@@#--=+*%@#=.             
            .=#@%+:     *@@@@@+.   .+@@@@@*     :+%@#=.          
          :*@@=.    .=#@@@@@@@       @@@@@@@#=.    .=@@*.        
            =@+    .%@@*%@@@@@*     *@@@@@%*@@%.    +@=          
             :@=    +@# :@@@@@#     #@@@@%. #@+    =@:           
              .#-   :@@  .%@@#       #@@#.  @@:   -#.            
                +:   %@:   =%         %=   :@%   -+              
                 -.  +@+                   +@+  .-               
                  .  :@#                   #@:  .                
                      %@      @ZELROTH    .@%                    
                      :+@:               =@+:                    
                        =@:             :@-                      
                         -%.           .%:                       
                          .#           #.                        
                            +         +                          
                             -       -

                    github: github.com/xelroth
                    telegram: @ZELROTH
                    instagram: @koohyar.py

'


function get_current_ip() {
    local current_ip
    current_ip=$(curl -s https://api.ipify.org)
    echo "$current_ip"
}

install_tunnel() {
    local iran_ip=$1
    local foreign_ip=$2
    local server_type=$3
    local tunnel_type=$4

    if [[ $tunnel_type == "6to4" ]]; then
        if [[ $server_type == "iran" ]]; then
            commands=(
                "ip tunnel add 6to4_iran mode sit remote $foreign_ip local $iran_ip"
                "ip -6 addr add 2002:a00:100::1/64 dev 6to4_iran"
                "ip link set 6to4_iran mtu 1480"
                "ip link set 6to4_iran up"
                "ip -6 tunnel add GRE6Tun_iran mode ip6gre remote 2002:a00:100::2 local 2002:a00:100::1"
                "ip addr add 192.168.168.1/30 dev GRE6Tun_iran"
                "ip link set GRE6Tun_iran mtu 1436"
                "ip link set GRE6Tun_iran up"
                "sysctl net.ipv4.ip_forward=1"
                "iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 192.168.168.1"
                "iptables -t nat -A PREROUTING -j DNAT --to-destination 192.168.168.2"
                "iptables -t nat -A POSTROUTING -j MASQUERADE"
            )
        elif [[ $server_type == "foreign" ]]; then
            commands=(
                "ip tunnel add 6to4_Forign mode sit remote $iran_ip local $foreign_ip"
                "ip -6 addr add 2002:a00:100::2/64 dev 6to4_Forign"
                "ip link set 6to4_Forign mtu 1480"
                "ip link set 6to4_Forign up"
                "ip -6 tunnel add GRE6Tun_Forign mode ip6gre remote 2002:a00:100::1 local 2002:a00:100::2"
                "ip addr add 192.168.168.2/30 dev GRE6Tun_Forign"
                "ip link set GRE6Tun_Forign mtu 1436"
                "ip link set GRE6Tun_Forign up"
                "iptables -A INPUT --proto icmp -j DROP"
            )
        fi
    elif [[ $tunnel_type == "iptables" ]]; then
        commands=(
            "sysctl net.ipv4.ip_forward=1"
            "iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination $iran_ip"
            "iptables -t nat -A PREROUTING -j DNAT --to-destination $foreign_ip"
            "iptables -t nat -A POSTROUTING -j MASQUERADE"
        )
    elif [[ $tunnel_type == "wireguard" ]]; then
        commands=(
            "curl -sSL https://get.docker.com | sh
            sudo usermod -aG docker $(whoami)"
            "docker run -d \
                --name=wg-easy \
                -e LANG=de \
                -e WG_HOST=$iran_ip \
                -e PASSWORD_HASH=$password \
                -e PORT=51821 \
                -e WG_PORT=51820 \
                -v ~/.wg-easy:/etc/wireguard \
                -p 51820:51820/udp \
                -p 51821:51821/tcp \
                --cap-add=NET_ADMIN \
                --cap-add=SYS_MODULE \
                --sysctl=\"net.ipv4.conf.all.src_valid_mark=1\" \
                --sysctl=\"net.ipv4.ip_forward=1\" \
                --restart unless-stopped \
                ghcr.io/wg-easy/wg-easy"
        )
    fi

    for command in "${commands[@]}"; do
        eval "$command"
    done


    if [[ -f "/etc/rc.local" ]]; then
        read -p "File /etc/rc.local already exists. Do you want to overwrite it? (y/n): " overwrite
        if [[ $overwrite != "y" && $overwrite != "yes" ]]; then
            echo "Stopped process."
            sleep 5
            return
        fi
    fi

    echo "#! /bin/bash" > /etc/rc.local

    for command in "${commands[@]}"; do
        echo "$command" >> /etc/rc.local
    done

    echo "exit 0" >> /etc/rc.local
    chmod +x /etc/rc.local
    echo -e "\033[92mSuccessful\033[0m"
}

uninstall_tunnel() {
    local server_type=$1
    rm /etc/rc.local
    echo -e "\033[92mSuccessful\033[0m"
}

install_sanaie_script() {
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

install_alireza_script() {
    bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
}

install_ghost_script() {
    bash <(curl -Ls https://github.com/masoudgb/Gost-ip6/raw/main/Gost.sh)
}

install_pftun_script() {
    bash <(curl -s https://raw.githubusercontent.com/opiran-club/pf-tun/main/pf-tun.sh --ipv4)
}

install_reverse_script() {
    bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/ReverseTlsTunnel/main/RtTunnel.sh)
}

install_ispblocker_script() {
    bash <(curl -s https://raw.githubusercontent.com/Kiya6955/IR-ISP-Blocker/main/ir-isp-blocker.sh)
}

main_menu() {
    echo -e "\033[94mVPNexus the Ultimate Tunnel and Panel System Installer/Uninstaller\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Install\033[0m"
    echo -e "\033[91m2. Uninstall\033[0m"
    echo -e "\033[94m3. Scripts\033[0m"
    echo -e "\033[95m4. Install VPN Panels/Bots\033[0m"
    echo -e "\033[96m5. Install Notifier\033[0m"
    read -p "What would you like to do? " choice

    if [[ $choice != "1" && $choice != "2" && $choice != "3" && $choice != "4" && $choice != "5" ]]; then
        echo -e "\033[91mInvalid action. Please enter '1', '2', '3', or '4'.\033[0m"
        return
    fi

    if [[ $choice == "1" ]]; then
        install_menu
    elif [[ $choice == "2" ]]; then
        uninstall_menu
    elif [[ $choice == "3" ]]; then
        scripts_menu
    elif [[ $choice == "4" ]]; then
        panel_installer
    elif [[ $choice == "5" ]]; then
        install_notifier
    fi
}

install_notifier() {
    clear
    echo -e "\033[95mInstall Notifier\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[96mFor installing the Notifier system, you need to have another server to run the Notifier on, which will notify you if your main server gets timed out via SMS panel.\033[0m"
    echo -e "\033[91mBack to main menu: type 'back' and press Enter\033[0m"
    read -p $'\033[37mPress Enter to continue... or type \'back\' to cancel: \033[0m' response
    if [[ $response == "back" ]]; then
        echo -e "\033[91mCancelled. Returning to main menu...\033[0m"
        sleep 5
        clear
        main_menu
        return
    fi

    clear
    echo -e "\033[95mChoose your SMS provider:\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Kavenegar\033[0m"
    echo -e "\033[94m2. Elanak\033[0m"
    echo -e "\033[96m3. IPPanel\033[0m"
    read -p $'\033[93mEnter the number of your choice: \033[0m' provider_choice

    case $provider_choice in
        1)
            ip_address=$(get_current_ip)
            read -p $'\033[92mIs this the IP of your server? ('$ip_address') (y/n):\033[0m ' response
            if [[ $response != "y" && $response != "yes" ]]; then
                read -p $'\033[94mEnter the IP address of your server: \033[0m' ip_address
            fi

            read -p $'\033[95mEnter your API key: \033[0m' api_key
            read -p $'\033[96mEnter the number to send SMS to (in the format 09******): \033[0m' number
            read -p $'\033[93mEnter the sender number (optional): \033[0m' sender_number

            python_file_name="notifire_kavenegar_$(echo $ip_address | tr -d '.')".py

            cat > $python_file_name << EOF
#!/usr/bin/env python

import os
import time
import subprocess
from kavenegar import *

class PingService:
    def __init__(self, api_key, number, sender_number, ip_address):
        self.api_key = api_key
        self.number = number
        self.sender_number = sender_number
        self.ip_address = ip_address
        self.api = KavenegarAPI(self.api_key)

    def _send_sms(self):
        sms_params = {
            'sender': self.sender_number,
            'receptor': self.number,
            'message': f'Warning!\n Your Service on {self.ip_address} is Down.',
        }
        try:
            response = self.api.sms_send(sms_params)
            print(response)
        except (APIException, HTTPException) as e:
            print(e)

    def _ping_ip(self):
        try:
            response = subprocess.check_call(f"ping -c 1 {self.ip_address} > /dev/null", shell=True)
            if response != 0:
                self._send_sms()
        except Exception as e:
            print(e)

    def _create_service_config(self):
        service_config = f'''
[Unit]
Description=Ping Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/python {__file__}
Restart=always

[Install]
WantedBy=multi-user.target
'''
        with open('/etc/systemd/system/ping_service.service', 'w') as f:
            f.write(service_config)

    def _start_service(self):
        os.system('systemctl daemon-reload')
        os.system('systemctl start ping_service')

    def run(self):
        self._create_service_config()
        self._start_service()
        while True:
            self._ping_ip()
            time.sleep(60)

if __name__ == '__main__':
    try:
        from kavenegar import *
    except ImportError:
        try:
            subprocess.check_call(['pip', 'install', 'kavenegar'])
        except:
            try:
                subprocess.check_call(['pip3', 'install', 'kavenegar'])
            except Exception as e:
                print(e)

    service = PingService('$api_key', '$number', '$sender_number', '$ip_address')
    service.run()
EOF
            clear
            echo "Your Notifier saved in $PWD/$python_file_name"
            echo "To run it, use the following commands:"
            echo "pip3 install kavenegar"
            echo "python3 $python_file_name"
            ;;
        2)
            ip_address=$(get_current_ip)
            read -p $'\033[92mIs this the IP of your server? ('$ip_address') (y/n):\033[0m'response
            if [[ $response != "y" && $response != "yes" ]]; then
                read -p $'\033[94mEnter the IP address of your server: \033[0m' ip_address
            fi

            read -p $'\033[95mEnter the sender number: \033[0m' sender_number
            read -p $'\033[96mEnter the number to send SMS to (in the format 09******): \033[0m' number
            read -p $'\033[93mEnter your Elanak username: \033[0m' elanak_username
            read -p $'\033[93mEnter your Elanak password: \033[0m' elanak_password

            python_file_name="notifire_elanak_$(echo $ip_address | tr -d '.')".py

            cat > $python_file_name << EOF
#!/usr/bin/env python

import os
import time
import subprocess
import requests

class PingService:
    def __init__(self, sender_number, number, elanak_username, elanak_password, ip_address):
        self.sender_number = sender_number
        self.number = number
        self.elanak_username = elanak_username
        self.elanak_password = elanak_password
        self.ip_address = ip_address

    def _send_sms(self):
        url = f"http://payammatni.com/webservice/url/send.php?method=sendsms&format=json&from={self.sender_number}&to={self.number}&text=Warning!%20Your%20Service%20on%20{self.ip_address}%20is%20Down.&type=0&username={self.elanak_username}&password={self.elanak_password}"
        try:
            response = requests.get(url)
            print(response.text)
        except Exception as e:
            print(e)

    def _ping_ip(self):
        response = os.system(f"ping -c 1 {self.ip_address}")
        if response != 0:
            self._send_sms()

    def _create_service_config(self):
        service_config = f'''
[Unit]
Description=Ping Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/python {__file__}
Restart=always

[Install]
WantedBy=multi-user.target
'''
        with open('/etc/systemd/system/ping_service.service', 'w') as f:
            f.write(service_config)

    def _start_service(self):
        os.system('systemctl daemon-reload')
        os.system('systemctl start ping_service')

    def run(self):
        self._create_service_config()
        self._start_service()
        while True:
            self._ping_ip()
            time.sleep(60)

if __name__ == '__main__':
    service = PingService('$sender_number', '$number', '$elanak_username', '$elanak_password', '$ip_address')
    service.run()
EOF

            clear
            echo "Your Notifier saved in $PWD/$python_file_name"
            echo "To run it, use the following commands:"
            echo "python3 $python_file_name"
            ;;
        3)
            ip_address=$(get_current_ip)
            read -p $'\033[92mIs this the IP of your server? ('$ip_address') (y/n):\033[0m ' response
            if [[ $response != "y" && $response != "yes" ]]; then
                read -p $'\033[94mEnter the IP address of your server: \033[0m' ip_address
            fi

            read -p $'\033[95mEnter your API key: \033[0m' api_key
            read -p $'\033[96mEnter the number to send SMS to (in the format 09******): \033[0m' number
            read -p $'\033[93mEnter the sender number (optional): \033[0m' sender_number
            read -p $'\033[92mEnter a name for this service: \033[0m' service_name

            python_file_name="notifire_ippanel_$(echo $service_name | tr -d '.')".py

            cat > $python_file_name << EOF
#!/usr/bin/env python

import os
import time
import subprocess
from ippanel import HTTPError, Error, ResponseCode

class PingService:
    def __init__(self, api_key, number, sender_number, ip_address, service_name):
        self.api_key = api_key
        self.number = number
        self.sender_number = sender_number
        self.ip_address = ip_address
        self.service_name = service_name
        self.sms = Client(self.api_key)

    def _send_sms(self):
        try:
            message_id = self.sms.send(self.sender_number, self.number, "message")
        except Error as e:
            print(f"Error handled => code: {e.code}, message: {e.message}")
            if e.code == ResponseCode.ErrUnprocessableEntity.value:
                for field in e.message:
                    print(f"Field: {field} , Errors: {e.message[field]}")
        except HTTPError as e:
            print(f"Error handled => code: {e}")

    def _ping_ip(self):
        response = os.system(f"ping -c 1 {self.ip_address}")
        if response != 0:
            self._send_sms()

    def _create_service_config(self):
        service_config = f'''
[Unit]
Description=Ping Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/python {__file__}
Restart=always

[Install]
WantedBy=multi-user.target
'''
        with open('/etc/systemd/system/ping_service.service', 'w') as f:
            f.write(service_config)

    def _start_service(self):
        os.system('systemctl daemon-reload')
        os.system('systemctl start ping_service')

    def run(self):
        self._create_service_config()
        self._start_service()
        while True:
            self._ping_ip()
            time.sleep(60)

if __name__ == '__main__':
    try:
        from kavenegar import *
    except ImportError:
        try:
            subprocess.check_call(['pip', 'install', 'kavenegar'])
        except:
            try:
                subprocess.check_call(['pip3', 'install', 'kavenegar'])
            except Exception as e:
                print(e)

    service = PingService('$api_key', '$number', '$sender_number', '$ip_address', '$service_name')
    service.run()
EOF
            clear
            echo "Your Notifier saved in $PWD/$python_file_name"
            echo "To run it, use the following commands:"
            echo "pip3 install ippanel"
            echo "python3 $python_file_name"
            ;;
        *)
            echo -e "\033[91mInvalid choice. Please enter a number from 1 to 2.\033[0m"
            ;;
    esac
}

panel_installer() {
    clear
    echo -e "\033[96mInstall VPN Selling Bot\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Install XSSH Panel/Bot\033[0m"
    echo -e "\033[94m2. Install WizWiz XUI Panel\033[0m"
    echo -e "\033[91m3. Back\033[0m"
    read -p $'\033[93mEnter the number of your choice: \033[0m' bot_choice

    case $bot_choice in
        1)
            bash <(curl -Ls https://raw.githubusercontent.com/Am-Delta/xssh/master/install.sh)
            ;;
        2)
            wizwiz_panel_installer
            ;;
        3)
            main_menu
            ;;
        *)
            echo -e "\033[91mInvalid choice. Please enter a number from 1 to 3.\033[0m"
            ;;
    esac
    main_menu
}

wizwiz_panel_installer() {
    clear
    echo -e "\033[94mWizWiz XUI Panel Installer\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Install\033[0m"
    echo -e "\033[95m2. Update\033[0m"
    echo -e "\033[96m3. Tutorial\033[0m"
    echo -e "\033[91m4. Back\033[0m"
    read -p $'\033[93mEnter the number of your choice: \033[0m' wizwiz_choice

    case $wizwiz_choice in
        1)
            bash <(curl -s https://raw.githubusercontent.com/wizwizdev/wizwizxui-timebot/main/wizwiz.sh)
            ;;
        2)
            bash <(curl -s https://raw.githubusercontent.com/wizwizdev/wizwizxui-timebot/main/update.sh)
            ;;
        3)
            echo -e "\033[93mTutorial:\033[0m"
            echo "If your server does not have root access, please grant root access with \"sudo -i\" command and then install"
            echo "Create a bot in @botfather and /start it"
            echo "The first option asks you for a domain, you must set the ip server for the domain and then enter it according to the example"
            echo "First enter \"sub.domain.com\" or \"domain.com\" without https"
            echo "Enter email"
            echo "Enter y"
            echo "Enter 2"
            echo "Enter username database"
            echo "Enter password database"
            echo "Enter token"
            echo "Enter Numerical ID of admin from @userinfobot"
            echo "Re-enter \"sub.domain.com\" or \"domain.com\" without https"
            echo "Very good, the installation message ( ✅ The wizwiz bot has been successfully installed! ) is sent to the bot"
            read -p $'\033[93mPress Enter to continue... \033[0m'
            wizwiz_panel_installer
            ;;
        4)
            clear
            panel_installer
            ;;
        *)
            echo -e "\033[91mInvalid choice. Please enter a number from 1 to 4.\033[0m"
            ;;
    esac
}

install_menu() {
    clear
    echo -e "\033[94mInstall Menu\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. 6to4\033[0m"
    echo -e "\033[91m2. iptables\033[0m"
    echo -e "\033[94m3. WireGuard\033[0m"
    echo -e "\033[90m4. Back\033[0m"
    echo -e "\033[37mEnter your choice: \033[0m"
    read -r tunnel_type

    if [[ $tunnel_type != "1" && $tunnel_type != "2" && $tunnel_type != "3" && $tunnel_type != "4" ]]; then
        echo -e "\033[91mInvalid tunnel type. Please enter '1', '2', '3', or '4' to back.\033[0m"
        return
    fi

    if [[ $tunnel_type == "1" ]]; then
        tunnel_type="6to4"
    elif [[ $tunnel_type == "2" ]]; then
        tunnel_type="iptables"
    elif [[ $tunnel_type == "3" ]]; then
        tunnel_type="wireguard"
        clear
        read -p $'\033[93mEnter iran IP: \033[0m' iran_ip
        read -p $'\033[93mEnter password: \033[0m' password
        install_tunnel "$iran_ip" "" "iran" "$tunnel_type" "$password"
        main_menu
        return
    elif [[ $tunnel_type == "4" ]]; then
        main_menu
        return
    fi

    echo -e "\033[93mSelect your server type:\n\033[92m1. Iran\033[0m\n\033[91m2. Foreign\033[0m\n\033[91m3. Back\033[0m\nEnter the number of your server type: "
    read -r server_type

    if [[ $server_type != "1" && $server_type != "2" && $server_type != "3" ]]; then
        echo -e "\033[91mInvalid server type. Please enter '1', '2', or '3'.\033[0m"
        return
    fi

    if [[ $server_type == "1" ]]; then
        server_type="iran"
        iran_ip=$(get_current_ip)
        echo -e "\033[93mIran server IP address: $iran_ip\033[0m"
        read -p $'\033[93mEnter Foreign server IP address: \033[0m' foreign_ip
    elif [[ $server_type == "2" ]]; then
        server_type="foreign"
        foreign_ip=$(get_current_ip)
        echo -e "\033[93mForeign server IP address: $foreign_ip\033[0m"
        read -p $'\033[93mEnter Iran server IP address: \033[0m' iran_ip
    elif [[ $server_type == "3" ]]; then
        install_menu
        return
    fi

    install_tunnel "$iran_ip" "$foreign_ip" "$server_type" "$tunnel_type"
    main_menu
}

uninstall_menu() {
    clear
    echo -e "\033[94mUninstall Menu\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Iran\033[0m"
    echo -e "\033[91m2. Foreign\033[0m"
    echo -e "\033[91m3. Back\033[0m"
    read -r server_type

    if [[ $server_type != "1" && $server_type != "2" && $server_type != "3" ]]; then
        echo -e "\033[91mInvalid server type. Please enter '1', '2', or '3'.\033[0m"
        return
    fi

    if [[ $server_type == "1" ]]; then
        server_type="iran"
    elif [[ $server_type == "2" ]]; then
        server_type="foreign"
    elif [[ $server_type == "3" ]]; then
        main_menu
        return
    fi

    uninstall_tunnel "$server_type"
    main_menu
}

scripts_menu() {
    clear
    echo -e "\033[94mScripts Menu\033[0m"
    echo -e "\033[93m-----------------------------------------\033[0m"
    echo -e "\033[92m1. Install Sanaie Script\033[0m"
    echo -e "\033[34m2. Install Alireza Script\033[0m"
    echo -e "\033[36m3. Install Ghost Script\033[0m"
    echo -e "\033[33m4. Install PFTUN Script\033[0m"
    echo -e "\033[35m5. Install Reverse Script\033[0m"
    echo -e "\033[34m6. Install IR-ISPBLOCKER Script\033[0m"
    echo -e "\033[91m6. Back\033[0m"

    read -p $'\033[93mEnter the number of your choice: \033[0m' script_choice

    case $script_choice in
        1)
            install_sanaie_script
            ;;
        2)
            install_alireza_script
            ;;
        3)
            install_ghost_script
            ;;
        4)
            install_pftun_script
            ;;
        5)
            install_reverse_script
            ;;
        6)
            install_ispblocker_script
            ;;
        7)
            main_menu
            ;;
        *)
            echo -e "\033[91mInvalid choice. Please enter a number from 1 to 6.\033[0m"
            ;;
    esac
    main_menu
}

main_menu