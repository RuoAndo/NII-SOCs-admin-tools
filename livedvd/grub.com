cat <<EOF | tee /boot/grub/grub.cfg
	      set timeout=1
	      serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
	      terminal_input console serial
	      terminal_output console serial

	      menuentry 'ubuntu-live' {
	      linux /boot/vmlinuz-4.4.0-45-generic boot=live console=tty1 console=ttyS0,115200
	      initrd /boot/initrd.img-4.4.0-45-generic
	      }
EOF
