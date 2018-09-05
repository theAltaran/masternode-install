# Pandemia install script for Ubuntu 16.04
VERSION="0.0.1"
NODEPORT='47666'
RPCPORT='47662'

# Useful variables
declare -r DATE_STAMP="$(date +%y-%m-%d-%s)"
declare -r SCRIPT_LOGFILE="/tmp/pandemia_node_${DATE_STAMP}_out.log"
declare -r SCRIPTPATH=$( cd $(dirname ${BASH_SOURCE[0]}) > /dev/null; pwd -P )


function print_greeting() {
  echo -e "\e[31m                         __    __                                   "
  echo -e "\e[31m                    _wr'''       ''-q_       "                      
  echo -e "\e[31m                 _dP                 9m_     "
  echo -e "\e[31m               _#P                     9#_                         "
  echo -e "\e[31m              d#@                       9#m                        "
  echo -e "\e[31m             d##                         ###                       "
  echo -e "\e[31m            J###                         ###L                      "
  echo -e "\e[31m            {###K                       J###K                      "
  echo -e "\e[31m            ]####K      ___aaa___      J####F                      "
  echo -e "\e[31m        __gmM######_  w#P""   ""9#m  _d#####Mmw__                  "
  echo -e "\e[31m     _g##############mZ_         __g##############m_               "
  echo -e "\e[31m   _d####M@PPPP@@M#######Mmp gm#########@@PP9@M####m_             "
  echo -e "\e[31m  a###""          ,Z #####@    @####\g             M##m            "
  echo -e "\e[31m J#@             0L   *##     ##@  J#               *#K           "
  echo -e "\e[31m #                #     _PANDM_~    dF               '#_          "
  echo -e "\e[31m7F                 #_   ]#####F   _dK                 JE          "
  echo -e "\e[31m]                    *m__ ##### __g@'                   F          "
  echo -e "\e[31m                       'PJ#####LP'                                 "
  echo -e "\e[31m '                       #######_                      '           "
  echo -e "\e[31m                       _0########_                                   "
  echo -e "\e[31m     .               _d#####^#####m__              ,              "
  echo -e "\e[31m      '*w_________am#####P'   ~9#####mw_________w*'                  "
  echo -e "\e[31m          ''9@#####@M''           ''P@#####@M''                    "
  echo -e "\e[0m"
}

function print_info() {
	echo -e "[0;35m Install scrypt version:[0m ${VERSION}"
	echo -e "[0;35m Date:[0m ${DATE_STAMP}"
	echo -e "[0;35m Logfile:[0m ${SCRIPT_LOGFILE}"
}

function install_packages() {
	echo "Install packages..."
	apt-get -y update &>> ${SCRIPT_LOGFILE}
	apt-get install -y software-properties-common dnsutils &>> ${SCRIPT_LOGFILE}
	add-apt-repository -yu ppa:bitcoin/bitcoin  &>> ${SCRIPT_LOGFILE}
	apt-get -y update &>> ${SCRIPT_LOGFILE}
	apt-get -y install wget make automake autoconf build-essential libtool autotools-dev \
	git nano python-virtualenv pwgen virtualenv \
	pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common \
	libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev &>> ${SCRIPT_LOGFILE}
	echo "Install done..."
}

function download_wallet() {
	echo "Downloading wallet..."
	mkdir /root/pandemia
	mkdir /root/.pandemia
	wget https://github.com/pandemiacoin/pandemia/releases/download/2.1.1.1/pandemia_ubuntu_16.04.tar.gz
	tar -zxvf pandemia_ubuntu_16.04.tar.gz
	rm pandemia_ubuntu_16.04.tar.gz
	echo "Done..."
}

function configure_masternode() {
	echo "Configuring masternode..."
	conffile=/root/.pandemia/pandemia.conf
	PASSWORD=`pwgen -1 20 -n` &>> ${SCRIPT_LOGFILE}
	WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
	if [ "x$PASSWORD" = "x" ]; then
	    PASSWORD=${WANIP}-`date +%s`
	fi
	echo "Loading and syncing wallet..."
	echo "    if you see *error: Could not locate RPC credentials* message, do not worry"
	/root/pandemia/pandemia-cli stop
	echo "It's okay :D"
	sleep 10
	echo -e "rpcuser=pandemiauser\nrpcpassword=${PASSWORD}\nrpcport=${RPCPORT}\nport=${NODEPORT}\nexternalip=${WANIP}\nlisten=1\nmaxconnections=250" >> ${conffile}
	echo ""
	echo -e "\e[31m=================================================================="
	echo -e "         PLEASE WAIT 1 MINUTE AND DON'T CLOSE THIS WINDOW"
	echo -e "==================================================================\e[0m"
	echo ""
	/root/pandemia/pandemiad -daemon
	echo "60 seconds left"
	sleep 10
	echo "50 seconds left"
	sleep 10
	echo "40 seconds left"
	sleep 10
	echo "30 seconds left"
	sleep 10
	echo "20 seconds left"
	sleep 10
	echo "10 seconds left"
	sleep 10
	masternodekey=$(/root/pandemia/pandemia-cli masternode genkey)
	/root/pandemia/pandemia-cli stop
	sleep 5
	echo "Creating masternode config..."
	echo -e "daemon=1\nmasternode=1\nmasternodeprivkey=$masternodekey" >> ${conffile}
	echo "Done...Starting daemon..."
	/root/pandemia/pandemiad -daemon
}

function addnodes() {
	echo "Adding nodes..."
	conffile=/root/.pandemia/pandemia.conf
	echo -e "\naddnode=5.189.228.166:47666" >> ${conffile}
	echo -e "addnode=95.213.191.188:47666"  >> ${conffile}
	echo -e "addnode=5.189.228.168:47666"   >> ${conffile}
	echo -e "addnode=31.184.252.68:47666"   >> ${conffile}
	echo -e "addnode=31.184.252.86:47666"   >> ${conffile}
	echo -e "addnode=31.184.252.85:47666"   >> ${conffile}
	echo -e "addnode=5.189.228.170:47666"   >> ${conffile}
	echo -e "addnode=92.53.67.44:47666"     >> ${conffile}
	echo -e "addnode=95.213.203.247:47666"  >> ${conffile}
	echo -e "addnode=5.188.41.254:47666\n"  >> ${conffile}
	echo "Done..."
}

function show_result() {
   echo ""
   echo -e "\e[31m==================================================================\e[0m"
   echo "DATE: ${DATE_STAMP}"
   echo "LOG: ${SCRIPT_LOGFILE}"
   echo ""
   echo -e "\e[31mMASTERNODE IP: ${WANIP}:${NODEPORT} \e[0m"
   echo -e "\e[31mMASTERNODE PRIVATE GENKEY: ${masternodekey} \e[0m"
   echo ""
   echo -e "You can check your masternode status on VPS with \e[31m/root/pandemia/pandemia-cli masternode status\e[0m command"
   echo -e "If you get \"Masternode not in masternode list\" status, don't worry,\nyou just have to start your MN from your local wallet and the status will change."
   echo -e "Now you need to add alias in your local wallet"
   echo -e "\e[31m==================================================================\e[0m"
}

function cronjob() {
	crontab -l > tempcron
	echo "@reboot /root/pandemia/pandemiad -daemon -reindex" > tempcron
	crontab tempcron
	rm tempcron
}

function cleanup() {
	echo "Cleanup..."
	apt-get -y autoremove 	&>> ${SCRIPT_LOGFILE}
	apt-get -y autoclean 		&>> ${SCRIPT_LOGFILE}
	echo "Done..."
}


# Main routine
print_greeting
print_info
install_packages
download_wallet
addnodes
configure_masternode
cronjob
show_result
cleanup
echo "All done!"