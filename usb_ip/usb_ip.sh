#!/usr/bin/env bash

KV_BASEDIR=$(dirname "$0")
KV_SCRIPT="${KV_BASEDIR}/"kv-sh

DB_DEFAULTS_DIR="" DB_DIR="/tmp/.kv-test" . "${KV_SCRIPT}"


function setup_usbip() {
    echo "Setting up USB IP"
    modprobe usbip_core
    modprobe usbip_host
    modprobe vhci-hcd
    usbipd -D
	echo ""
	echo ""
}

function set_server_ip(){
    echo ""
    echo "Getting the server IP: "
    kvset server_ip $1
    echo ""
    echo ""
}

function list_remote_devices() {
    echo "Listing Remote devices:"
    echo ""
    usbip list -r "$(kvget server_ip)"
    echo ""
    echo ""
}

function list_local_devices() {
    echo "Listing Local devices:"
    echo ""
    lsusb
    echo ""
	usbip list -l
    echo ""
    echo ""
}

function set_current_device(){
    echo ""
    echo "Getting the server IP: "
    kvset device $1
    echo ""
    echo ""
}

function bind_device() {
    echo "Binding the device bus: "
    echo ""
	usbip bind -b "$(kvget device)"
    echo ""
    echo ""
}

function unbind_device() {
    echo "Unbinding the device bus: "
    echo ""
	usbip unbind -b "$(kvget device)"
	echo ""
    echo ""
}

function attach_device() {
    echo ""
    echo "Ataching the device bus: "
    usbip attach -r "$(kvget server_ip)" -b "$(kvget device)"
    echo ""
    echo ""
}

function detach_device() {
    echo "Detaching the device port: "
    echo ""
	usbip detach -p "$(kvget device)"
	echo ""
    echo ""
}

function list_connected_devices() {
    echo "Listing connected devices: "
    echo ""
	usbip port
	echo ""
    echo ""
}

function clean() {
    #
    # Clean up
    #
    DB_DEFAULTS_DIR="" DB_DIR="/tmp/.kv-default" . "${KV_SCRIPT}"
    kvclear
    DB_DEFAULTS_DIR="" DB_DIR="/tmp/.kv-test" . "${KV_SCRIPT}"
    kvclear
}

usage() {
  cat - >&2 <<EOF
NAME
    usb_ip.sh - Configure and attach devices to USB IP
 
SYNOPSIS
    usb_ip.sh [-h|--help]
              [-s|--server_ip <arg>]
              [-i|--init_setup]
              [-r|--remote_devs]
              [-d|--local_devs]
              [-c|--current_device <arg>]
              [-u|--unbind]
              [-b|--bind]
              [-a|--attach]
              [-e|--dettach]
              [-t|--connected_devs]
              [--clean]

OPTIONS
  -h, --help
          Prints this and exits

  -s, --server_ip <arg>
          Set server ip.

  -i, --init_setup
        Setup usbip kernel modules and load daemon.

  -r, --remote_devs
        List remote devices.

  -d, --local_devs
        List local devices.

  -c, --current_device <arg>
        Set current device.

  -u, --unbind
        Unbind current device.

  -b, --bind
        Bind current device

  -a, --attach
        Attach current device.

  -e  --dettach
        Dettach device.

  -t  --connected_devs
        List connected devices.         

      --clean
      Erase device and ip cache.

EOF
}

fatal() {
    for i; do
        echo -e "${i}" >&2
    done
    exit 1
}

# For long option processing
next_arg() {
    if [[ $OPTARG == *=* ]]; then
        # for cases like '--opt=arg'
        OPTARG="${OPTARG#*=}"
    else
        # for cases like '--opt arg'
        OPTARG="${args[$OPTIND]}"
        OPTIND=$((OPTIND + 1))
    fi
}

# ':' means preceding option character expects one argument, except
# first ':' which make getopts run in silent mode. We handle errors with
# wildcard case catch. Long options are considered as the '-' character
optspec=":hsirdcubaetz:-:"
args=("" "$@")  # dummy first element so $1 and $args[1] are aligned
while getopts "$optspec" optchar; do
    case "$optchar" in
        h) usage; exit 0 ;;
        i) setup_usbip; exit 0 ;;
        s) set_server_ip "$OPTARG"; exit 0 ;;
        r) list_remote_devices; exit 0 ;;
        d) list_local_devices;  exit 0 ;;
        c) set_current_device "$OPTARG"; exit 0 ;;
        u) unbind_device; exit 0 ;;
        b) bind_device; exit 0 ;;
        a) attach_device; exit 0 ;;
        e) detach_device; exit 0 ;;
        t) list_connected_devices; exit 0 ;;
        -) # long option processing
            case "$OPTARG" in
                help)
                    usage; exit 0 ;;
                init_setup)
                    setup_usbip; exit 0 ;;
                server_ip|server_ip=*) next_arg
                    set_server_ip "$OPTARG";  exit 0 ;;
                remote_devs)
                    list_remote_devices; exit 0 ;;
                local_devs)
                    list_local_devices;  exit 0 ;;
                current_device|current_device=*) next_arg
                    set_current_device "$OPTARG"; exit 0 ;;
                unbind)
                    unbind_device; exit 0 ;;
                bind)
                    bind_device; exit 0 ;;
                attach)
                    attach_device; exit 0 ;;
                dettach)
                    detach_device; exit 0 ;;
                connected_devs)
                    list_connected_devices; exit 0 ;;
                clean) clean; exit 0 ;;
                -) break ;;
                *) fatal "Unknown option '--${OPTARG}'" "see '${0} --help' for usage" ;;
            esac
            ;;
        *) fatal "Unknown option: '-${OPTARG}'" "See '${0} --help' for usage" ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -eq 0 ]; then
    fatal "Expected at least one required argument FILE" \
    "See '${0} --help' for usage"
fi

echo " "
