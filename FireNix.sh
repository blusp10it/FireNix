#!/bin/bash
#------------------------------COPYRIGHT------------------------------#
# FireNix Versi 0.3 R1 (Configure your network in interactive shell)
# Copyright (C) 2012 Krisan Alfa Timur A.K.A blusp10it (=
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------COPYRIGHT------------------------------#

trap cleanup INT
versi="0.3 R1"
copyright="By blusp10it"
os=""
#------------------------------AKSI DALAM TERMINAL------------------------------#
aksi() {
error="free"
if [ -z "$1" ] || [ -z "$2" ] ; then error="1" ; fi # Inisialisasi kode error
if [ "$error" == "free" ] ; then
     xterm="xterm"
     command="$2"
     $xterm -geometry 100x15+0+0 -T "FireNix versi $versi - $1" -e "$command" > /dev/null # line+x+y
     return 0
else
     echo -e "ERROR *_*"
     return 1
fi
}

cekdist() {
#------------------------------Debian------------------------------#
if [ -e "/etc/lsb-release" ] ; then
     command=$(cat /etc/lsb-release | grep DISTRIB_ID | sed "s/DISTRIB_ID=//")
#------------------------------RHEL/Fedora/CentOS------------------------------#
elif [ -e "/etc/system-release" ] ; then
     command=$(cat /etc/system-release | grep Fedora | awk '{print $1}')
fi

#------------------------------Set Variabel OS------------------------------#
if [ "$command" == "BackTrack" ] ; then
     os="debian"
     tampil info "Distro = BackTrack =< 4.x "
     sleep 2
elif [ "$command" == "Ubuntu" ] ; then
     os="debian"
     tampil info "Distro = Debian / Ubuntu / BackTrack >= 5.x "
     sleep 2
elif [ "$command" == "Fedora" ] ; then
     os="rhel"
     tampil info "Distro = Fedora / RHEL / CentOS"
     sleep 2
else
     tampil error "Terjadi kesalahan, kami tidak bisa menemukan Distro yang kamu gunakan :("
     tampil info "Untuk membantu developer dalam mengembangkan script ini lakukan langkah berikut:"
     echo -e "1. Copy-Paste hasil output perintah [cat /etc/*-release && cat /etc/issue && uname -a]
2. Kirimkan hasil output ke email : blusp10it@gmail.com
3. Kirimkan email dengan subject 'CEKDIST_SUBMIT'"
     exit 0
fi
}
#------------------------------TAMPILAN PESAN------------------------------#
tampil() {
error="free"
if [ -z "$1" ] || [ -z "$2" ] ; then error="1" ; fi # Inisialisasi kode error
if [ "$1" != "aksi" ] && [ "$1" != "info" ] && [ "$1" != "error" ] ; then error="5"; fi
if [ "$error" == "free" ] ; then
     keluaran=""
     if [ "$1" == "aksi" ] ; then keluaran="\e[01;32m[>]\e[00m" ; fi
     if [ "$1" == "info" ] ; then keluaran="\e[01;33m[i]\e[00m" ; fi
     if [ "$1" == "error" ] ; then keluaran="\e[01;31m[!]\e[00m" ; fi
     keluaran="$keluaran $2"
     echo -e "$keluaran"
     if [ "$3" == "true" ] ; then
          if [ "$1" == "aksi" ] ; then keluaran="[>]" ; fi
          if [ "$1" == "info" ] ; then keluaran="[i]" ; fi
          if [ "$1" == "error" ] ; then keluaran="[-]" ; fi
     fi
     return 0
else
     tampil error "Error *_*"
     return 1
fi
}

#------------------------------CLEANUP------------------------------#
cleanup () {
clear
echo -e "#------------------------------CLEANUP------------------------------#"
tampil aksi "Exiting ..."
if [ -e "/tmp/iface.tmp" ] ; then
     tampil aksi "Menghapus temporary file ..."
     aksi "Clean up" " rm -fv /tmp/iface.tmp"
fi
if [ -e "/tmp/arp.tmp" ] ; then
     tampil aksi "Menghapus temporary file ..."
     aksi "Clean up" " rm -fv /tmp/arp.tmp"
fi
if [ -e "/tmp/netstat.tmp" ] ; then
     tampil aksi "Menghapus temporary file ..."
     aksi "Clean up" "rm -fv /tmp/netstat.tmp"
fi
sleep 1
exit 0
}

#------------------------------CREDITS------------------------------#
credits () {
clear
loopcr="true"
echo -e "#------------------------------CREDITS------------------------------#"
echo -e "             $copyright --- IPTables by Toba Pramudia"
echo -e "#-------------------------------------------------------------------#"
while [ $loopcr != "false" ] ; do
     echo -en "Tekan 'Enter' untuk melanjutkan "
     read keystroke
     if [ "$keystroke" == "" ] ; then
          echo ""
          loopcr="false"
     else
          tampil error "Pilihan tidak valid"
          sleep 1
          loopcr="true"
     fi
done
}
#------------------------------MEMASANG IPTABLES------------------------------#
pasang () {
clear
tampil aksi "Mengecek IPTABLES"
if [ "$os" == "debian" ] ; then
     cekiptables=( $(dpkg -l | awk '{print $2}' | grep iptables) )
     if [ $cekiptables != "iptables" ] ; then
          tampil error "IPTABLES belum terinstall"
          loopip="true"
          while [ $loopip != "false" ] ; do
               read -p "[?] Apakah kamu mau menginstall paket IPTables? [y/n] "
               if [ $REPLY == "y" ] ; then
                    tampil aksi "apt-get update"
                    aksi "UPDATING" "apt-get update" "true"
                    tampil aksi "apt-get install iptables -y"
                    aksi "Install IPTABLES" "apt-get install iptables -y" "true"
                    tampil info "Done"
                    loopip="false"
               elif [ $REPLY == "n" ] ; then
                    tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
                    sleep 2
                    loopip="false"
               else
                    tampil error "Pilihan tidak valid [$REPLY]"
                    fi
          done
     else
          echo -e "#------------------------------MEMASANG IPTABLES------------------------------#"
          iptables="iptables -A INPUT -p icmp -m icmp --icmp-type"
          tampil aksi "Memasang firewall ..."
          aksi "Memasang Firewall" "iptables --flush
          iptables -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type parameter-problem -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type redirect -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type router-advertisement -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type router-solicitation -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type source-quench -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type time-exceeded -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
          iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
          sleep 2" "true"
          tampil info "Berhasil memasang firewall"
          sleep 1
    fi
elif [ "$os" == "rhel" ] ; then
     cekiptables="rpm -qa | grep iptables | awk 'FNR == 2 {print}'"
     if [ "$cekiptables" == "" ] ; then
          tampil error "IPTABLES belum terinstall"
          tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
          sleep 3
     else
          echo -e "#------------------------------MEMASANG IPTABLES------------------------------#"
          iptables="iptables -A INPUT -p icmp -m icmp --icmp-type"
          tampil aksi "Memasang firewall ..."
          aksi "Memasang Firewall" "iptables --flush
          iptables -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type parameter-problem -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type redirect -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type router-advertisement -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type router-solicitation -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type source-quench -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -p icmp -m icmp --icmp-type time-exceeded -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
          iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
          iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
          sleep 2" "true"
          tampil info "Berhasil memasang firewall"
          sleep 1
     fi
fi
}

#------------------------------RESET IPTABLES (FLUSH)------------------------------#
reset () {
clear
tampil aksi "Mengecek IPTABLES"
sleep 1
if [ $os == "debian" ] ; then
     cekiptables=( $(dpkg -l | awk '{print $2}' | grep iptables) )
     if [ $cekiptables != "iptables" ] ; then
          tampil error "IPTABLES belum terinstall"
          loopip="true"
          while [ $loopip != "false" ] ; do
               read -p "[?] Apakah kamu mau menginstall paket IPTables? [y/n] "
               if [ $REPLY == "y" ] ; then
                    tampil aksi "apt-get update"
                    aksi "UPDATING" "apt-get update" "true"
                    tampil aksi "apt-get install iptables -y"
                    aksi "Install IPTABLES" "apt-get install iptables -y" "true"
                    tampil info "Done"
                    loopip="false"
               elif [ $REPLY == "n" ] ; then
                    tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
                    sleep 2
                    loopip="false"
               else
                    tampil error "Pilihan tidak valid [$REPLY]"
               fi
          done
     else
          echo -e "#------------------------------RESET IPTABLES (FLUSH)------------------------------#"
          tampil aksi "Mereset firewall ..."
          aksi "Reset Firewall" "iptables --flush && sleep 2" "true"
          sleep 1
          aksi "Reset ArpTables" "arptables --flush && sleep 2" "true"
          sleep 1
          tampil info "Berhasil mereset firewall"
          sleep 1
     fi
elif [ "$os" == "rhel" ] ; then
     cekiptables="rpm -qa | grep iptables | awk 'FNR == 2 {print}'"
     if [ "$cekiptables" == "" ] ; then
          tampil error "IPTABLES belum terinstall"
          tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
          sleep 3
     else
          echo -e "#------------------------------RESET IPTABLES (FLUSH)------------------------------#"
          tampil aksi "Mereset firewall ..."
          aksi "Reset Firewall" "iptables --flush && sleep 2" "true"
          sleep 1
          aksi "Reset ArpTables" "arptables --flush && sleep 2" "true"
          sleep 1
          tampil info "Berhasil mereset firewall"
          sleep 1
     fi
fi
}

#------------------------------MEMBACA STATUS IPTABLES------------------------------#
status () {
clear
tampil aksi "Mengecek IPTABLES"
sleep 1
if [ "$os" == "debian" ] ; then
     cekiptables=( $(dpkg -l | awk '{print $2}' | grep iptables) )
fi
if [ "$cekiptables" != "iptables" ] ; then
     tampil error "IPTABLES belum terinstall"
     loopip="true"
     while [ $loopip != "false" ] ; do
          read -p "[?] Apakah kamu mau menginstall paket IPTables? [y/n] "
          if [ $REPLY == "y" ] ; then
               tampil aksi "apt-get update"
               aksi "UPDATING" "apt-get update" "true"
               tampil aksi "apt-get install iptables -y"
               aksi "Install IPTABLES" "apt-get install iptables -y" "true"
               tampil info "Done"
               loopip="false"
          elif [ $REPLY == "n" ] ; then
               tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
               sleep 2
               loopip="false"
          else
               tampil error "Pilihan tidak valid [$REPLY]"
          fi
     done
else
     echo -e "                   #------------------------------MEMBACA STATUS IPTABLES------------------------------#"
     echo -e "#--------------------------------------------------------------------------------------------------------------------------#"
     iptables --list
     loopStatus="true"
     while [ $loopStatus != "false" ] ; do
          echo -e "#--------------------------------------------------------------------------------------------------------------------------#"
          read -p "[?] Tekan 'Enter' untuk melanjutkan "
          if [ "$REPLY" == "" ] ; then
               loopStatus="false"
          else
               tampil error "Pilihan tidak dikenali" 1>&2
               loopStatus="true"
          fi
     done
fi
}

#------------------------------BLOCK IP------------------------------#
block () {
clear
tampil aksi "Mengecek IPTABLES dan ARPTables"
sleep 2
if [ $os == "debian" ] ; then
     cekarptables=( $(dpkg -l | awk '{print $2}' | grep arptables) )
     cekiptables=( $(dpkg -l | awk '{print $2}' | grep iptables) )
     if [ $cekarptables != "arptables" ] ; then
          tampil error "ARPTABLES belum terinstall"
          looparp="true"
          while [ $looparp != "false" ] ; do
               read -p "[?] Apakah kamu mau menginstall paket ARPTables? [y/n] "
               if [ $REPLY == "y" ] ; then
                    tampil aksi "apt-get update"
                    aksi "UPDATING" "apt-get update" "true"
                    tampil aksi "apt-get install arptables -y"
                    aksi "Install ARPTABLES" "apt-get install arptables -y" "true"
                    tampil info "Done"
                    looparp="false"
               elif [ $REPLY == "n" ] ; then
                    tampil info "Pastikan kamu sudah menginstall paket ARPTables sebelum memilih menu ini"
                    sleep 2
                    looparp="false"
               else
                    tampil error "Pilihan tidak valid [$REPLY]"
               fi
          done
     elif [ $cekiptables != "iptables" ] ; then
          tampil error "IPTABLES belum terinstall"
          loopip="true"
          while [ $loopip != "false" ] ; do
               read -p "[?] Apakah kamu mau menginstall paket IPTables? [y/n] "
               if [ $REPLY == "y" ] ; then
                    tampil aksi "apt-get update"
                    aksi "UPDATING" "apt-get update" "true"
                    tampil aksi "apt-get install iptables -y"
                    aksi "Install IPTABLES" "apt-get install iptables -y" "true"
                    tampil info "Done"
                    loopip="false"
               elif [ $REPLY == "n" ] ; then
                    tampil info "Pastikan kamu sudah menginstall paket IPTables sebelum memilih menu ini"
                    sleep 2
                    loopip="false"
               else
                    tampil error "Pilihan tidak valid [$REPLY]"
               fi
          done
     #------------------------------Memilih interface------------------------------#
     else
          echo -e "#------------------------------BLOCK IP------------------------------#"
          tampil info "Berikut adalah daftar interface yang sedang aktif (up)"
          ifconfig | grep "Link encap" | awk '{print $1}' > /tmp/iface.tmp
          arrayInterface=( $(cat /tmp/iface.tmp) )
          namaInterface=""
          id=""
          index="0"
          loop=${#arrayInterface[@]}
          loopSub="false"
          for item in "${arrayInterface[@]}"; do
               if [ "$namaInterface" ] && [ "$namaInterface" == "$item" ] ; then id="$index" ; fi
               index=$(($index+1))
          done
          echo -e "  No | Interface |\n-----|-----------|"
          for (( i=0;i<$loop;i++)); do
               printf ' %-3s | %-9s |\n' "$(($i+1))" "${arrayInterface[${i}]}"
               echo "$(($i+1))" "${arrayInterface[${i}]}" >> /tmp/interface
          done
          while [ "$loopSub" != "true" ] ; do
               read -p "[~] E[x]it atau pilih nomor tabel Interface: "
               if [ "$REPLY" == "x" ] ; then cleanup
               elif [ -z $(echo "$REPLY" | tr -dc '[:digit:]'l) ] ; then tampil error "Pilihan tidak valid, $REPLY" 1>&2
               elif [ "$REPLY" -lt 1 ] || [ "$REPLY" -gt $loop ] ; then tampil error "Nomor tidak valid, $REPLY" 1>&2
               else id="$(($REPLY-1))" ; loopSub="true" ; loopMain="true"
               fi
          done
          interface="${arrayInterface[$id]}"
          tampil info "Interface = $interface"
          sleep 1
          #------------------------------Blocking------------------------------#
          IProute=$(ifconfig $interface | grep "inet addr" | awk '{print $2}' | sed 's/addr://')
          tampil info "IP address router kamu adalah: $IProute"
          tampil aksi "Scanning ARP packet ..."
          aksi "Scanning ARP" "arp -i $interface >> /tmp/arp.tmp" "true"
          tampil info "Berikut adalah hasil scanning: "
          cat /tmp/arp.tmp
          read -p "Ingin melanjutkan proses pemblokiran? [y/n] "
          loopBlock="true" # Karena variable di pasang sebagai true, maka proses loop akan terus terjadi
          while [ "$loopBlock" != "false" ] ; do
               if [ "$REPLY" == "y" ] ; then
                    echo -en "[?] Masukkan IP yang ingin kamu blok: "
                    read ip
                    tampil aksi "Memblokir IP $ip ..."
                    aksi "Memblokir IP attacker" "iptables -A INPUT -s $ip -j DROP 
                    iptables -A OUTPUT -p tcp -d $ip -j DROP
                    sleep 1" "true"
                    tampil info "Berhasil memblokir IP address attacker [$ip]"
                    echo -en "[?] Masukkan mac address yang ingin kamu blok: "
                    read mac
                    tampil aksi "Memblokir mac address $mac ..."
                    aksi "Memblokir mac address attacker" "arptables -A INPUT --source-mac $mac -j DROP
                    arptables -A OUTPUT -p tcp --destination-mac $mac -j DROP
                    sleep 1" "true"
                    tampil info "Berhasil memblokir mac address attacker [$mac]"
                    tampil aksi "Refreshing interface $interface"
                    aksi "Refreshing interface" "ifconfig $interface down && ifconfig $interface down && sleep 1" "true"
                    tampil info "Berhasil refresh, silahkan koneksikan ulang network kamu"
                    sleep 3
                    loopBlock="false" # Menghentikan proses looping
               elif [ "$REPLY" == "n" ] ; then
                    loopBlock="false" # Menghentikan proses looping
               else
                    tampil error "Pilihan tidak valid [$REPLY] (y/n)"
                    loopBlock="true" # Proses looping masih berlanjut
               fi
          done
     fi
elif [ "$os" == "rhel" ] ; then
     cekiptables=( $(rpm -qa | grep iptables | awk 'FNR == 2 {print}') )
     cekarptables=( $(rpm -qa | grep arptables | awk 'FNR == 2 {print}') )
     if [ "$cekarptables" == "" ] ; then
          tampil error "ARPTABLES belum terinstall"
          tampil info "Pastikan kamu sudah menginstall paket arptables sebelum memilih menu ini"
     elif [ "$cekiptables" == "" ] ; then
          tampil error "IPTABLES belum terinstall"
          tampil info "Pastikan kamu sudah menginstall paket arptables sebelum memilih menu ini"
     else
          #------------------------------Memilih interface------------------------------#
          echo -e "#------------------------------BLOCK IP------------------------------#"
          tampil info "Berikut adalah daftar interface yang sedang aktif (up)"
          ifconfig | grep "Link encap" | awk '{print $1}' > /tmp/iface.tmp
          arrayInterface=( $(cat /tmp/iface.tmp) )
          namaInterface=""
          id=""
          index="0"
          loop=${#arrayInterface[@]}
          loopSub="false"
          for item in "${arrayInterface[@]}"; do
               if [ "$namaInterface" ] && [ "$namaInterface" == "$item" ] ; then id="$index" ; fi
               index=$(($index+1))
          done
          echo -e "  No | Interface |\n-----|-----------|"
          for (( i=0;i<$loop;i++)); do
               printf ' %-3s | %-9s |\n' "$(($i+1))" "${arrayInterface[${i}]}"
               echo "$(($i+1))" "${arrayInterface[${i}]}" >> /tmp/interface
          done
          while [ "$loopSub" != "true" ] ; do
               read -p "[~] E[x]it atau pilih nomor tabel Interface: "
               if [ "$REPLY" == "x" ] ; then cleanup
               elif [ -z $(echo "$REPLY" | tr -dc '[:digit:]'l) ] ; then tampil error "Pilihan tidak valid, $REPLY" 1>&2
               elif [ "$REPLY" -lt 1 ] || [ "$REPLY" -gt $loop ] ; then tampil error "Nomor tidak valid, $REPLY" 1>&2
               else id="$(($REPLY-1))" ; loopSub="true" ; loopMain="true"
               fi
          done
          interface="${arrayInterface[$id]}"
          tampil info "Interface = $interface"
          sleep 1
          #------------------------------Blocking------------------------------#
          IProute=$(ifconfig $interface | grep "inet addr" | awk '{print $2}' | sed 's/addr://')
          tampil info "IP address router kamu adalah: $IProute"
          tampil aksi "Scanning ARP packet ..."
          aksi "Scanning ARP" "arp -i $interface >> /tmp/arp.tmp" "true"
          tampil info "Berikut adalah hasil scanning: "
          cat /tmp/arp.tmp
          loopBlock="true" # Karena variable di pasang sebagai true, maka proses loop akan terus terjadi
          while [ "$loopBlock" != "false" ] ; do
               echo -en "Ingin melanjutkan proses pemblokiran? [y/n] "
               read pilihan
               if [ "$pilihan" == "y" ] ; then
                    echo -en "[?] Masukkan IP yang ingin kamu blok: "
                    read ip
                    tampil aksi "Memblokir IP $ip ..."
                    aksi "Memblokir IP attacker" "iptables -A INPUT -s $ip -j DROP 
                    iptables -A OUTPUT -p tcp -d $ip -j DROP
                    sleep 1" "true"
                    tampil info "Berhasil memblokir IP address attacker [$ip]"
                    echo -en "[?] Masukkan mac address yang ingin kamu blok: "
                    read mac
                    tampil aksi "Memblokir mac address $mac ..."
                    aksi "Memblokir mac address attacker" "arptables -A INPUT --source-mac $mac -j DROP
                    arptables -A OUTPUT -p tcp --destination-mac $mac -j DROP
                    sleep 1" "true"
                    tampil info "Berhasil memblokir mac address attacker [$mac]"
                    tampil aksi "Refreshing interface $interface"
                    aksi "Refreshing interface" "ifconfig $interface down && ifconfig $interface down && sleep 1" "true"
                    tampil info "Berhasil refresh, silahkan koneksikan ulang network kamu"
                    sleep 3
                    loopBlock="false" # Menghentikan proses looping
               elif [ "$pilihan" == "n" ] ; then
                    loopBlock="false" # Menghentikan proses looping
               else
                    tampil error "Pilihan tidak valid [$REPLY] (y/n)"
                    loopBlock="true" # Proses looping masih berlanjut
               fi
          done
     fi
fi
}

tutupPort () {
echo -e "#------------------------------Tutup PORT------------------------------#"
id=""
index="0"
loopMain="true"
while [ $loopMain != "false" ] ; do
     netstat -lpn | grep -w "tcp" > /tmp/netstat.tmp
     arrayProto=( $(cat /tmp/netstat.tmp | awk '{print $1}') )
     arrayPort=( $(cat /tmp/netstat.tmp | awk '{print $4}' | sed "s/0.0.0.0://") )
     arrayState=( $(cat /tmp/netstat.tmp | awk '{print $6}') )
     arrayNamaProses=( $(cat /tmp/netstat.tmp | awk '{print $7}' | sed "s/.*\///") )
     arrayPID=( $(cat /tmp/netstat.tmp | awk '{print $7}' | sed "s/\/.*//") )
     cekcek=( $(netstat -lpn | grep -w "tcp") )
     if [ "$cekcek" == "" ] ; then
          tampil info "Tidak ada port yang terbuka..." 1>&2
          loopMain="false"
          sleep 3
     else
          for item in "${arrayNamaProses[@]}"; do
               if [ "$namaproses" ] && [ "$namaproses" == "$item" ] ; then id="$index" ; fi
               index=$(($index+1))
          done
          tampil info "Berikut adalah daftar port yang terbuka"
          echo -e " No. | Proto | Port | Status | Nama Proses |  PID  \n-----|-------|------|--------|-------------|------"
          loop=${#arrayNamaProses[@]}
          for (( i=0;i<$loop;i++)); do
                    printf ' %-3s | %-5s | %-4s | %-6s | %-11s | %-2s\n' "$(($i+1))" "${arrayProto[${i}]}" "${arrayPort[${i}]}" "${arrayState[${i}]}" "${arrayNamaProses[${i}]}" "${arrayPID[${i}]}"
          done
          loopSub="true"
          while [ $loopSub != "false" ] ; do
               echo -e "--------------------------------------------------"
               read -p "E[x]it, [r]efresh, kem[b]ali ke menu utama, atau pilih nomor yang akan ditutup: "
               if [ $REPLY == "x" ] ; then
                    cleanup
               elif [ $REPLY == "r" ] ; then
                    tutupPort
               elif [ $REPLY == "b" ] ; then
                    loopMain="false"
                    loopSub="false"
               elif [ -z $(echo "$REPLY" | tr -dc '[:digit:]'l) ] ; then
                    tampil error "Pilihan tidak valid [$REPLY]" 1>&2
               elif [ "$REPLY" -lt 1 ] || [ "$REPLY" -gt $loop ] ; then
                    tampil error "Nomor tidak valid [$REPLY]" 1>&2
               else
                    id="$(($REPLY-1))"
                    loopSub="false"
                    loopMain="false"
                    proto="${arrayProto[id]}"
                    port="${arrayPort[$id]}"
                    state="${arrayState[id]}"
                    proses="${arrayNamaProses[id]}"
                    PID="${arrayPID[id]}"
                    tampil info "Warning!!!"
                    echo -e "--------------------------------------------------
Spesifikasi
$proses yang berjalan di port $port, memiliki PID $PID
PROTOCOL = $proto
   STATE = $state
akan DITUTUP!!!
--------------------------------------------------"
                    loopSure="true"
                    while [ $loopSure != "false" ] ; do
                         echo -en "[?] Anda yakin ingin melanjutkan? [y/n] "
                         read sure
                         if [ $sure == "y" ] ; then
                              tampil aksi "Menutup port"
                              aksi "Menutup port $port" "killall $proses && sleep 1" true
                              tampil info "Done (="
                              sleep 2
                              loopSure="false"
                         elif [ $sure == "n" ] ; then
                              tampil aksi "Mengembalikan ke menu utama ..."
                              loopSure="false"
                              sleep 1
                         else
                              tampil error "Pilihan tidak valid $sure"
                         fi
                    done
               fi
          done
     fi
done
}

#------------------------------PROGRAM BERJALAN------------------------------#
#------------------------------Cek ROOT access------------------------------#
tampil aksi "Checking root account..."
if [ $(whoami) != "root" ] ; then
     tampil error "Pastikan kamu menjalankan script ini sebagai root! Gunakan SUDO!"
     sleep 1
     exit 0
fi
#------------------------------Cek OS------------------------------#
tampil aksi "Checking distribution..."
cekdist
tampil info "Done"
sleep 1

#------------------------------Cek Xterm------------------------------#
if [ "$os" == "debian" ] ; then
     command=( $(dpkg -l | awk '{print $2}' | grep -w 'xterm') )
elif [ "$os" == "rhel" ] ; then
     command=( $(rpm -qa | grep -w 'xterm') )
fi
tampil aksi "Mengecek xterm"
sleep 1
if [ "$command" == "" ] ; then
     tampil error "XTERM tidak terinstall"
     if [ "$os" == "debian" ] ; then
          install=( $(apt-get -y install xterm) )
     elif [ "$os" == "rhel" ] ; then
          install=( $(yum install xterm -y) )
     fi
     loop="true"
     while [ "$loop" != "false" ] ; do
          read -p "[?] Apakah kamu mau menginstall xterm? [y/n] "
          if [ "$REPLY" == "y" ] ; then
               tampil aksi "Menginstall xterm"
               exec "$install"
               loop="false"
               tampil info "Done"
               sleep 1
          elif [ "$REPLY" == "n" ] ; then
               tampil error "Pastikan kamu sudah menginstall XTERM sebelum melanjutkan"
               sleep 1
               exit 0
               loop="false"
          else
               tampil error "Bad Input [$REPLY]"
               sleep 1
               loop="true"
          fi
     done
else
     tampil info "Done"
     sleep 1
fi

#------------------------------LOOPING------------------------------#
while : ; do
clear
cat << !
#--------------------------------FireNIX MENU--------------------------------#
                              FireNix Versi $versi
                                 $copyright
(1) Memasang firewall             --- Mengkonfigurasikan IPTables
(2) Me-reset settingan firewall   --- Menghapus setting-an IPTables
(3) Mengecek status firewall      --- Melakukan pengecekkan status IPTables
(4) Blocking IP Attacker          --- Escape from hacker
(5) Cek dan tutup port            --- Are there backdoors?
(6) Credits                       --- Behind the scene
(7) Exit                          --- Keluar dari program ini
#----------------------------------------------------------------------------#
!
     echo -en "[?] What do you want today? "
     read choice
     case $choice in
          1) pasang ;;
          2) reset ;;
          3) status ;;
          4) block ;;
          5) tutupPort ;;
          6) credits ;;
          7) cleanup ;;
          *) echo "Pilihan tidak valid [$choice]" && sleep 1 ;;
     esac
done
