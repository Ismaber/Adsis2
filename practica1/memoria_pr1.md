# Práctica 1

## Configurar máquina base

Copiar los fichero o.qcow2 y o.xml y renombrarlos a od.qcow2 y od.xml.

Comprobar que od.qcow2 tenga permisos de grupo "rw".

Cambiar el path de source, la dirección MAC, el nombre de la máquina, y la uuid para que queden de la sihuiente manera:

```xml
<name>od</name>
<uuid>ecd3e45c-6426-432c-a700-fcdabb70d110</uuid>
<source file='/misc/alumnos/as2/as22022/a796902/od.qcow2'/>
<mac address='52:54:00:0d:11:01'/>
```

Definir la máquina en linbirt/kvm mediante el comando:

`virsh -c qemu:///system define od.xml`

Para eliminar la definición de la máquina, usar el comando:

`virsh -c qemu:///system undefine --domain od`

Arrancar la máquina en el virt-manager y modificar el fichero /etc/hostname.vio0 para que quede de la siguiente manera:

```text
up
inet6 eui64
```

Crear usuario mediante el comando:

`adduser -g wheel a796902`

Modificar doas.conf para que los usuarios del grupo wheel puedan usar doas sin contraseña:

`permit nopass :wheel`

Copiar la clave pública a esta máquina para poder hacer ssh sin contraseña mediante el comando:

```text
scp -6 /home/a796902/.ssh/id_rsa.pub a796902@[fe80::5054:ff:fe0d:1101%br1]:/home/a796902/.ssh/authorized_keys
```

Para la máquina, forzar su parada, ejecutar undefine, y quitar permisos de escritura a od.qcow2.

**NO VOLVER A TOCAR ESTA MÁQUINA**

## Configurar router

Crear imagen diferencial mediante el comando:

```text
qemu-img create -f qcow2 -o backing_file=od.qcow2 orouterd.qcow2
```

Copiar od.xml y nombrerlo orouterd.xml

Comprobar que orouterd.qcow2 tenga permisos de grupo "rw".

Cambiar el path de source, la dirección MAC, el nombre de la máquina, y la uuid para que queden de la siguiente manera:

```xml
<name>orouterd</name>
<uuid>ecd3e45c-6426-432c-a700-fcdabb70dff1</uuid>
<source file='/misc/alumnos/as2/as22022/a796902/orouterd.qcow2'/>
<mac address='52:54:00:0d:ff:01'/>
```

Definir la máquina:

```text
virsh -c qemu+ssh://a796902@155.210.154.XXX/system define orouterd.xml
```

Eliminar la definición de la máquina:

```text
virsh -c qemu+ssh://a796902@155.210.154.XXX/system undefine --domain orouterd
```

Modificar el fichero /etc/hostname.vio0 para que solo funcione con la @2001:470:736b:f000::1d1:

```text
up
inet6 alias 2001:470:736b:f000::1d1 64 -temporary
```

Modificar el fichero /etc/mygate para que el encaminador por defecto sea "central":

`2001:470:736b:f000::1`

Crear fichero /etc/hostname.vlan1399 y que quede tal que así:

```text
vlan 1399 vlandev vio0 up 
inet6 alias 2001:470:736b:dff::1 64
```

Añadir la siguiente línea al fichero sysctl.conf para activar encaminamiento ip6 y no contestación a anuncios de prefijo ip6:

`net.inet6.ip6.forwarding=1`

Activar el servicio rad para poner en funcionamiento el servicio de anuncio de prefijos IPv6 a la subred de la vlan:

`rcctl enable rad`

Modificar /etc/rad.conf para indicar la tarjeta en la que se anuncia:

`interface vlan1399`

Modificar /etc/myname para llamar a la máquina "orouterd":

`orouterd`

## Configurar máquina interna

Crear imagen diferencial mediante el comando:

```text
qemu-img create -f qcow2 -o backing_file=od.qcow2 odff2.qcow2
```

Copiar od.xml y nombrerlo odff2.xml

Comprobar que odff2.qcow2 tenga permisos de grupo "rw".

Cambiar el path de source, la dirección MAC, el nombre de la máquina, y la uuid para que queden de la siguiente manera:

```xml
<name>odff2</name>
<uuid>ecd3e45c-6426-432c-a700-fcdabb70dff2</uuid>
<source file='/misc/alumnos/as2/as22022/a796902/odff2.qcow2'/>
<mac address='52:54:00:0d:ff:02'/>
```

Modificar /etc/hostname.vio0 para que quede de la siguiente forma:

```text
-inet6
up
```

Crear fichero /etc/hostnam.vlan1399 y que quede tal que así:

```text
vlan 1399 vlandev vio0 up 
inet6 autoconf -soii -temporary
```

Modificar /etc/mygate para que el encaminador por defecto sea orouted:

`2001:470:736b:dff::1`

Modificar /etc/myname para llamar a la máquina "odff2":

`odff2`

Poner en marcha el servicio slaacd mediante el comando:

`rcctl enable slaacd`

Este servicio captura los anunciamientos del router mandados por el servicio rad, y autoconfigura los interfaces que tengan las opción autoconf.

Reiniciar la red mediante **sh /etc/netstart** y comprobar mediante **iconfig** que la ip asignada a esta máquina sea:

`2001:470:736b:dff:5054:ff:fe0d:ff02`

## Comprobaciones

Para comprobar que las máquinas tienen conexión entre ellas, probar los siguientes comandos:

Desde orouterd a odff2:

`ping6 2001:470:736b:dff:5054:ff:fe0d:ff02`

`traceroute6 2001:470:736b:dff:5054:ff:fe0d:ff02`

Desde odff2 a orouterd:

`ping6 2001:470:736b:dff::1`

`traceroute6 2001:470:736b:dff::1`

Desde central a orouterd:

`ping6 2001:470:736b:f000::1d1`

`traceroute6 2001:470:736b:f000::1d1`

Desde orouterd a orouterd:

`ping6 2001:470:736b:f000::1`

`traceroute6 2001:470:736b:f000::1`

Desde central a odff2:

`ping6 2001:470:736b:dff:5054:ff:fe0d:ff02`

`traceroute6 2001:470:736b:dff:5054:ff:fe0d:ff02`

Desde orouterd a odff2:

`ping6 2001:470:736b:f000::1`

`traceroute6 2001:470:736b:f000::1`
